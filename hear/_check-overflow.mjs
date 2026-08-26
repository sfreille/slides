// Headless-Chrome overflow checker for Quarto RevealJS decks.
// Drives Chrome via CDP (no deps; Node 22 global WebSocket).
// Usage: node _check-overflow.mjs <path-to-html>
import { spawn } from "node:child_process";
import { setTimeout as sleep } from "node:timers/promises";
import path from "node:path";

const CHROME = "C:\\Program Files\\Google\\Chrome\\Application\\chrome.exe";
const PORT = 9222;
const htmlArg = process.argv[2];
if (!htmlArg) { console.error("need html path"); process.exit(2); }
const fileUrl = "file:///" + path.resolve(htmlArg).replace(/\\/g, "/");

const userDir = path.join(process.env.TEMP || ".", "cdp-overflow-" + Date.now());
const chrome = spawn(CHROME, [
  "--headless=new", "--disable-gpu", "--no-first-run", "--no-default-browser-check",
  `--remote-debugging-port=${PORT}`, `--user-data-dir=${userDir}`,
  "--window-size=1500,900", fileUrl,
], { stdio: "ignore" });

async function getPageTarget() {
  for (let i = 0; i < 60; i++) {
    try {
      const r = await fetch(`http://127.0.0.1:${PORT}/json`);
      const targets = await r.json();
      const pg = targets.find(t => t.type === "page" && t.webSocketDebuggerUrl);
      if (pg) return pg;
    } catch {}
    await sleep(250);
  }
  throw new Error("no page target");
}

let msgId = 0;
function cdp(ws, method, params = {}) {
  const id = ++msgId;
  return new Promise((resolve, reject) => {
    const onMsg = (ev) => {
      const m = JSON.parse(ev.data);
      if (m.id === id) { ws.removeEventListener("message", onMsg); m.error ? reject(new Error(m.error.message)) : resolve(m.result); }
    };
    ws.addEventListener("message", onMsg);
    ws.send(JSON.stringify({ id, method, params }));
  });
}

const measureExpr = `
new Promise((resolve) => {
  function ready(){ return window.Reveal && Reveal.isReady && Reveal.isReady(); }
  function go(){
    if(!ready()){ return setTimeout(go, 200); }
    const R = window.Reveal;
    const container = document.querySelector('.reveal .slides');
    const H = container.offsetHeight; // logical slide height (900)
    const slides = R.getSlides();     // flat, in presentation order (leaf sections)
    const out = [];
    let i = 0;
    function step(){
      const el = slides[i];
      const idx = R.getIndices(el);
      R.slide(idx.h, idx.v || 0);
      setTimeout(() => {
        const h = el.scrollHeight;      // measure THIS element, not .present
        const head = el.querySelector('h1,h2');
        const title = head ? head.innerText.trim().replace(/\\s+/g,' ')
                           : el.textContent.trim().replace(/\\s+/g,' ').slice(0,40);
        out.push({ i, h, H, over: h - H, title });
        i++;
        if (i < slides.length) step(); else resolve(JSON.stringify(out));
      }, 130);
    }
    step();
  }
  go();
});
`;

(async () => {
  try {
    const pg = await getPageTarget();
    const ws = new WebSocket(pg.webSocketDebuggerUrl);
    await new Promise((res, rej) => { ws.addEventListener("open", res, { once: true }); ws.addEventListener("error", rej, { once: true }); });
    await cdp(ws, "Runtime.enable");
    // give reveal a moment to lay out
    await sleep(800);
    const { result, exceptionDetails } = await cdp(ws, "Runtime.evaluate", {
      expression: measureExpr, awaitPromise: true, returnByValue: true,
    });
    if (exceptionDetails) throw new Error(JSON.stringify(exceptionDetails));
    const rows = JSON.parse(result.value);
    const TOL = 12; // px slack
    console.log(`\nSlide  Content  Canvas  Over   Status  Title`);
    console.log("-".repeat(78));
    for (const r of rows) {
      const bad = r.over > TOL;
      const flag = bad ? "OVERFLOW" : "ok";
      console.log(
        `${String(r.i).padStart(3)}  ${String(r.h).padStart(7)}  ${String(r.H).padStart(6)}  ${String(r.over).padStart(5)}   ${flag.padEnd(8)} ${r.title}`
      );
    }
    const bad = rows.filter(r => r.over > TOL);
    console.log("-".repeat(78));
    console.log(bad.length ? `\n${bad.length} slide(s) OVERFLOW: ${bad.map(b => b.i).join(", ")}` : `\nAll ${rows.length} slides fit.`);
    ws.close();
  } catch (e) {
    console.error("ERROR:", e.message);
    process.exitCode = 1;
  } finally {
    chrome.kill();
  }
})();

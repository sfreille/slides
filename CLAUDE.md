# CLAUDE.md — Course Slides

Conventions for building Sebastián Freille's course slides. Applies to **all courses**.
(Session-specific progress lives in `_session-notes.md`.)

## What this is
Lecture slides in **Quarto (`.qmd`, RevealJS)**. Each lecture ships as **`.qmd` + `.html`
+ `.pdf`**. Repo mirrors GitHub `sfreille/slides`; HTML is served via GitHub Pages and
linked from `sfreille.github.io/teaching`.

## Courses

| Code | Course | Nivel |
|------|--------|-------|
| hpae | Historia del Pensamiento y del Análisis Económico | Grado |
| cyfi | Comercio y Finanzas Internacionales | Grado |
| hear | Historia Económica Argentina | Grado |
| epol | Economía Política | Grado |
| epol-uns | Economía Política (UNS) | Grado |
| fpub | Finanzas Públicas | Grado |
| epin | Economía Política Internacional | Grado |
| teaa | Tópicos de Economía Aplicada | Grado |
| gpre | Gestión Presupuestaria | Posgrado (Maestría) |
| lpfp | La Política de las Finanzas Públicas | Posgrado (Maestría) |
| tepm | Tópicos en Economía Política Moderna | Posgrado (Doctorado) |

`hpae` and `cyfi` are the most-developed reference courses.

## Philosophy
- **Spanish** always (English/foreign terms welcome where they read better).
- Slides are **comprehensive and motivational**, never cryptic bullet-dumps: each block
  answers an analytical question.
- **~99% from the course's own material.** Ask before adding beyond-syllabus sources.
- **Topical order**, not chronological — the lecture number reflects study order.
- **Density:** a class runs roughly **22–35 slides** — pack enough to develop ideas; use
  the source readings' **block quotes** to anchor key theoretical/conceptual points.
- **First 1–2 classes** of a course: extra engaging (hooks, striking figures, memes).
- Audience is mostly undergrads from the social-media generation — figures, charts, and
  (tasteful) memes are encouraged.

## Slide layout (minimalist)
- **One figure / table / meme per slide, on its own**, placed before or after the related
  text. Do **not** pair text and figure side-by-side in asymmetric two-column splits.
- Combine text + figure on one slide **only when mutually dependent** (e.g. reading a
  multi-trend time series while explaining it) — then a short **lead line above** a
  centered figure.
- **Tables** almost always stand alone. **Memes** stand alone as a beat.
- **Slide titles short — one line.** Watch for overflow.
- **Numbering:** `[B.n]` = bloque · slide-within-bloque (e.g. `[2.3]`). Apertura and
  Cierre are unnumbered; the "Mapa de la clase" lists the bloques.
- **Structure:** Apertura/hoja de ruta → thematic bloques → Cierre (ideas fuerza,
  preguntas, bibliografía). Skeleton: `hpae/_lect-template.qmd`.

## Callouts (semantic colors, `icon=false`)

| Callout | Color | Use for |
|---------|-------|---------|
| `callout-note` | blue | definiciones |
| `callout-tip` | green | ideas clave |
| `callout-important` | magenta | curiosidades / ejemplos |

Columns are fine for **parallel text** (e.g. wrap each in a titled callout).

## Text
- `**bold**` for emphasis; `*italics*` **only** for foreign terms.
- **Blockquotes** for source passages / theoretical statements — **no italics** in them.

## Figures & diagrams
- **Diagrams hand-built as SVG (or TikZ)** — never Mermaid in final slides. Store as
  `fig-diagram-*`.
- Images live in `_shared/images/<code>/`, named `fig-<type>-<topic>` (types: `chart`,
  `map`, `table`, `photo`, `diagram`, `quote`, `meme`; also `bg-<code>-NN`, `logo-…`).
- **Reuse all figures** from legacy materials — when splitting a lecture, distribute its
  figures; don't drop any.
- **Web images/memes must be public-domain or properly licensed** (repo is published);
  add a credit via `::: {.fuente}`.
- **Captions/sources are small** (`figcaption` ~0.45em, `.fuente` ~0.42em) so the larger
  base font doesn't overwhelm figures.
- **Meme** component: `.meme` with `[…]{.meme-top}` / `[…]{.meme-bottom}`. Keep tasteful;
  never meme documentary photos of hardship.

## Bibliography
Every lecture ends with a **Bibliografía de la clase** slide, split *Obligatoria* /
*Complementaria*, citing **chapters and selected pages**.

## Files & structure
```
slides/
├── _shared/{css, images/<code>, templates, scripts}
├── docs/<code>/               # rendered HTML + PDF (served by GitHub Pages)
└── <code>/
    ├── _quarto.yml            # inherits ../_shared/templates/_metadata.yml + house theme
    ├── <code>-overrides.scss  # per-course accents/sizing
    ├── lec-NN-topic-slug.qmd  # source only — HTML/PDF go to docs/
    └── _archive/<year>/       # past versions
```
- **Filenames:** `lec-NN-topic-slug` — lowercase kebab, **two-digit** number. Never
  `lect` / `clase`. Split parts: `lec-01a-…`.
- **No year in working filenames** — current version in the course root; dated snapshots
  in `_archive/<year>/`.
- No editor lock/backup files (`#…#`, `.#…`, `*~`) in the repo.
- **LaTeX migration:** old `.tex` file numbering does not map 1:1 to new `lec-NN`. Always
  verify content against the source file before assuming correspondence.

## Overflow checking
Slides render to a 900px-high canvas. Verify all slides fit after enriching a deck:
```
node _shared/scripts/_check-overflow.mjs docs/<code>/lec-NN-…html
```
Fix overflows with `.tight` (0.9em text + tighter list/callout rhythm, defined in the
course `overrides.scss`) or Quarto's built-in `.smaller`. Programmatic fit does not
substitute for a human visual pass — check SVG sizing, meme captions, and full-canvas
figure slides manually.

## Theme & build
- Every course `_quarto.yml` inherits `_shared/templates/_metadata.yml` and points at the
  **house theme `theme-default.scss`** + an optional `<code>-overrides.scss`. Bulk restyle
  = edit the shared theme once. *(TODO: `hpae` still self-contains its config — migrate it.)*
- Base text enlarged (~1.3×) and reveal `margin` reduced for less whitespace.

## Render & publish workflow

**HTML — always from `slides/` root:**
```
quarto render                                             # all courses
quarto render <code>/file.qmd                            # single file
Get-ChildItem <code>\*.qmd | ForEach-Object { quarto render "<code>\$($_.Name)" }  # single course
```
Output lands in `docs/<code>/` via `output-dir: docs` in `_quarto.yml`. Running from
inside a course folder bypasses this and renders in-place — do not do it.

**PDF — from `slides/` root, after HTML render:**
```
powershell -File make-pdfs.ps1 <code>
```
Decktape converts each `docs/<code>/*.html` → same path `.pdf`. For decks with a 2D
Reveal.js layout (stacked vertical slides), decktape loops infinitely unless capped with
`--slides 1-N`. The script already hardcodes `--slides 1-89` for `epol/lect07-24.html`;
add similar overrides for any other 2D deck that hangs.

**Publish:**
Commit `.qmd` source + `docs/<code>/` HTML + PDFs, push `main`; `.nojekyll` bypasses
Jekyll. Large-push fix: `git config http.postBuffer 524288000`. Commit/push only when asked.

## DO / DON'T
- **DO** keep it minimalist, comprehensive, and sourced from course material.
- **DO** put figures/tables/memes on their own slides; keep titles to one line.
- **DON'T** use emojis/icons, Mermaid diagrams, italic blockquotes, year-suffixed
  filenames, or beyond-syllabus sources without asking.

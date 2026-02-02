#' Batch Render Quarto Slides to HTML and PDF
#'
#' Renders all QMD files in a course folder to HTML using Quarto,
#' then converts to PDF using Decktape for better fidelity.
#'
#' @examples
#' # Render all hpae slides to HTML and PDF
#' render_slides("hpae")
#'
#' # Render only HTML for 2025 folder
#' render_slides("hpae", year = "2025", format = "html")
#'
#' # Render specific files
#' render_slides("cyfi", files = c("lect01.qmd", "lect02.qmd"))
#'
#' # Render single file
#' render_slide("P:/r-Projects/slides/hpae/lect01.qmd")

# Configuration
BASE_DIR <- "P:/r-Projects/slides"
DECKTAPE_PATH <- "decktape"
DECKTAPE_DELAY <- 1000  # milliseconds

#' Render a single QMD file to HTML and/or PDF
#'
#' @param qmd_path Full path to the QMD file
#' @param format Output format: "html", "pdf", or "both"
#' @param verbose Print progress messages
#' @return Logical indicating success
render_slide <- function(qmd_path, format = "both", verbose = TRUE) {
  if (!file.exists(qmd_path)) {
    if (verbose) message("File not found: ", qmd_path)
    return(FALSE)
  }

  file_name <- tools::file_path_sans_ext(basename(qmd_path))
  dir_path <- dirname(qmd_path)
  html_path <- file.path(dir_path, paste0(file_name, ".html"))
  pdf_path <- file.path(dir_path, paste0(file_name, ".pdf"))

  success <- TRUE

  # Render to HTML
  if (format %in% c("html", "both")) {
    if (verbose) message("[", file_name, "] Rendering to HTML...")
    start_time <- Sys.time()

    result <- tryCatch({
      quarto::quarto_render(qmd_path, output_format = "revealjs")
      TRUE
    }, error = function(e) {
      message("  Error: ", e$message)
      FALSE
    })

    if (result && file.exists(html_path)) {
      elapsed <- round(as.numeric(difftime(Sys.time(), start_time, units = "secs")), 1)
      if (verbose) message("[", file_name, "] HTML complete (", elapsed, "s)")
    } else {
      if (verbose) message("[", file_name, "] HTML FAILED")
      success <- FALSE
    }
  }

 # Convert to PDF via Decktape
  if (format %in% c("pdf", "both")) {
    if (!file.exists(html_path)) {
      if (verbose) message("[", file_name, "] HTML file not found, skipping PDF")
      return(FALSE)
    }

    if (verbose) message("[", file_name, "] Converting to PDF via Decktape...")
    start_time <- Sys.time()

    # Build Decktape command
    cmd <- sprintf(
      '%s reveal --size 1500x900 --pause %d "%s" "%s"',
      DECKTAPE_PATH, DECKTAPE_DELAY, html_path, pdf_path
    )

    result <- tryCatch({
      system(cmd, intern = FALSE, ignore.stdout = !verbose, ignore.stderr = !verbose)
    }, error = function(e) {
      message("  Error: ", e$message)
      1
    })

    if (result == 0 && file.exists(pdf_path)) {
      elapsed <- round(as.numeric(difftime(Sys.time(), start_time, units = "secs")), 1)
      pdf_size <- round(file.info(pdf_path)$size / 1024 / 1024, 2)
      if (verbose) message("[", file_name, "] PDF complete (", elapsed, "s, ", pdf_size, "MB)")
    } else {
      if (verbose) message("[", file_name, "] PDF FAILED")
      success <- FALSE
    }
  }

  return(success)
}

#' Batch render all QMD files in a course folder
#'
#' @param course Course folder name (e.g., "hpae", "cyfi")
#' @param year Optional year subfolder (e.g., "2025")
#' @param format Output format: "html", "pdf", or "both"
#' @param files Optional specific file names to render
#' @param verbose Print progress messages
#' @return Data frame with rendering results
render_slides <- function(course, year = NULL, format = "both",
                          files = NULL, verbose = TRUE) {

  # Determine working directory
  if (!is.null(year) && nchar(year) > 0) {
    work_dir <- file.path(BASE_DIR, course, year)
  } else {
    work_dir <- file.path(BASE_DIR, course)
  }

  if (!dir.exists(work_dir)) {
    stop("Directory not found: ", work_dir)
  }

  # Get QMD files to render
  if (!is.null(files) && length(files) > 0) {
    qmd_files <- file.path(work_dir, files)
    qmd_files <- qmd_files[file.exists(qmd_files)]
  } else {
    qmd_files <- list.files(work_dir, pattern = "\\.qmd$", full.names = TRUE)
  }

  if (length(qmd_files) == 0) {
    message("No QMD files found in ", work_dir)
    return(invisible(NULL))
  }

  # Print header
  if (verbose) {
    message("=========================================")
    message("Batch Slide Renderer")
    message("=========================================")
    message("Course: ", course)
    message("Directory: ", work_dir)
    message("Files: ", length(qmd_files))
    message("Format: ", format)
    message("=========================================")
  }

  # Process files
  total_start <- Sys.time()
  results <- data.frame(
    file = character(),
    success = logical(),
    stringsAsFactors = FALSE
  )

  for (qmd in qmd_files) {
    success <- render_slide(qmd, format = format, verbose = verbose)
    results <- rbind(results, data.frame(
      file = basename(qmd),
      success = success,
      stringsAsFactors = FALSE
    ))
  }

  # Summary
  total_elapsed <- round(as.numeric(difftime(Sys.time(), total_start, units = "secs")), 1)
  success_count <- sum(results$success)
  fail_count <- sum(!results$success)

  if (verbose) {
    message("\n=========================================")
    message("Rendering Complete")
    message("=========================================")
    message("Success: ", success_count)
    message("Failed: ", fail_count)
    message("Total time: ", total_elapsed, "s")
    message("=========================================")
  }

  invisible(results)
}

# Convenience aliases
render_hpae <- function(...) render_slides("hpae", ...)
render_cyfi <- function(...) render_slides("cyfi", ...)

# If running as script (not sourced)
if (!interactive() && length(commandArgs(trailingOnly = TRUE)) > 0) {
  args <- commandArgs(trailingOnly = TRUE)
  if (length(args) >= 1) {
    course <- args[1]
    year <- if (length(args) >= 2) args[2] else NULL
    format <- if (length(args) >= 3) args[3] else "both"
    render_slides(course, year = year, format = format)
  }
}

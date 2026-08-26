# CLAUDE.md - Project Configuration for `slides/hear`

## Scope
- This folder contains slide decks and related materials for the HEAR project/course.
- These rules apply to everything under `slides/hear/` unless overridden by deeper configuration.

## Project Type
- `slides` — presentation-focused repository.

## Structure
```
slides/hear/
  *.qmd           # Quarto slide sources
  *.html          # Rendered slide decks
  images/         # Figures, diagrams, photos
  data/           # Any data files used in slides
  custom.scss     # Optional Quarto/Revealjs theme overrides
```

## Conventions
- Use `here::here()` for all R paths.
- Prefer tidyverse grammar for data manipulation.
- Keep slides modular; one main topic per `.qmd` file.
- Render outputs to `*.html` using Quarto.

## Source

- Main book reference throughout the course is Gerchunoff and Llach (2007)
- Other main books are Gomez' Avatares de un sistema monetario (2018), teaching
  notes "La Caja y el Banco" in its different years and Della Paolera and Taylor
  (2001). These are specially relevant for monetary and financial aspects. 
- Other books and articles, more complementary but still used them if needed,
  are withink /biblio folder. 

## Output
- Rendered slides should be self-contained HTML when possible.
- Figures saved to `images/` or generated inline.

## Notes
- Add project-specific notes here as the project grows.

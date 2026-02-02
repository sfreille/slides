# Migration Guide: Slides Reorganization

This guide explains how to update your existing QMD slide files to use the new centralized structure.

## New Structure Overview

```
P:/r-Projects/slides/
├── _shared/
│   ├── css/
│   │   ├── _variables.scss       # Shared variables
│   │   ├── _base.scss            # Base styles
│   │   ├── theme-default.scss    # Clean professional theme
│   │   ├── theme-highlight.scss  # Yellow accent theme
│   │   ├── theme-academic.scss   # Elegant serif theme
│   │   └── theme-dark.scss       # Dark mode theme
│   ├── images/
│   │   ├── backgrounds/          # Shared background images
│   │   ├── logos/                # Institutional logos
│   │   ├── common/               # Shared figures across courses
│   │   ├── cyfi/                 # CyFI course-specific images
│   │   ├── epol/                 # EPOL course-specific images
│   │   └── ...                   # Other courses
│   └── templates/
│       ├── _metadata.yml         # Shared Quarto metadata
│       └── _quarto-course-template.yml
├── cyfi/
│   ├── _quarto.yml               # Course config (inherits from _shared)
│   ├── 2024/
│   └── 2025/
└── ...
```

## Step-by-Step Migration

### Step 1: Update YAML Front Matter

**Before (old format):**
```yaml
---
title: Course Title
format:
  revealjs:
    css: ..\quarto.css
    slide-number: true
    chalkboard:
      buttons: false
    # ... many repeated settings
---
```

**After (new format):**
```yaml
---
title: Course Title
subtitle: Unit X. Topic Name
title-slide-attributes:
  data-background-image: ../_shared/images/backgrounds/bg-cyfi-01.png
  data-background-size: stretch
  data-background-opacity: "0.85"
---
```

Most settings are now inherited from the course `_quarto.yml` file!

### Step 2: Update Image Paths

**Background images:**
```yaml
# Before
data-background-image: ../fig/fig-00-background.png

# After
data-background-image: ../_shared/images/backgrounds/bg-cyfi-01.png
```

**Inline images in slides:**
```markdown
# Before (from course/2025/ subfolder)
![](../fig/some-image.png)

# After - for course-specific images
![](../../_shared/images/cyfi/some-image.png)

# After - for common images used across courses
![](../../_shared/images/common/fig_supply_demand.png)
```

### Step 3: Path Reference Guide

From different locations, use these paths:

| Your QMD location | Path to _shared |
|-------------------|-----------------|
| `cyfi/lect01.qmd` | `../_shared/...` |
| `cyfi/2025/lect01.qmd` | `../../_shared/...` |
| `epol/lect01-24.qmd` | `../_shared/...` |

### Step 4: Switching Themes

To change themes, edit your course's `_quarto.yml`:

```yaml
format:
  revealjs:
    # Uncomment the theme you want:
    css: ../_shared/css/theme-default.scss    # Professional blue/gray
    # css: ../_shared/css/theme-highlight.scss  # Yellow accent
    # css: ../_shared/css/theme-academic.scss   # Elegant serif
    # css: ../_shared/css/theme-dark.scss       # Dark mode
```

All slides in that course will automatically use the new theme!

## Available Themes

| Theme | Best For | Colors |
|-------|----------|--------|
| `theme-default.scss` | General use | Blue/gray, white background |
| `theme-highlight.scss` | Dark background images | Yellow titles, black text |
| `theme-academic.scss` | Conferences, formal | Warm browns, cream background |
| `theme-dark.scss` | Evening presentations | Dark blue, light text |

## Image Naming Convention

Use descriptive names with type prefixes:

| Type | Prefix | Example |
|------|--------|---------|
| Background | `bg-` | `bg-gradient-blue.png` |
| Logo | `logo-` | `logo-unc.png` |
| Diagram | `diagram-` | `diagram-supply-demand.png` |
| Chart | `chart-` | `chart-gdp-trend-2020.png` |
| Photo | `photo-` | `photo-keynes-portrait.png` |
| Graph | `graph-` | `graph-utility-function.png` |
| Map | `map-` | `map-trade-routes.png` |
| Table | `table-` | `table-tariff-rates.png` |

## Common Image Locations

Images used across multiple courses are in `_shared/images/common/`:

- `fig_supply_demand.png` - Supply/demand diagram
- `fig_roewade.jpeg` - Electoral representation
- `fig_tvm1.jpg` through `fig_tvm4.jpg` - Voting mechanisms
- `fig_gp_pbi.png` - Government spending
- ... and more

## Quick Reference: Find & Replace

Use these patterns to bulk-update your QMD files:

```
Find: css: ..\quarto.css
Replace: (delete this line - now in _quarto.yml)

Find: ../fig/fig-00-background.png
Replace: ../_shared/images/backgrounds/bg-COURSE-01.png

Find: ../fig/
Replace: ../_shared/images/COURSE/
```

## Troubleshooting

### Images not loading?
- Check path depth (count the `../`)
- Use forward slashes `/` not backslashes `\`
- Verify the image exists in the new location

### Theme not applying?
- Make sure `_quarto.yml` exists in your course folder
- Check that the css path is correct
- Try running `quarto render` with `--verbose`

### Old and new structure coexisting?
During migration, both structures can coexist. The old `fig/` folders remain until you've updated all references and are ready to delete them.

## After Migration Checklist

- [ ] All QMD files updated with new image paths
- [ ] Tested rendering for each course
- [ ] Old `fig/` folders can be removed
- [ ] Old `quarto.css` files in course folders can be removed
- [ ] Git commit with migration changes

# Gemini CLI - Personal Website Project Summary

Created a professional personal website based on the [al-folio](https://github.com/alshedivat/al-folio) template for a Stanford graduate and Jump Trading Quantitative Researcher.

## Project Configuration
- **Name:** Beicheng Lastname
- **Affiliations:** Stanford University, Jump Trading
- **Navigation:** Minimalist design with tabs limited to "About" and "Publications". (CV tab is hidden as it is integrated into the home page).

## Key Customizations

### 1. Home Page Sections
- **Background:** A new section extracted from CV data (`_data/cv.yml`) showing **Education** and **Experience**.
- **Past Projects:** A manually editable section (`_includes/past_projects.liquid`) replacing the default "Selected Publications" to allow for project descriptions with links to papers.
- **Social Icons:** Streamlined to show only Email, LinkedIn, GitHub, and Google Scholar. (Twitter and CV PDF buttons removed).

### 2. File Architecture
- `_config.yml`: Core site settings, disabled `imagemagick` to resolve build errors.
- `_pages/about.md`: Main entry point. Controlled via flags: `background: true`, `past_projects: true`, `selected_papers: false`.
- `_layouts/about.liquid`: Modified to support the custom "Background" and "Past Projects" sections.
- `_includes/background.liquid`: Logic to pull Education/Experience from `_data/cv.yml`.
- `_includes/past_projects.liquid`: HTML template for manual project highlights.
- `_bibliography/papers.bib`: BibTeX file for the full publications list.

## Maintenance Guide

### Modifying Content
- **Bio/Subtitle:** Edit `_pages/about.md`.
- **Profile Picture:** Replace `assets/img/prof_pic.jpg`.
- **Education/Experience:** Edit `_data/cv.yml`.
- **Project Details:** Edit `_includes/past_projects.liquid`.
- **Publications:** Add BibTeX entries to `_bibliography/papers.bib`.
- **Social Links:** Update usernames in `_data/socials.yml`.

### Development
- **Preview Site:** `bundle exec jekyll serve`
- **Build Troubleshooting:** `imagemagick` is currently disabled in `_config.yml` to avoid dependency issues on systems without `convert`.
- **Clean State:** All default example posts were removed from `_posts/` to prevent build errors and clutter.

# CVGenerator

Swift CLI that generates PDF CVs from JSON data using HTML templates.

## Requirements

- Swift 5.9+ (Xcode 15+ or swift.org toolchain)
- [WeasyPrint](https://weasyprint.org) for PDF generation: `pip install weasyprint`

## Build

```bash
swift build -c release
```

## Usage

```bash
.build/release/CVGenerator \
  --templates ./Templates/NavyHeader \
  --input resume-iOS-staff.json \
  --output cv-staff.html \
  --pdf
```

| Flag | Description | Default |
|---|---|---|
| `--input` | Path to the JSON resume file | `resume-iOS.json` |
| `--output` | Output HTML path (PDF path is derived from this) | derived from `--input` |
| `--templates` | Directory containing `index.template`, `style.css`, and fragment files | `.` |
| `--pdf` | Also generate PDF via WeasyPrint | off |

### Generate all variants at once

```bash
bash cv.sh
```

This runs every template × data file combination and produces named PDFs in the project root.

## Project structure

```
CVGenerator/
├── Package.swift
├── cv.sh                        ← generates all template × data combinations
├── resume-iOS-staff.json        ← data for Staff Engineer variant
├── resume-iOS-senior.json       ← data for Senior Engineer variant
├── Templates/
│   ├── NavyHeader/              ← navy blue full-width header, teal accents
│   ├── ForestSidebar/           ← dark-green sidebar, white main column
│   ├── SlateAmber/              ← dark-slate header, amber accents, job border bars
│   └── Asphalt/                 ← light-grey header box, gradient company bars (classic style)
└── Sources/CVGenerator/
    ├── main.swift               ← CLI entry point and argument parsing
    ├── Models.swift               ← Codable structs mirroring the JSON schema
    ├── HTMLRenderer.swift       ← Resume → template context → HTML
    └── DateFormatter+CV.swift   ← date formatting helpers
```

## Template system

Each template directory is self-contained and contains:

| File | Purpose |
|---|---|
| `index.template` | Root document; references all other fragments |
| `style.css` | All styles, injected inline via `{{css}}` |
| `job.template` | One company block (loops over `position.template`) |
| `position.template` | One role within a company |
| `skill-row.template` | One skill category row |
| `bullet.template` | One highlight bullet |
| `earlier-section.template` | "Earlier Experience" wrapper |
| `earlier-item.template` | One condensed earlier-career entry |
| `oss-item.template` | One open-source project entry |
| `education-item.template` | One education entry |
| `footer.template` | (optional) two-column OSS + education + languages footer |

### Template syntax

| Directive | Effect |
|---|---|
| `{{variable}}` | Inline substitution |
| `{{#each collection fragment}}` | Loop — renders `fragment.template` for each item |
| `{{#if variable fragment}}` | Conditional — renders `fragment.template` if value is non-empty |
| `{{#include fragment}}` | Unconditional include of `fragment.template` |

### Available context variables

**Top-level** (`index.template`): `name`, `label`, `email`, `phone`, `linkedin`, `github`,
`location`, `visa`, `summary`, `skills`, `jobs`, `earlier_jobs`, `projects`, `education`, `languages`

**Job** (`job.template`): `company`, `location`, `website`, `company_summary`, `positions`

**Position** (`position.template`): `title`, `dates` (year range), `dates_long` (month/year range),
`company_summary`, `bullets`

**Earlier job** (`earlier-item.template`): `company`, `location`, `website`, `role`,
`years`, `years_long`, `note`

**Education** (`education-item.template`): `institution`, `area`, `location`, `website`,
`years`, `years_long`

**Skill row** (`skill-row.template`): `name`, `keywords`

**Bullet / OSS / Education**: `text` / `name`, `description`, `url`, `url_label` / `institution`, `area`, `years`

## Adding a new template

1. Copy an existing template directory: `cp -r Templates/NavyHeader Templates/MyTemplate`
2. Edit `style.css` and the fragment files
3. Add it to `cv.sh`

## JSON schema overview

```
resume-iOS-*.json
├── basics: { name, label, email, phone, visa, summary, location, profiles[] }
├── work:   [ { company, location, website, summary, positions[] } ]
│           positions: [ { position, startDate, endDate, showDetails, highlights[] } ]
├── skills: [ { name, keywords[] } ]
├── education: [ { institution, area, location, website, startDate, endDate } ]
├── languages: [ { language, fluency } ]
└── projects: [ { name, description, url } ]
```

`showDetails: true` → job appears in "Professional Experience" with full bullets  
`showDetails: false` → job appears in "Earlier Experience" as a one-liner

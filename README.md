# CVGenerator

Swift CLI that generates a PDF CV from `resume-iOS.json`.

## Requirements

- Swift 5.9+ (Xcode 15+ or swift.org toolchain)
- [WeasyPrint](https://weasyprint.org) for PDF generation: `pip install weasyprint`

## Build

```bash
swift build -c release
```

The binary will be at `.build/release/CVGenerator`.

## Usage

```bash
# Staff variant (HTML only)
.build/release/CVGenerator --input resume-iOS.json --variant staff

# Senior variant + PDF
.build/release/CVGenerator --input resume-iOS.json --variant senior --pdf

# Custom output path
.build/release/CVGenerator --input resume-iOS.json --variant staff --output out/LuizBarbosa_Staff.html --pdf
```

## Project structure

```
CVGenerator/
├── Package.swift
├── README.md
├── resume-iOS.json          ← your data source (copy here or pass via --input)
└── Sources/CVGenerator/
    ├── main.swift           ← CLI entry point & argument parsing
    ├── Models.swift         ← Codable structs mirroring the JSON schema
    ├── Variant.swift        ← Staff vs Senior label/summary/extra bullets
    ├── CSS.swift            ← All CV styles as a Swift string constant
    ├── HTMLRenderer.swift   ← Pure Resume + Variant → HTML string
    └── DateFormatter+CV.swift
```

## Iterating on the design

- **Layout/styles**: edit `CSS.swift`
- **Content/wording**: edit `Variant.swift` (summaries, extra bullets per company)
- **Data**: edit `resume-iOS.json`
- **New sections**: add to `HTMLRenderer.swift`

Re-run `swift run -- --input resume-iOS.json --variant staff --pdf` to regenerate.

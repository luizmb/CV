import Foundation

// MARK: - Argument parsing

func printUsage() {
    print("""
    Usage: CVGenerator --input <resume.json> --variant <staff|senior> [--output <file.html>] [--pdf]

    Options:
      --input    Path to resume JSON file (default: resume-iOS.json)
      --variant  staff or senior (default: staff)
      --output   Output HTML file path (default: CV_<Variant>.html)
      --pdf      Also generate PDF via weasyprint (must be on PATH)
    """)
}

var args = CommandLine.arguments.dropFirst()

func nextArg(after flag: String) -> String? {
    guard let idx = args.firstIndex(of: flag), args.index(after: idx) < args.endIndex else { return nil }
    return String(args[args.index(after: idx)])
}

let inputPath  = nextArg(after: "--input")  ?? "resume-iOS.json"
let variantRaw = nextArg(after: "--variant") ?? "staff"
let outputArg  = nextArg(after: "--output")
let generatePDF = args.contains("--pdf")

guard let variant = Variant(rawValue: variantRaw) else {
    fputs("Error: unknown variant '\(variantRaw)'. Use 'staff' or 'senior'.\n", stderr)
    printUsage()
    exit(1)
}

// MARK: - Load JSON

let inputURL = URL(fileURLWithPath: inputPath)
guard let data = try? Data(contentsOf: inputURL) else {
    fputs("Error: cannot read file at \(inputPath)\n", stderr)
    exit(1)
}

let decoder = JSONDecoder()
let resume: Resume
do {
    resume = try decoder.decode(Resume.self, from: data)
} catch {
    fputs("Error decoding JSON: \(error)\n", stderr)
    exit(1)
}

// MARK: - Render HTML

let renderer = HTMLRenderer(resume: resume, variant: variant)
let html = renderer.render()

let variantLabel = variantRaw.prefix(1).uppercased() + variantRaw.dropFirst()
let htmlPath = outputArg ?? "CV_\(variantLabel)_iOS.html"
let htmlURL  = URL(fileURLWithPath: htmlPath)

do {
    try html.write(to: htmlURL, atomically: true, encoding: .utf8)
    print("✓ HTML written to \(htmlPath)")
} catch {
    fputs("Error writing HTML: \(error)\n", stderr)
    exit(1)
}

// MARK: - Optional PDF generation

if generatePDF {
    let pdfPath = htmlPath.replacingOccurrences(of: ".html", with: ".pdf")
    let task = Process()
    task.executableURL = URL(fileURLWithPath: "/usr/bin/env")
    task.arguments = ["weasyprint", htmlPath, pdfPath]
    task.standardOutput = FileHandle.standardOutput
    task.standardError  = FileHandle.standardError

    do {
        try task.run()
        task.waitUntilExit()
        if task.terminationStatus == 0 {
            print("✓ PDF written to \(pdfPath)")
        } else {
            fputs("Error: weasyprint exited with status \(task.terminationStatus)\n", stderr)
            exit(Int32(task.terminationStatus))
        }
    } catch {
        fputs("Error running weasyprint: \(error)\nMake sure weasyprint is installed: pip install weasyprint\n", stderr)
        exit(1)
    }
}

import Foundation
import HTMLTemplating

// MARK: - Argument parsing

func printUsage() {
    print("""
    Usage: CVGenerator --input <resume.json> [options]

    Options:
      --input      Path to resume JSON file (default: resume-iOS.json)
      --output     Output HTML file path (default: derived from input filename)
      --templates  Directory containing index.html, style.css and fragment files (default: .)
      --pdf        Also generate PDF via weasyprint (must be on PATH)
    """)
}

let args = CommandLine.arguments.dropFirst()

func nextArg(after flag: String) -> String? {
    guard let idx = args.firstIndex(of: flag), args.index(after: idx) < args.endIndex else { return nil }
    return String(args[args.index(after: idx)])
}

let inputPath    = nextArg(after: "--input")     ?? "resume-iOS.json"
let outputArg    = nextArg(after: "--output")
let templatesDir = nextArg(after: "--templates") ?? "Templates"
let generatePDF  = args.contains("--pdf")

// MARK: - Load JSON

guard let data = try? Data(contentsOf: URL(fileURLWithPath: inputPath)) else {
    fputs("Error: cannot read file at \(inputPath)\n", stderr)
    exit(1)
}

let resume: Resume
do {
    resume = try JSONDecoder().decode(Resume.self, from: data)
} catch {
    fputs("Error decoding JSON: \(error)\n", stderr)
    exit(1)
}

// MARK: - Render HTML

let env = CVEnvironment(
    html: HTMLEnvironment.live(path: templatesDir),
    cssURL: URL(fileURLWithPath: "\(templatesDir)/style.css")
)

let renderResult = HTMLRenderer(resume: resume).render().runReader(env)

guard case .success(let html) = renderResult else {
    if case .failure(let err) = renderResult {
        fputs("Template error: \(err)\n", stderr)
    }
    exit(1)
}

let defaultName = inputPath
    .components(separatedBy: "/").last?
    .replacingOccurrences(of: ".json", with: ".html")
    ?? "CV.html"
let htmlPath = outputArg ?? defaultName
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
    task.arguments = ["weasyprint", "--presentational-hints", htmlPath, pdfPath]
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
        fputs("Error running weasyprint: \(error)\nMake sure weasyprint is installed.\n", stderr)
        exit(1)
    }
}

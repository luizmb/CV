import Foundation

// MARK: - Context types

public typealias Context = [String: TemplateValue]

public indirect enum TemplateValue {
    case string(String)
    case list([Context])
    case bool(Bool)
}

// MARK: - Render

/// Renders `template`, resolving `{{key}}`, `{{#each key fragment}}`,
/// `{{#if key fragment}}` and `{{#include fragment}}` directives.
/// Fragment files are loaded as `<fragmentsDir>/<name>.html`.
public func render(_ template: String, _ context: Context, fragmentsDir: String) -> String {
    var result    = ""
    var remaining = template[...]

    while let openRange = remaining.range(of: "{{") {
        result   += remaining[..<openRange.lowerBound]
        remaining = remaining[openRange.upperBound...]

        guard let closeRange = remaining.range(of: "}}") else {
            result += "{{"
            continue
        }

        let token = String(remaining[..<closeRange.lowerBound])
            .trimmingCharacters(in: .whitespaces)
        remaining = remaining[closeRange.upperBound...]

        if token.hasPrefix("#each ") {
            let parts = words(token.dropFirst(6), limit: 2)
            guard parts.count == 2,
                  case .list(let items) = context[parts[0]],
                  let frag = fragment(parts[1], dir: fragmentsDir)
            else { continue }
            result += items.map { render(frag, $0, fragmentsDir: fragmentsDir) }.joined()

        } else if token.hasPrefix("#if ") {
            let parts = words(token.dropFirst(4), limit: 2)
            guard parts.count == 2,
                  truthy(context[parts[0]]),
                  let frag = fragment(parts[1], dir: fragmentsDir)
            else { continue }
            result += render(frag, context, fragmentsDir: fragmentsDir)

        } else if token.hasPrefix("#include ") {
            let name = String(token.dropFirst(9)).trimmingCharacters(in: .whitespaces)
            guard let frag = fragment(name, dir: fragmentsDir) else { continue }
            result += render(frag, context, fragmentsDir: fragmentsDir)

        } else {
            switch context[token] {
            case .string(let s): result += s
            case .bool(let b):   result += b ? "true" : "false"
            case .list, nil:     break
            }
        }
    }

    result += remaining
    return result
}

// MARK: - HTML escaping

public func esc(_ s: String) -> String {
    s.replacingOccurrences(of: "&", with: "&amp;")
     .replacingOccurrences(of: "<", with: "&lt;")
     .replacingOccurrences(of: ">", with: "&gt;")
}

public func escAttr(_ s: String) -> String {
    esc(s).replacingOccurrences(of: "\"", with: "&quot;")
}

// MARK: - Private helpers

private func fragment(_ name: String, dir: String) -> String? {
    try? String(contentsOfFile: "\(dir)/\(name).html.template", encoding: .utf8)
}

private func truthy(_ value: TemplateValue?) -> Bool {
    switch value {
    case .string(let s): return !s.isEmpty
    case .bool(let b):   return b
    case .list(let l):   return !l.isEmpty
    case nil:            return false
    }
}

private func words(_ s: Substring, limit: Int) -> [String] {
    s.split(separator: " ", maxSplits: limit - 1).map(String.init)
}

// MARK: - Bundle-based loader (kept for other consumers)

public enum TemplateError: Error {
    case notFound(String)
    case io(String)
}

public func loadTemplate(_ name: String, in bundle: Bundle) -> Result<String, TemplateError> {
    guard let url = bundle.url(forResource: name, withExtension: "html",
                               subdirectory: "Resources/templates") else {
        return .failure(.notFound(name))
    }
    return Result { try String(contentsOf: url, encoding: .utf8) }
        .mapError { .io($0.localizedDescription) }
}

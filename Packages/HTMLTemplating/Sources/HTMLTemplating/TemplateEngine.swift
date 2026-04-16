import Foundation

/// Loads an HTML template by name from a given bundle's `Resources/templates/` directory.
public func loadTemplate(_ name: String, in bundle: Bundle) -> Result<String, TemplateError> {
    guard let url = bundle.url(forResource: name, withExtension: "html",
                               subdirectory: "Resources/templates") else {
        return .failure(.notFound(name))
    }
    return Result { try String(contentsOf: url, encoding: .utf8) }
        .mapError { .io($0.localizedDescription) }
}

/// Replaces all `{{key}}` placeholders in `template` with the corresponding values.
public func render(_ template: String, _ context: [String: String]) -> String {
    context.reduce(template) { result, pair in
        result.replacingOccurrences(of: "{{\(pair.key)}}", with: pair.value)
    }
}

// MARK: - HTML escaping

public func esc(_ s: String) -> String {
    s.replacingOccurrences(of: "&",  with: "&amp;")
     .replacingOccurrences(of: "<",  with: "&lt;")
     .replacingOccurrences(of: ">",  with: "&gt;")
}

public func escAttr(_ s: String) -> String {
    esc(s).replacingOccurrences(of: "\"", with: "&quot;")
}

// MARK: - Error

public enum TemplateError: Error {
    case notFound(String)
    case io(String)
}

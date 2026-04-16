import Foundation

enum Variant: String, CaseIterable {
    case staff
    case senior

    var label: String {
        switch self {
        case .staff:
            return "Staff iOS Engineer · Functional Programming · Architecture · OSS"
        case .senior:
            return "Senior iOS Engineer · Swift · Functional Programming · TDD"
        }
    }

    var summary: String {
        switch self {
        case .staff:
            return """
            iOS engineer with 15+ years of experience and a track record of setting technical \
            direction at scale. Creator of <strong>SwiftRex</strong>, an open-source Redux framework \
            for Swift. Deep expertise in functional programming, applied category theory and reactive \
            systems — Combine, RxSwift, Swift concurrency — building highly composable, testable \
            architectures. Comfortable operating from individual-contributor depth through to \
            cross-team technical influence, mentoring and hiring.
            """
        case .senior:
            return """
            Senior iOS engineer with 15+ years across FinTech, MedTech, consumer and marketplace \
            apps. Specialises in SwiftUI, Combine and pure functional programming — with a consistent \
            record of delivering near-zero-defect, well-architected codebases. Creator of \
            <strong>SwiftRex</strong> and active open-source contributor. Brings broad context across \
            backend, CI/CD and cross-platform domains.
            """
        }
    }

    // Extra bullets injected into specific companies for the Staff variant
    var extraBullets: [String: [String]] {
        switch self {
        case .staff:
            return [
                "Plum FinTech": [
                    "Acted as technical authority on iOS architecture decisions across squads, shaping patterns used by multiple feature teams"
                ],
                "Huma Therapeutics": [
                    "Defined iOS engineering standards and shaped onboarding and code-quality processes for a distributed team"
                ],
                "Delivery Hero": [
                    "Partnered with the iOS platform guild on cross-cutting technical strategy, influencing decisions affecting 50+ mobile engineers"
                ],
                "Lautsprecher Teufel": [
                    "Drove company-wide mobile technical vision, influencing backend and web teams through shared libraries and architecture patterns"
                ],
            ]
        case .senior:
            return [:]
        }
    }
}

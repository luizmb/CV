import Foundation
import HTMLTemplating
import FP

struct CVEnvironment {
    let html: HTMLEnvironment
    let cssURL: URL
}

struct HTMLRenderer {

    let resume: Resume

    // MARK: - Entry point

    func render() -> Reader<CVEnvironment, Result<String, TemplateError>> {
        loadCSS() >>- { css in
            (HTMLTemplating.loadTemplate("index") >>- { HTMLTemplating.render($0, context(css: css)) })
                .contramapEnvironment(\.html)
        }
    }

    private func loadCSS() -> Reader<CVEnvironment, Result<String, TemplateError>> {
        .asks { env in
            env.html.readFile(env.cssURL)
                .mapError { TemplateError.readError(env.cssURL.lastPathComponent, $0) }
        }
    }

    // MARK: - Top-level context

    private func context(css: String) -> Context {
        let githubs  = resume.basics.profiles.filter { $0.network == "GitHub" }
        let linkedin = resume.basics.profiles.first  { $0.network == "LinkedIn" }
        return [
            "css":          .string(css),
            "name":         .string(esc(resume.basics.name)),
            "label":        .string(esc(resume.basics.label)),
            "email":        .string(esc(resume.basics.email)),
            "phone":        .string(esc(resume.basics.phone)),
            "linkedin":     .string(linkedin.map { "<a href=\"\(escAttr($0.url))\">\(esc($0.username))</a>" } ?? ""),
            "github":       .string(githubs.map { "<a href=\"https://github.com/\(escAttr($0.username))\">\(esc($0.username))</a>" }.joined(separator: ", ")),
            "location":     .string(esc("\(resume.basics.location.city), \(resume.basics.location.countryCode)")),
            "visa":         .string(esc(resume.basics.visa)),
            "summary":      .string(resume.basics.summary),
            "skills":       .list(resume.skills.map(skillContext)),
            "jobs":         .list(detailedCompanies.map(jobContext)),
            "earlier_jobs": .list(earlierCompanies.map(earlierJobContext)),
            "projects":     .list(resume.projects.map(projectContext)),
            "education":    .list(resume.education.map(educationContext)),
            "languages":    .string(resume.languages
                .map { esc("\($0.language) (\($0.fluency))") }
                .joined(separator: " &nbsp;·&nbsp; ")),
        ]
    }

    // MARK: - Context builders

    private func skillContext(_ group: SkillGroup) -> Context {
        [
            "name":     .string(esc(group.name)),
            "keywords": .string(esc(group.keywords.joined(separator: " · "))),
        ]
    }

    private var detailedCompanies: [Company] {
        resume.work.filter { $0.positions.contains { $0.showDetails } }
    }

    private var earlierCompanies: [Company] {
        resume.work.filter { !$0.positions.contains { $0.showDetails } }
    }

    private func jobContext(_ company: Company) -> Context {
        [
            "company":   .string(esc(company.company)),
            "location":  .string(esc(company.location.strippingFlagEmoji())),
            "positions": .list(company.positions
                .filter { $0.showDetails }
                .map { positionContext($0, companySummary: company.summary) }),
        ]
    }

    private func positionContext(_ pos: Position, companySummary: String) -> Context {
        let start = pos.startDate.formattedAsYear()
        let end   = pos.endDate?.formattedAsYear() ?? "Present"
        return [
            "title":           .string(esc(pos.position)),
            "dates":           .string("\(start) – \(end)"),
            "company_summary": .string(esc(companySummary)),
            "bullets":         .list(pos.highlights.map { ["text": .string($0)] }),
        ]
    }

    private func earlierJobContext(_ company: Company) -> Context {
        let pos   = company.positions.first
        let start = pos?.startDate.formattedAsYear() ?? ""
        let end   = pos?.endDate?.formattedAsYear() ?? "Present"
        return [
            "company": .string(esc(company.company)),
            "role":    .string(esc(pos?.position ?? "")),
            "years":   .string("\(start)–\(end)"),
            "note":    .string(esc(pos?.highlights.first.map { ": \($0)" } ?? "")),
        ]
    }

    private func projectContext(_ proj: Project) -> Context {
        [
            "name":        .string(esc(proj.name)),
            "description": .string(esc(proj.description)),
            "url":         .string(escAttr(proj.url)),
            "url_label":   .string(esc(proj.url.replacingOccurrences(of: "https://", with: ""))),
        ]
    }

    private func educationContext(_ e: Education) -> Context {
        [
            "institution": .string(esc(e.institution)),
            "area":        .string(esc(e.area)),
            "years":       .string("\(e.startDate.formattedAsYear())–\(e.endDate.formattedAsYear())"),
        ]
    }
}

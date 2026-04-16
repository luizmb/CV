import Foundation
import HTMLTemplating

struct HTMLRenderer {

    let resume: Resume
    let template: String
    let css: String

    // MARK: - Entry point

    func render() -> String {
        let github   = resume.basics.profiles.first { $0.network == "GitHub" }
        let linkedin = resume.basics.profiles.first { $0.network == "LinkedIn" }

        let linkedinHTML = linkedin.map {
            "<a href=\"\(escAttr($0.url))\">\(esc($0.username))</a>"
        } ?? ""
        let githubHTML = github.map {
            "<a href=\"https://github.com/\(escAttr($0.username))\">github.com/\(esc($0.username))</a>"
        } ?? ""

        return HTMLTemplating.render(template, [
            "css":                css,
            "name":               esc(resume.basics.name),
            "label":              esc(resume.basics.label),
            "email":              esc(resume.basics.email),
            "phone":              esc(resume.basics.phone),
            "linkedin":           linkedinHTML,
            "github":             githubHTML,
            "location":           esc("\(resume.basics.location.city), \(resume.basics.location.countryCode)"),
            "visa":               esc(resume.basics.visa),
            "summary":            resume.basics.summary,
            "skills":             skills(),
            "experience":         experience(),
            "earlier_experience": earlierExperience(),
            "footer":             footer(),
        ])
    }

    // MARK: - Skills

    private func skills() -> String {
        let rows = resume.skills.map { group in
            HTMLTemplating.render(
                "<div class=\"skill-row\"><strong>{{name}}</strong>&nbsp; <span>{{keywords}}</span></div>",
                ["name": esc(group.name), "keywords": esc(group.keywords.joined(separator: " · "))]
            )
        }.joined(separator: "\n  ")

        return "<section>\n  <h2>Technical Skills</h2>\n  \(rows)\n</section>"
    }

    // MARK: - Experience

    private var detailedCompanies: [Company] {
        resume.work.filter { $0.positions.contains { $0.showDetails } }
    }

    private var earlierCompanies: [Company] {
        resume.work.filter { !$0.positions.contains { $0.showDetails } }
    }

    private func experience() -> String {
        let jobs = detailedCompanies.map(renderJob).joined(separator: "\n")
        return "<section>\n  <h2>Professional Experience</h2>\n  \(jobs)\n</section>"
    }

    private func renderJob(_ company: Company) -> String {
        let positions = company.positions
            .filter { $0.showDetails }
            .map { pos -> String in
                let start   = pos.startDate.formattedAsMonthYear()
                let end     = pos.endDate?.formattedAsMonthYear() ?? "Present"
                let bullets = pos.highlights
                    .map { HTMLTemplating.render("<li>{{bullet}}</li>", ["bullet": $0]) }
                    .joined(separator: "\n      ")
                return HTMLTemplating.render("""
                  <div class="role-line">
                    <div class="rleft"><span class="title">{{title}}</span></div>
                    <div class="rright"><span class="dates">{{dates}}</span></div>
                  </div>
                  <div class="jsummary">{{summary}}</div>
                  <ul class="b">
                    {{bullets}}
                  </ul>
                """, [
                    "title":   esc(pos.position),
                    "dates":   "\(start) – \(end)",
                    "summary": esc(company.summary),
                    "bullets": bullets,
                ])
            }.joined(separator: "\n")

        return HTMLTemplating.render("""
        <div class="job">
          <div class="job-top">
            <div class="jleft"><span class="company">{{company}}</span></div>
            <div class="jright"><span class="location">{{location}}</span></div>
          </div>
          {{positions}}
        </div>
        """, [
            "company":   esc(company.company),
            "location":  esc(company.location.strippingFlagEmoji()),
            "positions": positions,
        ])
    }

    // MARK: - Earlier experience

    private func earlierExperience() -> String {
        let items = earlierCompanies.map { company -> String in
            let pos   = company.positions.first
            let years = dateRange(start: pos?.startDate, end: pos?.endDate)
            let note  = pos?.highlights.first.map { ": \($0)" } ?? ""
            return HTMLTemplating.render(
                "<li><strong>{{company}}</strong> — {{role}} ({{years}}){{note}}</li>",
                [
                    "company": esc(company.company),
                    "role":    esc(pos?.position ?? ""),
                    "years":   years,
                    "note":    esc(note),
                ]
            )
        }.joined(separator: "\n    ")

        return "<section>\n  <h2>Earlier Experience</h2>\n  <ul class=\"b\">\n    \(items)\n  </ul>\n</section>"
    }

    // MARK: - Footer

    private func footer() -> String {
        let ossItems = resume.projects.map { proj in
            HTMLTemplating.render("""
            <div class="oss-item">
              <strong>{{name}}</strong>
              <p>{{description}} &nbsp;<a href="{{url}}">{{urlLabel}}</a></p>
            </div>
            """, [
                "name":        esc(proj.name),
                "description": esc(proj.description),
                "url":         escAttr(proj.url),
                "urlLabel":    esc(proj.url.replacingOccurrences(of: "https://", with: "")),
            ])
        }.joined(separator: "\n")

        let edu = resume.education.map { e in
            HTMLTemplating.render("""
            <p style="font-size:8.1pt"><strong>{{institution}}</strong></p>
            <p style="font-size:7.8pt;color:#6B7280">{{area}} &nbsp;·&nbsp; {{years}}</p>
            """, [
                "institution": esc(e.institution),
                "area":        esc(e.area),
                "years":       "\(yearOnly(e.startDate))–\(yearOnly(e.endDate))",
            ])
        }.joined(separator: "\n")

        let langs = resume.languages
            .map { esc("\($0.language) (\($0.fluency))") }
            .joined(separator: " &nbsp;·&nbsp; ")

        return """
        <div class="two-col">
          <div class="col">
            <section>
              <h2>Open Source</h2>
              \(ossItems)
            </section>
          </div>
          <div class="col last">
            <section>
              <h2>Education</h2>
              \(edu)
            </section>
            <section>
              <h2>Languages</h2>
              <p style="font-size:8pt">\(langs)</p>
            </section>
          </div>
        </div>
        """
    }

    // MARK: - Helpers

    private func dateRange(start: String?, end: String?) -> String {
        let s = start.map { yearOnly($0) } ?? ""
        let e = end.map { yearOnly($0) } ?? "Present"
        return "\(s)–\(e)"
    }

    private func yearOnly(_ dateString: String) -> String {
        String(dateString.prefix(4))
    }
}

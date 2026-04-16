import Foundation

struct HTMLRenderer {

    let resume: Resume
    let variant: Variant

    // MARK: - Entry point

    func render() -> String {
        """
        <!DOCTYPE html>
        <html lang="en">
        <head>
        <meta charset="UTF-8">
        <style>\(css)</style>
        </head>
        <body>
        \(header())
        <div class="content">
        \(summary())
        \(skills())
        \(experience())
        \(earlierExperience())
        \(footer())
        </div>
        </body>
        </html>
        """
    }

    // MARK: - Header

    private func header() -> String {
        let github = resume.basics.profiles.first { $0.network == "GitHub" }
        let linkedin = resume.basics.profiles.first { $0.network == "LinkedIn" }

        return """
        <table class="header-table"><tr>
          <td>
            <span class="hname">\(resume.basics.name)</span>
            <span class="hlabel">\(variant.label)</span>
          </td>
          <td class="hright">
            <span class="hcontact">
              <strong>\(resume.basics.email)</strong><br>
              \(resume.basics.phone)<br>
              \(linkedin.map { "<a href=\"\($0.url)\">\($0.username)</a>" } ?? "")<br>
              \(github.map { "<a href=\"https://github.com/\($0.username)\">github.com/\($0.username)</a>" } ?? "")<br>
              \(resume.basics.location.city), \(resume.basics.location.countryCode) &nbsp;·&nbsp; \(resume.basics.visa)
            </span>
          </td>
        </tr></table>
        """
    }

    // MARK: - Summary

    private func summary() -> String {
        "<p class=\"summary\">\(variant.summary)</p>"
    }

    // MARK: - Skills

    private func skills() -> String {
        let rows = resume.skills.map { group in
            let tags = group.keywords.joined(separator: " · ")
            return "<div class=\"skill-row\"><strong>\(group.name)</strong>&nbsp; <span>\(tags)</span></div>"
        }.joined(separator: "\n")

        return """
        <section>
          <h2>Technical Skills</h2>
          \(rows)
        </section>
        """
    }

    // MARK: - Experience

    // Companies shown in detail (showDetails = true)
    private var detailedCompanies: [Company] {
        resume.work.filter { $0.positions.contains { $0.showDetails } }
    }

    // Companies shown only in the "Earlier" condensed list
    private var earlierCompanies: [Company] {
        resume.work.filter { !$0.positions.contains { $0.showDetails } }
    }

    private func experience() -> String {
        let jobs = detailedCompanies.map(renderJob).joined(separator: "\n")
        return """
        <section>
          <h2>Professional Experience</h2>
          \(jobs)
        </section>
        """
    }

    private func renderJob(_ company: Company) -> String {
        let locationClean = company.location.strippingFlagEmoji()
        let extras = variant.extraBullets[company.company] ?? []

        let positions = company.positions
            .filter { $0.showDetails }
            .map { pos -> String in
                let start = pos.startDate.formattedAsMonthYear()
                let end = pos.endDate?.formattedAsMonthYear() ?? "Present"
                let allBullets = pos.highlights + (pos === company.positions.last ? extras : [])
                let bullets = allBullets.map { "<li>\($0)</li>" }.joined(separator: "\n      ")
                return """
                  <div class="role-line">
                    <div class="rleft"><span class="title">\(pos.position)</span></div>
                    <div class="rright"><span class="dates">\(start) – \(end)</span></div>
                  </div>
                  <div class="jsummary">\(company.summary)</div>
                  <ul class="b">
                    \(bullets)
                  </ul>
                """
            }.joined(separator: "\n")

        return """
        <div class="job">
          <div class="job-top">
            <div class="jleft"><span class="company">\(company.company)</span></div>
            <div class="jright"><span class="location">\(locationClean)</span></div>
          </div>
          \(positions)
        </div>
        """
    }

    // MARK: - Earlier experience (condensed)

    private func earlierExperience() -> String {
        let items = earlierCompanies.map { company -> String in
            let pos = company.positions.first
            let years = dateRange(start: pos?.startDate, end: pos?.endDate)
            let highlights = pos?.highlights.first.map { ": \($0)" } ?? ""
            return "<li><strong>\(company.company)</strong> — \(pos?.position ?? "") (\(years))\(highlights)</li>"
        }.joined(separator: "\n    ")

        return """
        <section>
          <h2>Earlier Experience</h2>
          <ul class="b">
            \(items)
          </ul>
        </section>
        """
    }

    // MARK: - Footer (OSS + Education + Languages)

    private func footer() -> String {
        let ossItems = resume.projects.map { proj in
            """
            <div class="oss-item">
              <strong>\(proj.name)</strong>
              <p>\(proj.description) &nbsp;<a href="\(proj.url)">\(proj.url.replacingOccurrences(of: "https://", with: ""))</a></p>
            </div>
            """
        }.joined(separator: "\n")

        let edu = resume.education.map { e in
            let years = "\(yearOnly(e.startDate))–\(yearOnly(e.endDate))"
            return """
            <p style="font-size:8.1pt"><strong>\(e.institution)</strong></p>
            <p style="font-size:7.8pt;color:#6B7280">\(e.area) &nbsp;·&nbsp; \(years)</p>
            """
        }.joined(separator: "\n")

        let langs = resume.languages
            .map { "\($0.language) (\($0.fluency))" }
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

// Equatable helper for Position (used in extras injection)
extension Position: Equatable {
    static func == (lhs: Position, rhs: Position) -> Bool {
        lhs.position == rhs.position && lhs.startDate == rhs.startDate
    }
}

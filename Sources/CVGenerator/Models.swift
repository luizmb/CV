import Foundation

// MARK: - Root

struct Resume: Decodable {
    let basics: Basics
    let work: [Company]
    let education: [Education]
    let skills: [SkillGroup]
    let languages: [Language]
    let projects: [Project]
}

// MARK: - Basics

struct Basics: Decodable {
    let name: String
    let email: String
    let phone: String
    let website: String
    let visa: String
    let summary: String
    let location: Location
    let profiles: [Profile]
}

struct Location: Decodable {
    let city: String
    let countryCode: String
}

struct Profile: Decodable {
    let network: String
    let username: String
    let url: String
}

// MARK: - Work

struct Company: Decodable {
    let company: String
    let location: String
    let summary: String
    let website: String
    let positions: [Position]
}

struct Position: Decodable {
    let position: String
    let startDate: String
    let endDate: String?
    let showDetails: Bool
    let highlights: [String]
}

// MARK: - Education

struct Education: Decodable {
    let institution: String
    let area: String
    let studyType: String
    let location: String
    let startDate: String
    let endDate: String
    let website: String
}

// MARK: - Skills

struct SkillGroup: Decodable {
    let name: String
    let keywords: [String]
}

// MARK: - Language

struct Language: Decodable {
    let language: String
    let fluency: String
}

// MARK: - Project

struct Project: Decodable {
    let name: String
    let description: String
    let url: String
}

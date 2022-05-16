//
//  Character.swift
//  RMModel
//
//  Created by Konrad Cureau on 03/05/2022.
//

import Foundation

public struct Character {
    public let identifier: Int
    public let name: String
    public let status: Status
    public let species: String
    public let type: String
    public let gender: Gender
    public let origin: Origin
    public let location: Location
    private let image: String
    private let episode: [String]
    public let url: String
    public let created: String

    public var imageURL: URL {
        URL(string: image)!
    }

    public var episodesNumber: [Int] {
        var lastComponents = [String]()
        episode.forEach { episodeURL in
            let url = URL(string: episodeURL)!
            lastComponents.append(url.lastPathComponent)
        }
        return lastComponents.compactMap { Int($0) }
    }
}

extension Character {
    public enum Status: String {
        case alive
        case dead
        case unknown
    }

    public enum Gender: String {
        case male
        case female
        case genderless
        case unknown
    }

    public struct Origin: Codable {
        public let name: String
        public let url: String
    }

    public struct Location: Codable {
        public let name: String
        public let url: String
    }
}

extension Character: Codable {
    private enum CodingKeys: String, CodingKey {
        case identifier = "id"
        case name
        case status
        case species
        case type
        case gender
        case origin
        case location
        case image
        case episode
        case url
        case created
    }
}

extension Character.Status: Codable {
    public init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        let rawString = try container.decode(String.self)

        if let status = Character.Status(rawValue: rawString.lowercased()) {
            self = status
        } else {
            throw DecodingError.dataCorruptedError(in: container, debugDescription: "Invalid string value: \(rawString)")
        }
    }
}

extension Character.Gender: Codable {
    public init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        let rawString = try container.decode(String.self)

        if let gender = Character.Gender(rawValue: rawString.lowercased()) {
            self = gender
        } else {
            throw DecodingError.dataCorruptedError(in: container, debugDescription: "Invalid string value: \(rawString)")
        }
    }
}

extension Character.Origin {
    private enum CodingKeys: String, CodingKey {
        case name
        case url
    }
}

extension Character.Location {
    private enum CodingKeys: String, CodingKey {
        case name
        case url
    }
}

extension Character: Equatable {
    public static func == (lhs: Character, rhs: Character) -> Bool {
        lhs.identifier == rhs.identifier
    }
}

extension Character: Hashable {
    public func hash(into hasher: inout Hasher) {
        hasher.combine(identifier)
    }
}

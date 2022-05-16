//
//  Episode.swift
//  RMModel
//
//  Created by Konrad Cureau on 03/05/2022.
//

import Foundation

public struct Episode {
    public let identifier: Int
    public let name: String
    public let airDate: String
    public let episode: String
    private let characters: [String]
    public let url: String
    public let created: String

    public var charactersNumber: [Int] {
        var lastComponents = [String]()
        characters.forEach { characterURL in
            let url = URL(string: characterURL)!
            lastComponents.append(url.lastPathComponent)
        }
        return lastComponents.compactMap { Int($0) }
    }
}

extension Episode: Codable {
    private enum CodingKeys: String, CodingKey {
        case identifier = "id"
        case name
        case airDate = "air_date"
        case episode
        case characters
        case url
        case created
    }
}

extension Episode: Equatable {
    public static func == (lhs: Episode, rhs: Episode) -> Bool {
        lhs.identifier == rhs.identifier
    }
}

extension Episode: Hashable {
    public func hash(into hasher: inout Hasher) {
        hasher.combine(identifier)
    }
}


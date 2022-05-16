//
//  Location.swift
//  RMModel
//
//  Created by Konrad Cureau on 03/05/2022.
//

import Foundation

public struct Location {
    public let identifier: Int
    public let name: String
    public let type: String
    public let dimension: String
    private let residents: [String]
    public let url: String
    public let created: String

    public var residentsNumber: [Int] {
        var lastComponents = [String]()
        residents.forEach { residentURL in
            let url = URL(string: residentURL)!
            lastComponents.append(url.lastPathComponent)
        }
        return lastComponents.compactMap { Int($0) }
    }
}

extension Location: Codable {
    private enum CodingKeys: String, CodingKey {
        case identifier = "id"
        case name
        case type
        case dimension
        case residents
        case url
        case created
    }
}

extension Location: Equatable {
    public static func == (lhs: Location, rhs: Location) -> Bool {
        lhs.identifier == rhs.identifier
    }
}

extension Location: Hashable {
    public func hash(into hasher: inout Hasher) {
        hasher.combine(identifier)
    }
}

//
//  EpisodeFilter.swift
//  Rick&Morty
//
//  Created by Konrad Cureau on 12/05/2022.
//

import Foundation

enum EpisodeFilter: Int, CaseIterable {
    case s01
    case s02
    case s03
    case s04
    case s05

    var filterQuery: String {
        switch self {
        case .s01:
            return "s01"
        case .s02:
            return "s02"
        case .s03:
            return "s03"
        case .s04:
            return "s04"
        case .s05:
            return "s05"
        }
    }

    var name: String {
        switch self {
        case .s01:
            return "Season 1"
        case .s02:
            return "Season 2"
        case .s03:
            return "Season 3"
        case .s04:
            return "Season 4"
        case .s05:
            return "Season 5"
        }
    }
}

//
//  EpisodesServices.swift
//  RMModel
//
//  Created by Konrad Cureau on 12/05/2022.
//

import Foundation
import Moya

enum EpisodesServices {
    case episodes(page: Int?, name: String?, episode: String?)
    case fetchEpisodesByID(episodes: [Int])
}

extension EpisodesServices: TargetType {
    var baseURL: URL {
        return URL(string: "https://rickandmortyapi.com/api")!
    }

    var path: String {
        switch self {
        case .episodes:
            return "/episode"
        case .fetchEpisodesByID(let episodes):
            return "/episode/\(episodes)"
        }
    }

    var method: Moya.Method {
        switch self {
        case .episodes:
            return .get
        case .fetchEpisodesByID:
            return .get
        }
    }

    var task: Task {
        switch self {
        case .episodes(let page, let name, let episode):
            var params: [String: Any] = [:]
            params["page"] = page
            params["name"] = name
            params["episode"] = episode
            return .requestParameters(parameters: params, encoding: URLEncoding.default)
        case .fetchEpisodesByID:
            return .requestPlain
        }
    }

    var headers: [String: String]? {
        return ["Content-type": "application/json"]
    }

    var validationType: ValidationType {
        return .successCodes
    }
}

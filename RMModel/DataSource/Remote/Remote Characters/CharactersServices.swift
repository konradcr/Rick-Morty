//
//  CharactersServices.swift
//  RMModel
//
//  Created by Konrad Cureau on 12/05/2022.
//

import Foundation
import Moya

enum CharactersServices {
    case characters(page: Int?, name: String?, status: String?, species: String?, type: String?, gender: String?)
    case fetchCharactersByID(characters: [Int])
}

extension CharactersServices: TargetType {
    var baseURL: URL {
        return URL(string: "https://rickandmortyapi.com/api")!
    }

    var path: String {
        switch self {
        case .characters:
            return "/character"
        case .fetchCharactersByID(let characters):
            return "/character/\(characters)"
        }
    }

    var method: Moya.Method {
        switch self {
        case .characters:
            return .get
        case .fetchCharactersByID:
            return .get
        }
    }

    var task: Task {
        switch self {
        case .characters(let page, let name, let status, let species, let type, let gender):
            var params: [String: Any] = [:]
            params["page"] = page
            params["name"] = name
            params["status"] = status
            params["species"] = species
            params["type"] = type
            params["gender"] = gender
            return .requestParameters(parameters: params, encoding: URLEncoding.default)
        case .fetchCharactersByID:
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

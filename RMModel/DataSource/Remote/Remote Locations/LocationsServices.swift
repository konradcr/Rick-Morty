//
//  LocationsDataSource.swift
//  RMModel
//
//  Created by Konrad Cureau on 12/05/2022.
//

import Foundation
import Moya

enum LocationsServices {
    case locations(page: Int?, name: String?, type: String?, dimension: String?)
}

extension LocationsServices: TargetType {
    var baseURL: URL {
        return URL(string: "https://rickandmortyapi.com/api")!
    }

    var path: String {
        switch self {
        case .locations:
            return "/location"
        }
    }

    var method: Moya.Method {
        switch self {
        case .locations:
            return .get
        }
    }

    var task: Task {
        switch self {
        case .locations(let page, let name, let type, let dimension):
            var params: [String: Any] = [:]
            params["page"] = page
            params["name"] = name
            params["type"] = type
            params["dimension"] = dimension
            return .requestParameters(parameters: params, encoding: URLEncoding.default)
        }
    }

    var headers: [String: String]? {
        return ["Content-type": "application/json"]
    }

    var validationType: ValidationType {
        return .successCodes
    }
}

//
//  RickMortyResult.swift
//  RMModel
//
//  Created by Konrad Cureau on 03/05/2022.
//

import Foundation

public struct RickMortyResult<T: Codable>: Codable {
    public let info: APIResponse
    public  let results: [T]
}

extension RickMortyResult {
    public struct APIResponse: Codable {
        public let count: Int
        public let pages: Int
        public let next: String?
        public let prev: String?
    }
}

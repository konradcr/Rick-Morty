//
//  CharactersRepository.swift
//  RMModel
//
//  Created by Konrad Cureau on 04/05/2022.
//

import Foundation

public protocol CharactersRepositoryProtocol: AnyObject {
    func fetchCharacters(page: Int,
                         completion: @escaping (Result<RickMortyResult<Character>, Error>) -> Void)

    func fetchCharactersByID(characters: [Int],
                             completion: @escaping (Result<[Character], Error>) -> Void)
}

final class CharactersRepository: CharactersRepositoryProtocol {
    private static var instance: CharactersRepositoryProtocol?

    static func shared(datasource: CharactersDataSourceProtocol) -> CharactersRepositoryProtocol {
        if instance == nil {
            instance = CharactersRepository(datasource: datasource)
        }

        return instance!
    }

    private let datasource: CharactersDataSourceProtocol

    private let cache = Cache<String, RickMortyResult<Character>>()

    private init(datasource: CharactersDataSourceProtocol) {
        self.datasource = datasource
    }

    func fetchCharacters(page: Int,
                         completion: @escaping (Result<RickMortyResult<Character>, Error>) -> Void) {

        if let cached = cache["CharactersPage\(page)"] {
            return completion(.success(cached))
        }

        datasource.fetchCharacters(page: page,
                                   name: nil,
                                   status: nil,
                                   species: nil,
                                   type: nil,
                                   gender: nil) { [weak self] result in
            let charactersResult = try? result.get()
            charactersResult.map { self?.cache["CharactersPage\(page)"] = $0 }
            completion(result)
        }
    }

    func fetchCharactersByID(characters: [Int],
                             completion: @escaping (Result<[Character], Error>) -> Void) {
        datasource.fetchCharactersByID(characters: characters,
                                       completion: completion)
    }
}

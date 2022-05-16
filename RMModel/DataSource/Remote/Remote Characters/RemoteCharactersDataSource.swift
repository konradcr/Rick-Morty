//
//  RemoteCharactersDataSource.swift
//  RMModel
//
//  Created by Konrad Cureau on 12/05/2022.
//

import Foundation
import Moya

final class RemoteCharactersDataSource: CharactersDataSourceProtocol {
    typealias T = CharactersServices

    var provider: RMProvider<CharactersServices> {
        return RMProvider<CharactersServices>()
    }

    func fetchCharacters(page: Int?,
                         name: String?,
                         status: String?,
                         species: String?,
                         type: String?,
                         gender: String?,
                         completion: @escaping (Result<RickMortyResult<Character>, Error>) -> Void) {
        provider.request(.characters(page: page,
                                     name: name,
                                     status: status,
                                     species: species,
                                     type: type,
                                     gender: gender),
                         responseType: RickMortyResult.self,
                         completion: completion)
    }

    func fetchCharactersByID(characters: [Int], completion: @escaping (Result<[Character], Error>) -> Void) {
        provider.request(.fetchCharactersByID(characters: characters),
                         responseType: [Character].self,
                         completion: completion)
    }
}

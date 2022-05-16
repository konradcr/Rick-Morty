//
//  CharactersDataSource.swift
//  RMModel
//
//  Created by Konrad Cureau on 12/05/2022.
//

import Foundation

protocol CharactersDataSourceProtocol: AnyObject {

    func fetchCharacters(page: Int?,
                         name: String?,
                         status: String?,
                         species: String?,
                         type: String?,
                         gender: String?,
                         completion: @escaping (Result<RickMortyResult<Character>, Error>) -> Void)

    func fetchCharactersByID(characters: [Int],
                             completion: @escaping (Result<[Character], Error>) -> Void)
}

//
//  EpisodesDataSource.swift
//  RMModel
//
//  Created by Konrad Cureau on 12/05/2022.
//

import Foundation

protocol EpisodesDataSourceProtocol: AnyObject {
    func fetchEpisodes(page: Int?,
                       name: String?,
                       episode: String?,
                       completion: @escaping (Result<RickMortyResult<Episode>, Error>) -> Void)

    func fetchEpisodesByID(episodes: [Int],
                           completion: @escaping (Result<[Episode], Error>) -> Void)
}

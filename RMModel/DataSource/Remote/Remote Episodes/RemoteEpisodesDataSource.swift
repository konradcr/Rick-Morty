//
//  RemoteEpisodesDataSource.swift
//  RMModel
//
//  Created by Konrad Cureau on 12/05/2022.
//

import Foundation
import Moya

final class RemoteEpisodesDataSource: EpisodesDataSourceProtocol {
    typealias T = EpisodesServices

    var provider: RMProvider<EpisodesServices> {
        return RMProvider<EpisodesServices>()
    }

    func fetchEpisodes(page: Int?,
                       name: String?,
                       episode: String?,
                       completion: @escaping (Result<RickMortyResult<Episode>, Error>) -> Void) {
        provider.request(.episodes(page: page, name: name, episode: episode),
                         responseType: RickMortyResult.self,
                         completion: completion)
    }

    func fetchEpisodesByID(episodes: [Int], completion: @escaping (Result<[Episode], Error>) -> Void) {
        provider.request(.fetchEpisodesByID(episodes: episodes),
                         responseType: [Episode].self,
                         completion: completion)
    }
}

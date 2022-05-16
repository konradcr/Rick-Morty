//
//  EpisodesRepository.swift
//  RMModel
//
//  Created by Konrad Cureau on 04/05/2022.
//

import Foundation

public protocol EpisodesRepositoryProtocol: AnyObject {
    func fetchEpisodes(page: Int,
                       completion: @escaping (Result<RickMortyResult<Episode>, Error>) -> Void)

    func fetchFilteredEpisodesBySeason(episode: String?,
                                       completion: @escaping (Result<RickMortyResult<Episode>, Error>) -> Void)

    func fetchEpisodesByID(episodes: [Int],
                           completion: @escaping (Result<[Episode], Error>) -> Void)
}

final class EpisodesRepository: EpisodesRepositoryProtocol {
    private static var instance: EpisodesRepositoryProtocol?

    static func shared(datasource: EpisodesDataSourceProtocol) -> EpisodesRepositoryProtocol {
        if instance == nil {
            instance = EpisodesRepository(datasource: datasource)
        }

        return instance!
    }

    private let datasource: EpisodesDataSourceProtocol

    private let cache = Cache<String, RickMortyResult<Episode>>()

    private init(datasource: EpisodesDataSourceProtocol) {
        self.datasource = datasource
    }

    func fetchEpisodes(page: Int,
                       completion: @escaping (Result<RickMortyResult<Episode>, Error>) -> Void) {

        if let cached = cache["EpisodesPage\(page)"] {
            return completion(.success(cached))
        }

        datasource.fetchEpisodes(page: page, name: nil, episode: nil) { [weak self] result in
            let episodesResult = try? result.get()
            episodesResult.map { self?.cache["EpisodesPage\(page)"] = $0 }
            completion(result)
        }
    }

    func fetchFilteredEpisodesBySeason(episode: String?,
                                       completion: @escaping (Result<RickMortyResult<Episode>, Error>) -> Void) {
        datasource.fetchEpisodes(page: nil, name: nil, episode: episode, completion: completion)
    }

    func fetchEpisodesByID(episodes: [Int],
                           completion: @escaping (Result<[Episode], Error>) -> Void) {
        datasource.fetchEpisodesByID(episodes: episodes, completion: completion)
    }
}

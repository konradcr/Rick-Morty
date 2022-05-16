//
//  InjectorUtils.swift
//  RMModel
//
//  Created by Konrad Cureau on 04/05/2022.
//

import Foundation

public final class InjectorUtils {
    public static let shared = InjectorUtils()

    // API
    private lazy var remoteCharacters: CharactersDataSourceProtocol = RemoteCharactersDataSource()
    private lazy var remoteEpisodes: EpisodesDataSourceProtocol = RemoteEpisodesDataSource()
    private lazy var remoteLocations: LocationsDataSourceProtocol = RemoteLocationsDataSource()

    // Repository
    public private(set) lazy var charactersRepository = CharactersRepository.shared(datasource: remoteCharacters)
    public private(set) lazy var locationsRepository = LocationsRepository.shared(datasource: remoteLocations)
    public private(set) lazy var episodesRepository = EpisodesRepository.shared(datasource: remoteEpisodes)

    private init() { }
}

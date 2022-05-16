//
//  LocationsRepository.swift
//  RMModel
//
//  Created by Konrad Cureau on 04/05/2022.
//

import Foundation

public protocol LocationsRepositoryProtocol: AnyObject {
    func fetchLocations(page: Int,
                        completion: @escaping (Result<RickMortyResult<Location>, Error>) -> Void)
}

final class LocationsRepository: LocationsRepositoryProtocol {
    private static var instance: LocationsRepositoryProtocol?

    static func shared(datasource: LocationsDataSourceProtocol) -> LocationsRepositoryProtocol {
        if instance == nil {
            instance = LocationsRepository(datasource: datasource)
        }

        return instance!
    }

    private let datasource: LocationsDataSourceProtocol

    private let cache = Cache<String, RickMortyResult<Location>>()

    private init(datasource: LocationsDataSourceProtocol) {
        self.datasource = datasource
    }

    func fetchLocations(page: Int,
                        completion: @escaping (Result<RickMortyResult<Location>, Error>) -> Void) {

        if let cached = cache["LocationsPage\(page)"] {
            return completion(.success(cached))
        }

        datasource.fetchLocations(page: page, name: nil, type: nil, dimension: nil) { [weak self] result in
            let locationsResult = try? result.get()
            locationsResult.map { self?.cache["LocationsPage\(page)"] = $0 }
            completion(result)
        }
    }
}

//
//  RemoteLocationsDataSource.swift
//  RMModel
//
//  Created by Konrad Cureau on 12/05/2022.
//

import Foundation
import Moya

final class RemoteLocationsDataSource: LocationsDataSourceProtocol {
    typealias T = LocationsServices

    var provider: RMProvider<LocationsServices> {
        return RMProvider<LocationsServices>()
    }

    func fetchLocations(page: Int?,
                        name: String?,
                        type: String?,
                        dimension: String?,
                        completion: @escaping (Result<RickMortyResult<Location>, Error>) -> Void) {
        provider.request(.locations(page: page, name: name, type: type, dimension: dimension),
                         responseType: RickMortyResult.self,
                         completion: completion)
    }
}

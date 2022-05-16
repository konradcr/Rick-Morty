//
//  LocationsDataSource.swift
//  RMModel
//
//  Created by Konrad Cureau on 12/05/2022.
//

import Foundation

protocol LocationsDataSourceProtocol: AnyObject {
    func fetchLocations(page: Int?,
                        name: String?,
                        type: String?,
                        dimension: String?,
                        completion: @escaping (Result<RickMortyResult<Location>, Error>) -> Void)
}

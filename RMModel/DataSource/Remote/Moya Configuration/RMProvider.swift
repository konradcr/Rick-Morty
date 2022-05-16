//
//  RMProvider.swift
//  RMModel
//
//  Created by Konrad Cureau on 04/05/2022.
//

import Foundation
import Moya

internal final class RMProvider<T: TargetType>: MoyaProvider<T> {
    typealias DecodableCompletion<D: Decodable> = (Swift.Result<D, Error>) -> Void

    enum DecodingKeyPath {
        case root
        case data

        var value: String? {
            switch self {
            case .root:
                return nil
            case .data:
                return "data"
            }
        }
    }

    @discardableResult
    func request<D: Decodable>(_ target: T,
                               callbackQueue: DispatchQueue? = .none,
                               progress: ProgressBlock? = .none,
                               responseType: D.Type,
                               at keyPath: DecodingKeyPath = .root,
                               decoder: JSONDecoder = JSONDecoder(),
                               completion: @escaping DecodableCompletion<D>) -> Cancellable {

        decoder.dateDecodingStrategy = .iso8601

        return _request(target, callbackQueue: callbackQueue, progress: progress) {
            switch $0 {
            case .success(let response):
                do {
                    let filteredResponse = try response.filterSuccessfulStatusCodes()

                    let representation = try filteredResponse.map(responseType,
                                                                  atKeyPath: keyPath.value,
                                                                  using: decoder)

                    completion(.success(representation))
                } catch {
                    completion(.failure(error))
                }

            case .failure(let error):
                completion(.failure(error))
            }
        }
    }

    private func _request(_ target: T,
                          callbackQueue: DispatchQueue? = .none,
                          progress: ProgressBlock? = .none,
                          completion: @escaping (Result<Response, Error>) -> Void) -> Cancellable {
        return request(target, callbackQueue: callbackQueue, progress: progress) {
            switch $0 {
            case .success(let response):
                completion(.success(response))

            case .failure(let error):
                completion(.failure(error))
            }
        }
    }
}

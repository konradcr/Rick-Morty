//
//  LocationDetailViewPresenter.swift
//  Rick&Morty
//
//  Created by Konrad Cureau on 09/05/2022.
//

import UIKit
import RMModel

protocol LocationDetailViewPresenterDelegate: AnyObject {
    func locationDetailViewPresenterStartLoading(_ presenter: LocationDetailViewPresenter)
    func locationDetailViewPresenterFinishedLoading(_ presenter: LocationDetailViewPresenter)
    func locationDetailViewPresenter(_ presenter: LocationDetailViewPresenter,
                                     didReceiveCharacters characters: [Character])
    func locationDetailViewPresenter(_ presenter: LocationDetailViewPresenter,
                                     didReceiveError error: Error)
}

final class LocationDetailViewPresenter: Presenter {
    typealias ViewDelegate = LocationDetailViewPresenterDelegate

    private weak var viewDelegate: LocationDetailViewPresenterDelegate?

    private lazy var charactersRepository = InjectorUtils.shared.charactersRepository

    let location: Location
    private(set) var charactersFromLocation = [Character]()
    private var charactersWorkItem: DispatchWorkItem?

    private var currentWorkCount: UInt = 0 {
        didSet {
            if currentWorkCount == 0 {
                viewDelegate?.locationDetailViewPresenterFinishedLoading(self)
            } else if currentWorkCount > 0 {
                viewDelegate?.locationDetailViewPresenterStartLoading(self)
            }
        }
    }

    // MARK: - Initializer

    init(location: Location) {
        self.location = location
    }

    // MARK: - Private Methods

    private func startLoading() {
        self.currentWorkCount += 1
    }

    private func stopLoading() {
        self.currentWorkCount -= 1
    }

    private func cancelFetch() {
        var charactersWorkItem: DispatchWorkItem!
        charactersWorkItem = DispatchWorkItem {
            self.startLoading()
            self.stopLoading()
        }
        self.charactersWorkItem = charactersWorkItem
        DispatchQueue.main.async(execute: charactersWorkItem)
    }

    // MARK: - Public Methods

    func attachView(_ view: LocationDetailViewPresenterDelegate?) {
        self.viewDelegate = view
    }

    func fetchCharacters() {
        guard !location.residentsNumber.isEmpty else {
            cancelFetch()
            return
        }

        var charactersWorkItem: DispatchWorkItem!
        charactersWorkItem = DispatchWorkItem {
            self.startLoading()

            self.charactersRepository.fetchCharactersByID(characters: self.location.residentsNumber) { [weak self] result in
                guard let self = self else {
                    return
                }

                let isCancelled = charactersWorkItem.isCancelled
                charactersWorkItem = nil

                if isCancelled {
                    self.stopLoading()
                    return
                }

                switch result {
                case .success(let response):
                    self.charactersFromLocation = response
                    self.viewDelegate?.locationDetailViewPresenter(self,
                                                                   didReceiveCharacters: self.charactersFromLocation)

                case .failure(let error):
                    self.viewDelegate?.locationDetailViewPresenter(self, didReceiveError: error)
                }

                self.stopLoading()
            }
        }
        self.charactersWorkItem = charactersWorkItem
        DispatchQueue.main.async(execute: charactersWorkItem)
    }
}

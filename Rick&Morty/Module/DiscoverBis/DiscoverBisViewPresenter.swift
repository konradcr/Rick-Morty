//
//  DiscoverBisViewPresenter.swift
//  Rick&Morty
//
//  Created by Konrad Cureau on 05/05/2022.
//

import UIKit
import RMModel

protocol DiscoverBisViewPresenterDelegate: AnyObject {
    func discoverViewPresenterStartLoading(_ presenter: DiscoverBisViewPresenter)
    func discoverViewPresenterFinishedLoading(_ presenter: DiscoverBisViewPresenter)
    func discoverViewPresenterdidReceiveCharacters(_ presenter: DiscoverBisViewPresenter)
    func discoverViewPresenterdidReceiveEpisodes(_ presenter: DiscoverBisViewPresenter)
    func discoverViewPresenterdidReceiveLocations(_ presenter: DiscoverBisViewPresenter)
    func discoverViewPresenter(_ presenter: DiscoverBisViewPresenter, didReceiveError error: Error)
}

final class DiscoverBisViewPresenter: Presenter {
    typealias ViewDelegate = DiscoverBisViewPresenterDelegate

    // MARK: - Properties

    private weak var viewDelegate: DiscoverBisViewPresenterDelegate?

    private lazy var charactersRepository = InjectorUtils.shared.charactersRepository
    private lazy var locationsRepository = InjectorUtils.shared.locationsRepository
    private lazy var episodesRepository = InjectorUtils.shared.episodesRepository

    private var charactersWorkItem: DispatchWorkItem?
    private var episodesWorkItem: DispatchWorkItem?
    private var locationsWorkItem: DispatchWorkItem?

    private(set) var characters = [Character]()
    private(set) var episodes = [Episode]()
    private(set) var locations = [Location]()

    private var currentWorkCount: UInt = 0 {
        didSet {
            if currentWorkCount == 0 {
                viewDelegate?.discoverViewPresenterFinishedLoading(self)
            } else if currentWorkCount > 0 {
                viewDelegate?.discoverViewPresenterStartLoading(self)
            }
        }
    }

    // MARK: - Initializers

    init() { }

    // MARK: - Private Methodsc

    private func startLoading() {
        self.currentWorkCount += 1
    }

    private func stopLoading() {
        self.currentWorkCount -= 1
    }

    private func fetchCharacters() {
        var charactersWorkItem: DispatchWorkItem!
        charactersWorkItem = DispatchWorkItem {
            self.startLoading()

            self.charactersRepository.fetchCharacters(page: 1) { [weak self] result in
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
                    var characters = response.results.shuffled()

                    for _ in 0 ..< 10 {
                        self.characters.append(characters[0])
                        characters.remove(at: 0)
                    }

                    self.viewDelegate?.discoverViewPresenterdidReceiveCharacters(self)

                case .failure(let error):
                    self.viewDelegate?.discoverViewPresenter(self, didReceiveError: error)
                }

                self.stopLoading()
            }
        }
        self.charactersWorkItem = charactersWorkItem
        DispatchQueue.main.async(execute: charactersWorkItem)
    }

    private func fetchEpisodes() {
        var episodesWorkItem: DispatchWorkItem!
        episodesWorkItem = DispatchWorkItem {
            self.startLoading()

            self.episodesRepository.fetchEpisodes(page: 1) { [weak self] result in
                guard let self = self else {
                    return
                }

                let isCancelled = episodesWorkItem.isCancelled
                episodesWorkItem = nil

                if isCancelled {
                    self.stopLoading()
                    return
                }

                switch result {
                case .success(let response):
                    var episodes = response.results.shuffled()

                    for _ in 0 ..< 10 {
                        self.episodes.append(episodes[0])
                        episodes.remove(at: 0)
                    }
                    self.viewDelegate?.discoverViewPresenterdidReceiveEpisodes(self)

                case .failure(let error):
                    self.viewDelegate?.discoverViewPresenter(self, didReceiveError: error)
                }

                self.stopLoading()
            }
        }
        self.episodesWorkItem = episodesWorkItem
        DispatchQueue.main.async(execute: episodesWorkItem)
    }

    private func fetchLocations() {
        var locationsWorkItem: DispatchWorkItem!
        locationsWorkItem = DispatchWorkItem {
            self.startLoading()

            self.locationsRepository.fetchLocations(page: 1) { [weak self] result in
                guard let self = self else {
                    return
                }

                let isCancelled = locationsWorkItem.isCancelled
                locationsWorkItem = nil

                if isCancelled {
                    self.stopLoading()
                    return
                }

                switch result {
                case .success(let response):
                    var locations = response.results.shuffled()

                    for _ in 0 ..< 3 {
                        self.locations.append(locations[0])
                        locations.remove(at: 0)
                    }

                    self.viewDelegate?.discoverViewPresenterdidReceiveLocations(self)

                case .failure(let error):
                    self.viewDelegate?.discoverViewPresenter(self, didReceiveError: error)
                }

                self.stopLoading()
            }
        }
        self.locationsWorkItem = locationsWorkItem
        DispatchQueue.main.async(execute: locationsWorkItem)
    }

    // MARK: - Public Methods

    func attachView(_ view: DiscoverBisViewPresenterDelegate?) {
        self.viewDelegate = view
    }

    func fetchData() {
        fetchCharacters()
        fetchEpisodes()
        fetchLocations()
    }
}

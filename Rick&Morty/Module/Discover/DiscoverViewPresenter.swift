//
//  DiscoverViewPresenter.swift
//  Rick&Morty
//
//  Created by Konrad Cureau on 04/05/2022.
//

import UIKit
import RMModel

protocol DiscoverViewPresenterDelegate: AnyObject {
    func discoverViewPresenterStartLoading(_ presenter: DiscoverViewPresenter)
    func discoverViewPresenterFinishedLoading(_ presenter: DiscoverViewPresenter)
    func discoverViewPresenter(_ presenter: DiscoverViewPresenter, didReceiveCharacters characters: [Character])
    func discoverViewPresenter(_ presenter: DiscoverViewPresenter, didReceiveEpisodes episodes: [Episode])
    func discoverViewPresenter(_ presenter: DiscoverViewPresenter, didReceiveLocations locations: [Location])
    func discoverViewPresenter(_ presenter: DiscoverViewPresenter, didReceiveError error: Error)
}

final class DiscoverViewPresenter: Presenter {
    typealias ViewDelegate = DiscoverViewPresenterDelegate

    // MARK: - Properties

    private weak var viewDelegate: DiscoverViewPresenterDelegate?

    private lazy var charactersRepository = InjectorUtils.shared.charactersRepository
    private lazy var locationsRepository = InjectorUtils.shared.locationsRepository
    private lazy var episodesRepository = InjectorUtils.shared.episodesRepository

    private var charactersWorkItem: DispatchWorkItem?
    private var episodesWorkItem: DispatchWorkItem?
    private var locationsWorkItem: DispatchWorkItem?

    private(set) var characters = [Character]()
    private(set) var episodes = [Episode]()
    private(set) var locations = [Location]()

    private var charactersPageIndex: Int = 1
    private var episodesPageIndex: Int = 1
    private var locationPageIndex: Int = 1

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

    private func fetchCharactersPagesInfo() {
        var charactersWorkItem: DispatchWorkItem!
        charactersWorkItem = DispatchWorkItem {
            self.startLoading()

            self.charactersRepository.fetchCharacters(page: self.charactersPageIndex) { [weak self] result in
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
                    let numberOfPages = response.info.pages
                    self.charactersPageIndex = Int.random(in: 1...numberOfPages)
                    self.fetchCharacters()
                case .failure(let error):
                    self.viewDelegate?.discoverViewPresenter(self, didReceiveError: error)
                }

                self.stopLoading()
            }
        }
        self.charactersWorkItem = charactersWorkItem
        DispatchQueue.main.async(execute: charactersWorkItem)
    }

    private func fetchCharacters() {
        var charactersWorkItem: DispatchWorkItem!
        charactersWorkItem = DispatchWorkItem {
            self.startLoading()

            self.charactersRepository.fetchCharacters(page: self.charactersPageIndex) { [weak self] result in
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
                    let characters = response.results.shuffled()
                    let count = characters.count

                    self.characters = characters.dropLast(count - 6)

                    self.viewDelegate?.discoverViewPresenter(self, didReceiveCharacters: self.characters)
                case .failure(let error):
                    self.viewDelegate?.discoverViewPresenter(self, didReceiveError: error)
                }

                self.stopLoading()
            }
        }
        self.charactersWorkItem = charactersWorkItem
        DispatchQueue.main.async(execute: charactersWorkItem)
    }

    private func fetchEpisodesPagesInfo() {
        var episodesWorkItem: DispatchWorkItem!
        episodesWorkItem = DispatchWorkItem {
            self.startLoading()

            self.episodesRepository.fetchEpisodes(page: self.episodesPageIndex) { [weak self] result in
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
                    let lastPage = response.info.pages
                    self.episodesPageIndex = lastPage

                    self.fetchEpisodes()
                case .failure(let error):
                    self.viewDelegate?.discoverViewPresenter(self, didReceiveError: error)
                }

                self.stopLoading()
            }
        }
        self.episodesWorkItem = episodesWorkItem
        DispatchQueue.main.async(execute: episodesWorkItem)
    }

    private func fetchEpisodes() {
        var episodesWorkItem: DispatchWorkItem!
        episodesWorkItem = DispatchWorkItem {
            self.startLoading()

            self.episodesRepository.fetchEpisodes(page: self.episodesPageIndex) { [weak self] result in
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
                    let episodes = response.results
                    let count = episodes.count

                    self.episodes = episodes.reversed().dropLast(count - 6)

                    self.viewDelegate?.discoverViewPresenter(self, didReceiveEpisodes: self.episodes)
                case .failure(let error):
                    self.viewDelegate?.discoverViewPresenter(self, didReceiveError: error)
                }

                self.stopLoading()
            }
        }
        self.episodesWorkItem = episodesWorkItem
        DispatchQueue.main.async(execute: episodesWorkItem)
    }

    private func fetchLocationsPagesInfo() {
        var locationsWorkItem: DispatchWorkItem!
        locationsWorkItem = DispatchWorkItem {
            self.startLoading()

            self.locationsRepository.fetchLocations(page: self.locationPageIndex) { [weak self] result in
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
                    let numberOfPages = response.info.pages
                    self.locationPageIndex = Int.random(in: 1...numberOfPages)
                    self.fetchLocations()

                case .failure(let error):
                    self.viewDelegate?.discoverViewPresenter(self, didReceiveError: error)
                }

                self.stopLoading()
            }
        }
        self.locationsWorkItem = locationsWorkItem
        DispatchQueue.main.async(execute: locationsWorkItem)
    }

    private func fetchLocations() {
        var locationsWorkItem: DispatchWorkItem!
        locationsWorkItem = DispatchWorkItem {
            self.startLoading()

            self.locationsRepository.fetchLocations(page: self.locationPageIndex) { [weak self] result in
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
                    let locations = response.results.shuffled()
                    let count = locations.count

                    self.locations = locations.dropLast(count - 3)

                    self.viewDelegate?.discoverViewPresenter(self, didReceiveLocations: self.locations)
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

    func attachView(_ view: DiscoverViewPresenterDelegate?) {
        self.viewDelegate = view
    }

    func fetchData() {
        fetchCharactersPagesInfo()
        fetchEpisodesPagesInfo()
        fetchLocationsPagesInfo()
    }
}


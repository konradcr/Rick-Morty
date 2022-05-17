//
//  EpisodesListViewPresenter.swift
//  Rick&Morty
//
//  Created by Konrad Cureau on 04/05/2022.
//

import UIKit
import RMModel

protocol EpisodesListViewPresenterDelegate: AnyObject {
    func episodesListViewPresenterStartLoading(_ presenter: EpisodesListViewPresenter)
    func episodesListViewPresenterFinishedLoading(_ presenter: EpisodesListViewPresenter)
    func episodesListViewPresenter(_ presenter: EpisodesListViewPresenter, didReceiveEpisodes episodes: [Episode])
    func episodesListViewPresenter(_ presenter: EpisodesListViewPresenter, didReceiveError error: Error)
    func episodesListViewPresenter(_ presenter: EpisodesListViewPresenter, didEnableFilter isEnable: Bool)
}

final class EpisodesListViewPresenter: Presenter {
    typealias ViewDelegate = EpisodesListViewPresenterDelegate

    // MARK: - Properties

    private weak var viewDelegate: EpisodesListViewPresenterDelegate?

    private lazy var episodesRepository = InjectorUtils.shared.episodesRepository

    private(set) var episodes = [Episode]()
    private var episodesWorkItem: DispatchWorkItem?
    private var episodesPageIndex: Int = 1
    private var hasUpcomingPage = true

    private var currentWorkCount: UInt = 0 {
        didSet {
            if currentWorkCount == 0 {
                viewDelegate?.episodesListViewPresenterFinishedLoading(self)
            } else if currentWorkCount > 0 {
                viewDelegate?.episodesListViewPresenterStartLoading(self)
            }
        }
    }

    private(set) var selectedFilter: EpisodeFilter? {
        didSet {
            viewDelegate?.episodesListViewPresenter(self, didEnableFilter: isFilterEnable)
            reloadEpisodes()
            if selectedFilter == nil {
                fetchEpisodes()
            } else {
                filterEpisodes()
            }
        }
    }

    var isFilterEnable: Bool {
        return selectedFilter != nil
    }

    // MARK: - Initializers

    init() { }

    // MARK: - Private Methods

    private func startLoading() {
        self.currentWorkCount += 1
    }

    private func stopLoading() {
        self.currentWorkCount -= 1
    }

    // MARK: - Public Methods

    func attachView(_ view: EpisodesListViewPresenterDelegate?) {
        self.viewDelegate = view
    }

    func reloadEpisodes() {
        episodesPageIndex = 1
        hasUpcomingPage = true
        episodesWorkItem?.cancel()
        episodesWorkItem = nil
        episodes.removeAll()
    }

    func fetchEpisodes() {
        guard hasUpcomingPage else {
            return
        }

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
                    self.episodesPageIndex += 1
                    self.episodes += response.results
                    self.hasUpcomingPage = response.info.next != nil

                    self.viewDelegate?.episodesListViewPresenter(self, didReceiveEpisodes: self.episodes)

                case .failure(let error):
                    self.viewDelegate?.episodesListViewPresenter(self, didReceiveError: error)
                }

                self.stopLoading()
            }
        }
        self.episodesWorkItem = episodesWorkItem
        DispatchQueue.main.async(execute: episodesWorkItem)
    }

    func filterEpisodes() {
        guard hasUpcomingPage else {
            return
        }

        var episodesWorkItem: DispatchWorkItem!
        episodesWorkItem = DispatchWorkItem {
            self.startLoading()

            self.episodesRepository.fetchFilteredEpisodesBySeason(episode: self.selectedFilter?.filterQuery) { [weak self] result in
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
                    self.episodesPageIndex += 1
                    self.episodes += response.results
                    self.hasUpcomingPage = response.info.next != nil

                    self.viewDelegate?.episodesListViewPresenter(self, didReceiveEpisodes: self.episodes)

                case .failure(let error):
                    self.viewDelegate?.episodesListViewPresenter(self, didReceiveError: error)
                }

                self.stopLoading()
            }
        }
        self.episodesWorkItem = episodesWorkItem
        DispatchQueue.main.async(execute: episodesWorkItem)
    }

    func addFilter(_ filter: EpisodeFilter) {
        guard selectedFilter != filter else {
            return
        }

        selectedFilter = filter
    }

    func removeFilter(_ filter: EpisodeFilter) {
        guard selectedFilter == filter else {
            return
        }

        selectedFilter = nil
    }
}

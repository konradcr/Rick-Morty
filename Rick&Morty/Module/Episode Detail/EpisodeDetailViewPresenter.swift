//
//  EpisodeDetailViewPresenter.swift
//  Rick&Morty
//
//  Created by Konrad Cureau on 09/05/2022.
//

import UIKit
import RMModel

protocol EpisodeDetailViewPresenterDelegate: AnyObject {
    func episodeDetailViewPresenterStartLoading(_ presenter: EpisodeDetailViewPresenter)
    func episodeDetailViewPresenterFinishedLoading(_ presenter: EpisodeDetailViewPresenter)
    func episodeDetailViewPresenter(_ presenter: EpisodeDetailViewPresenter, didReceiveCharacters characters: [Character])
    func episodeDetailViewPresenter(_ presenter: EpisodeDetailViewPresenter, didReceiveError error: Error)
}

final class EpisodeDetailViewPresenter: Presenter {
    typealias ViewDelegate = EpisodeDetailViewPresenterDelegate

    private weak var viewDelegate: EpisodeDetailViewPresenterDelegate?

    private lazy var charactersRepository = InjectorUtils.shared.charactersRepository

    let episode: Episode
    private(set) var charactersFromEpisode = [Character]()
    private var charactersWorkItem: DispatchWorkItem?

    private var currentWorkCount: UInt = 0 {
        didSet {
            if currentWorkCount == 0 {
                viewDelegate?.episodeDetailViewPresenterFinishedLoading(self)
            } else if currentWorkCount > 0 {
                viewDelegate?.episodeDetailViewPresenterStartLoading(self)
            }
        }
    }

    // MARK: - Initializer

    init(episode: Episode) {
        self.episode = episode
    }

    // MARK: - Private Methods

    private func startLoading() {
        self.currentWorkCount += 1
    }

    private func stopLoading() {
        self.currentWorkCount -= 1
    }

    // MARK: - Public Methods

    func attachView(_ view: EpisodeDetailViewPresenterDelegate?) {
        self.viewDelegate = view
    }

    func fetchCharacters() {
        var charactersWorkItem: DispatchWorkItem!
        charactersWorkItem = DispatchWorkItem {
            self.startLoading()

            self.charactersRepository.fetchCharactersByID(characters: self.episode.charactersNumber) { [weak self] result in
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
                    self.charactersFromEpisode = response
                    self.viewDelegate?.episodeDetailViewPresenter(self, didReceiveCharacters: self.charactersFromEpisode)

                case .failure(let error):
                    self.viewDelegate?.episodeDetailViewPresenter(self, didReceiveError: error)
                }

                self.stopLoading()
            }
        }
        self.charactersWorkItem = charactersWorkItem
        DispatchQueue.main.async(execute: charactersWorkItem)
    }
}

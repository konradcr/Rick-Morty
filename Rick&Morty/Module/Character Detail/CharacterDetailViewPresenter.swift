//
//  CharacterDetailViewPresenter.swift
//  Rick&Morty
//
//  Created by Konrad Cureau on 09/05/2022.
//

import UIKit
import RMModel

protocol CharacterDetailViewPresenterDelegate: AnyObject {
    func characterDetailViewPresenterStartLoading(_ presenter: CharacterDetailViewPresenter)
    func characterDetailViewPresenterFinishedLoading(_ presenter: CharacterDetailViewPresenter)
    func characterDetailViewPresenter(_ presenter: CharacterDetailViewPresenter, didReceiveEpisodes episodes: [Episode])
    func characterDetailViewPresenter(_ presenter: CharacterDetailViewPresenter, didReceiveError error: Error)
}

final class CharacterDetailViewPresenter: Presenter {
    typealias ViewDelegate = CharacterDetailViewPresenterDelegate

    enum CharacterInformation: Hashable {
        case image(URL)
        case name(String)
        case badgedDetailed(species: String, origin: String)
        case details(status: String, type: String?, gender: String)
        case episodes([Episode])
    }

    private weak var viewDelegate: CharacterDetailViewPresenterDelegate?

    private lazy var episodesRepository = InjectorUtils.shared.episodesRepository

    let character: Character
    private(set) var characterInformations = [CharacterInformation]()

    private var episodesWorkItem: DispatchWorkItem?

    private(set) var episodesFromCharacter = [Episode]() {
        didSet {
            self.createCharacterInformation(from: character)
        }
    }

    private var currentWorkCount: UInt = 0 {
        didSet {
            if currentWorkCount == 0 {
                viewDelegate?.characterDetailViewPresenterFinishedLoading(self)
            } else if currentWorkCount > 0 {
                viewDelegate?.characterDetailViewPresenterStartLoading(self)
            }
        }
    }

    // MARK: - Initializer

    init(character: Character) {
        self.character = character
        self.createCharacterInformation(from: character)
    }

    // MARK: - Private Methods

    private func createCharacterInformation(from character: Character) {
        var characterInformations = [CharacterInformation]()

        characterInformations.append(.image(character.imageURL))
        characterInformations.append(.name(character.name))
        characterInformations.append(.badgedDetailed(species: character.species, origin: character.origin.name))

        if character.type.isEmpty  {
            characterInformations.append(.details(status: character.status.rawValue.capitalized, type: nil, gender: character.gender.rawValue.capitalized))
        } else {
            characterInformations.append(.details(status: character.status.rawValue.capitalized, type: character.type, gender: character.gender.rawValue.capitalized))
        }

        characterInformations.append(.episodes(self.episodesFromCharacter))

        self.characterInformations = characterInformations
    }

    private func startLoading() {
        self.currentWorkCount += 1
    }

    private func stopLoading() {
        self.currentWorkCount -= 1
    }

    // MARK: - Public Methods

    func attachView(_ view: CharacterDetailViewPresenterDelegate?) {
        self.viewDelegate = view
    }

    func fetchEpisodes() {
        var episodesWorkItem: DispatchWorkItem!
        episodesWorkItem = DispatchWorkItem {
            self.startLoading()

            self.episodesRepository.fetchEpisodesByID(episodes: self.character.episodesNumber) { [weak self] result in
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
                    self.episodesFromCharacter = response
                    self.viewDelegate?.characterDetailViewPresenter(self, didReceiveEpisodes: self.episodesFromCharacter)
                case .failure(let error):
                    self.viewDelegate?.characterDetailViewPresenter(self, didReceiveError: error)
                }

                self.stopLoading()
            }
        }
        self.episodesWorkItem = episodesWorkItem
        DispatchQueue.main.async(execute: episodesWorkItem)
    }
}



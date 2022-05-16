//
//  CharactersListViewPresenter.swift
//  Rick&Morty
//
//  Created by Konrad Cureau on 04/05/2022.
//

import UIKit
import RMModel

protocol CharactersListViewPresenterDelegate: AnyObject {
    func charactersListViewPresenterStartLoading(_ presenter: CharactersListViewPresenter)
    func charactersListViewPresenterFinishedLoading(_ presenter: CharactersListViewPresenter)
    func charactersListViewPresenter(_ presenter: CharactersListViewPresenter, didReceiveCharacters characters: [Character])
    func charactersListViewPresenter(_ presenter: CharactersListViewPresenter, didReceiveError error: Error)
}

final class CharactersListViewPresenter: Presenter {
    typealias ViewDelegate = CharactersListViewPresenterDelegate

    // MARK: - Properties

    private weak var viewDelegate: CharactersListViewPresenterDelegate?

    private lazy var charactersRepository = InjectorUtils.shared.charactersRepository

    private(set) var characters = [Character]()
    private var charactersWorkItem: DispatchWorkItem?
    private var charactersPageIndex: Int = 1
    private var hasUpcomingPage = true

    private var currentWorkCount: UInt = 0 {
        didSet {
            if currentWorkCount == 0 {
                viewDelegate?.charactersListViewPresenterFinishedLoading(self)
            } else if currentWorkCount > 0 {
                viewDelegate?.charactersListViewPresenterStartLoading(self)
            }
        }
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

    func attachView(_ view: CharactersListViewPresenterDelegate?) {
        self.viewDelegate = view
    }

    func reloadCharacters() {
        charactersPageIndex = 1
        hasUpcomingPage = true
        charactersWorkItem?.cancel()
        charactersWorkItem = nil
        characters.removeAll()

        fetchCharacters()
    }

    func fetchCharacters() {
        guard hasUpcomingPage else {
            return
        }

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
                    self.charactersPageIndex += 1
                    self.characters += response.results
                    self.hasUpcomingPage = response.info.next != nil

                    self.viewDelegate?.charactersListViewPresenter(self, didReceiveCharacters: self.characters)
                case .failure(let error):
                    self.viewDelegate?.charactersListViewPresenter(self, didReceiveError: error)
                }

                self.stopLoading()
            }
        }
        self.charactersWorkItem = charactersWorkItem
        DispatchQueue.main.async(execute: charactersWorkItem)
    }
}


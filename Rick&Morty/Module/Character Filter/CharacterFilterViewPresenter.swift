//
//  CharacterFilterViewPresenter.swift
//  Rick&Morty
//
//  Created by Konrad Cureau on 13/05/2022.
//

import UIKit
import RMModel

protocol CharacterFilterViewPresenterDelegate: AnyObject {
    func characterFilterViewPresenter(_ presenter: CharacterFilterViewPresenter, didAddFilter filter: CharacterFilter)
    func characterFilterViewPresenter(_ presenter: CharacterFilterViewPresenter, didRemoveFilter filter: CharacterFilter)
}

final class CharacterFilterViewPresenter: Presenter {
    typealias ViewDelegate = CharacterFilterViewPresenterDelegate

    // MARK: - Properties

    private weak var viewDelegate: CharacterFilterViewPresenterDelegate?

    private(set) var selectedFilter: CharacterFilter?

    // MARK: - Init

    init(filter: CharacterFilter?) {
        self.selectedFilter = filter
    }

    // MARK: - Private Methods

    private func addFilter(_ filter: CharacterFilter) {
        selectedFilter = filter
        viewDelegate?.characterFilterViewPresenter(self, didAddFilter: filter)
    }

    private func removeFilter(_ filter: CharacterFilter) {
        selectedFilter = nil
        viewDelegate?.characterFilterViewPresenter(self, didRemoveFilter: filter)
    }

    // MARK: - Public Methods

    func attachView(_ view: CharacterFilterViewPresenterDelegate?) {
        self.viewDelegate = view
    }

    func selectFilter(at index: Int) {
        let filter = CharacterFilter.allCases[index]
        guard selectedFilter != filter else {
            removeFilter(filter)
            return
        }
        addFilter(filter)
    }

    func deselectFilter(at index: Int) {
        removeFilter(CharacterFilter.allCases[index])
    }
}

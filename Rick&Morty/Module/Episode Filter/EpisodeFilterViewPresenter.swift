//
//  EpisodeFilterViewPresenter.swift
//  Rick&Morty
//
//  Created by Konrad Cureau on 12/05/2022.
//

import UIKit
import RMModel

protocol EpisodeFilterViewPresenterDelegate: AnyObject {
    func episodeFilterViewPresenter(_ presenter: EpisodeFilterViewPresenter, didAddFilter filter: EpisodeFilter)
    func episodeFilterViewPresenter(_ presenter: EpisodeFilterViewPresenter, didRemoveFilter filter: EpisodeFilter)
}

final class EpisodeFilterViewPresenter: Presenter {
    typealias ViewDelegate = EpisodeFilterViewPresenterDelegate

    // MARK: - Properties

    private weak var viewDelegate: EpisodeFilterViewPresenterDelegate?

    private(set) var selectedFilter: EpisodeFilter?

    // MARK: - Init

    init(filter: EpisodeFilter?) {
        self.selectedFilter = filter
    }

    // MARK: - Private Methods

    private func addFilter(_ filter: EpisodeFilter) {
        selectedFilter = filter
        viewDelegate?.episodeFilterViewPresenter(self, didAddFilter: filter)
    }

    private func removeFilter(_ filter: EpisodeFilter) {
        selectedFilter = nil
        viewDelegate?.episodeFilterViewPresenter(self, didRemoveFilter: filter)
    }

    // MARK: - Public Methods

    func attachView(_ view: EpisodeFilterViewPresenterDelegate?) {
        self.viewDelegate = view
    }

    func selectFilter(at index: Int) {
        let filter = EpisodeFilter.allCases[index]
        guard selectedFilter != filter else {
            removeFilter(filter)
            return
        }
        addFilter(filter)
    }

    func deselectFilter(at index: Int) {
        removeFilter(EpisodeFilter.allCases[index])
    }
}

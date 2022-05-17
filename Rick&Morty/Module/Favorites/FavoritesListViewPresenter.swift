//
//  LocationsListViewPresenter.swift
//  Rick&Morty
//
//  Created by Konrad Cureau on 04/05/2022.
//

import UIKit
import RMModel

protocol FavoritesListViewPresenterDelegate: AnyObject {
}

final class FavoritesListViewPresenter: Presenter {
    typealias ViewDelegate = FavoritesListViewPresenterDelegate

    // MARK: - Properties

    private weak var viewDelegate: FavoritesListViewPresenterDelegate?

    private lazy var charactersRepository = InjectorUtils.shared.charactersRepository
    private lazy var locationsRepository = InjectorUtils.shared.locationsRepository
    private lazy var episodesRepository = InjectorUtils.shared.episodesRepository

    // MARK: - Initializers

    init() { }

    // MARK: - Private Methods

    // MARK: - Public Methods

    func attachView(_ view: FavoritesListViewPresenterDelegate?) {
        self.viewDelegate = view
    }
}

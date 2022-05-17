//
//  LocationsListViewPresenter.swift
//  Rick&Morty
//
//  Created by Konrad Cureau on 04/05/2022.
//

import UIKit
import RMModel

protocol LocationsListViewPresenterDelegate: AnyObject {
    func locationsListViewPresenterStartLoading(_ presenter: LocationsListViewPresenter)
    func locationsListViewPresenterFinishedLoading(_ presenter: LocationsListViewPresenter)
    func locationsListViewPresenter(_ presenter: LocationsListViewPresenter, didReceiveLocations locations: [Location])
    func locationsListViewPresenter(_ presenter: LocationsListViewPresenter, didReceiveError error: Error)
}

final class LocationsListViewPresenter: Presenter {
    typealias ViewDelegate = LocationsListViewPresenterDelegate

    // MARK: - Properties

    private weak var viewDelegate: LocationsListViewPresenterDelegate?

    private lazy var locationsRepository = InjectorUtils.shared.locationsRepository

    private(set) var locations = [Location]()
    private var locationsWorkItem: DispatchWorkItem?
    private var locationsPageIndex: Int = 1
    private var hasUpcomingPage = true

    private var currentWorkCount: UInt = 0 {
        didSet {
            if currentWorkCount == 0 {
                viewDelegate?.locationsListViewPresenterFinishedLoading(self)
            } else if currentWorkCount > 0 {
                viewDelegate?.locationsListViewPresenterStartLoading(self)
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

    func attachView(_ view: LocationsListViewPresenterDelegate?) {
        self.viewDelegate = view
    }

    func reloadCharacters() {
        locationsPageIndex = 1
        hasUpcomingPage = true
        locationsWorkItem?.cancel()
        locationsWorkItem = nil
        locations.removeAll()

        fetchLocations()
    }

    func fetchLocations() {
        guard hasUpcomingPage else {
            return
        }

        var locationsWorkItem: DispatchWorkItem!
        locationsWorkItem = DispatchWorkItem {
            self.startLoading()

            self.locationsRepository.fetchLocations(page: self.locationsPageIndex) { [weak self] result in
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
                    self.locationsPageIndex += 1
                    self.locations += response.results
                    self.hasUpcomingPage = response.info.next != nil

                    self.viewDelegate?.locationsListViewPresenter(self, didReceiveLocations: self.locations)

                case .failure(let error):
                    self.viewDelegate?.locationsListViewPresenter(self, didReceiveError: error)
                }

                self.stopLoading()
            }
        }
        self.locationsWorkItem = locationsWorkItem
        DispatchQueue.main.async(execute: locationsWorkItem)
    }
}

//
//  ViewController.swift
//  Rick&Morty
//
//  Created by Konrad Cureau on 03/05/2022.
//

import UIKit
import RMModel

final class ViewControllerFactory {
    init() { }

    func tabBarController() -> UIViewController {
        return TabBarController(presenter: .init(),
                                navigator: .init(factory: self))
    }

    func discoverViewController() -> UIViewController {
        let navigationController = DiscoverNavigationController()
        let controller = DiscoverViewController(presenter: .init(),
                                                navigator: .init(factory: self, rootViewController: navigationController))
        navigationController.setViewControllers([controller], animated: true)

        return navigationController
    }

    func discoverBisViewController() -> UIViewController {
        let navigationController = DiscoverBisNavigationController()
        let controller = DiscoverBisViewController(presenter: .init(),
                                                   navigator: .init(factory: self, rootViewController: navigationController))
        navigationController.setViewControllers([controller], animated: true)

        return navigationController
    }

    func charactersListViewController() -> UIViewController {
        let navigationController = CharactersListNavigationController()
        let controller = CharactersListViewController(presenter: .init(),
                                                      navigator: .init(factory: self, rootViewController: navigationController))
        navigationController.setViewControllers([controller], animated: true)

        return navigationController
    }

    func episodesListViewController() -> UIViewController {
        let navigationController = EpisodesListNavigationController()
        let controller = EpisodesListViewController(presenter: .init(),
                                                    navigator: .init(factory: self, rootViewController: navigationController))
        navigationController.setViewControllers([controller], animated: true)

        return navigationController
    }

    func locationsListViewController() -> UIViewController {
        let navigationController = LocationsListNavigationController()
        let controller = LocationsListViewController(presenter: .init(),
                                                     navigator: .init(factory: self, rootViewController: navigationController))
        navigationController.setViewControllers([controller], animated: true)

        return navigationController
    }

    func favoritesListViewController() -> UIViewController {
        let navigationController = FavoritesListNavigationController()
        let controller = FavoritesListViewController(presenter: .init(),
                                                     navigator: .init(factory: self, rootViewController: navigationController))
        navigationController.setViewControllers([controller], animated: true)

        return navigationController
    }

    func characterDetailViewController(character: Character, from rootViewController: UIViewController) -> UIViewController {
        let controller = CharacterDetailViewController(presenter: .init(character: character),
                                                       navigator: .init(factory: self, rootViewController: rootViewController))

        return controller
    }

    func episodeDetailViewController(episode: Episode, from rootViewController: UIViewController) -> UIViewController {
        let controller = EpisodeDetailViewController(presenter: .init(episode: episode),
                                                     navigator: .init(factory: self, rootViewController: rootViewController))

        return controller
    }

    func locationDetailViewController(location: Location, from rootViewController: UIViewController) -> UIViewController {
        let controller = LocationDetailViewController(presenter: .init(location: location),
                                                      navigator: .init(factory: self, rootViewController: rootViewController))

        return controller
    }

    func episodesFilterViewController(from barButtonItem: UIBarButtonItem, delegate: EpisodeFilterViewControllerDelegate, filter: EpisodeFilter?) -> UIViewController {
        let controller = EpisodeFilterViewController(presenter: .init(filter: filter))
        controller.delegate = delegate

        if let sheet = controller.sheetPresentationController {
            sheet.detents = [.medium()]
            sheet.prefersGrabberVisible = true
            sheet.largestUndimmedDetentIdentifier = .medium
            sheet.prefersScrollingExpandsWhenScrolledToEdge = false
            sheet.prefersEdgeAttachedInCompactHeight = true
            sheet.widthFollowsPreferredContentSizeWhenEdgeAttached = true
        }

        controller.modalPresentationStyle = .pageSheet

        return controller
    }
}


extension ViewControllerFactory {
    func errorAlert(error: Error) -> UIViewController {
        let ac = UIAlertController(title: "Error", message: error.localizedDescription, preferredStyle: .alert)
        ac.addAction(UIAlertAction(title: "OK", style: .default))
        return ac
    }
}


//
//  EpisodesListViewNavigator.swift
//  Rick&Morty
//
//  Created by Konrad Cureau on 04/05/2022.
//

import UIKit
import RMModel

final class EpisodesListViewNavigator: Navigator {
    enum Destination {
        case error(Error)
        case episodeDetail(Episode)
        case filter(EpisodeFilterViewControllerDelegate, EpisodeFilter?, UIBarButtonItem)
    }

    private let factory: ViewControllerFactory
    private let rootViewController: UIViewController

    init(factory: ViewControllerFactory, rootViewController: UIViewController) {
        self.factory = factory
        self.rootViewController = rootViewController
    }

    func navigate(to destination: Destination) {
        switch destination {
        case .error(let error):
            rootViewController.present(factory.errorAlert(error: error), animated: true)

        case .episodeDetail(let episode):
            let detailViewController = factory.episodeDetailViewController(episode: episode, from: rootViewController)
            (rootViewController as! UINavigationController).pushViewController(detailViewController, animated: true)

        case .filter(let delegate, let filter, let barButtonItem):
            rootViewController.present(factory.episodesFilterViewController(from: barButtonItem, delegate: delegate, filter: filter), animated: true)
        }
    }
}


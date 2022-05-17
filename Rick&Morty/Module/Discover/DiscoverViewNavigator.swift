//
//  DiscoverViewNavigator.swift
//  Rick&Morty
//
//  Created by Konrad Cureau on 04/05/2022.
//

import UIKit
import RMModel

final class DiscoverViewNavigator: Navigator {
    enum Destination {
        case error(Error)
        case characterDetail(Character)
        case locationDetail(Location)
        case episodeDetail(Episode)
        case charactersList
        case locationsList
        case episodesList
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

        case .characterDetail(let character):
            let detailViewController = factory.characterDetailViewController(character: character, from: rootViewController)
            (rootViewController as! UINavigationController).pushViewController(detailViewController, animated: true)

        case .locationDetail(let location):
            let detailViewController = factory.locationDetailViewController(location: location, from: rootViewController)
            (rootViewController as! UINavigationController).pushViewController(detailViewController, animated: true)

        case .episodeDetail(let episode):
            let detailViewController = factory.episodeDetailViewController(episode: episode, from: rootViewController)
            (rootViewController as! UINavigationController).pushViewController(detailViewController, animated: true)

        case .charactersList:
            guard let tabController = rootViewController.tabBarController as? TabBarController else {
                return
            }
            tabController.updateTabBarSelectedViewController(item: .characters)

        case .locationsList:
            guard let tabController = rootViewController.tabBarController as? TabBarController else {
                return
            }
            tabController.updateTabBarSelectedViewController(item: .locations)

        case .episodesList:
            guard let tabController = rootViewController.tabBarController as? TabBarController else {
                return
            }
            tabController.updateTabBarSelectedViewController(item: .episodes)
        }
    }
}

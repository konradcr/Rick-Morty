//
//  CharacterDetailViewNavigator.swift
//  Rick&Morty
//
//  Created by Konrad Cureau on 09/05/2022.
//

import UIKit
import RMModel

final class CharacterDetailViewNavigator: Navigator {
    enum Destination {
        case error(Error)
        case back
        case episodeDetail(Episode)
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

        case .back:
            (rootViewController as! UINavigationController).popViewController(animated: true)

        case .episodeDetail(let episode):
            let detailViewController = factory.episodeDetailViewController(episode: episode, from: rootViewController)
            (rootViewController as! UINavigationController).pushViewController(detailViewController, animated: true)
        }
    }
}

//
//  CharactersListViewNavigator.swift
//  Rick&Morty
//
//  Created by Konrad Cureau on 04/05/2022.
//

import UIKit
import RMModel

final class CharactersListViewNavigator: Navigator {
    enum Destination {
        case error(Error)
        case characterDetail(Character)
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
        }
    }
}


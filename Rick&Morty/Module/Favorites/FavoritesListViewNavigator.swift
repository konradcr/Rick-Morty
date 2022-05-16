//
//  FavoritesListViewNavigator.swift
//  Rick&Morty
//
//  Created by Konrad Cureau on 04/05/2022.
//

import UIKit

final class FavoritesListViewNavigator: Navigator {
    enum Destination {
        case error(Error)
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
        }
    }
}


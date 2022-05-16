//
//  TabBarNavigator.swift
//  Rick&Morty
//
//  Created by Konrad Cureau on 04/05/2022.
//

import UIKit

final class TabBarNavigator: Navigator {
    enum Destination {
        case home
    }

    private let factory: ViewControllerFactory

    init(factory: ViewControllerFactory) {
        self.factory = factory
    }

    func allViewControllers() -> [UIViewController] {
        return [
            factory.discoverViewController(),
            factory.charactersListViewController(),
            factory.episodesListViewController(),
            factory.locationsListViewController(),
            factory.favoritesListViewController()
        ]
    }

    func navigate(to destination: TabBarNavigator.Destination) {
        fatalError("Shouldn't call this method directly")
    }
}


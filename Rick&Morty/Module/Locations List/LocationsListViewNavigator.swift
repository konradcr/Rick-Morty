//
//  LocationsListViewNavigator.swift
//  Rick&Morty
//
//  Created by Konrad Cureau on 04/05/2022.
//

import UIKit
import RMModel

final class LocationsListViewNavigator: Navigator {
    enum Destination {
        case error(Error)
        case locationDetail(Location)
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

        case .locationDetail(let location):
            let detailViewController = factory.locationDetailViewController(location: location, from: rootViewController)
            (rootViewController as! UINavigationController).pushViewController(detailViewController, animated: true)
        }
    }
}



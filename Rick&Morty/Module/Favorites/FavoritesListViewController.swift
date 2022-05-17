//
//  FavoritesListViewController.swift
//  Rick&Morty
//
//  Created by Konrad Cureau on 04/05/2022.
//

import UIKit
import RMModel

final class FavoritesListViewController: UIViewController {
    private enum Constants {
    }

    private let presenter: FavoritesListViewPresenter
    private let navigator: FavoritesListViewNavigator

    init(presenter: FavoritesListViewPresenter, navigator: FavoritesListViewNavigator) {
        self.presenter = presenter
        self.navigator = navigator

        super.init(nibName: nil, bundle: nil)

        self.tabBarItem = UITabBarItem(title: "Favorites", image: UIImage(systemName: "heart"), tag: 4)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
    }
}

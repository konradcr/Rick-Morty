//
//  TabBarController.swift
//  Rick&Morty
//
//  Created by Konrad Cureau on 04/05/2022.
//

import UIKit

final class TabBarController: UITabBarController {

    // MARK: - Properties

    enum TabBarItem: Int {
        case discover
        case characters
        case episodes
        case locations
        case favorites
        case discoverBis
    }

    private let presenter: TabBarPresenter
    private let navigator: TabBarNavigator

    init(presenter: TabBarPresenter, navigator: TabBarNavigator) {
        self.presenter = presenter
        self.navigator = navigator

        super.init(nibName: nil, bundle: nil)
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        setViewControllers(navigator.allViewControllers(), animated: false)
    }

    override func removeFromParent() {
        setViewControllers(nil, animated: false)
        super.removeFromParent()
    }

    func updateTabBarSelectedViewController(item: TabBarController.TabBarItem) {
        self.selectedIndex = item.rawValue
    }
}


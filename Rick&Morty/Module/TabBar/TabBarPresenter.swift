//
//  TabBarPresenter.swift
//  Rick&Morty
//
//  Created by Konrad Cureau on 04/05/2022.
//

import Foundation

protocol TabBarPresenterDelegate: AnyObject { }

final class TabBarPresenter: Presenter {
    typealias ViewDelegate = TabBarPresenterDelegate

    private weak var viewDelegate: TabBarPresenterDelegate?

    func attachView(_ view: TabBarPresenterDelegate?) {
        self.viewDelegate = view
    }
}

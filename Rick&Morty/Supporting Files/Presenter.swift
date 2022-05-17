//
//  Presenter.swift
//  Rick&Morty
//
//  Created by Konrad Cureau on 04/05/2022.
//

import Foundation

protocol Presenter: AnyObject {
    associatedtype ViewDelegate

    func attachView(_ view: ViewDelegate?)
}

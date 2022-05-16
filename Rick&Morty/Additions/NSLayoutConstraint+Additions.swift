//
//  NSLayoutConstraint+Additions.swift
//  Rick&Morty
//
//  Created by Konrad Cureau on 05/05/2022.
//

import class UIKit.NSLayoutConstraint

extension NSLayoutConstraint {
    static func activate(_ constraints: [NSLayoutConstraint] ...) {
        activate(constraints.flatMap { $0 })
    }
}

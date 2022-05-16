//
//  Navigator.swift
//  Rick&Morty
//
//  Created by Konrad Cureau on 04/05/2022.
//

import Foundation

protocol Navigator {
    associatedtype Destination

    func navigate(to destination: Destination)
}

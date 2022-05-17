//
//  CharacterFilter.swift
//  Rick&Morty
//
//  Created by Konrad Cureau on 13/05/2022.
//

import Foundation
import RMModel

enum CharacterFilter: CaseIterable, Equatable {
    static var allCases: [CharacterFilter] = [.gender(.female), .gender(.male), .gender(.genderless), .gender(.unknown), .status(.alive), .status(.dead), .status(.unknown)]

    case gender(Character.Gender)
    case status(Character.Status)
}

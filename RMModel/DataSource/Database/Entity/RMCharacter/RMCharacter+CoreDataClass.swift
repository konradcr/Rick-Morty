//
//  RMCharacter+CoreDataClass.swift
//  RMModel
//
//  Created by Konrad Cureau on 16/05/2022.
//
//

import Foundation
import CoreData

@objc(RMCharacter)
public class RMCharacter: NSManagedObject {
    convenience init(remote: Character, context: NSManagedObjectContext) {
        self.init(context: context)

        identifier = Int64(remote.identifier)
        name = remote.name
        type = remote.type
        gender = remote.gender.rawValue
        status = remote.status.rawValue
        species = remote.species
    }
}

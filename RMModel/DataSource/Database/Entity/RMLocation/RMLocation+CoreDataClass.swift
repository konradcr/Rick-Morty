//
//  RMLocation+CoreDataClass.swift
//  RMModel
//
//  Created by Konrad Cureau on 16/05/2022.
//
//

import Foundation
import CoreData

@objc(RMLocation)
public class RMLocation: NSManagedObject {
    convenience init(remote: Location, context: NSManagedObjectContext) {
        self.init(context: context)

        identifier = Int64(remote.identifier)
        name = remote.name
        type = remote.type
        dimension = remote.dimension
    }
}

//
//  RMLocation+CoreDataProperties.swift
//  RMModel
//
//  Created by Konrad Cureau on 16/05/2022.
//
//

import Foundation
import CoreData

extension RMLocation {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<RMLocation> {
        return NSFetchRequest<RMLocation>(entityName: "RMLocation")
    }

    @NSManaged public var dimension: String
    @NSManaged public var identifier: Int64
    @NSManaged public var name: String
    @NSManaged public var type: String
    @NSManaged public var residents: Set<RMCharacter>

}

// MARK: Generated accessors for residents
extension RMLocation {

    @objc(addResidentsObject:)
    @NSManaged public func addToResidents(_ value: RMCharacter)

    @objc(removeResidentsObject:)
    @NSManaged public func removeFromResidents(_ value: RMCharacter)

    @objc(addResidents:)
    @NSManaged public func addToResidents(_ values: NSSet)

    @objc(removeResidents:)
    @NSManaged public func removeFromResidents(_ values: NSSet)

}

extension RMLocation: Identifiable {

}

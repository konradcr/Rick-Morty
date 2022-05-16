//
//  RMCharacter+CoreDataProperties.swift
//  RMModel
//
//  Created by Konrad Cureau on 16/05/2022.
//
//

import Foundation
import CoreData
import UIKit

extension RMCharacter {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<RMCharacter> {
        return NSFetchRequest<RMCharacter>(entityName: "RMCharacter")
    }

    @NSManaged public var gender: String
    @NSManaged public var identifier: Int64
    @NSManaged public var imagePath: String
    @NSManaged public var name: String
    @NSManaged public var species: String
    @NSManaged public var status: String
    @NSManaged public var type: String
    @NSManaged public var location: RMLocation?

    public var image: UIImage? {
        let documentsDirectory = FileManager.default.urls(for: .documentDirectory,
                                                          in: .userDomainMask).first!
        let url = documentsDirectory.appendingPathComponent(imagePath)

        guard let data = try? Data(contentsOf: url) else {
          return nil
        }

        return UIImage(data: data)
    }

}

extension RMCharacter: Identifiable {

}

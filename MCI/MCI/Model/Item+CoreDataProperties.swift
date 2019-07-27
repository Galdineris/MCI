//
//  Item+CoreDataProperties.swift
//  MCI
//
//  Created by Rafael Galdino on 27/07/19.
//  Copyright © 2019 Rafael Galdino. All rights reserved.
//
//

import Foundation
import CoreData


extension Item {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Item> {
        return NSFetchRequest<Item>(entityName: "Item")
    }

    @NSManaged public var itemDescription: String?
    @NSManaged public var dateAdded: NSDate?
    @NSManaged public var itemNumber: Int16

}

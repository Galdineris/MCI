//
//  Item+CoreDataProperties.swift
//  MCI
//
//  Created by Rafael Galdino on 02/08/19.
//  Copyright © 2019 Rafael Galdino. All rights reserved.
//
//

import Foundation
import CoreData


extension Item {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Item> {
        let fetchRequest = NSFetchRequest<Item>(entityName: "Item")
        
        fetchRequest.sortDescriptors = [NSSortDescriptor.init(key: "index",
                                                              ascending: false)]
        return fetchRequest
    }

    @NSManaged public var dateAdded: NSDate?
    @NSManaged public var index: Int16
    @NSManaged public var thing: String?

}

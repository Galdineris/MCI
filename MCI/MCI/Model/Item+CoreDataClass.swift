//
//  Item+CoreDataClass.swift
//  MCI
//
//  Created by Rafael Galdino on 02/08/19.
//  Copyright © 2019 Rafael Galdino. All rights reserved.
//
//

import Foundation
import CoreData

public class Item: NSManagedObject {
    func feed(thing: String, index: Int16) {
        self.dateAdded = Date.init() as NSDate
        self.thing = thing.trimmingCharacters(in: .whitespacesAndNewlines)
        self.index = index
    }

    func modifyThing(newThing: String) -> Bool {
        if (newThing.filter { !$0.isNewline && !$0.isWhitespace }) == "" {
            return false
        }
        self.thing = newThing
        return true
    }

    func modifyIndex(newIndex: Int16) {
        self.index = newIndex
    }

}

//
//  File.swift
//  MCI
//
//  Created by Rafael Galdino on 02/08/19.
//  Copyright © 2019 Rafael Galdino. All rights reserved.
//

import Foundation
import CoreData
import UIKit

public class ModelManager {
    // MARK: Basic properties to make a Singleton
    private init() {
        if let appDelegate = UIApplication.shared.delegate as? AppDelegate {
            context = appDelegate.persistentContainer.viewContext
            do {
                _items = try context.fetch(Item.fetchRequest())
            } catch {
                fatalError("Não foi possível recuperar os dados.")
            }
        } else {
            fatalError("failed to start context")
        }
    }

    class func shared() -> ModelManager {
        return sharedContextManager
    }

    private static var sharedContextManager: ModelManager = {
        let contextManager = ModelManager()

        return contextManager
    }()

    // MARK: Properties
    private let context: NSManagedObjectContext
    private var _items: [Item]
    private var delegates: [DataModifiedDelegate] = []
    public func addDelegate(_ newDelegate: DataModifiedDelegate) {
        delegates.append(newDelegate)
    }
    func notify() {
        for delegate in delegates {
            delegate.dataModified()
        }
    }

    // MARK: Connections Accessors
    public var items: [Item] {
            var copy: [Item] = []
            copy.append(contentsOf: _items)
            return copy
    }
    //Add
    public func addItem(thing: String) -> ModelStatus {
        guard let newItem = NSEntityDescription.insertNewObject(forEntityName: "Item",
                                                                into: context) as? Item else {
            return ModelStatus(successful: false, description: "Failed to create Item")

        }
        let currentIndex = _items.count + 1
        newItem.feed(thing: thing,
                     index: Int16(currentIndex))
        _items.append(newItem)
        _items.sort { (item1, item2) -> Bool in
            return (item1.index > item2.index)
        }
        do {
            try context.save()
        } catch {
            return ModelStatus(successful: false, description: "Não foi possível salvar um item.")
        }
        notify()
        return ModelStatus(successful: true)
    }
    //Edit
    public func editItem(target: Item, newThing: String) -> ModelStatus {
        if target.modifyThing(newThing: newThing) {
            do {
                try context.save()
                _items = try context.fetch(Item.fetchRequest())
                notify()
                return ModelStatus(successful: true)
            } catch {
                return ModelStatus(successful: false, description: "Não foi possível editar o item")
            }
        }
        return ModelStatus(successful: true, description: "Não houve modificações")
    }
    //Remove
    public func removeItem(at index: Int) -> ModelStatus {
        if index < _items.count && index >= 0 {
            context.delete(_items[index])
            _items.remove(at: index)
            for index in 0..<index {
                _items[index].modifyIndex(newIndex: Int16((_items.count - index)))
            }
            do {
                try context.save()
                _items = try context.fetch(Item.fetchRequest())
                notify()
                return ModelStatus(successful: true)
            } catch {
                return ModelStatus(successful: false, description: "Não foi possível deletar o item")
            }
        }
        return ModelStatus(successful: false, description: "O index desejado está fora da range")
    }
}

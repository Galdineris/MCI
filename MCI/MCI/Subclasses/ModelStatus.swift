//
//  ModelStatus.swift
//  MCI
//
//  Created by Rafael Galdino on 02/08/19.
//  Copyright © 2019 Rafael Galdino. All rights reserved.
//

import Foundation

public class ModelStatus {
    public private(set) var successful: Bool
    public private(set) var description: String

    init(successful: Bool, description: String) {
        self.successful = successful
        self.description = description
    }

    convenience init(successful: Bool) {
        self.init(successful: successful, description: "")
    }
}

//
//  DefaultTableViewCell.swift
//  MCI
//
//  Created by Rafael Galdino on 19/07/19.
//  Copyright © 2019 Rafael Galdino. All rights reserved.
//

import UIKit

class DefaultTableViewCell: UITableViewCell {
    @IBOutlet weak var numberLabel: UILabel!
    @IBOutlet weak var thingLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        accessoryType = selected ? .checkmark : .none
    }    
}

//
//  AddFoodTableViewCell.swift
//  IntelliKitchen_Myfood
//
//  Created by D.WANG on 5/23/20.
//  Copyright © 2020 D.WANG. All rights reserved.
//

import UIKit

class AddFoodTableViewCell: UITableViewCell {
    
    @IBOutlet weak var foodNameLabel: UILabel!
    @IBOutlet weak var bDateLabel: UILabel!
    @IBOutlet weak var eDateLabel: UILabel!
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
}

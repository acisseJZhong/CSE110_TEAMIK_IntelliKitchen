//
//  CustomTableViewCell.swift
//  IntelliKitchen_Myfood
//
//  Created by D.WANG on 5/23/20.
//  Copyright © 2020 D.WANG. All rights reserved.
//

import UIKit

class CustomTableViewCell: UITableViewCell {
    
    @IBOutlet weak var foodLabel: UILabel!
    @IBOutlet weak var edLabel: UILabel!
    @IBOutlet weak var bdLabel: UILabel!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        // Configure the view for the selected state
    }
}

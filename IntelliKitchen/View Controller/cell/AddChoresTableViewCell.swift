//
//  AddChoresTableViewCell.swift
//  IntelliKitchen_Myfood
//
//  Created by D.WANG on 5/24/20.
//  Copyright © 2020 D.WANG. All rights reserved.
//

import UIKit

class AddChoresTableViewCell: UITableViewCell {

    @IBOutlet weak var nameLabel: UILabel!
    
    @IBOutlet weak var ldLabel: UILabel!
    
    
    @IBOutlet weak var fLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}

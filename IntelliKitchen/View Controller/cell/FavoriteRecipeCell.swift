//
//  FavoriteRecipeCell.swift
//  IntellK_Profile_Page
//
//  Created by zhangjm on 5/19/20.
//  Copyright © 2020 zhangjm. All rights reserved.
//

import UIKit

class FavoriteRecipeCell: UITableViewCell {

    @IBOutlet weak var favoriteRecipeImage: UIImageView!
    @IBOutlet weak var favoriteRecipeLabel: UILabel!
    
    func setFavoriteRecipe(favoriteRecipe: FavoriteRecipe) {
        favoriteRecipeImage.image = favoriteRecipe.image
        favoriteRecipeLabel.text = favoriteRecipe.title
    }
}

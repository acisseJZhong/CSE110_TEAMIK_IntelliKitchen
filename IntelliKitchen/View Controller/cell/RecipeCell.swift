//
//  RecipeCell.swift
//  IntelliKitchen
//
//  Created by sawsa on 4/30/20.
//  Copyright © 2020 jigsaw. All rights reserved.
//

import UIKit

class RecipeCell: UITableViewCell {
    
    @IBOutlet weak var recipeImage: UIImageView!
    @IBOutlet weak var recipeTitle: UILabel!
    @IBOutlet weak var recipeRating: UILabel!
    
    func setRecipe(recipe:Recipe) {
        recipeImage.image = recipe.image
        recipeTitle.text = recipe.title
        recipeRating.text = "Average Rating: \(recipe.rating)"
    }
    
}

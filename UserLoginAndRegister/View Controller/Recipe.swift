//
//  Recipe.swift
//  IntelliKitchen
//
//  Created by sawsa on 4/30/20.
//  Copyright © 2020 jigsaw. All rights reserved.
//

import Foundation
import UIKit

class Recipe {
    var image: UIImage
    var title: String
    
    init(image: UIImage, title: String) {
        self.image = image
        self.title = title
    }
}

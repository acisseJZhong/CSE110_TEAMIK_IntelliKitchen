//
//  Extentions.swift
//  homepage-Food Reminder
//
//  Created by Ricky Zhang on 5/19/20.
//  Copyright © 2020 Yilun Hao. All rights reserved.
//

import UIKit

extension RecipeViewController : UICollectionViewDelegateFlowLayout{
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        let bounds = collectionView.bounds
        let heightVal = self.view.frame.height
        let widthVal = self.view.frame.width
        let cellsize = (heightVal < widthVal) ? bounds.height/2 : bounds.width/2
        return CGSize(width: cellsize, height: cellsize)
    }
}

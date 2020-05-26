//
//  Extentions.swift
//  homepage-Food Reminder
//
//  Created by Ricky Zhang on 5/19/20.
//  Copyright © 2020 Yilun Hao. All rights reserved.
//

import UIKit

extension RecipeViewController : UICollectionViewDelegateFlowLayout{
    /*
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
    }
 */

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        //let layout = UICollectionViewFlowLayout()
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        let bounds = collectionView.bounds
        let heightVal = self.view.frame.height
        let widthVal = self.view.frame.width
        //print(heightVal)
        //print(widthVal)
        let cellsize = (heightVal < widthVal) ? bounds.height/2 : bounds.width/2
        return CGSize(width: cellsize, height: cellsize)
        //return CGSize(width: (widthVal)/2, height: (heightVal)/2)
        //return CGSize(width: 50, height: 50)
    }
    /*
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 5
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 5
    }
 */
}

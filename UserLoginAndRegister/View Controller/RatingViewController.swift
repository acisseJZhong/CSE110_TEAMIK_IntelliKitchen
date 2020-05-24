//
//  RatingViewController.swift
//  intellik
//
//  Created by 江南 on 5/4/20.
//  Copyright © 2020 江南. All rights reserved.
//


import UIKit
import Cosmos
import TinyConstraints
import Firebase

class RatingViewController: UIViewController {
    //var wordlabel: UILabel!
    
   // var ref: DatabaseReference!

    var ref = Database.database().reference().child("recipetest1")
    var ratingarray = [Double]()
    
    @IBOutlet weak var smallerView: UIView!
    
    
    @IBAction func clickSubmit(_ sender: Any) {
        dismiss(animated: true, completion: nil)
        ref.setValue(ratingarray.last)
        print("Successfully stored into firebase!")
    }
    
    lazy var cosmosView: CosmosView = {
        var view = CosmosView()
        view.settings.filledImage = UIImage(named: "Icon awesome-star")?.withRenderingMode(.alwaysOriginal)
        view.settings.emptyImage = UIImage(named: "Icon awesome-star2")?.withRenderingMode(.alwaysOriginal)
        view.settings.starSize = 30
        view.settings.fillMode = .full
        
        return view
    }()

    
  
    override func viewDidLoad() {
        super.viewDidLoad()
        smallerView.layer.cornerRadius=10
        //wordlabel = UILabel()
//        wordlabel.text = "How would you rate this recipe?"
//        wordlabel.font = UIFont.systemFont(ofSize: 25)
//        wordlabel.sizeToFit()
        //view.addSubview(wordlabel)
        
        // Do any additional setup after loading the view.
    
        view.addSubview(smallerView)
        //smallerView.addSubview(wordlabel)
        smallerView.addSubview(cosmosView)
        cosmosView.centerInSuperview()
        cosmosView.didTouchCosmos = {rating in
            self.ratingarray.append(rating)
            print("Rated: \(rating)")
            print(self.ratingarray)
        }
        
    }

}


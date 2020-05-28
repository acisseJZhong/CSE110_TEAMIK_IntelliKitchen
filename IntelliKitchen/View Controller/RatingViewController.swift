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
import FirebaseAuth

class RatingViewController: UIViewController {
    //var wordlabel: UILabel!
    
   // var ref: DatabaseReference!
    let db = Firestore.firestore()
    var ref = Database.database().reference().child("recipetest1")
    var ratingarray = [Int]()
    var passid:String = ""
    var currentUid: String = ""
    var ratedlist:[String] = []
    var ratedornot:Bool = false
    var numofpeople:Int = 0;
    var ratingsum:Int = 0;
    
   
    @IBOutlet weak var submitbutton: UIButton!
    
    @IBOutlet weak var smallerView: UIView!
    
    @IBAction func clickCancel(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func clickSubmit(_ sender: Any) {
        if (!ratedornot){
            ratedlist.append(passid)
            db.collection("users").document(currentUid).updateData(["ratedlist" : self.ratedlist])
            self.numofpeople = self.numofpeople + 1
            self.ratingsum = self.ratingsum + ratingarray.last!
            print(self.numofpeople)
            print(self.ratingsum)
            var ratingdb = Database.database().reference().child("Recipe/-M8IVR-st6dljGq6M4xN/"+passid+"/rating");
            ratingdb.setValue([ratingsum,numofpeople])
            ratedornot = true
            dismiss(animated: true, completion: nil)}
            //ref.setValue(ratingarray.last)}
            //print("Successfully stored into firebase!")}
        else {
            let alert = UIAlertController(title: "Already rated", message: "You have already rated this recipe~", preferredStyle: UIAlertController.Style.alert)
           alert.addAction(UIAlertAction(title: "OK", style: UIAlertAction.Style.default, handler: nil))
            self.present(alert, animated: true, completion: nil)
            submitbutton.isEnabled = false
            submitbutton.setTitleColor(.gray, for: .normal)
        }
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
        self.currentUid = Auth.auth().currentUser!.uid
        var ratingdb = Database.database().reference().child("Recipe/-M8IVR-st6dljGq6M4xN/"+passid+"/rating");
        
        print(self.passid)
        print(self.currentUid)
        view.addSubview(smallerView)
        //smallerView.addSubview(wordlabel)
        smallerView.addSubview(cosmosView)
        cosmosView.centerInSuperview()
        cosmosView.didTouchCosmos = {rating in
            self.ratingarray.append(Int(rating))
            print("Rated: \(rating)")
            print(self.ratingarray)
        }
        
        //get ratingnumber
        ratingdb.observeSingleEvent(of: .value) { (snapshot) in
        var ratingtuple = snapshot.value as! [Int];
            self.numofpeople = ratingtuple[1]
            self.ratingsum = ratingtuple[0]
           }

        //get ratedlist
        db.collection("users").document(currentUid).getDocument { (document, error) in
                if error == nil {
                    if document != nil && document!.exists {
                        let documentData = document?.data()
                        self.ratedlist = documentData?["ratedlist"] as? [String] ?? []
                        //print(self.favlist)
                        if self.ratedlist.contains(self.passid){
                           self.ratedornot = true
                        }
                    } else {
                        print("Can read the document but the document might not exists")
                    }
                    
                } else {
                    print("Something wrong reading the document")
                }
            }
    }

}


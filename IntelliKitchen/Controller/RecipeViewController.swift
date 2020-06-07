//
//  RecipeViewController.swift
//  homepage-Food Reminder
//
//  Created by Ricky Zhang on 5/7/20.
//  Copyright © 2020 Yilun Hao. All rights reserved.
//

import UIKit
import FirebaseDatabase
import FirebaseFirestore
import FirebaseAuth

class RecipeViewController: UIViewController{
    
    // reference and global variable
    @IBOutlet weak var collectionView: UICollectionView!
    var ref : DatabaseReference?
    var databaseHandle : DatabaseHandle?

    var allRecipe = [String]()
    var list = [Food]()
    var recipelist = [Recipehomepage]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        //collectionView.delegate = self
        //collectionView.dataSource = self
        
        ref = Database.database().reference()
        let db = Firestore.firestore()
        let currentUid = Auth.auth().currentUser!.uid
        db.collection("users").document(currentUid).collection("foods").getDocuments { (snapshot,error) in
            if(error != nil){
                print(error!)
            }else{
                for document in (snapshot!.documents){
                    let name = document.data()["foodName"] as! String
                    let expireSingle = document.data()["expireDate"] as! String
                    let dateFormatter = DateFormatter()
                    dateFormatter.dateFormat = "MM/dd/yyyy"
                    dateFormatter.locale = Locale.init(identifier: "en_GB")
                    if(expireSingle != ""){
                        let d = dateFormatter.date(from: expireSingle)!
                        let today = Date()
                        let calendar = Calendar.current
                        // Replace the hour (time) of both dates with 00:00
                        let date1 = calendar.startOfDay(for: today)
                        let date2 = calendar.startOfDay(for: d)
                        
                        let components = calendar.dateComponents([.day], from: date1, to: date2)
                        let inday = components.day!
                        if(inday>0){
                            self.list.append(Food(name: name,expiredate: inday))
                        }
                    }
                }
                self.list = self.list.sorted(by: { $0.expiredate < $1.expiredate })
                self.getdicList(){ (list) in
                    let list = list
                    for index in list{
                        self.databaseHandle = self.ref?.child("Recipe/-M8IVR-st6dljGq6M4xN/"+String(index)).observe(.value, with: { (snapshot) in
                            let value = snapshot.value as? NSDictionary
                            let recipe_name = value?.value(forKey: "recipe_name") as! String
                            if(!self.allRecipe.contains(recipe_name)){
                                var image = UIImage(named: "Mask Group 7")
                                if(value?.value(forKey: "img") != nil){
                                    let name = value?.value(forKey: "img") as! String
                                    let imageURL = URL(string: name)
                                    let data = try? Data(contentsOf: imageURL!)
                                    image = UIImage(data: data!)
                                    self.allRecipe.append(recipe_name)
                                    self.recipelist.append(Recipehomepage(image: image!, name: recipe_name, id: String(index)))
                                    self.collectionView.reloadData()
                                    self.collectionView .layoutIfNeeded()
                                }
                                else{
                                    if(value?.value(forKey: "recipe_pic") != nil){
                                        let name = value?.value(forKey: "recipe_pic") as! String
                                        let imageURL = URL(string: name)
                                        let data = try? Data(contentsOf: imageURL!)
                                        image = UIImage(data: data!)
                                        self.allRecipe.append(recipe_name)
                                        self.recipelist.append(Recipehomepage(image: image!, name: recipe_name, id: String(index)))
                                        self.collectionView.reloadData()
                                        self.collectionView .layoutIfNeeded()
                                    }
                                }
                            }
                        })
                    }
                }
            }
        }
    }
    
    func getRecipeList(name: String, completionHandler:@escaping ([Int], [Int]) -> ()) {
        var currentfood:[Int] = []
        var transfer:[Int] = []
        self.databaseHandle = self.ref?.child("Ingredients/"+name).observe(.value, with: { (snapshot) in
            if(snapshot.exists()){
                transfer.append(contentsOf: snapshot.value as! [Int])
                currentfood = snapshot.value as! [Int]
            }
            self.databaseHandle = self.ref?.child("Ingredients/"+name+"s").observe(.value, with: { (snapshot) in
                if(snapshot.exists()){
                    transfer.append(contentsOf: snapshot.value as! [Int])
                    currentfood = snapshot.value as! [Int]
                }
                completionHandler(transfer, currentfood)
            })
        })
    }
    
    func getdicList(completionHandler:@escaping ([Int]) -> ()) {
        var list:[Int] = []
        for food in self.list{
            getRecipeList(name: food.name){ (translist, currlist) in
                list.append(contentsOf: translist)
                let currlist = currlist
                let mappedItems = list.map { ($0, 1) }
                var returned = [Int]()
                let counts = Dictionary(mappedItems, uniquingKeysWith: +)
                for key in counts.keys{
                    if(counts[key]! >= 2 && returned.count<3){
                        returned.append(key)
                        list = list.filter{$0 != key}
                    }
                }
                while(counts.count > 0 && food.expiredate <= 3 && food.expiredate > 0 && currlist.count > 0 && returned.count<3){
                    returned.append(currlist.randomElement()!)
                }
                while(counts.count > 0 && food.expiredate <= 5 && food.expiredate > 3 && currlist.count > 0 && returned.count<2){
                    returned.append(currlist.randomElement()!)
                }
                while(counts.count > 0 && food.expiredate > 5 && currlist.count > 0 && returned.count<1){
                    returned.append(currlist.randomElement()!)
                }
                completionHandler(returned)
            }
        }
    }
}

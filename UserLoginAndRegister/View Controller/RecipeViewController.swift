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

class RecipeViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource {
    
    @IBOutlet weak var collectionView: UICollectionView!
    
    var ref : DatabaseReference?
    var databaseHandle : DatabaseHandle?
    
    var RecipeName = [String]()
    var RecipeImage = [UIImage]()
    var expire = [Date]()
    var allFood = [String]()
    var allRecipe = [String]()
    var AllImage = [UIImage]()
    var mylist:[Int] = []
    
    var ExpiredFood = [String]()
    var EmergencyFood = [String]()
    var AlmostFood = [String]()
    var SafeFood = [String]()
    
    var list = [(String, String)]()
    var sortedfoodList = [String]()
    var allTuples = [(String, Int)]()
    
    var no = 0
    var e = 0
    var a = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        collectionView.delegate = self
        collectionView.dataSource = self

        ref = Database.database().reference()
        let db = Firestore.firestore()
        let currentUid = Auth.auth().currentUser!.uid
        db.collection("users").document(currentUid).collection("foods").getDocuments { (snapshot,error) in
            if(error != nil){
                print(error!)
            }else{
                for document in (snapshot!.documents){
                    let name = document.data()["foodName"] as! String
                    //self.foodList.append(name)
                    let date = document.data()["expireDate"] as! String
                    self.list.append((name,date))
                }
                self.sortList()
                self.getEmergencyList(){ (list) in
                    let list = list
                    for index in list{
                        if(self.allRecipe.count<10){
                        self.databaseHandle = self.ref?.child("Recipe/"+String(index)).observe(.value, with: { (snapshot) in
                            let value = snapshot.value as? NSDictionary
                            let recipe_name = value?.value(forKey: "recipe_name") as! String
                            var image = UIImage(named: "Mask Group 7")
                            if(value?.value(forKey: "img") != nil){
                                let name = value?.value(forKey: "img") as! String
                                let imageURL = URL(string: name)
                                let data = try? Data(contentsOf: imageURL!)
                                image = UIImage(data: data!)
                                if(!self.allRecipe.contains(recipe_name)){
                                    print(recipe_name+"1")
                                    print(self.allRecipe)
                                    self.AllImage.append(image!)
                                    self.allRecipe.append(recipe_name)
                                    self.collectionView.reloadData()
                                    self.collectionView .layoutIfNeeded()
                                }
                                }
                            })
                        }
                    }
                    if(self.allRecipe.count<10){
                        self.getAlmostList(){ (list) in
                        let list = list
                        for index in list{
                            if(self.allRecipe.count<10){
                            self.databaseHandle = self.ref?.child("Recipe/"+String(index)).observe(.value, with: { (snapshot) in
                                let value = snapshot.value as? NSDictionary
                                let recipe_name = value?.value(forKey: "recipe_name") as! String
                                var image = UIImage(named: "Mask Group 7")
                                if(value?.value(forKey: "img") != nil){
                                    let name = value?.value(forKey: "img") as! String
                                    let imageURL = URL(string: name)
                                    let data = try? Data(contentsOf: imageURL!)
                                    image = UIImage(data: data!)
                                    if(!self.allRecipe.contains(recipe_name)){
                                        print(recipe_name+"2")
                                        print(self.allRecipe)
                                        self.AllImage.append(image!)
                                        self.allRecipe.append(recipe_name)
                                        self.collectionView.reloadData()
                                        self.collectionView .layoutIfNeeded()
                                    }
                                    }
                                })
                            }
                        }
                        }
                    }
                    if(self.allRecipe.count<10){
                        self.getSafeList(){ (list) in
                        let list = list
                        for index in list{
                            if(self.allRecipe.count<10){
                            self.databaseHandle = self.ref?.child("Recipe/"+String(index)).observe(.value, with: { (snapshot) in
                                let value = snapshot.value as? NSDictionary
                                let recipe_name = value?.value(forKey: "recipe_name") as! String
                                var image = UIImage(named: "Mask Group 7")
                                if(value?.value(forKey: "img") != nil){
                                    let name = value?.value(forKey: "img") as! String
                                    let imageURL = URL(string: name)
                                    let data = try? Data(contentsOf: imageURL!)
                                    image = UIImage(data: data!)
                                    if(!self.allRecipe.contains(recipe_name)){
                                        print(recipe_name+"3")
                                        print(self.allRecipe)
                                        self.AllImage.append(image!)
                                        self.allRecipe.append(recipe_name)
                                        self.collectionView.reloadData()
                                        self.collectionView .layoutIfNeeded()
                                    }
                                    }
                                })
                            }
                        }
                        }
                    }
                    if(self.allRecipe.count<10){
                        let mylist = self.mylist
                        for index in mylist{
                            if(self.allRecipe.count<10){
                            self.databaseHandle = self.ref?.child("Recipe/"+String(index)).observe(.value, with: { (snapshot) in
                                let value = snapshot.value as? NSDictionary
                                let recipe_name = value?.value(forKey: "recipe_name") as! String
                                var image = UIImage(named: "Mask Group 7")
                                if(value?.value(forKey: "img") != nil){
                                    let name = value?.value(forKey: "img") as! String
                                    let imageURL = URL(string: name)
                                    let data = try? Data(contentsOf: imageURL!)
                                    image = UIImage(data: data!)
                                    if(!self.allRecipe.contains(recipe_name)){
                                        print(recipe_name+"4")
                                        print(self.allRecipe)
                                        self.AllImage.append(image!)
                                        self.allRecipe.append(recipe_name)
                                        self.collectionView.reloadData()
                                        self.collectionView .layoutIfNeeded()
                                    }
                                    }
                                })
                            }
                        }
                    }
                }
            }
        }
    }
    
    func getSafeList(completionHandler:@escaping ([Int]) -> ()) {
            for name in SafeFood{
            self.databaseHandle = self.ref?.child("Ingredients/"+name).observe(.value, with: { (snapshot) in
            if(snapshot.exists()){
                self.mylist.append(contentsOf: snapshot.value as! [Int])
            }
            self.databaseHandle = self.ref?.child("Ingredients/"+name+"s").observe(.value, with: { (snapshot) in
            if(snapshot.exists()){
                self.mylist.append(contentsOf: snapshot.value as! [Int])
            }
            let mappedItems = self.mylist.map { ($0, 1) }
            var returned = [Int]()
            let counts = Dictionary(mappedItems, uniquingKeysWith: +)
                for key in counts.keys{
                    if(counts[key]! >= 2){
                        returned.append(key)
                        self.mylist = self.mylist.filter{$0 != key}
                    }
                }
            completionHandler(returned)
            })
            })
        }
    }

    func getAlmostList(completionHandler:@escaping ([Int]) -> ()) {
            for name in AlmostFood{
            self.databaseHandle = self.ref?.child("Ingredients/"+name).observe(.value, with: { (snapshot) in
            if(snapshot.exists()){
                self.mylist.append(contentsOf: snapshot.value as! [Int])
            }
            self.databaseHandle = self.ref?.child("Ingredients/"+name+"s").observe(.value, with: { (snapshot) in
            if(snapshot.exists()){
                self.mylist.append(contentsOf: snapshot.value as! [Int])
            }
            let mappedItems = self.mylist.map { ($0, 1) }
            var returned = [Int]()
            let counts = Dictionary(mappedItems, uniquingKeysWith: +)
                for key in counts.keys{
                    if(counts[key]! >= 2){
                        returned.append(key)
                        self.mylist = self.mylist.filter{$0 != key}
                    }
                }
            completionHandler(returned)
            })
            })
        }
    }
    
    func getEmergencyList(completionHandler:@escaping ([Int]) -> ()) {
            for name in EmergencyFood{
            self.databaseHandle = self.ref?.child("Ingredients/"+name).observe(.value, with: { (snapshot) in
            if(snapshot.exists()){
                self.mylist.append(contentsOf: snapshot.value as! [Int])
            }
            self.databaseHandle = self.ref?.child("Ingredients/"+name+"s").observe(.value, with: { (snapshot) in
            if(snapshot.exists()){
                self.mylist.append(contentsOf: snapshot.value as! [Int])
            }
            let mappedItems = self.mylist.map { ($0, 1) }
            var returned = [Int]()
            let counts = Dictionary(mappedItems, uniquingKeysWith: +)
                for key in counts.keys{
                    if(counts[key]! >= 2){
                        returned.append(key)
                        self.mylist = self.mylist.filter{$0 != key}
                    }
                }
            completionHandler(returned)
            })
            })
        }
    }
    
 
    func sortList(){
        for data in list{
            let expireSingle = data.1
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
                var index = 0
                while(index < self.allTuples.count && self.allTuples[index].1 < inday ){
                    index+=1
                }
                self.allTuples.insert((data.0, inday), at: index)
                if(inday < 0){
                    self.sortedfoodList.insert(data.0, at: index)
                    self.ExpiredFood.append(data.0)
                    self.no+=1
                    self.e+=1
                    self.a+=1
                }
                else if(inday <= 3){
                    self.sortedfoodList.insert(data.0, at: index)
                    self.EmergencyFood.append(data.0)
                    self.e+=1
                    self.a+=1
                }
                else if(inday <= 5){
                    self.sortedfoodList.insert(data.0, at: index)
                    self.AlmostFood.append(data.0)
                    self.a+=1
                }
                else{
                    self.sortedfoodList.insert(data.0, at: index)
                    self.SafeFood.append(data.0)
                }
            }
        }
    }

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return allRecipe.count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "cell", for: indexPath) as! CollectionViewCell
        
        let cellIndex = indexPath.item
        
        cell.imageView.image = AllImage[cellIndex]
        cell.imageView.translatesAutoresizingMaskIntoConstraints = true
        cell.imageView.contentMode = .scaleAspectFit
        cell.imageView.clipsToBounds = true
        cell.labelView.text = allRecipe[cellIndex]
        
        return cell
    }

    @IBAction func foodTapped(_ sender: Any) {
        let homepageFoodController = self.storyboard?.instantiateViewController(identifier: Constants.Storyboard.homepageFoodController) as? FoodViewController
               self.view.window?.rootViewController = homepageFoodController
               self.view.window?.makeKeyAndVisible()
    }
    
    
    
    @IBAction func choresTapped(_ sender: Any) {
        let choresController = self.storyboard?.instantiateViewController(identifier: "chores") as? ChoresViewController
        self.view.window?.rootViewController = choresController
        self.view.window?.makeKeyAndVisible()
    }
    
    
    @IBAction func profileTapped(_ sender: Any) {
        let profileController = storyboard?.instantiateViewController(identifier: Constants.Storyboard.profileController) as? ProfilePageViewController
        print(Constants.Storyboard.profileController)
        view.window?.rootViewController = profileController
        view.window?.makeKeyAndVisible()
    }
    
    
    
    
}

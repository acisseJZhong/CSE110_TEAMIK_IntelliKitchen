//
//  ChoresViewController.swift
//  homepage-Food Reminder
//
//  Created by Ricky Zhang on 5/7/20.
//  Copyright © 2020 Yilun Hao. All rights reserved.
//

import UIKit
import FirebaseDatabase
import FirebaseFirestore
import FirebaseAuth



class ChoresViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet weak var tableView: UITableView!
    
    var ref:DatabaseReference?
    var databaseHandle:DatabaseHandle?
    
    var allChores = [String]()
    var allTuples = [(String, Int)]()
    var notfinished = 0
    
    var allDays = [String]()
    var list = [(String, String)]()
    var sortedchoreList = [String]()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        tableView.delegate = self
        tableView.dataSource = self
        
        
        let db = Firestore.firestore()
        let currentUid = Auth.auth().currentUser!.uid
        db.collection("users").document(currentUid).collection("chores").getDocuments { (snapshot,error) in
            if(error != nil){
                print(error!)
            }else{
                for document in (snapshot!.documents){
                    let name = document.data()["choreName"] as! String
                    //self.foodList.append(name)
                    let date = document.data()["remindDate"] as! String
                    self.list.append((name,date))
                }
                self.sortList()
                self.tableView.reloadData()
            }
        }
    }
    
    
    func sortList(){
        for data in list{
            let remind = data.1
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "MM/dd/yyyy"
            dateFormatter.locale = Locale.init(identifier: "en_GB")
            if(remind != ""){
            let d = dateFormatter.date(from: remind)!
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
            //print(self.allTuples)
            if(inday < 0){
                self.allChores.insert("did not " + data.0 + " for ", at: index)
                self.allDays.insert(String(0-inday) + " days", at: index)
                self.notfinished+=1
            }
            else if(inday == 0){
                self.allChores.insert(data.0, at: index)
                self.allDays.insert("today", at: index)
            }
            else if(inday > 0){
                self.allChores.insert(data.0 + " in ", at: index)
                self.allDays.insert(String(inday) + " days", at: index)
            }
            }
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return allChores.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "ChoresCell") as! ChoresTableViewCell
        cell.textLabel?.text = allChores[indexPath.row]
        cell.textLabel?.font = UIFont(name: "Acumin Pro SemiCondensed", size: 15)
        cell.textLabel?.textColor = UIColor.darkGray
        if(indexPath.row < notfinished){
            cell.backgroundColor = UIColor(red: 250/255, green: 160/255, blue: 160/255, alpha: 1)
        }
        
        cell.labelView.text = allDays[indexPath.row]
        cell.labelView.font = UIFont(name: "Acumin Pro SemiCondensed", size: 15)
        cell.labelView.textColor = UIColor.darkGray
        return cell
    }
    

    @IBAction func foodTapped(_ sender: Any) {
        
        let homepageFoodController = self.storyboard?.instantiateViewController(identifier: Constants.Storyboard.homepageFoodController) as? FoodViewController
        self.view.window?.rootViewController = homepageFoodController
        self.view.window?.makeKeyAndVisible()
        
        
    }
    
    @IBAction func recipeTapped(_ sender: Any) {
        
        let recipeController = self.storyboard?.instantiateViewController(identifier: "recipe") as? RecipeViewController
        self.view.window?.rootViewController = recipeController
        self.view.window?.makeKeyAndVisible()
        
    }
    
    
    
    @IBAction func profileTapped(_ sender: Any) {
        let profileController = storyboard?.instantiateViewController(identifier: Constants.Storyboard.profileController) as? ProfilePageViewController
        print(Constants.Storyboard.profileController)
        view.window?.rootViewController = profileController
        view.window?.makeKeyAndVisible()
    }
    
    
    
}

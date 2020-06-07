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

class ChoresViewController: UIViewController {
    
    @IBOutlet weak var tableView: UITableView!
    
    var ref:DatabaseReference?
    var databaseHandle:DatabaseHandle?
    
//    var allChores = [String]()
//    var allTuples = [(String, Int)]()
//    var notfinished = 0
    var list = [Choreshomepage]()

    
//    var allDays = [String]()
//    var list = [(String, String)]()
//    var sortedchoreList = [String]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        tableView.delegate = self
        tableView.dataSource = self
        
        let db = Firestore.firestore()
        let currentUid = Auth.auth().currentUser!.uid
        db.collection("users").document(currentUid).collection("chores").getDocuments { (snapshot,error) in
            if (error != nil) {
                print(error!)
            } else {
                for document in (snapshot!.documents){
                    let name = document.data()["choreName"] as! String
                    //self.foodList.append(name)
                    let expireSingle = document.data()["remindDate"] as! String
                    let dateFormatter = DateFormatter()
                    dateFormatter.dateFormat = "MM/dd/yyyy"
                    dateFormatter.locale = Locale.init(identifier: "en_GB")
                    if(expireSingle != "") {
                        let d = dateFormatter.date(from: expireSingle)!
                        let today = Date()
                        let calendar = Calendar.current
                        // Replace the hour (time) of both dates with 00:00
                        let date1 = calendar.startOfDay(for: today)
                        let date2 = calendar.startOfDay(for: d)
                        let components = calendar.dateComponents([.day], from: date1, to: date2)
                        let inday = components.day!
                        var message = ""
                        var message2 = ""
                        if(inday < 0){
                            message = "Did not " + name + " for "
                            message2 = String(0-inday) + " days"
                        }
                        else if(inday == 0){
                            message = name
                            message2 = "today"
                        }
                        else if(inday > 0){
                            message = name + " in "
                            message2 = String(inday) + " days"
                        }
                        self.list.append(Choreshomepage(name: name,expiredate: inday, message: message, message2: message2))
                    }
                    self.list = self.list.sorted(by: { $0.expiredate < $1.expiredate })
                    self.tableView.reloadData()
                }
            }
        }
    }
}

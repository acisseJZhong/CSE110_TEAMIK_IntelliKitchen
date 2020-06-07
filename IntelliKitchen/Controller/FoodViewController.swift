//
//  FoodViewController.swift
//  homepage-Food Reminder
//
//  Created by Ricky Zhang on 4/29/20.
//  Copyright © 2020 Yilun Hao. All rights reserved.
//

import UIKit
import FirebaseAuth
import FirebaseDatabase
import FirebaseFirestore

class FoodViewController: UIViewController {
    
    @IBOutlet weak var tableView: UITableView!
    
    var ref : DatabaseReference?
    var databaseHandle : DatabaseHandle?
    
    var list = [Food]()

    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        tableView.delegate = self
        tableView.dataSource = self

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
                        self.list.append(Food(name: name,expiredate: inday))
                }
                self.list = self.list.sorted(by: { $0.expiredate < $1.expiredate })
                self.tableView.reloadData()
            }
        }
        }
    }
}


//
//  ViewController.swift
//  IntelliKitchen_Myfood
//
//  Created by D.WANG on 4/25/20.
//  Copyright © 2020 D.WANG. All rights reserved.
//

import UIKit
import Firebase
import FirebaseFirestore


class MyFoodViewController: UIViewController{
    
    
    @IBOutlet weak var foodListTable: UITableView!
    
    //var ref: DatabaseReference?
    var databaseHandle: DatabaseHandle?
    var foodName = [String]()
    var boughtDate = [String]()
    var expireDate = [String]()
    var foods = [Foods]()
    var editFoodName: UITextField?
    var editBoughtDate: UITextField?
    var editExpireDate: UITextField?
    var row: Int = 0
    let db = Firestore.firestore()
    var currentUid = Auth.auth().currentUser!.uid
    
    public var datePicker: UIDatePicker?
    public var datePicker2: UIDatePicker?
    //var contents = ""
    
    
    override func viewDidLoad() {
        db.collection("users").document(self.currentUid).collection("foods").getDocuments { (snapshot, error) in
            for document in snapshot!.documents{
                let data = document.data()
                let name = data["foodName"] as? String ?? ""
                let bDate = data["boughtDate"] as? String ?? ""
                let eDate = data["expireDate"] as? String ?? ""
                let newFood = Foods(foodName: name, boughtDate: bDate, expireDate: eDate)
                self.foods.append(newFood)
                //self.foodName.append(name)
                //self.boughtDate.append(bDate)
                //self.expireDate.append(eDate)
            }
            self.foodListTable.reloadData()
        }
        
        datePicker = UIDatePicker()
        datePicker2 = UIDatePicker()
        datePicker?.datePickerMode = .date
        datePicker2?.datePickerMode = .date
        datePicker?.addTarget(self, action: #selector(self.dateChanged(datePicker:)), for: .valueChanged)
        datePicker2?.addTarget(self, action: #selector(self.dateChanged2(datePicker2:)), for: .valueChanged)
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(MyFoodViewController.viewTapped(gestureRecognizer:)))
        
        view.addGestureRecognizer(tapGesture)
        
        super.viewDidLoad()
    }
    
    @objc func viewTapped(gestureRecognizer: UITapGestureRecognizer){
        view.endEditing(true)
    }
    
    @objc func dateChanged(datePicker: UIDatePicker) {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MM/dd/yyyy"
        if( NSDate.init().laterDate(datePicker.date) == datePicker.date){
            createAlert(title: "Oops", message: "Bought date can't be in the futue!")
            view.endEditing(true)
        } else {
            editBoughtDate?.text = dateFormatter.string(from: datePicker.date)
        }
    }
    
    @objc func dateChanged2(datePicker2: UIDatePicker) {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MM/dd/yyyy"
        if( NSDate.init().earlierDate(datePicker2.date) == datePicker2.date){
            createAlert(title: "Oops", message: "Your food has already expired!")
            view.endEditing(true)
        } else {
            editExpireDate?.text = dateFormatter.string(from: datePicker2.date)
        }
    }
    
    func createAlert(title:String, message:String){
        let alert = UIAlertController(title: title, message: message, preferredStyle: UIAlertController.Style.alert)
        alert.addAction(UIAlertAction(title: "OK", style: UIAlertAction.Style.default, handler: {(action) in alert.dismiss(animated: true, completion: nil)
        }))
        self.present(alert, animated: true, completion: nil)
        
    }
    
}


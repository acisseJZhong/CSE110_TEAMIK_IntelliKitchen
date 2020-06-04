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
    var foods = [String]()
    var editFoodName: UITextField?
    var editBoughtDate: UITextField?
    var editExpireDate: UITextField?
    var row: Int = 0
    let db = Firestore.firestore()
    var currentUid = Auth.auth().currentUser!.uid
    
    private var datePicker: UIDatePicker?
    private var datePicker2: UIDatePicker?
    //var contents = ""
    
    
    override func viewDidLoad() {
        //read data from database
        
        /*ref = Database.database().reference()
         databaseHandle = ref?.child("Food").observe(.childAdded, with: { (snapshot) in
         let value = snapshot.value as? NSDictionary
         self.foodName.append(value?.value(forKey: "FoodName") as! String)
         self.expireDate.append(value?.value(forKey: "ExpireDate") as? String ?? "")
         self.boughtDate.append(value?.value(forKey: "BoughtDate") as? String ?? "")
         })*/
        db.collection("users").document(self.currentUid).collection("foods").getDocuments { (snapshot, error) in
            for document in snapshot!.documents{
                let data = document.data()
                let name = data["foodName"] as? String ?? ""
                let bDate = data["boughtDate"] as? String ?? ""
                let eDate = data["expireDate"] as? String ?? ""
                self.foodName.append(name)
                self.boughtDate.append(bDate)
                self.expireDate.append(eDate)
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

extension MyFoodViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return foodName.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        /*let cell = UITableViewCell(style: UITableViewCell.CellStyle.default, reuseIdentifier: "cell") as! CustomTableViewCell*/
        let cell = foodListTable.dequeueReusableCell(withIdentifier: "cell") as! CustomTableViewCell
        /*foods.append(foodName[indexPath.row] + "          " + boughtDate[indexPath.row] + "          " + expireDate[indexPath.row])*/
        cell.foodLabel.adjustsFontSizeToFitWidth = true
        cell.bdLabel.adjustsFontSizeToFitWidth = true
        cell.edLabel.adjustsFontSizeToFitWidth = true
        cell.foodLabel.text = foodName[indexPath.row]
        cell.bdLabel.text = boughtDate[indexPath.row]
        cell.edLabel.text = expireDate[indexPath.row]
        cell.textLabel?.adjustsFontSizeToFitWidth = true
        return cell
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == UITableViewCell.EditingStyle.delete {
            db.collection("users").document(self.currentUid).collection("foods").document(foodName[indexPath.row]).delete()
            //self.foods.remove(at: indexPath.row)
            self.foodName.remove(at: indexPath.row)
            self.boughtDate.remove(at: indexPath.row)
            self.expireDate.remove(at: indexPath.row)
            self.foodListTable.reloadData()
            self.createAlert(title: "Delete success!", message: "Successfully delete the food!")
            //Delete data in database
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let alertController = UIAlertController(title: "Edit food", message: nil, preferredStyle: .alert)
        alertController.addTextField(configurationHandler: editFoodName)
        alertController.addTextField(configurationHandler: editBoughtDate)
        alertController.addTextField(configurationHandler: editExpireDate)
        row = indexPath.row
        
        let okAction = UIAlertAction(title: "Save", style: .default, handler: self.okHandler)
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        
        alertController.addAction(okAction)
        alertController.addAction(cancelAction)
        self.present(alertController, animated: true)
    }
    
    func editFoodName(textField: UITextField!) {
        editFoodName = textField
        editFoodName?.placeholder = "Name"
    }
    func editBoughtDate(textField: UITextField!) {
        editBoughtDate = textField
        editBoughtDate?.inputView = datePicker
        editBoughtDate?.placeholder = "Bought Date"
    }
    func editExpireDate(textField: UITextField!) {
        editExpireDate = textField
        editExpireDate?.inputView = datePicker2
        editExpireDate?.placeholder = "Expiration Date"
    }
    
    func okHandler(alert: UIAlertAction) {
        if(editExpireDate?.text == "" || editBoughtDate?.text == "" || editFoodName?.text == ""){
            print("error")
        } else {
            //deal with data change here
            db.collection("users").document(self.currentUid).collection("foods").document(foodName[row]).delete()
            db.collection("users").document(self.currentUid).collection("foods").document(editFoodName?.text ?? "").setData(["foodName":editFoodName?.text ?? "", "boughtDate":editBoughtDate?.text ?? "", "expireDate":editExpireDate?.text ?? ""])
            foodName.remove(at: row)
            boughtDate.remove(at: row)
            expireDate.remove(at: row)
            //foods.remove(at: row)
            foodName.append(editFoodName?.text ?? "")
            boughtDate.append(editBoughtDate?.text ?? "")
            expireDate.append(editExpireDate?.text ?? "")
            self.foodListTable.reloadData()
            
        }
    }
    
}

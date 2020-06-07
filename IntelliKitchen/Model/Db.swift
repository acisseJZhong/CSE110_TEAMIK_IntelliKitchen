//
//  Db.swift
//  IntelliKitchen
//
//  Created by sawsa on 6/6/20.
//  Copyright © 2020 Emily Xu. All rights reserved.
//

import Foundation
import UIKit
import FirebaseAuth
import UserNotifications
import FirebaseDatabase
import FirebaseFirestore
import FirebaseStorage

class Db {
    var db = Firestore.firestore()
    
    // Function from MyChoresViewController
    
    func loadMyChores(mcvc: MyChoresViewController) {
        let currentUid = Auth.auth().currentUser!.uid
        db.collection("users").document(currentUid).collection("chores").getDocuments { (snapshot, error) in
            for document in snapshot!.documents{
                let data = document.data()
                let name = data["choreName"] as? String ?? ""
                let ldDate = data["lastDone"] as? String ?? ""
                let freq = data["frequency"] as? String ?? ""
                let rDate = data["remindDate"] as? String ?? ""
                let rOrNot = data["remindOrNot"] as? Bool ?? false
                let chore = Chore(task: name, lastDone: ldDate, timePeriod: freq, remindDate: rDate, remindOrNot: rOrNot)
                mcvc.chores.append(chore)
            }
            mcvc.choresList.reloadData()
        }
    }
    
    func deleteChores (mcvc: MyChoresViewController, taskName: String, index: Int) {
        let currentUid = Auth.auth().currentUser!.uid
        let choreRef = self.db.collection("users").document(currentUid).collection("chores").document(taskName)
        choreRef.getDocument { (document, error) in
            if error == nil {
                if document != nil && document!.exists {
                    let documentData = document?.data()
                    let remindOrNot = documentData?["remindOrNot"] as! Bool
                    if remindOrNot{
                        let reminderID = documentData?["reminderID"] as! String
                        let center = UNUserNotificationCenter.current()
                        center.removePendingNotificationRequests(withIdentifiers: [reminderID])
                    }
                    self.db.collection("users").document(currentUid).collection("chores").document(taskName).delete()
                    mcvc.chores.remove(at: index)
                    mcvc.choresList.reloadData()
                }
            }
        }
    }
    
    func skipChores(mcvc: MyChoresViewController, taskName: String) {
        let currentUid = Auth.auth().currentUser!.uid
        let choreRef = self.db.collection("users").document(currentUid).collection("chores").document(taskName)
        choreRef.getDocument { (document, error) in
            if error == nil {
                if document != nil && document!.exists {
                    let documentData = document?.data()
                    let remindOrNot = documentData?["remindOrNot"] as! Bool
                    if remindOrNot{
                        let reminderID = documentData?["reminderID"] as! String
                        let center = UNUserNotificationCenter.current()
                        center.removePendingNotificationRequests(withIdentifiers: [reminderID])
                    }
                    let choreName = documentData?["choreName"] as! String
                    let lastDone = documentData?["lastDone"] as! String
                    let remindDate = documentData?["remindDate"] as! String
                    let frequency = documentData?["frequency"] as! String
                    let formatter = DateFormatter()
                    formatter.dateFormat = "MM/dd/yyyy"
                    let newRemindDate = mcvc.updateRemindDate(date: formatter.string(from: Date()), freq: frequency)
                    var newRequestID = ""
                    if remindOrNot{
                        newRequestID = self.pushNotification(chore: choreRef, choreName: choreName, frequency: frequency, lastDone: lastDone, remindDate: remindDate)
                    }
                    choreRef.setData(["choreName": choreName, "frequency": frequency, "lastDone": lastDone, "remindDate": newRemindDate, "remindOrNot": remindOrNot, "reminderID": newRequestID])
                    mcvc.choresList.reloadData()
                }
            }
        }
    }
    
    func remindChores(mcvc: MyChoresViewController, taskName: String) {
        let currentUid = Auth.auth().currentUser!.uid
        let choreRef = self.db.collection("users").document(currentUid).collection("chores").document(taskName)
        choreRef.getDocument { (document, error) in
            if error == nil {
                if document != nil && document!.exists {
                    let documentData = document?.data()
                    let choreName = documentData?["choreName"] as! String
                    let lastDone = documentData?["lastDone"] as! String
                    var remindDate = documentData?["remindDate"] as! String
                    let frequency = documentData?["frequency"] as! String
                    let date = Date()
                    let formatter = DateFormatter()
                    formatter.dateFormat = "MM/dd/yyyy"
                    let remindDateObj = formatter.date(from: remindDate)
                    let reChoose = remindDateObj ?? date < date // is true if remind date is in the past
                    if reChoose {
                        //1. Create the alert controller.
                        let alert = UIAlertController(title: "Your remind date has passed", message: "Please reselect your remind date", preferredStyle: .alert)
                        
                        //2. Add the text field. You can configure it however you need.
                        alert.addTextField { (textField) in
                            mcvc.doDatePicker()
                            textField.inputView = mcvc.datePicker
                            textField.text = formatter.string(from: mcvc.datePicker!.date)
                            mcvc.RemindRechooseTextF = textField
                            mcvc.datePicker?.addTarget(mcvc, action: #selector(mcvc.datePickerChanged), for: .valueChanged)
                        }
                        
                        // 3. Grab the value from the text field, and print it when the user clicks OK.
                        alert.addAction(UIAlertAction(title: "Confirm", style: .default, handler: { [weak alert] (_) in
                            let formatter = DateFormatter()
                            formatter.dateFormat = "MM/dd/yyyy"
                            mcvc.remindDate = formatter.string(from: mcvc.datePicker!.date)
                            
                            if mcvc.RemindRechoosePastDate {
                                mcvc.createAlert(title: "Remind failed", message: "You have to set the remind date to a future day")
                            } else {
                                self.pushNotification(chore: choreRef, choreName: choreName, frequency: frequency, lastDone: lastDone, remindDate: mcvc
                                    .remindDate)
                                mcvc.createAlert(title: "Remind success", message: "Remind date changed successfully!")
                            }
                        }))
                        // 4. Present the alert.
                        mcvc.present(alert, animated: true, completion: nil)
                        
                    } else {
                        remindDate = formatter.string(from: date)
                        self.pushNotification(chore: choreRef, choreName: choreName, frequency: frequency, lastDone: lastDone, remindDate: remindDate)
                        mcvc.createAlert(title: "Remind success!", message: "Successfully set the reminder")
                    }
                }
            }
        }
    }
    
    func finishChores(mcvc: MyChoresViewController, taskName: String, index: Int) {
        let currentUid = Auth.auth().currentUser!.uid
        var choreRef = self.db.collection("users").document(currentUid).collection("chores").document(taskName)
        choreRef.getDocument { (document, error) in
            if error == nil {
                if document != nil && document!.exists {
                    let documentData = document?.data()
                    let remindOrNot = documentData?["remindOrNot"] as! Bool
                    if remindOrNot{
                        let reminderID = documentData?["reminderID"] as! String
                        let center = UNUserNotificationCenter.current()
                        center.removePendingNotificationRequests(withIdentifiers: [reminderID])
                    }
                    
                    let dateFormatter = DateFormatter()
                    dateFormatter.dateFormat = "MM/dd/yyyy"
                    mcvc.remindDate = mcvc.updateRemindDate(date: dateFormatter.string(from: Date()), freq: mcvc
                        .chores[index].timePeriod)
                    let choreName = documentData?["choreName"] as! String
                    let lastDone = documentData?["lastDone"] as! String
                    let remindDate = documentData?["remindDate"] as! String
                    let frequency = documentData?["frequency"] as! String
                    let date = Date()
                    let formatter = DateFormatter()
                    formatter.dateFormat = "MM/dd/yyyy"
                    
                    mcvc.chores[index].lastDone = formatter.string(from: date)
                    
                    if remindOrNot {
                        let requestID = self.pushNotification(chore: choreRef, choreName: choreName, frequency: frequency, lastDone: lastDone, remindDate: remindDate)
                        self.db.collection("users").document(currentUid).collection("chores").document(taskName)
                            .setData(
                                ["choreName":mcvc.chores[index].task,
                                 "lastDone": mcvc.chores[index].lastDone,
                                 "frequency": mcvc.chores[index].timePeriod,
                                 "remindDate": mcvc.remindDate,
                                 "remindOrNot": mcvc.chores[index].remindOrNot,
                                 "reminderID": requestID])
                    } else {
                        self.db.collection("users").document(currentUid).collection("chores").document(taskName)
                            .setData(
                                ["choreName":mcvc.chores[index].task,
                                 "lastDone": mcvc.chores[index].lastDone,
                                 "frequency": mcvc.chores[index].timePeriod,
                                 "remindDate": mcvc.remindDate,
                                 "remindOrNot": mcvc.chores[index].remindOrNot])
                    }
                    mcvc.choresList.reloadData()
                }
            }
        }
    }
    
    func editDeleteChores (taskName: String) {
        let currentUid = Auth.auth().currentUser!.uid
        self.db.collection("users").document(currentUid).collection("chores").document(taskName).delete()
    }
    
    func editAddChores(mcvc: MyChoresViewController, remindDate: String) {
        let currentUid = Auth.auth().currentUser!.uid
        db.collection("users").document(currentUid).collection("chores").document(mcvc.editTaskName?.text ?? "").setData(["choreName": mcvc.editTaskName?.text ?? "", "lastDone": mcvc.editLastDoneDate?.text ?? "", "frequency": mcvc.editFrequency?.text ?? "", "remindDate":remindDate, "remindOrNot": false])
    }
    
    func pushNotification (chore:  DocumentReference, choreName: String, frequency:String, lastDone:String, remindDate:String) -> String {
            let choreRemindingDate = remindDate
            let year = Int(choreRemindingDate.split(separator: "/")[2])
            let day = Int(choreRemindingDate.split(separator: "/")[1])
            let month = Int(choreRemindingDate.split(separator: "/")[0])
            
            // Notification
            // Step 1: Ask for permission
            let center = UNUserNotificationCenter.current()
            
            center.requestAuthorization(options: [.alert, .sound]) { (granted, error) in
            }
            
            // Step 2: Create the notification content
            let content = UNMutableNotificationContent()
            content.title = "Chores Reminder from IntelliKitchen"
            content.body = "You have to do " + choreName + " on " + remindDate
            
            // Step 3: Create the notification trigger
            var dateComponents = DateComponents()
            dateComponents.year = year
            dateComponents.month = month
            dateComponents.day = day
            dateComponents.timeZone = TimeZone(abbreviation: "PST")
            dateComponents.hour = 15
            dateComponents.minute = 27
            
            let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: false)
            
            // Step 4: Create the request
            
            let uuidString = UUID().uuidString
            
            let request = UNNotificationRequest(identifier: uuidString, content: content, trigger: trigger)
            let requestID = request.identifier // Need to save to Firebase
            
            // Step 5: Register the request
            center.add(request) { (error) in
                // Check the error parameter and handle any errors
            }
            
            // update information in databse
            chore.setData(["choreName": choreName, "frequency": frequency, "lastDone": lastDone, "remindDate": remindDate, "remindOrNot": true, "reminderID": requestID])
            return requestID
        }
    
    
    // Function from AddFoodViewController
    func loadAddFood (afvc: AddFoodViewController) {
        let currentUid = Auth.auth().currentUser!.uid
        self.db.collection("users").document(currentUid).collection("foods").document(afvc.foodNameField.text ?? "")
            .setData(
                ["foodName": afvc.foodNameField.text ?? "",
                 "boughtDate": afvc.boughtDateField.text ?? "",
                 "expireDate": afvc.expirationDateField.text ?? ""])
    }
    
    // Function from MyFoodViewController
    func loadMyFood (mfvc: MyFoodViewController) {
        let currentUid = Auth.auth().currentUser!.uid
        self.db.collection("users").document(currentUid).collection("foods").getDocuments { (snapshot, error) in
            for document in snapshot!.documents{
                let data = document.data()
                let name = data["foodName"] as? String ?? ""
                let bDate = data["boughtDate"] as? String ?? ""
                let eDate = data["expireDate"] as? String ?? ""
                let newFood = Foods(foodName: name, boughtDate: bDate, expireDate: eDate)
                mfvc.foods.append(newFood)
            }
            mfvc.foodListTable.reloadData()
        }
    }
    
    func deleteFood(mfvc: MyFoodViewController, index: Int) {
        let currentUid = Auth.auth().currentUser!.uid
        self.db.collection("users").document(currentUid).collection("foods").document(mfvc.foods[index].foodName).delete()
    }
    
    func editFood(mfvc: MyFoodViewController, index: Int) {
        let currentUid = Auth.auth().currentUser!.uid
        db.collection("users").document(currentUid).collection("foods").document(mfvc.foodName[index]).delete()
        db.collection("users").document(currentUid).collection("foods").document(mfvc.editFoodName?.text ?? "").setData(["foodName":mfvc.editFoodName?.text ?? "", "boughtDate":mfvc.editBoughtDate?.text ?? "", "expireDate":mfvc.editExpireDate?.text ?? ""])
    }
    
    // Function from FoodViewController
    func loadFoodInfo (fvc: FoodViewController) {
        let currentUid = Auth.auth().currentUser!.uid
        self.db.collection("users").document(currentUid).collection("foods").getDocuments { (snapshot,error) in
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
                            fvc.list.append(Food(name: name,expiredate: inday))
                    }
                    fvc.list = fvc.list.sorted(by: { $0.expiredate < $1.expiredate })
                    fvc.tableView.reloadData()
                }
            }
        }
    }
    
    // Function from ChoresViewController
    func loadChoresInfo(cvc: ChoresViewController){
        
        let currentUid = Auth.auth().currentUser!.uid
        let db = Firestore.firestore()
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
                        cvc.list.append(Choreshomepage(name: name,expiredate: inday, message: message, message2: message2))
                    }
                    cvc.list = cvc.list.sorted(by: { $0.expiredate < $1.expiredate })
                    cvc.tableView.reloadData()
                }
            }
        }
    }

    
    // Function from ByIngredientController
    func getIngredients(bic:ByIngredientController) {
        let ingredientRef = Database.database().reference().child("Ingredients")
        ingredientRef.observeSingleEvent(of: .value) { (snapshot) in
            for child in snapshot.children {
                let snap = child as! DataSnapshot
                bic.allIngredient.append(snap.key)
                bic.ingredientTableView.reloadData()
            }
        }
    }
    
    // Function from ByNameController
    func getRecipeNames(bnc:ByNameController) {
        let nameRef = Database.database().reference().child("RecipeNameTOId")
        nameRef.observeSingleEvent(of: .value) { (snapshot) in
            for child in snapshot.children {
                let snap = child as! DataSnapshot
                bnc.recipeNameArray.append(snap.key)
                bnc.nameTableView.reloadData()
            }
        }
    }
    
    // Function from RecipeViewController
    
    // Function from MyChoresViewController
    
}


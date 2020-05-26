//
//  ProfilePageViewController.swift
//  IntellK_Profile_Page
//
//  Created by zhangjm on 5/19/20.
//  Copyright © 2020 zhangjm. All rights reserved.
//

import UIKit
import FirebaseAuth
import UserNotifications
import FirebaseDatabase
import FirebaseFirestore
import FirebaseStorage

class ProfilePageViewController: UIViewController, UINavigationControllerDelegate, UIImagePickerControllerDelegate  {
    
    @IBOutlet weak var myImageView: UIImageView!
    @IBOutlet weak var userName: UITextField!
    @IBOutlet weak var userEmail: UILabel!
    @IBOutlet weak var userPassword: UITextField!
    @IBOutlet weak var saveUsername: UIButton!
    
    @IBOutlet weak var tableView: UITableView!
    
    var favoriteRecipes:[FavoriteRecipe] = []
    
    var iconClick = false
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        loadUserInfo()
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        userName?.resignFirstResponder()
        userEmail?.resignFirstResponder()
        userPassword?.resignFirstResponder()
    }
    
    func loadUserInfo(){
        //let ref = Database.database().reference()
        //var favoriteIDList:[String] = []
        let db = Firestore.firestore()
        let currentUid = Auth.auth().currentUser!.uid
        db.collection("users").document(currentUid).getDocument { (document, error) in
            if error == nil {
                if document != nil && document!.exists {
                    let documentData = document?.data()
                    self.userName?.text = documentData?["username"] as? String
                    self.userEmail?.text = documentData?["email"] as? String
                    //favoriteIDList = documentData?["Favorite"] as! [String]
                    //self.favoriteRecipes = self.createArray(favoriteIDList)

                    
                } else {
                    print("Can read the document but the document might not exists")
                }
                
            } else {
                print("Something wrong reading the document")
            }
        }
    }
    
    func createArray(_ favoriteIDList: [String]) -> [FavoriteRecipe]{
        var temp: [FavoriteRecipe] = []
        
        //var favoriteIDList:[String] = ["5344","5345","5346"]
        print("1. about to retrieve favorite recipes")
        retrieveFR(favoriteIDList, completion: {searchedRecipes in
            self.favoriteRecipes = searchedRecipes
            self.tableView?.reloadData()
        })
                
        print("5. finish retrieve favorite recipes and about to return")
        
        return temp
    }
    
    func retrieveFR(_ favoriteIDList: [String], completion: @escaping (_ searchedRecipes: [FavoriteRecipe]) -> Void){
        print("2. Retrieving favorite recipes: ====")
        let ref = Database.database().reference()
        var temp: [FavoriteRecipe] = []

        for recipe in favoriteIDList{
            let currentRecipeString = "Recipe/" + recipe
            let recipeRef = ref.child(currentRecipeString)
            recipeRef.observe(.value, with: {snapshot in
                let snap = snapshot as! DataSnapshot
                if let dict = snap.value as? [String: Any]{
                    var currentImage = UIImage()
                    let imageUrl = URL(string: dict["img"] as! String)
                    let imageData = try! Data(contentsOf: imageUrl!)
                    currentImage = UIImage(data: imageData)!
                    var currentTitle = dict["recipe_name"] as! String
                    let tempFR = FavoriteRecipe(image: currentImage, title: currentTitle)
                    print("3. construct one tempFR")
                    temp.append(tempFR)
                    print("4. Finish append current tempFR to the list")
                }
                completion(temp)
            })
        }
    }
    
    

    
    
    
    @IBAction func showOrHidePassword(_ sender: Any) {
        
        let email = Auth.auth().currentUser?.email
        
        Auth.auth().sendPasswordReset(withEmail: email!) { (error) in
                if error == nil{
                    self.signoutTapped((Any).self)
                    print("an email has sent!")
                    let loginController = self.storyboard?.instantiateViewController(identifier: Constants.Storyboard.loginController) as? LoginController
                    self.view.window?.rootViewController = loginController
                    self.view.window?.makeKeyAndVisible()
                }
                else{
                    ///
                    print("error")
                }
            }
    }

        
    @IBAction func importImage(_ sender: Any) {
        //Given the user the opportunity to pick a picture.
        let image = UIImagePickerController()
        image.delegate = self
        image.sourceType = UIImagePickerController.SourceType.photoLibrary
        image.allowsEditing = false
        
        self.present(image, animated: true){
            //After it is complete.
        }
    }
    
    
    func uploadProfileImage(_ image:UIImage, completion: @escaping ((_ url:URL?)->())){
        guard let uid = Auth.auth().currentUser?.uid else {return}
        let storageRef = Storage.storage().reference().child("users/\(uid)")
        
        guard let imageData = image.jpegData(compressionQuality: 0.75) else {return}
        
        let metaData = StorageMetadata()
        metaData.contentType = "image/jpg"
        
        storageRef.putData(imageData, metadata: metaData) {metaData, error in
            if error == nil, metaData != nil {
                //if let url = storageRef.downloadURL(completion: (URL?, Error?) -> Void){
                    completion(nil)
                    
                } else {
                    completion(nil)
                }
                //success
        }
        
        
    }
    
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        if let image = info[UIImagePickerController.InfoKey.originalImage] as? UIImage{
            myImageView.image = image
            self.uploadProfileImage(image){(url) in
                
            }
        }
        else{
            //error message
        }
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func saveUsernameAction(_ sender: Any) {
        //Should we directly store this to the database and each time gain the data from the data base
        let db = Firestore.firestore()
        let currentUid = Auth.auth().currentUser!.uid
        let updateString = self.userName.text
        db.collection("users").document(currentUid).updateData(["username": updateString])
    }
    
    @IBAction func switchNotificationControl(_ sender: Any) {
        let center = UNUserNotificationCenter.current()
        center.requestAuthorization(options: [.alert, .sound]) { (granted, error) in }
        let content = UNMutableNotificationContent()
        let date = Date().addingTimeInterval(8)
        let dateComponents = Calendar.current.dateComponents([.year, .month, .day, .hour, .minute, .second], from: date)
        let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: false)
        
        if((sender as AnyObject).isOn == true){
            content.title = "I'm the notification"
            content.body = "Your food is about to expire!"
        }
        else{
            content.title = "I'm the notification"
            content.body = "you closed the notification!"
        }
        
        let uuidString = UUID().uuidString
        let request = UNNotificationRequest(identifier: uuidString, content: content, trigger: trigger)
        center.add(request) { (error) in }
    }
    
    

    
    @IBAction func signoutTapped(_ sender: Any) {
        
        let firebaseAuth = Auth.auth()
        do {
            try firebaseAuth.signOut()
        } catch let signOutError as NSError {
            print ("Error signing out: %@", signOutError)
        }
        let loginController = self.storyboard?.instantiateViewController(identifier: Constants.Storyboard.loginController) as? LoginController
        view.window?.rootViewController = loginController
        view.window?.makeKeyAndVisible()
          
    }
    
    
    
}

extension ProfilePageViewController : UITextFieldDelegate{
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        return true
    }
}

extension ProfilePageViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return favoriteRecipes.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let favoriteRecipe = favoriteRecipes[indexPath.row]
        let cell = tableView.dequeueReusableCell(withIdentifier: "FavoriteRecipeCell") as! FavoriteRecipeCell
        
        cell.setFavoriteRecipe(favoriteRecipe: favoriteRecipe)
        
        return cell
    }
    
    
    
    
    
    
    
    
    

    
    
}

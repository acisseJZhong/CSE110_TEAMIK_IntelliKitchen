//
//  ScrollViewController.swift
//  intellik
//
//  Created by 江南 on 5/5/20.
//  Copyright © 2020 江南. All rights reserved.
//

import UIKit
import Firebase
import Foundation
import FirebaseAuth


class ScrollViewController: UIViewController, UITextFieldDelegate {
    
    
    // add data
    // var allrecipes:[String] = []
    
    let db = Firestore.firestore()
    var currentUid: String = ""
    // varaibles for steps for the first recipe
    var passid = ""
    var mylist:[String] = []
    
    //favourite
    var favlist: [String] = []
    var favornot: Bool = false;
    
    var wholelist: String = "";
    @IBOutlet weak var stepsdisplay: UILabel!
    @IBOutlet weak var innerscroll: UIScrollView!
    //let rootRef = Database.database().reference().child("Recipe/"+passid+"/steps");
    
    //rating
    @IBOutlet weak var ratinglabel: UILabel!
    
    // title of the menu
    @IBOutlet weak var menutitle: UILabel!
    
    
    // ingredients container
    @IBOutlet weak var ingrescroll: UIScrollView!
    @IBOutlet weak var lefthalf: UILabel!
    @IBOutlet weak var righthalf: UILabel!
    var ingredientlist:[String] = [];
    var leftstring: String = "";
    var rightstring: String = "";
    
    
    // menu picture
    @IBOutlet weak var menupic: UIImageView!
    var imageurl:URL!;
    
    
    // test comments
    //var ref = Database.database().reference().child("commentstest1")
    var username:String = ""
    var commentlist: [[String]] = [[]];
    var commentcelllist: [Comment] = [];
    @IBOutlet weak var commentstableview: UITableView!
    var commentedlist: [String] = []
    var commentornot: Bool = false;
    
    @IBOutlet weak var submitdisplay: UIButton!
    
    // test ratings
    var ratingarray = [Double]()
    @IBOutlet weak var Comments: UITextField!
    
    @IBAction func clickRating(_ sender: Any) {
        performSegue(withIdentifier: "seguetest", sender: self)
    }
    //favourite button
    @IBOutlet weak var FavouriteButton: UIButton!
    //var isFavourite:Bool = false;
    
    //@IBOutlet weak var CommentsDisplay: UITextView!
    
    @IBAction func SubmitButton(_ sender: Any) {
        
        if (!self.commentornot){
            let new = Comment(image: UIImage(imageLiteralResourceName: "Ellipse1"), name: self.username, description: Comments.text!);
            var commentdb = Database.database().reference().child("Recipe/-M8IVR-st6dljGq6M4xN/"+passid+"/comments");
            commentcelllist.append(new)
            self.commentstableview.reloadData();
            commentlist.append([self.currentUid, Comments.text!]);
            commentdb.setValue(commentlist);
            
            
            commentedlist.append(passid)
            //db.collection("users").document(currentUid).updateData(["commentedlist" : self.commentedlist])
            db.collection("users").document(currentUid).collection("commentedlistCollection").document("commentedDocument").setData(["commentedlist": self.commentedlist])
            self.commentornot = true
            Comments.text = nil}
            // dismiss(animated: true, completion: nil)}
            
        else {
            //Comments.isEnabled = false
            let alert = UIAlertController(title: "Already commented", message: "You have already commented this recipe~", preferredStyle: UIAlertController.Style.alert)
            Comments.text = nil
            alert.addAction(UIAlertAction(title: "OK", style: UIAlertAction.Style.default, handler: nil))
            self.present(alert, animated: true, completion: nil)
            self.submitdisplay.isEnabled = false
            self.submitdisplay.setTitleColor(.gray, for: .normal)
        }
        
    }
    
    
    @IBAction func ClickFavouriteButton(_ sender: Any) {
        
        if(!favornot) {
            FavouriteButton.setImage(UIImage(named:"feather-heart"), for: .normal)
            self.favlist.append(passid)
            //db.collection("users").document(currentUid).updateData(["favRecipe" : self.favlist])
            db.collection("users").document(currentUid).collection("favoriteRecipe").document("favRecipeList").setData(["favRecipe": self.favlist])
            favornot = true
        }
        else{
            FavouriteButton.setImage(UIImage(named:"Ellipse 2"), for: .normal)
            let index = self.favlist.firstIndex(of: passid)
            self.favlist.remove(at: index!)
            //db.collection("users").document(currentUid).updateData(["favRecipe" : self.favlist])
            db.collection("users").document(currentUid).collection("favoriteRecipe").document("favRecipeList").setData(["favRecipe": self.favlist])
            favornot = false
        }
    }
    

    
    @IBAction func backbutton(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        var nextstage = segue.destination as! RatingViewController
        nextstage.passid = self.passid
        
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        Comments.delegate = self
        
        stepsdisplay.sizeToFit();
        let rootRef = Database.database().reference().child("Recipe/-M8IVR-st6dljGq6M4xN/"+passid+"/steps");
        let titledb = Database.database().reference().child("Recipe/-M8IVR-st6dljGq6M4xN/"+passid+"/recipe_name");
        let ingredientsdb = Database.database().reference().child("Recipe/-M8IVR-st6dljGq6M4xN/"+passid+"/ingredients");
        var imagedb = Database.database().reference().child("Recipe/-M8IVR-st6dljGq6M4xN/"+passid+"/img");
        var imagedbnew = Database.database().reference().child("Recipe/-M8IVR-st6dljGq6M4xN/"+passid+"/recipe_pic");
        print("new")
        print(imagedb)
        var ratingdb = Database.database().reference().child("Recipe/-M8IVR-st6dljGq6M4xN/"+passid+"/rating");
        var commentdb = Database.database().reference().child("Recipe/-M8IVR-st6dljGq6M4xN/"+passid+"/comments");
        //print(passid)
        
        self.currentUid = Auth.auth().currentUser!.uid
        //print("11111111111")
        print(currentUid)
        db.collection("users").document(currentUid).collection("favoriteRecipe").getDocuments { (snapshot, error) in
            for document in snapshot!.documents{
                let documentData = document.data()
                self.favlist = documentData["favRecipe"] as? [String] ?? []
                //print(self.favlist)
                if self.favlist.contains(self.passid){
                    self.favornot = true
                }
                if self.favornot{
                    self.FavouriteButton.setImage(UIImage(named:"feather-heart"), for: .normal)
                }
                else{
                    self.FavouriteButton.setImage(UIImage(named:"Ellipse 2"), for: .normal)
                }
            }
        }
        
        //get rating
        //print("hihihihihihihihihi")
        ratingdb.observeSingleEvent(of: .value) { (snapshot) in
            var ratingtuple = snapshot.value as! [Int];
            var avrating = Double(ratingtuple[0])/Double(ratingtuple[1])
            self.ratinglabel.text = String(format: "%.2f", avrating)
        }
        
        
        
        //grab steps from db
        rootRef.observe(.value, with: { snapshot in
            //print(snapshot)
            //print(type(of:snapshot));
            self.mylist = snapshot.value as! [String];
            //let max_cm = value?["0"] as? String;
            //print(self.mylist)
            let length = self.mylist.count;
            
            for i in 0...length-1{
                self.wholelist = self.wholelist + String(i+1) + ". " + self.mylist[i]+"\n\n";
                
            }
            //self.wholelist =
            //print(self.wholelist)
            self.stepsdisplay.text = self.wholelist;
            self.innerscroll.contentLayoutGuide.bottomAnchor.constraint(equalTo: self.stepsdisplay.bottomAnchor).isActive = true
            //print("successfully display!");
            
        })
        
        // grab menutitle
        titledb.observeSingleEvent(of: .value) { (snapshot) in
            self.menutitle.text = snapshot.value as! String;
            self.menutitle.text = (self.menutitle.text)?.capitalized;
            //print( NSStringFromClass(self.menutitle.text).capitalized)
        }
        
        // grab ingredients
        ingredientsdb.observe(.value) { (snapshot) in
            self.ingredientlist = snapshot.value as! [String];
            self.ingredientlist = (self.ingredientlist).removingDuplicates();
            let length2 = self.ingredientlist.count;
            for j in 0...length2-1{
                if (j%2 == 0) {
                    //var tempword = (self.ingredientlist[j]).capitalizingFirstLetter();
                    self.leftstring = self.leftstring + (self.ingredientlist[j]).capitalized + "\n";
                }
                else{
                    //var tempword2 = (self.ingredientlist[j]).capitalizingFirstLetter();
                    self.rightstring = self.rightstring + (self.ingredientlist[j]).capitalized + "\n";
                }
            }
            //print(self.leftstring)
            //print(self.rightstring)
            self.lefthalf.text = self.leftstring;
            self.righthalf.text = self.rightstring;
            self.ingrescroll.contentLayoutGuide.bottomAnchor.constraint(equalTo: self.lefthalf.bottomAnchor).isActive = true
            
        }
        
        // grab recipe photo
        imagedb.observeSingleEvent(of: .value) { (snapshot) in
            if(!(snapshot.value is NSNull)){
                self.imageurl = URL(string: snapshot.value as! String);
                print(self.imageurl!);
                self.menupic.load(url: self.imageurl);
                self.menupic.layer.cornerRadius = 10;
            }
            else{
                imagedbnew.observeSingleEvent(of: .value) { (snapshot) in
                    if(snapshot.value != nil){
                        self.imageurl = URL(string: snapshot.value as! String);
                        print(self.imageurl!);
                        self.menupic.load(url: self.imageurl);
                        self.menupic.layer.cornerRadius = 10;
                    }
                }
            }
        }
        
        // grab comments
        commentdb.observe(.value) { (snapshot) in
            print("yoyoyooyoyoyoyoyoyoy")
            //self.commentlist = snapshot.value as! NSArray;
            self.commentlist = snapshot.value as! [[String]] ;
            
            for eachstring in self.commentlist {
                var userid = eachstring[0]
                
                
                self.db.collection("users").document(userid).getDocument { (document, error) in
                    if error == nil {
                        if document != nil && document!.exists {
                            let documentData = document?.data()
                            self.username = documentData?["username"] as? String ?? ""
                            let tempcomment = Comment(image: UIImage(imageLiteralResourceName: "Ellipse1"), name: self.username, description: eachstring[1]);
                            self.commentcelllist.append(tempcomment);
                        } else {
                            print("Can read the document but the document might not exists")
                        }
                        
                    } else {
                        print("Something wrong reading the document")
                    }
                }
                
            }
            
            self.commentstableview.delegate = self
            self.commentstableview.dataSource = self
            //print(self.commentcelllist);
        }
        
        //get comments from cloudfirestore
        db.collection("users").document(currentUid).collection("commentedCollection").getDocuments { (snapshot, error) in
            for document in snapshot!.documents{
                let documentData = document.data()
                self.commentedlist = documentData["commentedlist"] as? [String] ?? []
                if self.commentedlist.contains(self.passid){
                    self.commentornot = true
                }
            }
        }
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        Comments?.resignFirstResponder()
        self.view.endEditing(true)

    }

}

extension UIImageView {
    func load(url: URL) {
        DispatchQueue.global().async { [weak self] in
            if let data = try? Data(contentsOf: url) {
                if let image = UIImage(data: data) {
                    DispatchQueue.main.async {
                        self?.image = image
                    }
                }
            }
        }
    }
}


extension ScrollViewController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        //print("I am inside extension")
        //print(commentcelllist.count)
        return commentcelllist.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let eachcomment = commentcelllist[indexPath.row]
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "CommentCell") as! CommentCell
        
        //cell.setRecipe(recipe: recipe)
        cell.setComments(comment: eachcomment)
        return cell
    }
}


extension String {
    func capitalizingFirstLetter() -> String {
        return prefix(1).capitalized + dropFirst()
    }
    
    mutating func capitalizeFirstLetter() {
        self = self.capitalizingFirstLetter()
    }
}

extension Array where Element: Hashable {
    func removingDuplicates() -> [Element] {
        var addedDict = [Element: Bool]()
        
        return filter {
            addedDict.updateValue(true, forKey: $0) == nil
        }
    }
    
    mutating func removeDuplicates() {
        self = self.removingDuplicates()
    }
}

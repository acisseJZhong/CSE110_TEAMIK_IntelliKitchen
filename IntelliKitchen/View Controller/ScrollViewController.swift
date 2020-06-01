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
    
    
    @IBOutlet weak var scrollview: UIScrollView!
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
        let storyboard = UIStoryboard(name: "Main", bundle:nil)
        let secondVC = storyboard.instantiateViewController(identifier: "Rating") as! RatingViewController
        secondVC.passid = self.passid
        self.present(secondVC, animated: true, completion: nil)

//        performSegue(withIdentifier: "seguetest", sender: self)
    }
    //favourite button
    @IBOutlet weak var FavouriteButton: UIButton!
    //var isFavourite:Bool = false;
    
    
    var tempname:[String] = []
    //@IBOutlet weak var CommentsDisplay: UITextView!
    
    @IBAction func SubmitButton(_ sender: Any) {
        
        if (!self.commentornot){
            print(commentcelllist.count)
//            let new = Comment(image: UIImage(imageLiteralResourceName: "Ellipse1"), name: self.username, description: Comments.text!);
            var commentdb = Database.database().reference().child("Recipe/-M8IVR-st6dljGq6M4xN/"+passid+"/comments");
            commentcelllist.removeAll()
            print(commentcelllist.count)
//            self.commentstableview.reloadData();
            
            commentlist.append([self.currentUid, Comments.text!]);
            commentdb.setValue(commentlist);
            commentedlist.append(passid)
            db.collection("users").document(currentUid).updateData(["commentedlist" : self.commentedlist])
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
        //self.Comments?.resignFirstResponder()
    }
    
    
    @IBAction func ClickFavouriteButton(_ sender: Any) {
        
        if(!favornot) {
            FavouriteButton.setImage(UIImage(named:"feather-heart"), for: .normal)
            self.favlist.append(passid)
            db.collection("users").document(currentUid).updateData(["favRecipe" : self.favlist])
            favornot = true
        }
        else{
            FavouriteButton.setImage(UIImage(named:"Ellipse 2"), for: .normal)
            let index = self.favlist.firstIndex(of: passid)
            self.favlist.remove(at: index!)
            db.collection("users").document(currentUid).updateData(["favRecipe" : self.favlist])
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
    
    
    // generate the commentlist that including all the comments
    func beforeforloop(completion: @escaping (_ temptemp: [[String]]) ->Void){
        var temptemp: [[String]] = [[""]]
        var commentdb = Database.database().reference().child("Recipe/-M8IVR-st6dljGq6M4xN/"+passid+"/comments");
        commentdb.observe(.value) { (snapshot) in
            //print("yoyoyooyoyoyoyoyoyoy")
            //self.commentlist = snapshot.value as! NSArray;
            temptemp = snapshot.value as! [[String]] ;
            //self.commentlist = snapshot.value as! [[String]] ;
            completion(temptemp)
        }
    }
    
    
    func generateuserpic(_ currentid: String, completion: @escaping (_ picarray: Data ) -> Void){
        //print(temptemp)
        //self.commentlist = temptemp
        self.generateusername(currentid, completion: { namearray in
            //print(namearray)
            var picarray: Data?
            var lala: String = ""
            self.tempname.append(namearray)
            
            let storageRef = Storage.storage().reference().child("users/\(currentid)")
            storageRef.getData(maxSize: 1*65536*655366) { (data, error) in
                print("converting to string")
                //                if let error = error {
                //                    print(error.localizedDescription)
                //                }
                //else{
                if (data == nil) {
                    print("hihi")
                    picarray = try! Data(contentsOf: URL(string:"https://revleap.com/wp-content/themes/revleap/images/no-profile-image.jpg")!)
                    print(picarray)
                }
                else{
                    picarray = data
                }
                completion(picarray!)
            }
            
        })
        
    }
    
    func generateusername(_ currentid: String, completion: @escaping (_ namearray: (String) ) -> Void){
        
        var namearray:String = ""
        self.db.collection("users").document(currentid).getDocument { (document, error) in
            if error == nil {
                if document != nil && document!.exists {
                    let documentData = document?.data()
                    namearray = documentData?["username"] as? String ?? ""
                    
                } else {
                    print("Can read the document but the document might not exists")
                }
                
            } else {
                print("Something wrong reading the document")
            }
            completion(namearray)
        }
    }
    
    
    func forloop(){
        beforeforloop (completion: {temptemp in
            self.commentlist = temptemp
            var count = 0
            for eachstring in self.commentlist {
             let currentid = eachstring[0]
                print(currentid)
                self.generateuserpic(currentid, completion: { namepic in
                    print(namepic)
                    print("temptemptemptemptemp")
                    print(self.tempname)
                    print(self.tempname.last)
                    let tempcomment = Comment(image: UIImage(data: namepic)!, name: self.tempname[count] ?? "", description: eachstring[1]);
                    count = count + 1
//                    tempcommentcelllist.append(tempcomment)
                    self.commentcelllist.append(tempcomment)
                    if self.commentcelllist.count == 0{
                        self.commentstableview.isHidden = true
                    } else {
                        self.commentstableview.isHidden = false
                        self.commentstableview.reloadData()
                    }
                })
            }

        })
    }
   
    
    override func viewWillAppear(_ animated: Bool) {
        print("akjdfldsjfls")
        var ratingdb = Database.database().reference().child("Recipe/-M8IVR-st6dljGq6M4xN/"+passid+"/rating");
        ratingdb.observeSingleEvent(of: .value) { (snapshot) in
                   var ratingtuple = snapshot.value as! [Int];
                   var avrating = Double(ratingtuple[0])/Double(ratingtuple[1])
                   self.ratinglabel.text = "Average Rating: " + String(format: "%.1f", avrating) + "     " + String(ratingtuple[1]) + " have rated"
                    print(ratingtuple)
               }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        print("loaddded view did load")
        Comments.delegate = self
        self.commentstableview.delegate = self
        self.commentstableview.dataSource = self
        stepsdisplay.sizeToFit();
        
        let recognizer = UITapGestureRecognizer(target: self, action: #selector(self.touch))
               recognizer.numberOfTapsRequired = 1
               recognizer.numberOfTouchesRequired = 1
        self.scrollview.addGestureRecognizer(recognizer)
                 
        let rootRef = Database.database().reference().child("Recipe/-M8IVR-st6dljGq6M4xN/"+passid+"/steps");
        let titledb = Database.database().reference().child("Recipe/-M8IVR-st6dljGq6M4xN/"+passid+"/recipe_name");
        let ingredientsdb = Database.database().reference().child("Recipe/-M8IVR-st6dljGq6M4xN/"+passid+"/ingredients");
        var imagedb = Database.database().reference().child("Recipe/-M8IVR-st6dljGq6M4xN/"+passid+"/img");
        var imagedbnew = Database.database().reference().child("Recipe/-M8IVR-st6dljGq6M4xN/"+passid+"/recipe_pic");
        print("new")
        print(imagedb)
        var ratingdb = Database.database().reference().child("Recipe/-M8IVR-st6dljGq6M4xN/"+passid+"/rating");
        
        //print(passid)
        
        self.currentUid = Auth.auth().currentUser!.uid
        //print("11111111111")
        print(currentUid)
        db.collection("users").document(currentUid).getDocument { (document, error) in
            if error == nil {
                if document != nil && document!.exists {
                    let documentData = document?.data()
                    self.favlist = documentData?["favRecipe"] as? [String] ?? []
                    //print(self.favlist)
                    if self.favlist .contains(self.passid){
                        self.favornot = true
                    }
                    if self.favornot{
                        self.FavouriteButton.setImage(UIImage(named:"feather-heart"), for: .normal)
                    }
                    else{
                        self.FavouriteButton.setImage(UIImage(named:"Ellipse 2"), for: .normal)
                    }
                } else {
                    print("Can read the document but the document might not exists")
                }
                
            } else {
                print("Something wrong reading the document")
            }
        }
        
        //get rating
        //print("hihihihihihihihihi")
        ratingdb.observeSingleEvent(of: .value) { (snapshot) in
            var ratingtuple = snapshot.value as! [Int];
            var avrating = Double(ratingtuple[0])/Double(ratingtuple[1])
            self.ratinglabel.text = "Average Rating: " + String(format: "%.1f", avrating) + "     " + String(ratingtuple[1]) + " have rated"
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
        
        forloop();

        //get comments from cloudfirestore
        db.collection("users").document(currentUid).getDocument { (document, error) in
            if error == nil {
                if document != nil && document!.exists {
                    let documentData = document?.data()
                    self.commentedlist = documentData?["commentedlist"] as? [String] ?? []
                    if self.commentedlist.contains(self.passid){
                        self.commentornot = true
                    }
                } else {
                    print("Can read the document but the document might not exists")
                }
                
            } else {
                print("Something wrong reading the document")
            }
        }
        
    }
    
}

extension ScrollViewController {
@objc func touch() {
    self.Comments.endEditing(true)
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
        print("cccccccccccount")
        print(commentcelllist.count)
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

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
    var ref = Database.database().reference().child("commentstest1")
    var commentlist: [String] = [];
    var commentcelllist: [Comment] = [];
    @IBOutlet weak var commentstableview: UITableView!
    
    // test ratings
    var ratingarray = [Double]()
    @IBOutlet weak var Comments: UITextField!
    
    //favourite button
    @IBOutlet weak var FavouriteButton: UIButton!
    //var isFavourite:Bool = false;
    
    //@IBOutlet weak var CommentsDisplay: UITextView!
    
    @IBAction func SubmitButton(_ sender: Any) {
        
        //CommentsDisplay.text = Comments.text!
        //ref.setValue(Comments.text)
        let new = Comment(image: UIImage(imageLiteralResourceName: "Ellipse1"), name: "Jiangnan", description: Comments.text!);
        commentcelllist.append(new)
        self.commentstableview.reloadData();
        commentlist.append(Comments.text!);
        ref.setValue(commentlist);
        Comments.text = nil
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
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        Comments.resignFirstResponder()
    }
    
    @IBAction func backbutton(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        Comments.delegate = self
        
        stepsdisplay.sizeToFit();
        let rootRef = Database.database().reference().child("Recipe/"+passid+"/steps");
        let titledb = Database.database().reference().child("Recipe/"+passid+"/recipe_name");
        let ingredientsdb = Database.database().reference().child("Recipe/"+passid+"/ingredients");
        var imagedb = Database.database().reference().child("Recipe/"+passid+"/img");
        print(passid)
        
        
        //load favornot
        self.currentUid = Auth.auth().currentUser!.uid
        //print("11111111111")
        print(currentUid)
        db.collection("users").document(currentUid).getDocument { (document, error) in
             if error == nil {
                 if document != nil && document!.exists {
                     let documentData = document?.data()
                     self.favlist = documentData?["favRecipe"] as? [String] ?? []
                     print(self.favlist)
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
        
        
        
        //grab steps from db
        rootRef.observe(.value, with: { snapshot in
            print(snapshot)
            //print(type(of:snapshot));
            self.mylist = snapshot.value as! [String];
            //let max_cm = value?["0"] as? String;
            print(self.mylist)
            let length = self.mylist.count;
            
            for i in 0...length-1{
                self.wholelist = self.wholelist + String(i+1) + ". " + self.mylist[i]+"\n\n";
                
            }
            //self.wholelist =
            //print(self.wholelist)
            self.stepsdisplay.text = self.wholelist;
            self.innerscroll.contentLayoutGuide.bottomAnchor.constraint(equalTo: self.stepsdisplay.bottomAnchor).isActive = true
            print("successfully display!");

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
            self.imageurl = URL(string: snapshot.value as! String);
            print(self.imageurl);
            self.menupic.load(url: self.imageurl);
            self.menupic.layer.cornerRadius = 10;
        }
        
        // grab comments
        ref.observe(.value) { (snapshot) in
            self.commentlist = snapshot.value as! [String];
            print(self.commentlist);
            for eachstring in self.commentlist {
                let tempcomment = Comment(image: UIImage(imageLiteralResourceName: "Ellipse1"), name: "David", description: eachstring);
                self.commentcelllist.append(tempcomment);}
            self.commentstableview.delegate = self
            self.commentstableview.dataSource = self
            print(self.commentcelllist);
        }
        
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

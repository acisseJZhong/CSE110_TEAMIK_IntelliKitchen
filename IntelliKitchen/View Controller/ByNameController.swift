//
//  ByNameController.swift
//  IntelliKitchen
//
//  Created by sawsa on 5/7/20.
//  Copyright © 2020 jigsaw. All rights reserved.
//

import UIKit
import Firebase

class ByNameController: UIViewController {
    
    @IBOutlet weak var nameSearchBar: UISearchBar!
    @IBOutlet weak var nameTableView: UITableView!
    @IBOutlet weak var searchButton: UIButton!
    @IBOutlet weak var searchByName: UIButton!
    @IBOutlet weak var searchByIngredient: UIButton!
    
    var searchArray: [String] = []
    let lightGreen = UIColor(red: 146.0/255.0, green: 170.0/255.0, blue: 68.0/255.0, alpha: 1.0)
    let darkGreen = UIColor(red: 87.0/255.0, green: 132.0/255.0, blue: 56.0/255.0, alpha: 0.8)
    
    var recipeNameArray: [String] = []
    var searchRecipe = [String]()
    var searching = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        searchByName.titleLabel?.textAlignment = .center
        searchByIngredient.titleLabel?.textAlignment = .center
        searchButton.layer.cornerRadius = 5
        searchButton.backgroundColor = darkGreen
        searchButton.tintColor = .white
        nameTableView.backgroundColor = lightGreen
        nameTableView.layer.cornerRadius = 20
        getRecipeNames()
    }
    
    func getRecipeNames() {
        let nameRef = Database.database().reference().child("RecipeNameTOId")
        nameRef.observeSingleEvent(of: .value) { (snapshot) in
            for child in snapshot.children {
                let snap = child as! DataSnapshot
                self.recipeNameArray.append(snap.key)
                self.nameTableView.reloadData()
            }
        }
    }
    
    @IBAction func search(_ sender: Any) {
        if nameSearchBar.text == "" {
            let alert = UIAlertController(title: "No entry!", message: "Please add some text before searching", preferredStyle: UIAlertController.Style.alert)
            alert.addAction(UIAlertAction(title: "OK", style: UIAlertAction.Style.default, handler: nil))
            self.present(alert, animated: true, completion: nil)
        } else {
            if searching {
                searchArray = searchRecipe
                searchArray.insert(nameSearchBar.text!, at: 0)
            } else {
                searchArray = []
                searchArray.append(nameSearchBar.text!)
                searchArray.append(nameSearchBar.text!)
            }
            performSegue(withIdentifier: "searchResult", sender: self)
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "searchResult" {
            let vc = segue.destination as! RecipeListScreen
            vc.searchArray = self.searchArray
            vc.searchByName = true
        }
    }
}

extension ByNameController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if searching {
            return searchRecipe.count
        } else {
            return recipeNameArray.count
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell")
        if searching {
            cell?.textLabel?.text = searchRecipe[indexPath.row]
        } else {
            cell?.textLabel?.text = recipeNameArray[indexPath.row]
        }
        cell?.backgroundColor = lightGreen
        cell?.textLabel?.textColor = .white
        cell?.tintColor = .white
        return cell!
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let index = indexPath.row
        if searching {
            nameSearchBar.text = searchRecipe[index]
        } else {
            nameSearchBar.text = recipeNameArray[index]
        }
        //        searching = false
        nameTableView.reloadData()
    }
}



extension ByNameController: UISearchBarDelegate {
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        if searching {
            searchArray = searchRecipe
            searchArray.insert(nameSearchBar.text!, at: 0)
        } else {
            searchArray = []
            searchArray.append(nameSearchBar.text!)
            searchArray.append(nameSearchBar.text!)
        }
        performSegue(withIdentifier: "searchResult", sender: self)
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        if (searchText == "") {
            searching = false
            nameTableView.reloadData()
            return
        }
        searchRecipe = recipeNameArray.filter({$0.localizedCaseInsensitiveContains(searchText)})
        searching = true
        nameTableView.reloadData()
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.nameSearchBar?.resignFirstResponder()
        self.nameTableView?.resignFirstResponder()
    }
}

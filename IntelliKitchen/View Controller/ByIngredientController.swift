//
//  ByIngredientController.swift
//  IntelliKitchen
//
//  Created by sawsa on 5/7/20.
//  Copyright © 2020 jigsaw. All rights reserved.
//

import UIKit
import Firebase


class ByIngredientController: UIViewController {

    @IBOutlet weak var ingredientSearchBar: UISearchBar!
    @IBOutlet weak var ingredientTableView: UITableView!
    @IBOutlet weak var searchButton: UIButton!
    @IBOutlet weak var clearButton: UIButton!
    @IBOutlet weak var searchByName: UIButton!
    @IBOutlet weak var searchByIngredient: UIButton!
    
    let lightGreen = UIColor(red: 146.0/255.0, green: 170.0/255.0, blue: 68.0/255.0, alpha: 0.9)
    let darkGreen = UIColor(red: 87.0/255.0, green: 132.0/255.0, blue: 56.0/255.0, alpha: 0.8)
    
    var allIngredient: [String] = []
    var selectedIngredient: [String] = []

    var searchAllIngredient = [String]()
    var searchSelectedIngredient = [String]()

    var searching = false
        
    override func viewDidLoad() {
        super.viewDidLoad()
        getIngredients()
        searchByName.titleLabel?.textAlignment = .center
        searchByIngredient.titleLabel?.textAlignment = .center

        searchButton.layer.cornerRadius = 5
        searchButton.backgroundColor = darkGreen
        searchButton.tintColor = .white
        clearButton.layer.cornerRadius = 5
        clearButton.backgroundColor = darkGreen
        clearButton.tintColor = .white
        ingredientTableView.layer.cornerRadius = 20
    }
    
    func getIngredients() {
        let ingredientRef = Database.database().reference().child("Ingredients")
        ingredientRef.observeSingleEvent(of: .value) { (snapshot) in
            for child in snapshot.children {
                let snap = child as! DataSnapshot
                self.allIngredient.append(snap.key)
                self.ingredientTableView.reloadData()
            }
        }
    }

    @IBAction func search(_ sender: Any) {
        if selectedIngredient.count == 0 {
            let alert = UIAlertController(title: "No ingredients!", message: "Please add ingredients before searching", preferredStyle: UIAlertController.Style.alert)
            alert.addAction(UIAlertAction(title: "OK", style: UIAlertAction.Style.default, handler: nil))
            self.present(alert, animated: true, completion: nil)
        } else {
            print("searched")
            performSegue(withIdentifier: "searchResult", sender: self)
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "searchResult" {
            let vc = segue.destination as! RecipeListScreen
            vc.searchArray = self.selectedIngredient
            vc.searchByName = false
        }
    }
    
    @IBAction func clearAll(_ sender: Any) {
        for item in selectedIngredient {
            allIngredient.append(item)
        }
        selectedIngredient = []
        allIngredient.sort()
        searching = false
        ingredientSearchBar.text = ""
        ingredientTableView.reloadData()
    }
}



extension ByIngredientController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if searching {
            return searchAllIngredient.count + searchSelectedIngredient.count
        } else {
            return allIngredient.count + selectedIngredient.count
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell")
        let index = indexPath.row
        if searching {
            if index < searchSelectedIngredient.count {
                cell?.textLabel?.text = searchSelectedIngredient[index]
                cell?.accessoryType = UITableViewCell.AccessoryType.checkmark
            } else {
                cell?.textLabel?.text = searchAllIngredient[index - searchSelectedIngredient.count]
                cell?.accessoryType = UITableViewCell.AccessoryType.none
            }
        } else {
            if index < selectedIngredient.count {
                cell?.textLabel?.text = selectedIngredient[index]
                cell?.accessoryType = UITableViewCell.AccessoryType.checkmark
            } else {
                cell?.textLabel?.text = allIngredient[index - selectedIngredient.count]
                cell?.accessoryType = UITableViewCell.AccessoryType.none
            }
            
        }
        cell?.backgroundColor = lightGreen
        cell?.textLabel?.textColor = .white
        cell?.tintColor = .white
        return cell!
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if (selectedIngredient.count >= 20) {
            let alert = UIAlertController(title: "Too many ingredients!", message: "Please remove ingredients before adding", preferredStyle: UIAlertController.Style.alert)
            alert.addAction(UIAlertAction(title: "OK", style: UIAlertAction.Style.default, handler: nil))
            self.present(alert, animated: true, completion: nil)
        } else {
            let index = indexPath.row
            let cell = tableView.cellForRow(at: indexPath)
            let label = (cell?.textLabel?.text)!
            if searching {
                if index < searchSelectedIngredient.count {
                    selectedIngredient = selectedIngredient.filter { $0 != label }
                    allIngredient.append(label)
                    allIngredient.sort()
                } else {
                    selectedIngredient.append(label)
                    selectedIngredient.sort()
                    allIngredient = allIngredient.filter { $0 != label }
                }
                searching = false
                ingredientSearchBar.text = ""
            } else {
                if index < selectedIngredient.count {
                    selectedIngredient = selectedIngredient.filter { $0 != label }
                    allIngredient.append(label)
                    allIngredient.sort()
                } else {
                    selectedIngredient.append(label)
                    selectedIngredient.sort()
                    allIngredient = allIngredient.filter { $0 != label }
                }
            }
            ingredientTableView.reloadData()
        }
    }
}



extension ByIngredientController: UISearchBarDelegate {
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        if (searchText == "") {
            searching = false
            ingredientTableView.reloadData()
            return
        }
        searchAllIngredient = allIngredient.filter({$0.localizedCaseInsensitiveContains(searchText)})
        searchSelectedIngredient = selectedIngredient.filter({$0.localizedCaseInsensitiveContains(searchText)})
        searching = true
        ingredientTableView.reloadData()
    }
}

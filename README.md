# IntelliKitchen 

![IK logo](https://github.com/acisseJZhong/CSE110_TEAMIK_IntelliKitchen/blob/master/logo.png)
| Contributor                                                   | Role                      |
| ---                                                           | ---                       |
| [Jessica Zhong](https://github.com/acisseJZhong)              | Project Manager           |
| [Yilun Hao](https://github.com/ylh301)                        | Senior System Analyst     |
| [Duolan Ouyang](https://github.com/duouyang)                  | User Interface Specialist |
| [Jiangnan Xu](https://github.com/jn1118)                      | Database Specialist       |
| [Qiao Rong](https://github.com/QRrong)                        | Business Analyst          |
| [David Cheung](https://github.com/sawsa307)                   | Software Development Lead |
| [Dawei Wang](https://github.com/wdwei9717)                    | Algorithm Specialist      |
| [Jialu Xu](https://github.com/machaeese)                      | Quality Assurance Lead    |
| [Jiaming Zhang](https://github.com/FanTasZZhang)              | Software Architect        |
| [Kaixun Zhang](https://github.com/Lucas610)                   | Algorithm Specialist      |

### Introduction
As busy students who focus on studying, we always forget to use our food in the fridge and lead to waste, which is very environmentally unfriendly. Sometimes we also forget to do the chores, 
such as cleaning the house and washing the dishes. Therefore, we develop IntelliKitchen, a convenient, simple, and effective mobile application that can lead you to an easier and more relaxing life. It can keep track of expiration dates of the food in your fridge, generates recipes based on food expiration dates, and assists your chores by sending notifications based on your chores plan. With the above functionalities, our users can have a clear overview of their fridges and manage their food properly to minimize potential food wastes.


### Sign in Credentials
For testing purposes, we have created an outlook account and a Gmail account to adapt to two different sign in options. Please see the provided sign in credentials below.

Email: intellikitchen@outlook.com</br>
Password: cse110gogary!

Email: intellikitchentest001@gmail.com</br>
Password: cse110gogary!


### Requirements
This application must be run on an iOS platform. 
The User must have an Internet connection while using the application. 
Minimum Specs: 
        - iPhone 11 
        - iOS version 13.4 or above
        - Xcode version 11.4 or above

### Installation Instructions
1. Download the app from GitHub. 
2. Open the terminal, go to the directory and execute `pod install`(if it doesn't work out, first run `sudo gem install cocoapods`). 


### How to Run on the Simulator
1. Use a MacBook to open Xcode, and run the file "IntelliKitchen.xcworkspace" inside the directory. 
2. Select the "IntelliKitchen" scheme if it's not the current scheme. 
3. Select the iPhone version(we only support iPhone 11) you want to test on. 
4. Click on the "Run" button. 
5. When you finish building the project, and the simulator pops up, you can start testing.

### How to Run on the iPhone 11
1. Use a MacBook to open Xcode, and run the file "IntelliKitchen.xcworkspace" inside the directory. 
2. Select the "IntelliKitchen" scheme if it's not the current scheme. 
3. Select the iPhone version(in this case will be your own iPhone 11) you want to test on. 
4. On the left side, click on the icon “IntelliKitchen” on the top left corner.
5. On the main page, click on the “Signing & Capabilities” on the top bar.
6. Choose your own team in the “Team” setting.
7. Change “com.xu.IntelliKitchen” to something else, for example “com.xxx.IntelliKichen”.
8. Click on the “Try Again” button in the status.
9. Click on the "Run" button. 
10. When you finish building the project, and the simulator pops up, you can start testing.

### Software Desgin (MVC)
In this project, we incorporate MVC(Model View Controller) architecture to ensure the code is maintainable and readable. We mainly distribute our code into three folders: Model, View, and Controller. 
- Model is folder includes the database access file and objects in our project. 
- View represents the UI layout of our App, i.e. how we present data to the users. 
- Controllers are used to connect View and Model.

### Code samples
This is an example of a Recipe Model, which is a simple struct to hold all the properties of Recipe.
```
class Recipe {
    var image: UIImage
    var title: String
    var rating: String
    
    init(image: UIImage, title: String, rating: String) {
        self.image = image
        self.title = title
        self.rating = rating
    }
}
```
This is an example of RecipeCell View in which we set up the visualization of a recipe cell. When we load all TableView cells using the following function.
```
func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let recipe = recipes[indexPath.row]
        let cell = tableView.dequeueReusableCell(withIdentifier: "RecipeCell") as! RecipeCell
        cell.setRecipe(recipe: recipe)
        return cell
    }

The setRecipe() method will take a Recipe struct and unwrap its information and set up each cell’s visualization on the user interface.
    
    func setRecipe(recipe:Recipe) {
        recipeImage.image = recipe.image
        recipeTitle.text = recipe.title
        recipeRating.text = "Average Rating: \(recipe.rating)"
    }
```

The following is an example of Controller. The code is from ByNameController.swift, where it defines the searching activity initiated by the user. The event handler will take the user’s searching keyword(s) and perform queries in the database for all matching results.
```
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
```

### Known bugs
1. 
- Expected behavior: After the user signs in with Google, the app shall redirect the user to the home page without displaying any alert.

- Actual behavior: Before the app redirects the user to the profile page, it may display the error “Please fill in all fields.” on the home page for a few seconds. It may also sometimes have less than a second delay on the sign in page before the app redirects the users to the profile page.

2. 
- Expected behavior: In my chores list, if the user first turns on the remind function by clicking the “Remind” button, and then chooses to finish the chore, and the user will receive the notifications for later repeating tasks. 

- Actual behavior: In my chores list, if the user first turns on the remind function by clicking the “Remind” button, and then chooses to finish the chore, and the user will no longer receive the notifications for later repeating tasks. 

3. 
- Expected behavior: When the user clicks on “View My Favorites”, and comments under the recipes from this list, and then goes back to the view my favorite list, it will double the amount of the recipes that was previously commented.

- Actual behavior: When the user clicks on “View My Favorites”, and comments under the recipes from this list, and then goes back to the view my favorite list, the number of recipes on this favorite list should remain the same. 

4. 
- Expected behavior: After the user rates a recipe and clicks on the “Submit” button, the pop-up window shall disappear, and both the average rating and the number of people rated on the recipe detail page should automatically be updated. 

- Actual behavior: After the user rates a recipe and clicks on the “Submit” button, the pop-up window shall disappear, and both the average rating and the number of people rated on the recipe detail page will not be updated. Both of the data will be updated when we re-enter this page.

5. 
- Expected behavior: When the user clicks on a recipe that has a very long recipe title,  the user is able to see both the recipe title, the recipe rating, and the recipe image separately.

- Actual behavior: When the user clicks on a recipe that has a very long recipe title, the 
recipe title may overflow and cover the recipe rating or/and the recipe image.

6. 
- Expected behavior: When the user clicks into the recipe to see the details, the recipe name and the recipe details should match.

- Actual behavior: When the user clicks into the recipe to see the details, the recipe name 
and the recipe details don't match for a few certain recipes. (It’s because our database store the wrong information)

7. 
- Sometimes when the user clicks on a certain recipe, the whole app freezes and has a runtime exception. In this case, please re-run the whole app. 

### Notes
After the user enters the recipe name/ingredients they want to search and click the “search” button, a recipe list will pop up. There might be repetitive recipe pictures. However, even if they have the same recipe picture shown, the recipes are actually different. They have either different ingredients or different instructions.

### Contacts for Technical Support
| Name                                                          | Contact                   |
| ---                                                           | ---                       |
| Jiaming Zhang - Software Architect                            | (858)263-5398             |
| Jessica Zhong - Project Manager                               | (858)900-5337             |
| David Cheung - Software Development Lead                      | (415)269-4604             |

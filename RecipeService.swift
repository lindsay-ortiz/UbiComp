//
//  RecipeService.swift
//  RecipeBox
//
//  Created by Team2 on 10/22/18.
//  Copyright © 2018 Team2. All rights reserved.
//

import Firebase
import FirebaseStorage
import Foundation
import UIKit
import FirebaseDatabase
import Promises

struct item {
    var Title = ""
}

struct KeyAndName {
    var Key: String = ""
    var Name: String = ""
}

struct MyError: Error {
    var desc: String
}
extension MyError: LocalizedError {
    private var errorDescription: String {
        return desc
    }
}

class RecipeService {
    //----functions Chris is using in RecipeBoxViewController.swift
    public static var favoriteIDs = ["8RVht4prdYu8dunyNbqe", "ChPWA7sL4P9YDkUgmsmh", "EtymfR2fmckc4qGz37KP"]
    public static var customRecipeIDs = ["FGncsbL33teiadUv3LBC", "jY8Z7jG6Tzq4JGhYrxLX"]
    public static var shoppingList2 = [String]()//"X3XpFCTyS6rCWBMGeFGY", "99nM3BqRzgSUnpMvUvbx", "mEfzNsK5Yi83u3AqApmb"]
    
    static var rowHeight: CGFloat = 200
    
//    private static var favoriteIDs = [String]()
//    private static var customRecipeIDs = [String]()
    
    private static let database = Database.database().reference()
    private static let databaseA = database.child("DatabaseA")
    
    static func initialize() {
        UserDefaults.standard.set(RecipeService.favoriteIDs, forKey: "favorites")
        UserDefaults.standard.set(RecipeService.customRecipeIDs, forKey: "custom")
        UserDefaults.standard.set(RecipeService.shoppingList2, forKey: "shoppingList2")
    }
    
    static func getFavoriteIDs() -> [String] {
        return UserDefaults.standard.object(forKey: "favorites") as! [String]
    }
    
    static func getCartIDs() -> [String] {
        return UserDefaults.standard.object(forKey: "shoppingList2") as! [String]
    }
    
    static func addIDToFavorites(input: String) {
        var currentIDs = getFavoriteIDs()
        currentIDs.append(input)
        UserDefaults.standard.set(currentIDs, forKey: "favorites")
        //print(favoriteIDs)
    }
    
    static func addIDToCart(input: String) {
        var currentIDs = getCartIDs()
        currentIDs.append(input)
        RecipeService.shoppingList2 = currentIDs
        //UserDefaults.standard.set(currentIDs, forKey: "shoppingList2")
        initialize()
    }
    
    static func addIDToCustomRecipes(input: String) {
        var currentIDs = getFavoriteIDs()
        currentIDs.append(input)
        UserDefaults.standard.set(currentIDs, forKey: "custom")
        //print(favoriteIDs)
    }
    
    static func getCustomRecipeIDs() -> [String] {
        return UserDefaults.standard.object(forKey: "custom") as! [String]
    }
    
    
    
    static func final_removeDuplicates<T: Hashable>(array: [T]) -> [T] {
        let set = Set<T>(array)
        return Array(set)
    }
    
    static func final_removeDuplicates<T: Hashable>(array1: [T], array2: [T]) -> [T] {
        let set1 = Set<T>(array1)
        let set2 = Set<T>(array2)
        return Array(set1.union(set2))
    }
    
    //Usage example provided below.
    static func final_getRecipe(for ID: String) -> Promise<Recipe2> {
        return Promise<Recipe2>(on: .global()) {fulfill, reject in
            let title = try await(final_getTitle(for: ID))
            let ingredients = try await(final_getIngredients(for: ID))
            let procedure = try await(final_getProcedure(for: ID))
            let filters = try await(final_getFilters(for: ID))
            let tempRatingData = try await(final_getRating(for: ID))
            let rating = (tempRatingData["Rating"] as! NSNumber).floatValue
            let numRatings = tempRatingData["NumberOfRatings"] as! Int

            let recipe = Recipe2(ID: ID, title: title, ingredients: ingredients, procedure: procedure, rating: rating, numRatings: numRatings, filters: filters, relevance: 0)
//            print(title)
            fulfill(recipe)
        }
    }
    
    //  *Inside viewcontroller*
    //
    //    var displayArray = [Recipe2]()
    //    func display(IDs: [String]){
    //        let IDsWithoutDuplicates = RecipeService.final_removeDuplicates(array: IDs)
    //        for ID in IDsWithoutDuplicates {
    //            RecipeService.final_getRecipe(for: ID).then { recipe in
    //                self.displayArray.append(recipe)
    //                self.tableView.reloadData()
    //                }.catch {error in
    //                    print(error)
    //            }
    //        }
    //    }
    
    //This function might be slower than using final_getRecipe and getting and displaying the results one recipe at a time.
    static func final_getRecipes(for IDs: [String]) -> Promise<[Recipe2]> {
        return Promise<[Recipe2]> { fulfill, reject in
            all(IDs.map {final_getRecipe(for: $0)}).then { result in
                if(result.isEmpty){
                    reject(MyError(desc: "final_getRecipes didn't get a match and failed"))
                } else {
                    fulfill(result)
                }
                }.catch { error in
                    print("final_getRecipes failed due to an invalid recipeID or conversion: \(error)")
            }
        }
    }
    
    static func updateRating(id: String, rating: Float, numberOfRatings: Int) {
        databaseA.child("Ratings").child(id).child("NumberOfRatings").setValue(numberOfRatings)
        databaseA.child("Ratings").child(id).child("Rating").setValue(rating)
    }
    
    static func getRecipeImages(ID: String, assignImageData: @escaping ((UIImage) -> Void)) {
        let storage = Storage.storage().reference().child("Images")
        let fileName = ID + ".jpg"
        let imgRef = storage.child(fileName)
        var image = UIImage()
        
        DispatchQueue.main.async {
            imgRef.getData(maxSize: 1 * 2048 * 2048) { data, error in
                if let error = error {
                    print(error)
                } else {
                    // Data for "images/recipeID.png" is returned
                    image = UIImage(data: data!)!
                    assignImageData(image)
                }
            }
        }
    }
    
    //Usage example is inside RecipeBoxViewController.swift
    static func final_filterRecipesBySearchKeywords(textFieldText: String, recipesToFilter: [Recipe2]) -> Promise<[Recipe2]>{
        return Promise<[Recipe2]> { fulfill, reject in
            for recipe in recipesToFilter {
                recipe.relevance = 0
            }
            let searchKeywords: [String] = textFieldText.components(separatedBy: " ").map{$0.capitalized}
            var searchResults = Set<Recipe2>()
            let group = DispatchGroup()
            for _ in searchKeywords {
                group.enter()
            }
            print("searchKeywords: ")
            print(searchKeywords)
            for keyword in searchKeywords {
                RecipeService.getFirebaseData(path: "SearchKeywords/\(keyword)", receiveData: {(dataArray, error) in
                    if(!error){
                        print("dataArray: ")
                        print(dataArray)
                        for data in dataArray {
                            for recipe in recipesToFilter {
                                if (data.key == recipe.ID) {
                                    
                                    recipe.relevance += 1
                                    searchResults.insert(recipe)
                                    print(searchResults)
                                    break
                                }
                            }
                        }
                    }
                    group.leave()
                })
            }
            group.notify(queue: .main) {
                let sortedSearchResults = Array(searchResults).sorted()
                fulfill(sortedSearchResults)
            }
        }
    }
    
    static func final_getIDsByFilters(selectedFilters: [String]) -> Promise<[String]>{
        return Promise<[String]> { fulfill, reject in
            
            var searchResults = Set<String>()
            let group = DispatchGroup()
            for _ in selectedFilters {
                group.enter()
            }
            for keyword in selectedFilters {
                RecipeService.getFirebaseData(path: "Filters/\(keyword)", receiveData: {(dataArray, error) in
                    if(!error){
                        for data in dataArray {
                            print("getIDsByFilters: \(data)")
                            searchResults.insert(data.key)
                        }
                    }
                    group.leave()
                })
            }
            group.notify(queue: .main) {
                //let sortedSearchResults = Array(searchResults).sorted()
                fulfill(Array(searchResults))
            }
        }
    }
    
    static func final_getIDsBySearchKeywords(textFieldText: String) -> Promise<[String]>{
        return Promise<[String]> { fulfill, reject in
            let searchKeywords: [String] = textFieldText.components(separatedBy: " ").map{$0.capitalized}
            var searchResults = Set<String>()
            let group = DispatchGroup()
            for _ in searchKeywords {
                group.enter()
            }
            for keyword in searchKeywords {
                RecipeService.getFirebaseData(path: "SearchKeywords/\(keyword)", receiveData: {(dataArray, error) in
                    if(!error){
                        for data in dataArray {
                            searchResults.insert(data.key)
                        }
                    }
                    group.leave()
                })
            }
            group.notify(queue: .main) {
                //let sortedSearchResults = Array(searchResults).sorted()
                fulfill(Array(searchResults))
            }
        }
    }
    
    static func getFirebaseData(path: String, receiveData: @escaping typeDictStrAny) {
        databaseA.child(path).observeSingleEvent(of: .value, with: {downloadedSnapshot in
            if let dataAsDictionary = downloadedSnapshot.value as? [String : Any] {
                receiveData(dataAsDictionary, false)
            } else {
                print(downloadedSnapshot.value as Any)
                print("No values found or found values couldn't be converted to [String:Any] at path \(path).")
                receiveData(["Error" : "Error"], true)
            }
        })
    }
    
    //----Start of private final functions.
    //These are used in the get recipe(s) functions. If you'd like to use these instead of getting a full recipe at once, then please remove the private label.
    private static func final_getTitle(for ID: String) -> Promise<String> {
        return Promise<String> { fulfill, reject in
            databaseA.child("Titles").child(ID).observeSingleEvent(of: .value, with: {downloadedSnapshot in
                print(downloadedSnapshot)
                if let title = downloadedSnapshot.value as? String {
                    fulfill(title)
                } else {
                    reject(MyError(desc: "final_getTitle failed"))
                }
            })
        }
    }
    
    private static func final_getIngredients(for ID: String) -> Promise<[String : String]> {
        return Promise<[String : String]> { fulfill, reject in
            databaseA.child("Details").child(ID).child("Ingredients").observeSingleEvent(of: .value, with: {downloadedSnapshot in
                if let ingredients = downloadedSnapshot.value as? [String : String] {
                    fulfill(ingredients)
                } else {
                    reject(MyError(desc: "final_getIngredients failed"))
                }
            })
        }
    }
    
    private static func final_getProcedure(for ID: String) -> Promise<String> {
        return Promise<String> { fulfill, reject in
            databaseA.child("Details").child(ID).child("Procedure").observeSingleEvent(of: .value, with: {downloadedSnapshot in
                if let procedure = downloadedSnapshot.value as? String {
                    fulfill(procedure)
                } else {
                    reject(MyError(desc: "final_getProcedure failed"))
                }
            })
        }
    }
    
    private static func final_getFilters(for ID: String) -> Promise<[String]> {
        return Promise<[String]> { fulfill, reject in
            databaseA.child("Filters").observeSingleEvent(of: .value, with: {downloadedSnapshot in
                print("Downloaded snapshot is: ")
                print(downloadedSnapshot)
                if let filterData = downloadedSnapshot.value as? [String : [String : Bool]] {
                    var results = [String]()
                    for filter in filterData {
                        for kvp in filter.value {
                            if(kvp.key == ID){
                                results.append(filter.key)
                                break
                            }
                        }
                    }
                    if(results.isEmpty){
                        reject(MyError(desc: "final_getFilters failed1"))
                    } else {
                        fulfill(results)
                    }
                } else {
                    reject(MyError(desc: "final_getFilters failed2"))
                }
            })
        }
    }
    
    private static func final_getRating(for ID: String) -> Promise<[String : Any]> {
        return Promise<[String : Any]> { fulfill, reject in
            databaseA.child("Ratings").child(ID).observeSingleEvent(of: .value, with: {downloadedSnapshot in
                if let ratingData = downloadedSnapshot.value as? [String : Any] {
                    fulfill(ratingData)
                } else {
                    print(downloadedSnapshot.value!)
                    reject(MyError(desc: "final_getRating failed"))
                }
            })
        }
    }
    
    //----These are not currently used anywhere. Remove the private label and use them if needed.
    private static func final_getAllTitles() -> Promise<[String]>{
        return Promise<[String]> { fulfill, reject in
            databaseA.child("Titles").observeSingleEvent(of: .value, with: {downloadedSnapshot in
                if let dataAsDictionary = downloadedSnapshot.value as? [String : Any] {
                    if let titles = Array(dataAsDictionary.values) as? [String]{
                        fulfill(titles)
                    } else {
                        reject(MyError(desc: "final_getAllTitles failed"))
                    }
                } else {
                    reject(MyError(desc: "final_getAllTitles failed"))
                }
            })
        }
    }
    
    public static func final_getAllIDs() -> Promise<[String]>{
        return Promise<[String]> { fulfill, reject in
            databaseA.child("Titles").observeSingleEvent(of: .value, with: {downloadedSnapshot in
                if let dataAsDictionary = downloadedSnapshot.value as? [String : Any] {
                    let IDs = Array(dataAsDictionary.keys)
                    fulfill(IDs)
                } else {
                    reject(MyError(desc: "final_getAllIDs failed"))
                }
            })
        }
    }
    
    private static func final_getTitles(for IDs: [String]) -> Promise<[String]> {
        return Promise<[String]> { fulfill, reject in
            all(IDs.map {final_getTitle(for: $0)}).then { result in
                if (!result.isEmpty){
                    fulfill(result)
                } else {
                    reject(MyError(desc: "final_getTitles failed"))
                }
            }
        }
    }
    //----end

    
    
    
    
    
//    private static var favoriteIDs = [String]()
//    private static var customRecipeIDs = [String]()
    
    typealias typeDictStringInt = ([String: Int]) -> Void
    typealias typeDictStringString = ([String: String]) -> Void
    
    typealias typeDictStrAny = ([String: Any], Bool) -> Void
    typealias typeAnyAny = (Any, Any) -> Void

    static func getFirebaseData(path: String, IDs: [String], receiveData: @escaping typeAnyAny) {
        for ID in IDs {
            databaseA.child(path).child(ID).observeSingleEvent(of: .value, with: {downloadedSnapshot in
                if let value = downloadedSnapshot.value {
                    receiveData(ID, value)
                } else {
                    print(downloadedSnapshot.value as Any)
                    print("\(ID) at path \(path) was not found in Firebase Database.")
                }
            })
        }
    }
    //List of IDs and titles
    //Given list of IDs, get a list of SearchKeywords for all the IDs
    //
    //Need to create a function where, given a list of keywords, search firebase once per keyword and see if
    static func search_SearchKeywords(textFieldText: String, receiveData: @escaping typeDictStringInt) {
        let searchKeywords: [String] = textFieldText.components(separatedBy: " ").map{$0.capitalized}
        var IDsAndFrequency = [String : Int]()
        let group = DispatchGroup()
        for keyword in searchKeywords {
            group.enter()
            RecipeService.getFirebaseData(path: "SearchKeywords/\(keyword)", receiveData: {(IDs, error) in
                if(!error){
                    for ID in IDs {
                        //print("ID: \(ID)")
                        if(IDsAndFrequency[ID.key] != nil){
                            IDsAndFrequency[ID.key] = Int(IDsAndFrequency[ID.key]! + 1)
                        } else {
                            IDsAndFrequency[ID.key] = 1
                        }
                    }
                }
                group.leave()
            })
        }
        group.notify(queue: .main) {
            receiveData(IDsAndFrequency)
        }
    }
 
    static func showToast(message: String, view: UIView) {
        let toastLabel = UILabel(frame: CGRect(x: view.frame.size.width/2 - 125, y: view.frame.size.height-100, width: 250, height: 35))
        toastLabel.backgroundColor = UIColor.purple
        toastLabel.textColor = UIColor.white
        toastLabel.textAlignment = .center
        toastLabel.font = UIFont(name: "Montserrat-Light", size: 12.0)
        toastLabel.text = message
        toastLabel.alpha = 1.0
        toastLabel.layer.cornerRadius = 10
        toastLabel.clipsToBounds = true
        view.addSubview(toastLabel)
        UIView.animate(withDuration: 4.0, delay: 0.1, options: .curveEaseOut, animations: {
            toastLabel.alpha = 0.0
        }, completion: {(isCompleted) in
            toastLabel.removeFromSuperview()
        })
    }
    
    static func search_Filters(selectedFilters: [String], receiveData: @escaping typeDictStringInt) {
        let filters: [String] = selectedFilters.map{$0.capitalized}
        var IDsAndFrequency = [String : Int]()
        let group = DispatchGroup()
        for keyword in filters {
            group.enter()
            RecipeService.getFirebaseData(path: "Filters/\(keyword)", receiveData: {(IDs, error) in
                if(!error){
                    for ID in IDs {
                        //print("ID: \(ID)")
                        if(IDsAndFrequency[ID.key] != nil){
                            IDsAndFrequency[ID.key] = Int(IDsAndFrequency[ID.key]! + 1)
                        } else {
                            IDsAndFrequency[ID.key] = 1
                        }
                    }
                }
                group.leave()
            })
        }
        group.notify(queue: .main) {
            receiveData(IDsAndFrequency)
        }
    }
    
    static func GetWithIngredients(searchIngredients: [String], callback: @escaping (([String:String]) -> Void)) {
        let ingredients: [String] = searchIngredients.map{$0.capitalized}
        var dictionary : [String:String] = [:]
        var keySet : Set<String> = []
        let group = DispatchGroup()
        
        for ingredient in ingredients {
            group.enter()
            RecipeService.getFirebaseData(path: "Ingredients/\(ingredient)", receiveData: {(IDs, error) in
                if(!error)
                {
                    if(keySet.count == 0) {
                        for ID in IDs {
                            keySet.insert(ID.key)
                        }
                    } else {
                        var otherKeySet : Set<String> = []
                        for ID in IDs {
                            if(keySet.contains(ID.key)) {
                                otherKeySet.insert(ID.key)
                            }
                        }
                        keySet = otherKeySet
                    }
                }
                else
                {
                    print("ingredient not foundho")
                }
                group.leave()
            })
        }
        
        group.notify(queue: .main) {
            databaseA.child("Titles").observeSingleEvent(of: .value, with: { snapshot in
                for child in snapshot.children.allObjects as! [DataSnapshot] {
                    if(keySet.contains(child.key))
                    {
                        dictionary[child.key] = child.value as? String
                    }
                }
                
                callback(dictionary)
            })
        }
    }
    
    //First try. Doesn't work too well
    //Also, this pulls data from the database one line at a time. Which actually might be better, but is more complicated to use in programming.
    static func getAllRecipeIDs() -> [String] {
        var recipeIDs = [String]()
        database.child("Recipies").observe(.childAdded, with: { (snapshot) in
            recipeIDs.append(snapshot.key)
            print(recipeIDs)
        })
        return recipeIDs
    }
    
    //Second try. Was able to get the database into a single snapshot in a single pull.
    private static let database2 = Database.database().reference(withPath: "Recipies")
    
    static func getAllDatabaseInfoVersion2() {
        database2.observeSingleEvent(of: .value, with: {snapshot in
            print(snapshot.value!)
        })
    }
    
    static func GetWithIngredienty(searchIngredient: String) -> [KeyAndName] {
        var resultsList : [KeyAndName] = []
        database2.observeSingleEvent(of: .value, with: { snapshot in
            for child in snapshot.children.allObjects as![DataSnapshot]{
                let recObj = child.value as? [String: AnyObject]
                print(recObj!["Title"]!)
                let ingredients = recObj!["Ingredients"] as! NSDictionary
                let keys = ingredients.allKeys as! [String]
                if keys.map({ (Ingredient) -> String in
                    return Ingredient.lowercased()
                }).contains(searchIngredient.lowercased())
                {
                    var newElement : KeyAndName = KeyAndName()
                    newElement.Key = child.key
                    newElement.Name = recObj!["Title"] as! String 
                    resultsList.append(newElement)
                }
                
            }
        })
        return resultsList
    }
    
    static func GetWithTitley(searchTitle: String) -> [KeyAndName] {
        var resultsList : [KeyAndName] = []
        database2.observeSingleEvent(of: .value, with: { snapshot in
            for child in snapshot.children.allObjects as![DataSnapshot]{
                let recObj = child.value as? [String: AnyObject]

                let title = recObj!["Title"] as! String
                if title.lowercased().contains(searchTitle.lowercased())
                {
                    var newElement : KeyAndName = KeyAndName()
                    newElement.Key = child.key
                    newElement.Name = recObj!["Title"] as! String
                    resultsList.append(newElement)
                }
                
            }
            print(resultsList)
        })
        return resultsList
    }
    
    //11-13 EXAMPLE 1: Retrieve and print data
    static let databaseATitles = databaseA.child("Titles")
    
    static func printAllTitles() {
        databaseATitles.observeSingleEvent(of: .value, with: {dataSnapshot in
            print(dataSnapshot)
            let snapshotValue = dataSnapshot.value as! [String:AnyObject]
            
            print("Print Keys:")
            for child in snapshotValue {
                print(child.key)
            }
            
            print("Print Values:")
            for child in snapshotValue {
                print(child.value)
            }
        })
    }
    
    //11-13 EXAMPLE 2 for creating a custom parsing function given a snapshot
    //init(snapshot: FDataSnapshot) {
    
    //let snapshotValue = snapshot.value as! [String:AnyObject]
    
    //code = snapshotValue["code"] as! String
    //data = snapshotValue["data"] as! String
    //engines = snapshotValue["engines"] as! String
    //}
    //----End of new Firebase database functionality
    
    
    //Firebase is up so let's switch this over to Firebase or delete - Chris 11/6
    static var recipesList =
        [Recipe(Id: 003, Title: "Southwest Shrimp Alfredo",
               Ingredients:
                    [Ingredient(Name: "Shrimp", Measurement: "lbs."): 1,
                    Ingredient(Name: "Coastal blend seasoning", Measurement: "tsp."): 2,
                    Ingredient(Name: "Heavy whipping cream", Measurement: "oz."): 8,
                    Ingredient(Name: "Cream cheese", Measurement: "tbsp."): 2,
                    Ingredient(Name: "Butter", Measurement: "tbsp."): 2,
                    Ingredient(Name: "Italian cheese blend", Measurement: "oz."): 6,
                    Ingredient(Name: "Penne pasta", Measurement: "oz."): 6],
               Procedure:
                    "1. Cook pasta according to directions.\n\n" +
                    "2. Add Coastal blend seasoning to shrimp in a bag and shake until shrimp is fully coated. \n\n" +
                    "3. Cook Shrimp in medium sauce pan on medium-high heat for 5-10 minutes until fully cooked. Remove from pan and keep warm.\n\n" +
                    "4. Add whipping cream and cream cheese to pan.  Cook on medium-low heat for about 5 minutes until cream cheese has melted into whipping cream.\n\n" +
                    "5. Reduce heat to low and slowly add Italian cheese blend into pan.  Stir until all cheese is melted into the sauce.\n\n" +
                    "6. Serve shrimp and sauce on pasta.",
               Filters: ["Non-Vegetarian", "Dinner", "Southwest", "Shrimp"],
               Rating: 0,
               NumberOfRatings: 0)]
    
    //Firebase is up so let's switch this over to Firebase or delete - Chris 11/6
    //I think the shopping cart can stay local on the device.  Any reasons why this should not be? - Lindsay 11/13
    static var shoppingList = [Recipe]()
    
    //Firebase is up so let's switch this over to Firebase or delete - Chris 11/6
    static var myRecipeBox = [Recipe]()
    
    //Firebase is up so let's switch this over to Firebase or delete - Chris 11/6
    static func GetByTitle(searchString: String) -> [Recipe] {
        return recipesList.filter{ (someRecipe) -> Bool in
            someRecipe.Title.lowercased()
                            .contains(searchString.lowercased())
        }
    }
    
    //Firebase is up so let's switch this over to Firebase or delete - Chris 11/6
    static func GetByIngredients(ingredientList : [String]) -> [Recipe] {
        return recipesList.filter({ (someRecipe) -> Bool in
            ingredientList.allSatisfy({ (ingredient) -> Bool in
                return someRecipe.Ingredients.keys.map({ (Ingredient) -> String in
                    return Ingredient.Name.lowercased()
                }).contains(ingredient.lowercased())
            })
        })
    }
    
    //Firebase is up so let's switch this over to Firebase or delete - Chris 11/6
    static func GetByIngredient(ingredient: String) -> [Recipe] {
        return recipesList.filter{ (someRecipe) -> Bool in
            someRecipe.Ingredients.filter({ (value) -> Bool in
                let (key, _) = value
                return key.Name.lowercased().contains(ingredient.lowercased())
            }).count != 0
        }
    }
    
    //Firebase is up so let's switch this over to Firebase or delete - Chris 11/6
    static func GetByFilters(filter : String) -> [Recipe] {
        return recipesList.filter({ (someRecipe) -> Bool in
            someRecipe.Filters.contains(filter)
        })
    }
}

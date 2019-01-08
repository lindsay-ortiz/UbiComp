//
//  ViewController.swift
//  Shopping Cart
//
//  Created by Lindsay Ortiz on 10/2/18.
//  Copyright © 2018 Lindsay Ortiz. All rights reserved.
//

import UIKit

@available(iOS 11.0, *)
class RecipeViewController: UIViewController/*MainViewController*/, UITableViewDelegate, UITableViewDataSource {
    
    
    @IBOutlet weak var ingredientsList: UITableView!
    
    //var refreshControl = UIRefreshControl()
    
    var titles = Array<String>()
    //[Recipename: [Ingredients]]
    //var recipes = [String: [String]]()
    var ingredients = [String: String]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //refreshControl.addTarget(self, action: #selector(RecipeViewController.refreshTable), for: UIControl.Event.valueChanged)
        //ingredientsList.refreshControl = refreshControl
        getIngsForRecipe(recipeID: "99nM3BqRzgSUnpMvUvbx")
        //ingredientsList.refreshControl = super.refreshControl
    }
    
//    override func viewWillAppear(_ animated: Bool) {
//        //getIngsForRecipe(recipeID: "99nM3BqRzgSUnpMvUvbx")
//    }
    
    func getIngsForRecipe(recipeID: String) {
        RecipeService.getFirebaseData(path: "Details/\(recipeID)/Ingredients") { (Ings, error) in
            if !error {
                for ing in Ings {
                    self.ingredients[ing.key] = ing.value as? String
                    print("blah blaha blahasdfsdf")
                    print(Ings)
                    print(ing)
                    print(ing.key)
                    //print(self.ingredients)
                    
                    //                    if self.ingredients[ing.key] == nil {
                    //                        self.ingredients[ing.key] = ing.value as? String
                    //                        print("Added new Ingredient")
                    //                    } else {
                    //
                    //                        let tempQuant = self.ingredients[ing.key] as! String
                    //                        var tempQuantStringArray = tempQuant.components(separatedBy: "_")
                    //                        tempQuantStringArray.insert("Xcode sucks", at: 0) ** I still believe this sentiment
                    //                        var tempQuantValueString = tempQuantStringArray[1]
                    //                        var tempQuantValue = Double(tempQuantValueString)
                    //
                    //                        print(tempQuantStringArray)
                    //
                    //                        let newQuant = ing.value as! String
                    //                        let newQuantValue = Double(newQuant.components(separatedBy: "_")[0])
                    //                        //tempQuantValue! += newQuantValue!
                    //                        self.ingredients[ing.key] = "\(tempQuantValue)_\(tempQuant.components(separatedBy: "_"))"
                    //                    }
                    self.ingredientsList.reloadData()
                }
            } else {
                print("error getting info from database")
            }
        }
    }
    
//    @objc func refreshTable() {
//        ingredientsList.reloadData()
//        refreshControl.endRefreshing()
//    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        //return RecipeService.shoppingList2.count
        return 1
    }
    
    public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        //return RecipeService.shoppingList[section].Ingredients.count + 1
        return ingredients.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
//        if indexPath.row == 0 {
//            let cell = UITableViewCell(style: UITableViewCell.CellStyle.default, reuseIdentifier: "TestCell")
//            cell.textLabel?.text = self.titles[indexPath.section]
//            return cell
//        } else {
//            let ingredientKeys = Array(self.ingredients.keys)
//            let quantities = Array(self.ingredients.values)
//            let cell = UITableViewCell(style: UITableViewCell.CellStyle.default, reuseIdentifier: "TestCell")
//            cell.textLabel?.text = ingredientKeys[indexPath.row - 1] + ":\t" + quantities[indexPath.row - 1]
//
//            if MainViewController.purchasedIngs.contains(ingredientKeys[indexPath.row - 1]) {
//                cell.textLabel?.textColor = UIColor.gray
//                cell.accessoryType = .checkmark
//            }
//
//            return cell
//        }
        
        print(self.ingredients)
        let ingredientKeys = Array(self.ingredients.keys)
        let quantities = Array(self.ingredients.values)
        
        let cell = UITableViewCell(style: UITableViewCell.CellStyle.default, reuseIdentifier: "TestCell")
        
        cell.textLabel?.text = ingredientKeys[indexPath.row] + ": " + quantities[indexPath.row]
        
        if MainViewController.purchasedIngs.contains(ingredientKeys[indexPath.row]) {
            cell.textLabel?.textColor = UIColor.gray
            cell.accessoryType = .checkmark
        }
        
        return cell
    }
    
    
    /*
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.row == 0 {
            let recToRemove = RecipeService.shoppingList2[indexPath.section]
            let ings = MainViewController.getIngsForRecipe(recipeID: recToRemove)
            for ing in MainViewController.ingredients {
                MainViewController.purchasedIngs.append(ing)
            }
        } else {
            let cell = tableView.cellForRow(at: indexPath)
            
            let ingredients = Array(RecipeService.shoppingList[indexPath.section].Ingredients.keys)
            let selectedIng = ingredients[indexPath.row - 1]
            
            if  MainViewController.purchasedIngs.contains(selectedIng) {
                let indexToRemove = MainViewController.purchasedIngs.index(of: selectedIng)
                MainViewController.purchasedIngs.remove(at: indexToRemove!)
                cell?.textLabel?.textColor = UIColor.black
                cell?.accessoryType = .none
            } else {
                MainViewController.purchasedIngs.append(selectedIng)
                cell?.textLabel?.textColor = UIColor.gray
                cell?.accessoryType = .checkmark
            }
        }
    }
 */
    
    
    func tableView(_ tableView: UITableView, leadingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        if indexPath.row == 0 {
            return nil
        } else {
            let modify = UIContextualAction(style: .normal, title: "Modify Amount") { (action, view, nil) in
                let alert = UIAlertController(title: "Modify", message: "Enter new amount:", preferredStyle: .alert)
                let modifyAction = UIAlertAction(title: "OK", style: .default) { (_) in
                    if let textField = alert.textFields?[0] {
                        let ingredients = Array(RecipeService.shoppingList[indexPath.section].Ingredients.keys)
                        RecipeService.shoppingList[indexPath.section].Ingredients[ingredients[indexPath.row - 1]] = Float(textField.text!)
                        self.ingredientsList.reloadData()
                    }
                }
                
                alert.addTextField { (textField) in
                    textField.placeholder = "New amount"
                }
                
                alert.addAction(modifyAction)
                self.present(alert, animated: true, completion: nil)
            }
            
            modify.backgroundColor = #colorLiteral(red: 0.3411764801, green: 0.6235294342, blue: 0.1686274558, alpha: 1)
            return UISwipeActionsConfiguration(actions: [modify])
        }
    }
    
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == UITableViewCell.EditingStyle.delete {
            if indexPath.row == 0 {
                RecipeService.shoppingList.remove(at: indexPath.row)
                ingredientsList.reloadData()
            } else {
                let ingredients = Array(RecipeService.shoppingList[indexPath.section].Ingredients.keys)
                RecipeService.shoppingList[indexPath.section].Ingredients.removeValue(forKey: ingredients[indexPath.row - 1])
                ingredientsList.reloadData()
            }
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 50
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    @IBAction func deleteAll(_ sender: Any) {
        RecipeService.shoppingList.removeAll()
        ingredientsList.reloadData()
    }
}


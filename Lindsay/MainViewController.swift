//
//  MainViewController.swift
//  Shopping Cart
//
//  Created by XCodeClub on 2018-10-11.
//  Copyright © 2018 Lindsay Ortiz. All rights reserved.
//

import UIKit

class MainViewController: UIViewController, UITableViewDelegate, UITableViewDataSource{
    
    var purchasedIngs = Array<String>()
    var showByRecipe = false;
    var allIngredients = [String: String]()
    var recipeIngredients = [[String: String]]()
    var titles = [String]()
    var numOfIngs = [Int]()
    
    @IBOutlet weak var ingredientsList: UITableView!
    
    @objc func deleteAll() {
        let alert = UIAlertController(title: "Delete All?", message: "Are you sure you want to remove all items from the cart?", preferredStyle: .alert)
        
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: { (_) in
            RecipeService.shoppingList2.removeAll()
            self.purchasedIngs.removeAll()
            self.allIngredients.removeAll()
            self.recipeIngredients.removeAll()
            self.titles.removeAll()
            self.numOfIngs.removeAll()
            
            self.ingredientsList.reloadData()
        }))
        
        alert.addAction(UIAlertAction(title: "Cancel", style: .destructive, handler: nil))
        
        self.present(alert, animated: true)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: UIBarButtonItem.SystemItem.trash, target: self, action: #selector(deleteAll))
        
//        for recipe in RecipeService.shoppingList2 {
//            getAllIngredients(recipeID: recipe)
//            getRecipeTitles(recipeID: recipe)
//            getNumOfIngsForRecipe(recipeID: recipe)
//        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        for recipe in RecipeService.shoppingList2 {
            getAllIngredients(recipeID: recipe)
            getRecipeTitles(recipeID: recipe)
            getNumOfIngsForRecipe(recipeID: recipe)
        }
    }
    
    @IBAction func toggleView(_ sender: UISegmentedControl) {
        if sender.selectedSegmentIndex == 0 {
            showByRecipe = false
            ingredientsList.reloadData()
        } else {
            showByRecipe = true
            ingredientsList.reloadData()
        }
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        if showByRecipe {
            return RecipeService.shoppingList2.count
        } else {
            return 1
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if showByRecipe {
            if numOfIngs.count == 0 {
                return 0
            } else {
                return self.numOfIngs[section] + 1
            }
        } else {
            return allIngredients.count
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell(style: UITableViewCell.CellStyle.default, reuseIdentifier: "TestCell")
        
        if showByRecipe {
            if indexPath.row == 0 {
                cell.textLabel?.text = self.titles[indexPath.section]
            } else {
                let ingredientKeys = Array(recipeIngredients[indexPath.section].keys)
                let quantities = Array(recipeIngredients[indexPath.section].values)
                
                cell.textLabel?.text = "\t" + ingredientKeys[indexPath.row - 1] + ": " + quantities[indexPath.row - 1].replacingOccurrences(of: "_", with: " ")
                
                if purchasedIngs.contains(ingredientKeys[indexPath.row - 1]) {
                    cell.textLabel?.textColor = UIColor.gray
                    cell.accessoryType = .checkmark
                }
            }
        } else {
            let ingredientKeys = Array(self.allIngredients.keys)
            let quantities = Array(self.allIngredients.values)
            
            cell.textLabel?.text = ingredientKeys[indexPath.row] + ": " + quantities[indexPath.row].replacingOccurrences(of: "_", with: " ")
            
            if purchasedIngs.contains(ingredientKeys[indexPath.row]) {
                cell.textLabel?.textColor = UIColor.gray
                cell.accessoryType = .checkmark
            }
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if showByRecipe {
            if indexPath.row == 0 {
                for ing in recipeIngredients[indexPath.section] {
                    purchasedIngs.append(ing.key)
                }
                
                ingredientsList.reloadData()
                
            } else {
                let cell = tableView.cellForRow(at: indexPath)
                
                let ingredients = Array(recipeIngredients[indexPath.section].keys)
                let selectedIng = ingredients[indexPath.row - 1]
                
                if  purchasedIngs.contains(selectedIng) {
                    let indexToRemove = purchasedIngs.index(of: selectedIng)
                    purchasedIngs.remove(at: indexToRemove!)
                    cell?.textLabel?.textColor = UIColor.black
                    cell?.accessoryType = .none
                } else {
                    purchasedIngs.append(selectedIng)
                    cell?.textLabel?.textColor = UIColor.gray
                    cell?.accessoryType = .checkmark
                }
                
                ingredientsList.reloadData()
            }
        } else {
            let cell = tableView.cellForRow(at: indexPath)
            
            let ingredients = Array(self.allIngredients.keys)
            let selectedIng = ingredients[indexPath.row]
            
            if  purchasedIngs.contains(selectedIng) {
                let indexToRemove = purchasedIngs.index(of: selectedIng)
                purchasedIngs.remove(at: indexToRemove!)
                cell?.textLabel?.textColor = UIColor.black
                cell?.accessoryType = .none
            } else {
                purchasedIngs.append(selectedIng)
                cell?.textLabel?.textColor = UIColor.gray
                cell?.accessoryType = .checkmark
            }
            
            ingredientsList.reloadData()
        }
    }
    
    func tableView(_ tableView: UITableView, leadingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        if showByRecipe {
            if indexPath.row == 0 {
                return nil
            } else {
                let modify = UIContextualAction(style: .normal, title: "Modify Amount") { (action, view, nil) in
                    let alert = UIAlertController(title: "Modify", message: "Enter new amount:", preferredStyle: .alert)
                    let modifyAction = UIAlertAction(title: "OK", style: .default) { (_) in
                        if let textField = alert.textFields?[0] {
                            let ingredients = Array(self.recipeIngredients[indexPath.section].keys)
                            let quantities = Array(self.recipeIngredients[indexPath.section].values)
                            let ing = ingredients[indexPath.row - 1]
                            
                            let oldQuantString = quantities[indexPath.row - 1]
                            let oldQuantArray = oldQuantString.components(separatedBy: "_")
                            let newQuantString = "\(textField.text!)_\(oldQuantArray[1])"
                            
                            self.recipeIngredients[indexPath.section][ing] = newQuantString
                            
                            let oldQuantFloat = Float(oldQuantArray[0])
                            let newQuantFloat = Float(textField.text!)
                            let quantDiff = oldQuantFloat! - newQuantFloat!
                            self.updateAllIngredients(ing: ing, quantDiff: quantDiff)

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
            
        } else {
            let modify = UIContextualAction(style: .normal, title: "Modify") { (action, view, nil) in
                let alert = UIAlertController(title: "Modify Amount", message: "Enter new amount:", preferredStyle: .alert)
                let modifyAction = UIAlertAction(title: "OK", style: .default) { (_) in
                    if let textField = alert.textFields?[0] {
                        let ingredients = Array(self.allIngredients.keys)
                        let quantities = Array(self.allIngredients.values)
                        let ing = ingredients[indexPath.row]
                        
                        let oldQuantString = quantities[indexPath.row]
                        let oldQuantArray = oldQuantString.components(separatedBy: "_")
                        let newQuantString = "\(textField.text!)_\(oldQuantArray[1])"
                        
                        self.allIngredients[ing] = newQuantString
                        
                        //Send new quantity to recipeIngredients - This should be acceptable if not implemented
                        
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
    
    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        if showByRecipe {
            if indexPath.row == 0 {
                let deleteAll = UIContextualAction(style: .normal, title: "Delete") { (action, view, nil) in
                    for ing in self.recipeIngredients[indexPath.section] {
                        self.reduceAllQuantity(ing.key, ing.value)
                    }
                    self.recipeIngredients.remove(at: indexPath.section)
                    self.numOfIngs.remove(at: indexPath.section)
                    self.titles.remove(at: indexPath.section)
                    
                    RecipeService.shoppingList2.remove(at: indexPath.section)
                    
                    self.ingredientsList.reloadData()
                }
                
                deleteAll.backgroundColor = #colorLiteral(red: 0.9254902005, green: 0.2352941185, blue: 0.1019607857, alpha: 1)
                return UISwipeActionsConfiguration(actions: [deleteAll])
            } else {
                let delete = UIContextualAction(style: .normal, title: "Delete") { (action, view, nil) in
                    let ingredients = Array(self.recipeIngredients[indexPath.section].keys)
                    let quantities = Array(self.recipeIngredients[indexPath.section].values)
                    
                    self.reduceAllQuantity(ingredients[indexPath.row - 1], quantities[indexPath.row - 1])
                    
                    self.recipeIngredients[indexPath.section].removeValue(forKey: ingredients[indexPath.row - 1])
                    self.numOfIngs[indexPath.section] -= 1
                    
                    self.ingredientsList.reloadData()
                }
                
                delete.backgroundColor = #colorLiteral(red: 0.9254902005, green: 0.2352941185, blue: 0.1019607857, alpha: 1)
                return UISwipeActionsConfiguration(actions: [delete])
            }
            
        } else {
            let delete = UIContextualAction(style: .normal, title: "Delete") { (action, view, nil) in
                let ingredients = Array(self.allIngredients.keys)
                self.allIngredients.removeValue(forKey: ingredients[indexPath.row])
                
                self.removeFromRecipes(ingredients[indexPath.row])
                
                self.ingredientsList.reloadData()
            }
            
            delete.backgroundColor = #colorLiteral(red: 0.9254902005, green: 0.2352941185, blue: 0.1019607857, alpha: 1)
            return UISwipeActionsConfiguration(actions: [delete])
        }
    }
    
    private func getAllIngredients(recipeID: String) {
        RecipeService.getFirebaseData(path: "Details/\(recipeID)/Ingredients") { (Ings, error) in
            if !error {
                self.recipeIngredients.insert((Ings as? [String: String])!, at: self.recipeIngredients.count)
                for ing in Ings {
                    if self.allIngredients[ing.key] == nil {
                        self.allIngredients[ing.key] = ing.value as? String
                        self.ingredientsList.reloadData()
                    } else {
                        let oldIngString = self.allIngredients[ing.key]
                        let oldIngStringArray = oldIngString?.components(separatedBy: "_")
                        let oldValueString = oldIngStringArray![0]
                        let oldValueFloat = Float(oldValueString)
                        
                        let newIngString = ing.value as? String
                        let newIngStringArray = newIngString?.components(separatedBy: "_")
                        let newValueString = newIngStringArray![0]
                        let newValueFloat = Float(newValueString)
                        
                        let finalValue = oldValueFloat! + newValueFloat!
                        let finalValueString = String(format: "%.2f", finalValue)
                        let finalValueStringWithMeasure = "\(finalValueString)_\(newIngStringArray![1])"
                        self.allIngredients[ing.key] = finalValueStringWithMeasure
                        
                        self.ingredientsList.reloadData()
                    }
                }
            } else {
                print("error getting info from database")
            }
        }
    }
    
    private func getRecipeTitles(recipeID: String) {
        RecipeService.getFirebaseData(path: "Titles") { (Titles, error) in
            if !error {
                for title in Titles {
                    if title.key == recipeID {
                        self.titles.insert(title.value as! String, at: self.titles.count)
                    }
                }
            } else {
                print("Error getting info from database")
            }
        }
    }
    
    private func getNumOfIngsForRecipe(recipeID: String) {
        RecipeService.getFirebaseData(path: "Details/\(recipeID)/Ingredients") { (Ings, error) in
            if !error {
                self.numOfIngs.insert(Ings.count, at: self.numOfIngs.count)
            } else {
                print("Error getting info from database")
            }
        }
    }
    
    private func reduceAllQuantity(_ key: String, _ value: String) {
        let oldIngString = self.allIngredients[key]
        let oldIngStringArray = oldIngString?.components(separatedBy: "_")
        let oldValueString = oldIngStringArray![0]
        let oldValueFloat = Float(oldValueString)
        
        let newIngString = value
        let newIngStringArray = newIngString.components(separatedBy: "_")
        let newValueString = newIngStringArray[0]
        let newValueFloat = Float(newValueString)
        
        let finalValue = oldValueFloat! - newValueFloat!
        
        if finalValue == 0.0 {
            self.allIngredients[key] = nil
        } else {
            let finalValueString = String(format: "%.2f", finalValue)
            let finalValueStringWithMeasure = "\(finalValueString)_\(oldIngStringArray![1])"
            self.allIngredients[key] = finalValueStringWithMeasure
        }
    }
    
    private func removeFromRecipes(_ inputKey: String) {
        for i in 0...recipeIngredients.count - 1 {
            for ing in recipeIngredients[i] {
                if ing.key == inputKey {
                    recipeIngredients[i][inputKey] = nil
                    
                    numOfIngs[i] -= 1
                }
            }
        }
    }
    
    private func updateAllIngredients(ing: String, quantDiff: Float) {
        let ingString = allIngredients[ing]
        let ingStringArray = ingString?.components(separatedBy: "_")
        let ingValueString = ingStringArray![0]
        let ingValueFloat = Float(ingValueString)
        let newValueFloat = ingValueFloat! - quantDiff
        allIngredients[ing] = "\(newValueFloat)_\(ingStringArray![1])"
    }
}

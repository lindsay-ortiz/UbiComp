//
//  ViewController.swift
//  Shopping Cart
//
//  Created by Lindsay Ortiz on 10/2/18.
//  Copyright © 2018 Lindsay Ortiz. All rights reserved.
//

import UIKit

@available(iOS 11.0, *)
class IngredientViewController: /*UIViewController*/MainViewController, UITableViewDelegate, UITableViewDataSource {
        
    @IBOutlet weak var ingredientsList: UITableView!
    
    var refreshControl = UIRefreshControl()
    var ingredients = [String: String]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        refreshControl.addTarget(self, action: #selector(IngredientViewController.refreshTable), for: UIControl.Event.valueChanged)
        ingredientsList.refreshControl = refreshControl

//        for ing in RecipeService.shoppingList2 {
//            getIngsForRecipe(recipeID: ing)
//        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        getIngsForRecipe(recipeID: "99nM3BqRzgSUnpMvUvbx")
    }
    
    func getIngsForRecipe(recipeID: String) {
        RecipeService.getFirebaseData(path: "Details/\(recipeID)/Ingredients") { (Ings, error) in
            if !error {
                for ing in Ings {
                    self.ingredients[ing.key] = ing.value as? String
                    
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
    
//    override func viewWillAppear(_ animated: Bool) {
//        ingredientsList.reloadData()
//    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    @objc func refreshTable() {
        ingredientsList.reloadData()
        refreshControl.endRefreshing()
    }
    
    public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.ingredients.count
    }
    
    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
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
    
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let cell = tableView.cellForRow(at: indexPath)
        
        let ingredients = Array(self.ingredients.keys)
        let selectedIng = ingredients[indexPath.row]
        
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
 
    
    func tableView(_ tableView: UITableView, leadingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let modify = UIContextualAction(style: .normal, title: "Modify") { (action, view, nil) in
            let alert = UIAlertController(title: "Modify Amount", message: "Enter new amout:", preferredStyle: .alert)
            let modifyAction = UIAlertAction(title: "OK", style: .default) { (_) in
                if let textField = alert.textFields?[0] {
                    let ingredients = Array(RecipeService.shoppingList[indexPath.section].Ingredients.keys)
                    RecipeService.shoppingList[indexPath.section].Ingredients[ingredients[indexPath.row]] = Float(textField.text!)
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
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            let ingredients = Array(RecipeService.shoppingList[indexPath.section].Ingredients.keys)
            RecipeService.shoppingList[indexPath.section].Ingredients.removeValue(forKey: ingredients[indexPath.row])
            ingredientsList.reloadData()
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 50
    }
    
    @IBAction func deleteAll(_ sender: Any) {
        RecipeService.shoppingList.removeAll()
        ingredientsList.reloadData()
    }
}


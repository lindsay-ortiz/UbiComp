//
//  FiltersTableTableViewController.swift
//  RecipeBox
//
//  Created by Team2 on 10/17/18.
//  Copyright © 2018 Team2. All rights reserved.
//

import UIKit

struct Category {
    let name : String
    var items : [String]
}

class FiltersTableTableViewController: UITableViewController {
    var section = [Category]()
    var diet = ["Vegetarian", "Non-Vegetarian", "Vegan", "Eggs", "Seafood"]
    var mealTime = ["Breakfast", "Lunch", "Dinner", "Dessert", "Soup"]
    var cuisine = ["American", "Italian", "Mediterranean", "Mexican", "Korean", "Chinese", "Vietnamese", "Southwest"]
    var meatTypes = ["Chicken", "Turkey", "Beef", "Pork", "Bacon", "Shrimp"]
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.clearsSelectionOnViewWillAppear = false
        
        section = [Category(name:"Diet", items:self.diet),Category(name:"Meal", items:self.mealTime),Category(name:"Cuisine", items:self.cuisine),Category(name:"Meat", items:self.meatTypes)]
    }

    override func numberOfSections(in tableView: UITableView) -> Int {
        return self.section.count
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let items = self.section[section].items
        return items.count
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "filter", for: indexPath)
        cell.textLabel?.text = section[indexPath.section].items[indexPath.row]
        
        if SearchForRecipeViewController.selectedFilters.contains(section[indexPath.section].items[indexPath.row]) {
           cell.accessoryType = .checkmark
           cell.textLabel?.textColor = #colorLiteral(red: 0.3607843137, green: 0.07850172839, blue: 0.35949295, alpha: 1)
        }
        return cell
    }
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return self.section[section].name
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let cell = tableView.cellForRow(at: indexPath)
        let selectedFilter = section[indexPath.section].items[indexPath.row]
        
        if  SearchForRecipeViewController.selectedFilters.contains(selectedFilter) {
            let indexToRemove = SearchForRecipeViewController.selectedFilters.index(of: selectedFilter)
            SearchForRecipeViewController.selectedFilters.remove(at: indexToRemove!)
            cell?.textLabel?.textColor = UIColor.black
            cell?.accessoryType = .none
        } else {
            SearchForRecipeViewController.selectedFilters.append(selectedFilter)
            cell?.textLabel?.textColor = #colorLiteral(red: 0.3607843137, green: 0.07850172839, blue: 0.35949295, alpha: 1)
            cell?.accessoryType = .checkmark
        }
    }
}

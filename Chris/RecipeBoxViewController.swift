//
//  RecipeBoxViewController.swift
//  TestProject_UI
//
//  Created by Chris Hill on 10/3/18.
//  Copyright © 2018 Christopher Hill. All rights reserved.
//

import UIKit
import Promises

class RecipeBoxViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    @IBOutlet weak var tableView: UITableView!
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return displayArray.count
    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return RecipeService.rowHeight
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "tableViewCell") as! RecipeBoxTableViewCell
        cell.cLabel.text = displayArray[indexPath.row].title
        RecipeService.getRecipeImages(ID: self.displayArray[indexPath.row].ID, assignImageData: { (input: UIImage) -> Void in
            cell.cImage.image = input
        })
        return cell
    }
    
    var displayArray = [Recipe2]()
    func display(IDs: [String]){
        let IDsWithoutDuplicates = RecipeService.final_removeDuplicates(array: IDs)
        for ID in IDsWithoutDuplicates {
            RecipeService.final_getRecipe(for: ID).then { recipe in
                self.displayArray.append(recipe)
                self.tableView.reloadData()
            }.catch {error in
                    print(error)
            }
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.delegate = self
        tableView.dataSource = self
        tableView.keyboardDismissMode = .onDrag

        display(IDs: RecipeService.getFavoriteIDs() + RecipeService.getCustomRecipeIDs())
    }
    
    @IBOutlet weak var segctrlSelection: UISegmentedControl!
    @IBAction func toggleView(_ sender: UISegmentedControl) {
        if sender.selectedSegmentIndex == 0 {
            displayArray.removeAll()
            display(IDs: RecipeService.getFavoriteIDs() + RecipeService.getCustomRecipeIDs())
        }
        if sender.selectedSegmentIndex == 1 {
            displayArray.removeAll()
            display(IDs: RecipeService.getCustomRecipeIDs())
        }
        if sender.selectedSegmentIndex == 2 {
            displayArray.removeAll()
            display(IDs: RecipeService.getFavoriteIDs())
        }
    }
    
    @IBOutlet weak var txtfldSearchBox: UITextField!
    @IBAction func btnClick(_ sender: UIButton) {
        displayArray.removeAll()
        
        if(segctrlSelection.selectedSegmentIndex == 0){
            RecipeService.final_getRecipes(for: RecipeService.getFavoriteIDs() + RecipeService.getCustomRecipeIDs()).then { recipes in
                self.displayArray = RecipeService.final_removeDuplicates(array: recipes)
                RecipeService.final_filterRecipesBySearchKeywords(textFieldText: self.txtfldSearchBox.text!, recipesToFilter: self.displayArray).then { recipes in
                    self.displayArray = recipes
                    self.txtfldSearchBox.text = ""
                    self.tableView.reloadData()
                }.catch { error in
                        print(error)
                }
            }
        } else if(segctrlSelection.selectedSegmentIndex == 1){
            RecipeService.final_getRecipes(for: RecipeService.getFavoriteIDs() + RecipeService.getCustomRecipeIDs()).then { recipes in
                self.displayArray = RecipeService.final_removeDuplicates(array: recipes)
                RecipeService.final_filterRecipesBySearchKeywords(textFieldText: self.txtfldSearchBox.text!, recipesToFilter: self.displayArray).then { recipes in
                    self.displayArray = recipes
                    self.txtfldSearchBox.text = ""
                    self.tableView.reloadData()
                    }.catch { error in
                        print(error)
                }
            }
        } else if(segctrlSelection.selectedSegmentIndex == 2){
            RecipeService.final_getRecipes(for: RecipeService.getFavoriteIDs() + RecipeService.getCustomRecipeIDs()).then { recipes in
                self.displayArray = RecipeService.final_removeDuplicates(array: recipes)
                RecipeService.final_filterRecipesBySearchKeywords(textFieldText: self.txtfldSearchBox.text!, recipesToFilter: self.displayArray).then { recipes in
                    self.displayArray = recipes
                    self.txtfldSearchBox.text = ""
                    self.tableView.reloadData()
                    }.catch { error in
                        print(error)
                }
            }
        }
    }
    
    
    var chosenIndex = 0;
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        chosenIndex = indexPath.row
        performSegue(withIdentifier: "showRecipe", sender: self)
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let target = segue.destination as! SelectedRecipeViewController
        target.titleText = displayArray[chosenIndex].title
        target.chosenID = displayArray[chosenIndex].ID
     }
}

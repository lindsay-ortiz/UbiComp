//
//  SearchViewController.swift
//  NicScreen
//
//  Created by Team2 on 10/3/18.
//  Copyright © 2018 Team2. All rights reserved.
//

import UIKit

class SearchViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    @IBOutlet weak var table: UITableView!
    @IBOutlet weak var searchTxt: UITextField!
    
    @IBAction func addSearchFilter(_ sender: Any) {
        if searchTxt.text == nil || (searchTxt.text?.isEmpty)! {
            return
        }
        
        searchTerms.append(searchTxt.text!.lowercased())
        
        print(searchTerms)
        
        RecipeService.GetWithIngredients(searchIngredients: searchTerms, callback: { (input: [String:String]) -> Void in
            self.searchTxt.text! = ""
            self.data = []
            for item in input {
                var newItem = KeyAndName()
                newItem.Key = item.key
                newItem.Name = item.value
                self.data.append(newItem)
            }
            self.table.reloadData()
            
            if(self.data.count == 0) {
                self.searchTerms = []
            }
        })
    }
    
    private var searchTerms : [String] = []
    
    private var data: [KeyAndName] = []
    
    var chosenIndex = 0
    
    @IBOutlet var mainView: UIView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        //self.navigationController?.isNavigationBarHidden = true

        table.dataSource = self
        table.delegate = self
        table.keyboardDismissMode = .onDrag
        
        let clearTableGestureRecognizer = UISwipeGestureRecognizer(target: self, action: #selector(handleSwipes))
        clearTableGestureRecognizer.numberOfTouchesRequired = 2
        clearTableGestureRecognizer.direction = .left
        self.mainView.addGestureRecognizer(clearTableGestureRecognizer)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        //self.navigationController?.isNavigationBarHidden = true
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return data.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "tableViewCell") as! RecipeBoxTableViewCell
        
        //let chosenKey = keys[indexPath.row]
        cell.cLabel.text = data[indexPath.row].Name
        RecipeService.getRecipeImages(ID: self.data[indexPath.row].Key, assignImageData: { (input: UIImage) -> Void in
            cell.cImage.image = input
        })
        
        cell.index = indexPath.row
        
        let addToBox = UISwipeGestureRecognizer(target: self, action: #selector(handleSwipes))
        addToBox.direction = .right
        cell.addGestureRecognizer(addToBox)

        return cell
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView,
                   didSelectRowAt indexPath: IndexPath){
        chosenIndex = indexPath.row
        self.performSegue(withIdentifier: "SelectRecipe", sender: self)
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return RecipeService.rowHeight
    }
    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return false
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if (editingStyle == .delete) {
            data.remove(at: indexPath.row)
            tableView.reloadData()
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "SelectRecipe" {
            let target = segue.destination as! SelectedRecipeViewController
            target.titleText = data[chosenIndex].Name
            target.chosenID = data[chosenIndex].Key
        }
    }
    
    @objc func handleSwipes(_ sender:UISwipeGestureRecognizer) {
        if (sender.direction == .left) {
            data = []
            searchTerms = []
            table.reloadData()
        }
        else if (sender.direction == .right) {
            let cell = sender.view as! RecipeBoxTableViewCell

            UIView.animate(withDuration: 0.5, animations: {
                cell.transform = CGAffineTransform(translationX: cell.frame.width, y: 0)
            }, completion: {(isCompleted) in
                let chosenRecipe = self.data[cell.index]
                RecipeService.addIDToFavorites(input: chosenRecipe.Key)
                
                self.data.remove(at: cell.index)
                RecipeService.showToast(message: "Added to box", view: self.view)
                self.table.reloadData()
            })
        }
    }

}

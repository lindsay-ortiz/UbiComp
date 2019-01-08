//
//  ViewController.swift
//  search
//
//  Created by Team2 on 10/9/18.
//  Copyright © 2018 Team2. All rights reserved.
//

import UIKit
import CoreMotion

class SearchForRecipeViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    var motionManager = CMMotionManager()
    //var rowHeight: CGFloat = 200
    
    static var selectedFilters = Array<String>()
    var filterSelected = false
    @IBOutlet var mainView: UIView!
    
    var IDsAndTitles = [String:String]()
    var displayIDs = [String]()
    var recipeImage = UIImage()
    
    @IBOutlet weak var table: UITableView!
    @IBOutlet weak var searchtxtbar: UITextField!
    
    var chosenIndex = 0
    
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        
        switch (traitCollection.horizontalSizeClass, traitCollection.verticalSizeClass) {
        case (.regular, .regular):
            setupRegularRegular()
            
        case (.compact, .compact):
            setupCompactCompact()
            
        case (.regular, .compact):
            setupRegularCompact()
            
        case (.compact, .regular):
            setupCompactRegular()
            
        default: break
        }
    }
    
    func setupCompactRegular() {
        RecipeService.rowHeight = 200
    }
    
    func setupRegularCompact() {
        RecipeService.rowHeight = 300
    }
    
    func setupRegularRegular() {
        RecipeService.rowHeight = 400
    }
    
    func setupCompactCompact() {
        RecipeService.rowHeight = 300
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        //let filters = segue.destination as! FiltersTableTableViewController
        if segue.identifier == "showRecipe"{
            let target = segue.destination as! SelectedRecipeViewController
        //target.recipeToDisplay = displayArray[chosenIndex]
        
            target.chosenID =  displayArray[chosenIndex].ID
            target.titleText = displayArray[chosenIndex].title
        }
    }
    
    var displayArray = [Recipe2]()
    
    func display(IDs: [String]){
        let IDsWithoutDuplicates = RecipeService.final_removeDuplicates(array: IDs)
        for ID in IDsWithoutDuplicates {
            RecipeService.final_getRecipe(for: ID).then { recipe in
                self.displayArray.append(recipe)
                self.table.reloadData()
                }.catch {error in
                    print(error)
            }
        }
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "tableViewCell") as! RecipeBoxTableViewCell
        cell.cLabel.text = self.displayArray[indexPath.row].title
        
        RecipeService.getRecipeImages(ID: self.displayArray[indexPath.row].ID, assignImageData: { (input: UIImage) -> Void in
            cell.cImage.image = input
        })
        
        let addToBox = UISwipeGestureRecognizer(target: self, action: #selector(handleSwipes))
        addToBox.direction = .right
        cell.addGestureRecognizer(addToBox)
        
        return cell
    }
    
    @objc func handleSwipes(_ sender:UISwipeGestureRecognizer) {
        if (sender.direction == .left) {
            displayArray = []
            //searchTerms = []
            table.reloadData()
        }
        else if (sender.direction == .right) {
            let cell = sender.view as! RecipeBoxTableViewCell
            
            UIView.animate(withDuration: 0.5, animations: {
                cell.transform = CGAffineTransform(translationX: cell.frame.width, y: 0)
            }, completion: {(isCompleted) in
                let item = self.displayArray[cell.index]
                print(item)
                RecipeService.addIDToFavorites(input: item.ID)
                
                self.displayArray.remove(at: cell.index)
                RecipeService.showToast(message: "Recipe add to box", view: self.view)
                self.table.reloadData()
            })
        }
    }
    
    @IBAction func searchbtn(_ sender: Any) {
        if self.filterSelected == false{
            self.displayArray.removeAll()
            self.displayIDs.removeAll()
            
            if self.searchtxtbar.text != ""{
                RecipeService.final_getIDsBySearchKeywords(textFieldText: self.searchtxtbar.text!).then { data in
                    self.displayIDs = data
                    for ID in self.displayIDs{
                        RecipeService.final_getRecipe(for : ID).then{ recipe in
                            self.displayArray.append(recipe)
                            self.table.reloadData()
                        }
                    }
                }
            }
            else{
                self.table.reloadData()
            }
        }
        if self.filterSelected == true{
            print(self.filterSelected)
            RecipeService.final_filterRecipesBySearchKeywords(textFieldText: self.searchtxtbar.text!, recipesToFilter: displayArray).then { recipes in
                self.displayArray = recipes
                self.table.reloadData()
            }
        }
    }
    
    func searchAndUpdateDisplay(rawTextFieldText: String){
        RecipeService.search_SearchKeywords(textFieldText: rawTextFieldText, receiveData: {(IDsAndFrequency) in
            self.IDsAndTitles.removeAll()
            RecipeService.getFirebaseData(path: "Titles", IDs: Array(IDsAndFrequency.keys), receiveData: {(ID, value) in
                self.IDsAndTitles[ID as! String] = value as? String
                self.table.reloadData()
            })
        })
    }
    
    func searchAndUpdateDisplayFilters(selectedFilters: [String]){
        
        RecipeService.search_Filters(selectedFilters: SearchForRecipeViewController.selectedFilters, receiveData:
            {(IDsAndFrequency) in
                self.IDsAndTitles.removeAll()
                RecipeService.getFirebaseData(path: "Titles", IDs: Array(IDsAndFrequency.keys), receiveData: {(ID, value) in
                    self.IDsAndTitles[ID as! String] = value as? String
                    self.table.reloadData()
                    print(self.IDsAndTitles)
                })
        })
        
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        table.dataSource = self
        table.delegate = self
        table.keyboardDismissMode = .onDrag
        
        let clearTableGestureRecognizer = UISwipeGestureRecognizer(target: self, action: #selector(handleSwipes))
        clearTableGestureRecognizer.numberOfTouchesRequired = 2
        clearTableGestureRecognizer.direction = .left
        self.mainView.addGestureRecognizer(clearTableGestureRecognizer)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        RecipeService.initialize()
        self.motionManager.accelerometerUpdateInterval = 0.1
        
        self.motionManager.startAccelerometerUpdates(to: OperationQueue.current!){(data, error) in
            if let myData = data{
                if abs(myData.acceleration.x) >= 1.75 || abs(myData.acceleration.y) >= 1.75 || abs(myData.acceleration.z) >= 1.75{
                    self.displayIDs.removeAll()
                    self.displayArray.removeAll()
                    
                    RecipeService.final_getAllIDs().then({ (data) in
                        RecipeService.final_getRecipe(for : data.randomElement()!).then{ recipe in
                            self.displayArray = [recipe]
                            self.table.reloadData()
                            RecipeService.showToast(message: "Random Recipe Fetched", view: self.view)
                        }
                    })
                }
            }
        }
    }
    
    //This function probably needs to be revisited
    override func viewWillAppear(_ animated: Bool) {
        //self.navigationController?.isNavigationBarHidden = true
        
        self.displayIDs.removeAll()
        self.displayArray.removeAll()
        RecipeService.final_getIDsByFilters(selectedFilters: SearchForRecipeViewController.selectedFilters).then { data in
            self.displayIDs = data
            //print(data)
            print(self.displayIDs)
            for ID in self.displayIDs{
                //self.recipeImage = RecipeService.getRecipeImages(ID: ID)
                //print(self.displayIDs)
                RecipeService.final_getRecipe(for : ID).then{ recipe in
                    self.displayArray.append(recipe)
                    self.filterSelected = true
                    print(self.displayArray)
                    self.table.reloadData()
                }
            }
        }
        
        //print(SearchForRecipeViewController.selectedFilters)
        
        table.reloadData()
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        chosenIndex = indexPath.row
        performSegue(withIdentifier: "showRecipe", sender: self)
    }
    
    @IBAction func addfilter(_ sender: Any) {
        performSegue(withIdentifier: "showfilter", sender: self)
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        
        return RecipeService.rowHeight
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.displayArray.count
    }
}


//
//  SelectedRecipeViewController.swift
//  NicScreen
//
//  Created by Team2 on 10/8/18.
//  Copyright © 2018 Team2. All rights reserved.
//

import UIKit

class SelectedRecipeViewController: UIViewController {
            
    var titleText = ""
    var chosenID = ""
    
    var instructionsText = "Instructions:\n"
    var ingredientText = "Ingredients:\n"
    
    var ratingsCount = 0
    var recipeBoxCount = 0
    
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var ingredientsList: UITextView!
    
    @IBAction func ratingButton(_ sender: UIButton) {
        if self.ratingsCount == 0{
            let alert = UIAlertController(title: "Rating", message: "Please rate this recipe", preferredStyle: .alert)
            
            for i in 1...5 {
                alert.addAction(UIAlertAction(title: "\(i)", style: .default, handler: { (_) in
                    self.addRating(PresRating: i)
                }))
            }
            self.present(alert, animated: true)
            self.ratingsCount = 10
        }
    }
    
    @IBOutlet weak var image: UIImageView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let ratingButtonReference = self.view.viewWithTag(4) as! UIButton
        
        let recipeBoxButtonReference = self.navigationItem.rightBarButtonItem
        for recipeID in RecipeService.favoriteIDs{
            if recipeID == chosenID || self.recipeBoxCount != 0{
                print("Recipe already available!")
                recipeBoxButtonReference!.isEnabled = false
                //recipeBoxButtonReference.isHidden = true
            }
        }
        
        titleLabel.text = titleText
        
        RecipeService.final_getRecipe(for: chosenID).then { recipe in
            
            ratingButtonReference.setTitle("\(recipe.rating)", for: .normal)
            
            var ingredientString = ""
            
            for (ingredient, value) in recipe.ingredients {
                let splitValue = value.split(separator: "_")
                ingredientString += (ingredient + " " + splitValue[0] + " " + splitValue[1]) + "\r\r"
            }
            
            self.ingredientsList.text = "Ingredients\r\r" + ingredientString + "\r\r"
            
            self.ingredientsList.text += "Method\r\r" + recipe.procedure.replacingOccurrences(of: "\\n", with: "\r")
            
        }.catch { error in
            print(error)
        }
        
        RecipeService.getRecipeImages(ID: self.chosenID, assignImageData: { (input: UIImage) -> Void in
            self.image.image = input
        })
        
        if self.ratingsCount != 0{
            print(self.ratingsCount)
            let ratingButtonReference = self.view.viewWithTag(4) as! UIButton
            ratingButtonReference.isEnabled = false
            ratingButtonReference.isUserInteractionEnabled = false
        }
        /*
        var tempText = ""
        var tempQuant = ""
        var tempMeasure = ""
        for ing in RecipeService.recipesList[index].Ingredients {
            tempQuant = String("\(ing.value)")
            tempMeasure = "\(ing.key.Measurement)"
            tempText.append("- \(ing.key.Name): \(tempQuant) \(tempMeasure)\n")
        }
        
        self.ingredientsList.text.append(":\n\n" + tempText)
        
        self.instructions.text.append(":\n\n" + RecipeService.recipesList[index].Procedure)
        
        if RecipeService.recipesList[index].NumberOfRatings != 0 {
            self.ratingLabel.text = "Rating: " +  String(Float(RecipeService.recipesList[index].Rating / RecipeService.recipesList[index].NumberOfRatings)) + "/5.0"
        } else {
            self.ratingLabel.text = "Rating: 0.0/5.0"
        }
        */
        //self.image.image = RecipeService.recipesList[index].Image.image
        
        //self.navigationController?.isNavigationBarHidden = false
    }
    
    override func viewWillAppear(_ animated: Bool) {
        let recipeBoxButtonReference = self.navigationItem.rightBarButtonItem
        for recipeID in RecipeService.favoriteIDs{
            if recipeID == chosenID || self.recipeBoxCount != 0{
                print("Recipe already available!")
                recipeBoxButtonReference!.isEnabled = false
                //recipeBoxButtonReference.isHidden = true
            }
        }
    }
    
    @IBAction func addToRecipeBox(_ sender: Any) {
        // RecipeService.favoriteIDs.append(current Recipe ID)
        // UserDefaults.standard.set(RecipeService.favoriteIDs, forKey: "favorites")
        // RecipeService.myRecipeBox.append(RecipeService.recipesList[index])
        if self.recipeBoxCount == 0{
            RecipeService.addIDToFavorites(input: chosenID)
            RecipeService.showToast(message: "Added to Recipe Box", view: self.view)
        }
    }
 
    func addRating(PresRating: Int) {
        RecipeService.final_getRecipe(for: self.chosenID).then({ recipe in
            
            //            let CurRating = recipe.rating
            //            let num:Float = recipe.numRatings as! Float
            //            let pres = PresRating as! Float
            print("\(recipe.rating)  \(recipe.numRatings)")
            let newRating = (((Float(recipe.numRatings)*Float(recipe.rating))+Float(PresRating))/Float(recipe.numRatings+1))
            
            recipe.rating = Float(newRating)
            let newRatingStr = String(format: "%.2f", recipe.rating)
            recipe.numRatings += 1
            
            let ratingButtonReference = self.view.viewWithTag(4) as! UIButton
            ratingButtonReference.setTitle("\(newRatingStr)", for: .normal)
            
            print("\(recipe.rating)  \(recipe.numRatings)")
            RecipeService.showToast(message: "Rating submitted", view: self.view)
            RecipeService.updateRating(id: self.chosenID, rating: recipe.rating, numberOfRatings: recipe.numRatings)
        })
        
            //recipe.rating += rating
            //recipe.numRatings += 1
            
            //var ratingButtonReference = self.view.viewWithTag(4) as! UIButton
            //ratingButtonReference.setTitle("Rating: " + String(Float(recipe.rating / recipe.numRatings)) + "/5.0", for: .normal)
    }
    
    @IBAction func addToCart(_ sender: Any) {
        //RecipeService.shoppingList.append(RecipeService.recipesList[index])
        print(RecipeService.shoppingList2)
        RecipeService.addIDToCart(input: self.chosenID)
        RecipeService.showToast(message: "Added to Cart", view: self.view)
        print(RecipeService.shoppingList2)
    }
}

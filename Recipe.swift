//
//  Recipe.swift
//  RecipeBox
//
//  Created by Team2 on 10/17/18.
//  Copyright © 2018 Team2. All rights reserved.
//

import Foundation
import UIKit

struct Ingredient: Hashable {
    var Name: String
    var Measurement: String
}

struct Recipe {
    var Id: Int
    var Title: String
    var Ingredients = Dictionary<Ingredient, Float>()
    var Procedure: String
    var Filters: [String]
    var Rating: Int
    var NumberOfRatings: Int
    //var Image: UIImage
}

class Recipe2 : CustomStringConvertible, Hashable, Comparable{
    var ID: String = ""
    var title: String = ""
    var ingredients: Dictionary<String, String> = [:]
    var procedure: String = ""
    var filters: [String] = []
    var rating: Float = 0.0
    var numRatings: Int = 0
    //relevance is not stored in firebase. It is a local variable used in sorting search results.
    var relevance: Int = 0
    //image will be implemented once I figure out how to retrieve it
    var image: UIImage? = nil
    
    init(ID: String, title: String, ingredients: Dictionary<String, String>, procedure: String, rating: Float, numRatings: Int, filters: [String], relevance: Int) {
        self.ID = ID
        self.title = title
        self.ingredients = ingredients
        self.procedure = procedure
        self.rating = rating
        self.numRatings = numRatings
        self.filters = filters
        self.relevance = relevance
    }
    
    var hashValue: Int {
        return ID.hashValue
    }
    
    static func < (lhs: Recipe2, rhs: Recipe2) -> Bool {
        if (lhs.relevance < rhs.relevance) {
            return true
        } else if (lhs.relevance > rhs.relevance){
            return false
        }
        if (lhs.title < rhs.title) {
            return true
        }
        return false
    }
    
    static func == (lhs: Recipe2, rhs: Recipe2) -> Bool {
        if(lhs.ID == rhs.ID){
            return true
        } else {
            return false
        }
    }
    
    var description: String {
        return "\n \n title: \(String(describing: title)), relevance: \(String(describing: relevance)), ID: \(String(describing: ID)), rating: \(String(describing: rating)), numRatings: \(String(describing: numRatings))"
    }
}


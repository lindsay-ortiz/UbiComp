//
//  CustomRecipeViewController.swift
//  RecipeBox
//
//  Created by Team2 on 10/10/18.
//  Copyright © 2018 Team2. All rights reserved.
//

import UIKit
import Firebase
import FirebaseStorage
import FirebaseDatabase

class CustomRecipeViewController: UIViewController ,UIPickerViewDelegate, UINavigationControllerDelegate, UIImagePickerControllerDelegate, UIPickerViewDataSource,UIActionSheetDelegate{
    
    var ref:DatabaseReference?
    
    @IBOutlet weak var Titletxt: UITextField!
    @IBOutlet weak var IngredientNameTxt: UITextField!
    @IBOutlet weak var quantityTxt: UITextField!
    @IBOutlet weak var measureTxt: UITextField!
    @IBOutlet weak var Proceduretxt: UITextView!
    @IBOutlet weak var filterTxt: UITextField!
    @IBOutlet weak var listArea: UIView!
    

    @IBOutlet weak var placeholder: UILabel!
    @IBOutlet weak var scrollView: UIScrollView!
    
    @IBOutlet weak var SelImg: UIImageView!
    var FilterPicker = UIPickerView()
    var measurePicker = UIPickerView()
    var selectedmeasure: String?
    var selectedFilter: String?
    let measurelist = ["counts","Tsp","tbsp","cups","glasses","pints","ml","liter","kg","pounds"]
    let filterlist = ["Vegetarian", "Non-Vegetarian", "Vegan", "Eggs", "Seafood","Breakfast", "Lunch", "Dinner", "Dessert", "Soup","American", "Italian", "Mediterranean", "Mexican", "Korean", "Chinese", "Vietnamese", "Southwest","Chicken", "Turkey", "Beef", "Pork", "Bacon", "Shrimp"]
    
    
    
    var Ingredients = [String : String]()
    var IngList = [String]()
    var filters = [String]()
    var keylist = [String]()
    var imageData : Data?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        //scrollView.contentSize = CGSize(width: Double(self.view.frame.size.width), height: Double(self.view.frame.size.height))
        
        ref = Database.database().reference()
        createMeasurePicker()
        createFilterPicker()
        
        let toolbar = UIToolbar(frame: CGRect(x: 0, y: 0,  width: self.view.frame.size.width, height: 30))
        let flexSpace = UIBarButtonItem(barButtonSystemItem:    .flexibleSpace, target: nil, action: nil)
        let doneBtn = UIBarButtonItem(title: "Done", style: .done, target: self, action: #selector(CustomRecipeViewController.doneButtonAction))
        toolbar.setItems([flexSpace, doneBtn], animated: false)
        toolbar.sizeToFit()
        
        self.Titletxt.inputAccessoryView = toolbar
        self.IngredientNameTxt.inputAccessoryView = toolbar
        self.quantityTxt.inputAccessoryView = toolbar
        self.measureTxt.inputAccessoryView = toolbar
        self.Proceduretxt.inputAccessoryView = toolbar
        self.filterTxt.inputAccessoryView = toolbar
        
        Proceduretxt.layer.borderColor = #colorLiteral(red: 0.8039215803, green: 0.8039215803, blue: 0.8039215803, alpha: 1)
        Proceduretxt.layer.borderWidth = 1
    }
    
    func createToolbar(){
        let toolBar = UIToolbar()
        toolBar.sizeToFit()
        let doneButton = UIBarButtonItem(title: "Done", style: .plain, target: self, action: #selector(self.dismissKeyboard) )
        toolBar.setItems([doneButton], animated: false)
        toolBar.isUserInteractionEnabled = true
        measureTxt.inputAccessoryView = toolBar
        filterTxt.inputAccessoryView = toolBar
    }
    
    @objc func dismissKeyboard(){
        view.endEditing(true)
    }
    
    func createMeasurePicker(){
        measurePicker.delegate = self
        measurePicker.dataSource = self
        measureTxt.inputView = measurePicker
    }
    func createFilterPicker(){
        FilterPicker.delegate = self
        FilterPicker.dataSource = self
        filterTxt.inputView = FilterPicker
        
    }
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1;
    }
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        var countrows:Int = measurelist.count
        if pickerView == FilterPicker{
            countrows = self.filterlist.count
        }
        return countrows
    }
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        if pickerView == measurePicker{
            let titleRow = measurelist[row]
            return titleRow
        }
        else if pickerView == FilterPicker{
            let titleRow = filterlist[row]
            return titleRow
        }
        
        return ""
    }
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        if pickerView == measurePicker{
            selectedmeasure = self.measurelist[row]
            self.measureTxt.text = selectedmeasure
        }
        if pickerView == FilterPicker{
            self.filterTxt.text = self.filterlist[row]
        }
    }
    
    @IBOutlet weak var IngListArea: UITextView!
    
    @IBAction func AddIngredientBtn(_ sender: UIButton) {
        
        if IngredientNameTxt.text == "" || quantityTxt.text == "" || measureTxt.text == "" {
            let alert = UIAlertController(title: "Error", message: "Please enter name, quantity, and measurement of the ingredient", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
            self.present(alert, animated: true)
        } else {
            guard let _ = Float(quantityTxt.text!) else {
                let alert = UIAlertController(title: "Error", message: "Quantity must be a number", preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
                self.present(alert, animated: true)
                return
            }
            var quantity = quantityTxt.text
            quantity?.append("_")
            quantity?.append(measureTxt.text!)
            Ingredients[IngredientNameTxt.text!] = quantity
            var Ing = IngredientNameTxt.text!;
            Ing.append(" - ")
            Ing.append(quantityTxt.text!)
            Ing.append("_")
            Ing.append(measureTxt.text!)
            IngListArea.text.append(Ing);
            IngListArea.text.append(" , ");
            Ing = ""
            print(Ingredients)
            IngList = Array(Ingredients.keys)
            
            quantityTxt.text = ""
            measureTxt.text = ""
            IngredientNameTxt.text = ""
        }
    }
    
    @IBOutlet weak var FilterArea: UITextView!
    
    @IBAction func AddFilter(_ sender: UIButton) {
        filters.append(filterTxt.text!)
        var Filter = filterTxt.text!;
        FilterArea.text.append(Filter);
        FilterArea.text.append(" , ");
        Filter = ""
        print(filters)
    }
    
    @objc
    func doneButtonAction() {
        self.view.endEditing(true)
    }
    
    @IBAction func imgBtn(_ sender: Any) {
      
        let actionSheetController = UIAlertController(title: "Please select", message: "Select a source for the image", preferredStyle: .actionSheet)
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel) { action -> Void in
        }
        actionSheetController.addAction(cancelAction)
        let takePictureAction = UIAlertAction(title: "Camera", style: .default) { action -> Void in
            let image = UIImagePickerController()
             image.delegate=self
             image.sourceType = UIImagePickerController.SourceType.camera
             image.allowsEditing=false
             self.present(image,animated:true)
             self.placeholder.text=""
        }
        actionSheetController.addAction(takePictureAction)
        let choosePictureAction = UIAlertAction(title: "Gallery", style: .default) { action -> Void in
            
            if UIImagePickerController.isSourceTypeAvailable(UIImagePickerController.SourceType.photoLibrary){
                let image = UIImagePickerController()
                image.delegate=self
                image.sourceType = UIImagePickerController.SourceType.photoLibrary
                image.allowsEditing=false
                self.present(image,animated:true)
                 self.placeholder.text=""
            }
        }
        actionSheetController.addAction(choosePictureAction)
        actionSheetController.popoverPresentationController?.sourceView = self.view
        self.present(actionSheetController, animated: true, completion: nil)
    }
    @objc func imagePickerController(_ picker:UIImagePickerController, didFinishPickingMediaWithInfo info : [UIImagePickerController.InfoKey : Any]){
        if let image = info[UIImagePickerController.InfoKey.originalImage] as? UIImage {
            SelImg.image=image
        }
        else{
            print("error")
        }
        self.dismiss(animated: true , completion: nil)
        
    }
    
    var allowedToUpload = false;
    @IBAction func saveNewRecipe(_ sender: Any) {
        allowedToUpload = true;
        if Titletxt.text == "" {
            allowedToUpload = false;
            let alert = UIAlertController(title: "Error", message: "Missing title of recipe", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
            self.present(alert, animated: true)
        } else if Ingredients.count == 0 {
            allowedToUpload = false;
            let alert = UIAlertController(title: "Error", message: "You have not added any ingredients to this recipe", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
            self.present(alert, animated: true)
        } else if Proceduretxt.text == "" {
            allowedToUpload = false;
            let alert = UIAlertController(title: "Error", message: "Missing steps to prepare recipe", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
            self.present(alert, animated: true)
        } else if (allowedToUpload == true) {
            allowedToUpload = false;
            var title = self.Titletxt.text!
            keylist = Titletxt.text!.components(separatedBy: " ").map{$0.capitalized}
            let storageRef = Storage.storage().reference().child("Images")
            var uid : String?
            self.imageData = self.SelImg.image!.jpegData(compressionQuality: 0.5)
            let recipeReference = ref?.child("DatabaseA")
            let idRef = recipeReference?.child("Details")
            let titleref = recipeReference?.child("Titles")
            let rateref = recipeReference?.child("Ratings")
            let filterRef = recipeReference?.child("Filters")
            let ingRef = recipeReference?.child("Ingredients")
            let keyref = recipeReference?.child("SearchKeywords")
            let detref = idRef?.childByAutoId()
            uid = detref?.key
            
            var procedure = Proceduretxt.text!
            let values = ["Ingredients": Ingredients ,"Procedure": procedure] as [String : Any]
            detref?.updateChildValues(values)
          
            //idRef?.queryLimited(toLast: 1).observe(.childAdded, with:{ DataSnapshot in
              //  uid = DataSnapshot.key
                titleref!.child(uid!).setValue(title)
                let ratings = ["NumberOfRatings": 0 ,"Rating": 0]
                let rref =  rateref?.child(uid!)
                rref?.updateChildValues(ratings)
                for i in 0 ... self.filters.count-1{
                    filterRef!.child(self.filters[i]).child(uid!).setValue(true)
                }
                for i in 0 ... self.IngList.count-1{
                    ingRef!.child(self.IngList[i]).child(uid!).setValue(true)
                }
                for i in 0 ... self.keylist.count-1{
                    print("NOW PRINTING KEYLIST \(self.keylist)")
                    keyref!.child(self.keylist[i]).child(uid!).setValue(true)
                }
                let imagePath = uid! + ".jpg"
                let imageref = storageRef.child(imagePath)
                imageref.putData(self.imageData! , metadata:nil, completion:{
                    (metadata,error) in
                    if error != nil{
                        print(error!)
                        return
                    }
                    print(metadata!)
                })
            
            RecipeService.addIDToCustomRecipes(input: uid!)
            RecipeService.showToast(message: "Recipe Submitted Successfully", view: self.view)
            self.Titletxt.text = ""
            self.IngredientNameTxt.text = ""
            self.quantityTxt.text = ""
            self.measureTxt.text = ""
            self.Proceduretxt.text = ""
            self.filterTxt.text = ""
            self.IngListArea.text = ""
            self.FilterArea.text = ""
            self.SelImg.image = UIImage()
            title = ""
            procedure = ""
            self.Ingredients.removeAll()
            self.IngList.removeAll()
            self.filters.removeAll()
            self.keylist.removeAll()
            self.imageData = nil
            uid = ""
            placeholder.text = "Chosen Image Shows Up Here"
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
}

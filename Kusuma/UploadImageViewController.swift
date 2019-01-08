//
//  UploadImageViewController.swift
//  RecipeBox
//
//  Created by Team2 on 10/19/18.
//  Copyright © 2018 Team2. All rights reserved.
//

import UIKit

class UploadImageViewController: UIViewController,UINavigationControllerDelegate,UIImagePickerControllerDelegate {
    @IBOutlet weak var SelImg: UIImageView!
    override func viewDidLoad() {
        super.viewDidLoad()
         //self.navigationController?.navigationBar.isHidden = false
    }
    
    @IBAction func SelectFrmGallerybtn(_ sender: UIButton) {
        if UIImagePickerController.isSourceTypeAvailable(UIImagePickerController.SourceType.photoLibrary){
        let image = UIImagePickerController()
        image.delegate=self
        image.sourceType = UIImagePickerController.SourceType.photoLibrary
        image.allowsEditing=false
        self.present(image,animated:true)
      }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "signinTouser" {
            let segueUser = segue.destination as!CustomRecipeViewController
            let imgData = SelImg.image!.pngData()
            segueUser.imageData = imgData
        }
    }
    
    @IBAction func SaveButton(_ sender: UIButton) {
        let imageData = SelImg.image!.pngData()
        let compressedImage = UIImage(data: imageData!)
        UIImageWriteToSavedPhotosAlbum(compressedImage!, nil, nil ,nil )
        let alert = UIAlertController(title: "Saved",message: "Your Image Has Been Saved",preferredStyle: .alert)
        let okAction = UIAlertAction(title: "ok",style: .default, handler: nil)
        alert.addAction(okAction)
        self.performSegue(withIdentifier: "imageUploaded", sender: self)
        self.present(alert, animated: true, completion: nil)
    }
   /*
    @IBAction func UseCamerabtn(_ sender: UIButton) {
        let image = UIImagePickerController()
        image.delegate=self
        image.sourceType = UIImagePickerController.SourceType.camera
        image.allowsEditing=false
        self.present(image,animated:true)
    }
    */
    @objc func imagePickerController(_ picker:UIImagePickerController, didFinishPickingMediaWithInfo info : [UIImagePickerController.InfoKey : Any]){
        if let image = info[UIImagePickerController.InfoKey.originalImage] as? UIImage {
           SelImg.image=image
        }
        else{
            print("error")
        }
        self.dismiss(animated: true , completion: nil)
        
    }
    
    /*
    func imagePickerController(_ picker:UIImagePickerController, didFinishPickingMediaWithInfo info : [String : Any]){
        if let image = info[UIImagePickerControllerOriginalImage] as? UIImage {
            //SelImg.image=image
        }
        else{
            
        }
        self.dismiss(animated: true , completion: nil)
        
    }*/
}

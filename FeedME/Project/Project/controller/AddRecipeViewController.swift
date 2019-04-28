//
//  AddRecipeViewController.swift
//  Project
//
//  Created by Deepak Chandwani on 12/8/18.
//  Copyright © 2018 Deepak Chandwani. All rights reserved.
//

import UIKit
import AWSDynamoDB
import AWSS3
import Photos

class AddRecipeViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate, UIPickerViewDataSource, UIPickerViewDelegate {

    @IBOutlet weak var cuisineSelector: UIPickerView!
    @IBOutlet weak var recipeTitle: UITextField!
    @IBOutlet weak var cookingTime: UITextField!
    @IBOutlet weak var servings: UITextField!
    @IBOutlet weak var recipeImageView: UIImageView!
    @IBOutlet weak var methodOfPreparation: UITextView!
    @IBOutlet weak var recipeDescription: UITextView!
    @IBOutlet weak var recipeIngredients: UITextView!
    
    
    let imagePicker = UIImagePickerController()
    var galleryAccessGranted: Bool = false
    let cuisine: [Cuisine] = CuisineArray.cuisineArray!
    var cuisineId: String?
    let bucketName = "mybucket10771/recipeImage"
    var authorName: String?
    var authorEmail: String?
    let timestamp = NSDate().timeIntervalSince1970
    let appName = "FeedME"
    
    var isTitleSet = false, isDescriptionSet = false, isIngredientsSet = false, isMethodSet = false, isCookingTimeSet = false, isServingsSet = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "Add Recipe"
        // Connect data:
        self.cuisineSelector.delegate = self
        self.cuisineSelector.dataSource = self
        
        imagePicker.delegate = self
        
        let defaults = UserDefaults.standard
        authorName = defaults.string(forKey: "name")!
        authorEmail = defaults.string(forKey: "email")!
        // Do any additional setup after loading the view.
    }
    
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1;
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return cuisine.count
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return cuisine[row]._cuisine
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        
        self.cuisineId = self.cuisine[row]._cuisineId
        //self.dropDown.isHidden = true
    }
    
    
    @IBAction func makeYourContribution(_ sender: Any) {
        // Recipe Title
        if recipeTitle.text!.count > 0{
            isTitleSet = true
        }else{
            isTitleSet = false
            let alert = UIAlertController(title: appName, message: "Title Required)", preferredStyle: .alert)
            let action = UIAlertAction(title: "Ok", style: .cancel, handler: nil)
            alert.addAction(action)
            UIApplication.shared.keyWindow?.rootViewController?.present(alert, animated: true, completion: nil)
        }
        
        // Recipe Description
        if recipeDescription.text!.count > 0{
            isDescriptionSet = true
        }else{
            isDescriptionSet = false
            let alert = UIAlertController(title: appName, message: "Description Required)", preferredStyle: .alert)
            let action = UIAlertAction(title: "Ok", style: .cancel, handler: nil)
            alert.addAction(action)
            UIApplication.shared.keyWindow?.rootViewController?.present(alert, animated: true, completion: nil)
        }
        
        // Recipe Ingredients
        if recipeIngredients.text!.count > 0{
            isIngredientsSet = true
        }else{
            isIngredientsSet = false
            let alert = UIAlertController(title: appName, message: "Ingredients Required)", preferredStyle: .alert)
            let action = UIAlertAction(title: "Ok", style: .cancel, handler: nil)
            alert.addAction(action)
            UIApplication.shared.keyWindow?.rootViewController?.present(alert, animated: true, completion: nil)
        }
        
        // Recipe MethodOfPreparation
        if methodOfPreparation.text!.count > 0{
            isMethodSet = true
        }else{
            isMethodSet = false
            let alert = UIAlertController(title: appName, message: "Method of Preparation Required)", preferredStyle: .alert)
            let action = UIAlertAction(title: "Ok", style: .cancel, handler: nil)
            alert.addAction(action)
            UIApplication.shared.keyWindow?.rootViewController?.present(alert, animated: true, completion: nil)
        }
        
        // Recipe Cooking Time
        if cookingTime.text!.count > 0{
            isCookingTimeSet = true
        }else{
            isCookingTimeSet = false
            let alert = UIAlertController(title: appName, message: "Cooking Time Required)", preferredStyle: .alert)
            let action = UIAlertAction(title: "Ok", style: .cancel, handler: nil)
            alert.addAction(action)
            UIApplication.shared.keyWindow?.rootViewController?.present(alert, animated: true, completion: nil)
        }
        
        // Recipe Servings
        if servings.text!.count > 0{
            isServingsSet = true
        }else{
            isServingsSet = false
            let alert = UIAlertController(title: appName, message: "Servings Required)", preferredStyle: .alert)
            let action = UIAlertAction(title: "Ok", style: .cancel, handler: nil)
            alert.addAction(action)
            UIApplication.shared.keyWindow?.rootViewController?.present(alert, animated: true, completion: nil)
        }
        
        if isTitleSet && isDescriptionSet && isIngredientsSet && isMethodSet && isCookingTimeSet && isServingsSet{
                uploadButtonPressed()
        }else{
            
            let alert = UIAlertController(title: appName, message: "All fields are required)", preferredStyle: .alert)
            let action = UIAlertAction(title: "Ok", style: .cancel, handler: nil)
            alert.addAction(action)
            UIApplication.shared.keyWindow?.rootViewController?.present(alert, animated: true, completion: nil)
        }
        
        
    }
    
    @IBAction func chooseImage(_ sender: Any) {
        checkPermission()
        if galleryAccessGranted {
            self.imagePicker.allowsEditing = true
            self.imagePicker.sourceType = .photoLibrary
            self.present(self.imagePicker, animated: true, completion: nil)
        }
    }
    
    func checkPermission() {
        let photoAuthorizationStatus = PHPhotoLibrary.authorizationStatus()
        switch photoAuthorizationStatus {
        case .authorized:
            print("Access is granted by user")
            galleryAccessGranted = true
        case .notDetermined:
            PHPhotoLibrary.requestAuthorization({
                (newStatus) in
                print("status is \(newStatus)")
                if newStatus ==  PHAuthorizationStatus.authorized {
                    /* do stuff here */
                    print("Permission Granted success")
                    self.galleryAccessGranted = true                    
                }
            })
            print("It is not determined until now")
        case .restricted:
            // same same
            print("User do not have access to photo album.")
        case .denied:
            // same same
            print("User has denied the permission.")
        }
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        print("inside imagePickerController")
        var selectedImageFromPicker: UIImage?
        if let editedImage = info[.editedImage] as? UIImage {
            selectedImageFromPicker = editedImage
        } else if let originalImage = info[.originalImage] as? UIImage {
            selectedImageFromPicker = originalImage
        }
        
        if let selectedImage = selectedImageFromPicker {
            recipeImageView.image = selectedImage
        }
        dismiss(animated: true, completion: nil)
    }
    
    
    func addRecipe()
    {
        let objectMapper = AWSDynamoDBObjectMapper.default()

        let itemToCreate:Recipes = Recipes()
        itemToCreate._recipeId = recipeTitle.text!+String(timestamp)
        itemToCreate._authorFullName = authorName
        itemToCreate._userId = authorEmail
        itemToCreate._cuisine = self.cuisineId
        itemToCreate._imageKey = authorEmail!+String(timestamp)
        itemToCreate._description = recipeDescription.text!
        itemToCreate._cookingTime = cookingTime.text!
        itemToCreate._ingredients = recipeIngredients.text!
        itemToCreate._methodOfPreparation = methodOfPreparation.text!
        itemToCreate._servesTo = servings.text!
        itemToCreate._title = recipeTitle.text!
        itemToCreate._totalUserRatings = 3
        itemToCreate._totalUsersRated = 1
        itemToCreate._totalViews = 1
        itemToCreate._videoKey = recipeTitle.text!.trimmingCharacters(in: NSCharacterSet.whitespaces)+String(timestamp)
        
        objectMapper.save(itemToCreate, completionHandler: {(error: Error?) -> Void in
            if let error = error{
                print("Amazon DynamoDB save Error \(error)")
                return
            }
            print("Recipe uploaded")
            self.isTitleSet = false
            self.isDescriptionSet = false
            self.isIngredientsSet = false
            self.isMethodSet = false
            self.isCookingTimeSet = false
            self.isServingsSet = false
            
            let alert = UIAlertController(title: self.appName, message: "Thank you for your contribution in FeedME", preferredStyle: .alert)
            let action = UIAlertAction(title: "Ok", style: .cancel, handler: nil)
            alert.addAction(action)
            UIApplication.shared.keyWindow?.rootViewController?.present(alert, animated: true, completion: nil)
        })
    }
    
    func uploadButtonPressed() {
        
        let image = recipeImageView.image!
        let fileManager = FileManager.default
        let path = (NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0] as NSString).appendingPathComponent(authorEmail!)
        let imageData = image.jpegData(compressionQuality: 1)
        fileManager.createFile(atPath: path as String, contents: imageData, attributes: nil)
        
        let fileUrl = NSURL(fileURLWithPath: path)
        let uploadRequest = AWSS3TransferManagerUploadRequest()
        uploadRequest?.bucket = bucketName
        uploadRequest?.key = authorEmail!+String(timestamp)
        uploadRequest?.contentType = "image/jpeg"
        uploadRequest?.body = fileUrl as URL
        //uploadRequest?.serverSideEncryption = AWSS3ServerSideEncryption.awsKms
        uploadRequest?.uploadProgress = { (bytesSent, totalBytesSent, totalBytesExpectedToSend) -> Void in
            DispatchQueue.main.async(execute: {
                print("totalBytesSent",totalBytesSent)
                print("totalBytesExpectedToSend",totalBytesExpectedToSend)
            })
        }
        
        let transferManager = AWSS3TransferManager.default()
        transferManager.upload(uploadRequest!).continueWith(executor: AWSExecutor.mainThread(), block: { (task:AWSTask<AnyObject>) -> Any? in
            if task.error != nil {
                // Error.
                print("\(task.error)")
            } else {
                // Do something with your result.
                self.addRecipe()
                /*
                let alert = UIAlertController(title: "Upload Successful", message: nil, preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "OK", style: .default, handler: { action in
                    
                    //self.myImageView.image = UIImage(named:self.fileArray[0])
                }))
                self.present(alert, animated: true)
 */
                print("No error Upload Done")
            }
            return nil
        })
        
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}

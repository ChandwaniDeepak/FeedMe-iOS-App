//
//  ViewController.swift
//  Project
//
//  Created by Deepak Chandwani on 11/16/18.
//  Copyright © 2018 Deepak Chandwani. All rights reserved.
//

import UIKit
import AWSMobileClient
import AWSAuthCore
import AWSDynamoDB
import AWSS3
import Photos

class ViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    let deviceId: String = (UIDevice.current.identifierForVendor?.uuidString)!
    let adminName = "DeepakChandwani"
    @IBOutlet weak var myImageView: UIImageView!
    
    let bucketName = "mybucket10771"
    var contentUrl: URL!
    var s3Url: URL!
    
    let imagePicker = UIImagePickerController()
    var galleryAccessGranted: Bool = false
    
    let fileArray = ["earth", "neptune", "saturn"]

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        imagePicker.delegate = self
        //myImageView.image = UIImage(named: "neptune")
        postToDB()
        getDataFromDynamoDB()
        
        
        
        // Initialize the Amazon Cognito credentials provider
        
        //let credentialsProvider = AWSCognitoCredentialsProvider(regionType:.USEast1,                                                                identityPoolId:"us-east-1:971d7676-cd7d-4c17-bf07-49928fee0cc9")
        
        
        // Get the AWSCredentialsProvider from the AWSMobileClient
        let credentialsProvider = AWSMobileClient.sharedInstance().getCredentialsProvider()
        
        // Get the identity Id from the AWSIdentityManager
        let identityId = AWSIdentityManager.default().identityId
        
        let configuration = AWSServiceConfiguration(region:.USEast1, credentialsProvider:credentialsProvider)
        
        AWSServiceManager.default().defaultServiceConfiguration = configuration
        
        s3Url = AWSS3.default().configuration.endpoint.url
        print(s3Url.absoluteString+"/mybucket10771/bmw-x6-wallpaper-16.jpg")
        let fileURL = URL(string: s3Url.absoluteString+"/mybucket10771/bmw-x6-wallpaper-16.jpg")
      
        print(fileURL!)
        
        myImageView.load(url: fileURL!)
        //myImageView.load(url: <#T##URL#>)
    }
    
    func postToDB(){
        let cui:[String] = ["Indian", "Chinese", "Mexican", "Italian", "Thai", "Mughlai"]
        let cuiImg:[String] = ["Indian", "Chinese", "Mexican", "Italian", "Thai", "Mughlai"]
        let objectMapper = AWSDynamoDBObjectMapper.default()
        for i in 0...5{
            //var i=1
            let itemToCreate:Cuisine = Cuisine()
            let _cuisineId:String = "cui1"
            itemToCreate._cuisineId = _cuisineId
            itemToCreate._cuisine = "Indian"
            itemToCreate._imageKey = "Indian"
            objectMapper.save(itemToCreate, completionHandler: {(error: Error?) -> Void in
                if let error = error{
                    print("Amazon DynamoDB save Error \(error)")
                    return
                }
                print("userData saved")
            })
        }
        
    }
    
    func getDataFromDynamoDB(){
        let objectMapper = AWSDynamoDBObjectMapper.default()
        let queryExpression = AWSDynamoDBQueryExpression()
        queryExpression.keyConditionExpression = "#userId = :userId"
        queryExpression.expressionAttributeNames = [
            "#userId" : "userId",
        ]
        queryExpression.expressionAttributeValues = [
            ":userId" : deviceId,
        ]
        
        
        
        
    }
    
    @IBAction func upload(_ sender: Any) {
        uploadButtonPressed()
    }
    func uploadButtonPressed() {
        
        let timestamp = NSDate().timeIntervalSince1970
        
        let image = myImageView.image!
        let fileManager = FileManager.default
        let path = (NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0] as NSString).appendingPathComponent(fileArray[1])
        let imageData = image.jpegData(compressionQuality: 1)
        fileManager.createFile(atPath: path as String, contents: imageData, attributes: nil)
        
        let fileUrl = NSURL(fileURLWithPath: path)
        let uploadRequest = AWSS3TransferManagerUploadRequest()
        uploadRequest?.bucket = bucketName
        uploadRequest?.key = adminName+String(timestamp)
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
                let alert = UIAlertController(title: "Upload Successful", message: nil, preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "OK", style: .default, handler: { action in
                    
                    self.myImageView.image = UIImage(named:self.fileArray[0])
                }))
                self.present(alert, animated: true)
                print("No error Upload Done")
            }
            return nil
        })
        
    }
    
    @IBAction func load(_ sender: Any) {
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
                myImageView.image = selectedImage
            }
            dismiss(animated: true, completion: nil)
        }
}

extension UIImageView {
    func load(url: URL) {
        print("inside load")
        print(url)
        DispatchQueue.global().async { [weak self] in
            if let data = try? Data(contentsOf: url) {
                if let image = UIImage(data: data) {
                    DispatchQueue.main.async {
                        self?.image = image
                    }
                }
            }else{
                print("data is nil in load")
            }
        }
    }
}


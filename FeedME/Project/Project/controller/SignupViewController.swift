//
//  SignupViewController.swift
//  Project
//
//  Created by Deepak Chandwani on 12/3/18.
//  Copyright © 2018 Deepak Chandwani. All rights reserved.
//

import UIKit
import AWSDynamoDB

class SignupViewController: UIViewController {

    @IBOutlet weak var firstName: UITextField!
    @IBOutlet weak var lastName: UITextField!
    @IBOutlet weak var email: UITextField!
    @IBOutlet weak var password: UITextField!
    @IBOutlet weak var confirmPassword: UITextField!
    
    
    let deviceId: String = (UIDevice.current.identifierForVendor?.uuidString)!
    var isEmailSet = false, isFirstNameSet = false, isLastNameSet = false, isPasswordSet = false, isConfirmPasswordSet = false, isPasswordMatch = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "Sign up"
        password.isSecureTextEntry.toggle()
        confirmPassword.isSecureTextEntry.toggle()
        // Do any additional setup after loading the view.
    }
    @IBAction func signupButton(_ sender: Any) {
        if (firstName.text?.count)! > 3
        {
            isFirstNameSet = true
        }else{
            isFirstNameSet = false
            let alert = UIAlertController(title: "FeedME", message: "Atleast 3 letters required in FirstName", preferredStyle: .alert)
            let action = UIAlertAction(title: "Ok", style: .cancel, handler: nil)
            alert.addAction(action)
            UIApplication.shared.keyWindow?.rootViewController?.present(alert, animated: true, completion: nil)
        }
        if (lastName.text?.count)! > 3
        {
            isLastNameSet = true
        }else{
            isLastNameSet = false
            let alert = UIAlertController(title: "FeedME", message: "Atleast 3 letters required in LastName", preferredStyle: .alert)
            let action = UIAlertAction(title: "Ok", style: .cancel, handler: nil)
            alert.addAction(action)
            UIApplication.shared.keyWindow?.rootViewController?.present(alert, animated: true, completion: nil)
        }
        if (email.text?.count)! > 5
        {
            isEmailSet = true
        }else{
            isEmailSet = false
            let alert = UIAlertController(title: "FeedME", message: "Atleast 5 letters required in Email", preferredStyle: .alert)
            let action = UIAlertAction(title: "Ok", style: .cancel, handler: nil)
            alert.addAction(action)
            UIApplication.shared.keyWindow?.rootViewController?.present(alert, animated: true, completion: nil)
        }
        if (password.text?.count)! > 3
        {
            isPasswordSet = true
        }else{
            isPasswordSet = false
            let alert = UIAlertController(title: "FeedME", message: "Atleast 3 letters required in Password", preferredStyle: .alert)
            let action = UIAlertAction(title: "Ok", style: .cancel, handler: nil)
            alert.addAction(action)
            UIApplication.shared.keyWindow?.rootViewController?.present(alert, animated: true, completion: nil)
        }
        if (confirmPassword.text?.count)! > 3
        {
            isConfirmPasswordSet = true
        }else{
            isConfirmPasswordSet = false
            let alert = UIAlertController(title: "FeedME", message: "Atleast 3 letters required in LastName", preferredStyle: .alert)
            let action = UIAlertAction(title: "Ok", style: .cancel, handler: nil)
            alert.addAction(action)
            UIApplication.shared.keyWindow?.rootViewController?.present(alert, animated: true, completion: nil)
        }
        if isPasswordSet && isConfirmPasswordSet
        {
            if (password.text)! == (confirmPassword.text)!
            {
                isPasswordMatch = true
            }else{
                isPasswordMatch = false
                let alert = UIAlertController(title: "FeedME", message: "Password doesnot match", preferredStyle: .alert)
                let action = UIAlertAction(title: "Ok", style: .cancel, handler: nil)
                alert.addAction(action)
                UIApplication.shared.keyWindow?.rootViewController?.present(alert, animated: true, completion: nil)
                password.text = ""
                confirmPassword.text = ""
            }
        }
        
        if isFirstNameSet && isLastNameSet && isEmailSet && isPasswordMatch{
            var emailFound = checkEmailExists()
            print("emailFound:- \(emailFound)")
            
            
        }
    }
    
    func addUserToDynamoDB() -> String
    {
        var registered: String = ""
        let objectMapper = AWSDynamoDBObjectMapper.default()

        let itemToCreate:Users = Users()
        
        itemToCreate._userId = email.text!
        itemToCreate._deviceId = deviceId
        itemToCreate._firstName = firstName.text!
        itemToCreate._lastName = lastName.text!
        itemToCreate._imageKey = "user.png"
        itemToCreate._password = password.text!
        
        objectMapper.save(itemToCreate, completionHandler: {(error: Error?) -> Void in
            if let error = error{
                print("Amazon DynamoDB save Error \(error)")
                return
            }
            //if error == nil{return false}
            self.isEmailSet = false
            self.isFirstNameSet = false
            self.isLastNameSet = false
            self.isPasswordSet = false
            self.isConfirmPasswordSet = false
            self.isPasswordMatch = false
            
            print("User Registered Successfully")
            registered = "true"
        })
        
        let delayTime = DispatchTime.now() + 1
        DispatchQueue.main.asyncAfter(deadline: delayTime) {
            if registered == "true"{
                let alert = UIAlertController(title: "FeedME", message: "User added successfully", preferredStyle: .alert)
                let action = UIAlertAction(title: "Ok", style: .cancel, handler: nil)
                alert.addAction(action)
                UIApplication.shared.keyWindow?.rootViewController?.present(alert, animated: true, completion: nil)
                self.firstName.text = ""
                self.lastName.text = ""
                self.email.text = ""
                self.password.text = ""
                self.confirmPassword.text = ""
            }
        }
            
        
        print("userRegistered:- \(registered)")
        return registered
    }
    
    func checkEmailExists() -> String{
        var emailFound: String = ""
        let objectMapper = AWSDynamoDBObjectMapper.default()
        let queryExpression = AWSDynamoDBQueryExpression()
        queryExpression.keyConditionExpression = "#userId = :userId"
        queryExpression.expressionAttributeNames = [
            "#userId" : "userId",
        ]
        queryExpression.expressionAttributeValues = [
            ":userId" : email.text!,
        ]
        objectMapper.query(Users.self, expression: queryExpression, completionHandler: {(response: AWSDynamoDBPaginatedOutput?, error: Error?) -> Void in
            if let error = error{
                print("The request failed. Error: \(error)")
            }
            DispatchQueue.main.async(execute:{
                //print("querying")
                if response != nil{
                    //print("got a response")
                    if(response!.items.count == 0){
                        emailFound = "false"
                        print("email not found, GOOD TO GO")
                        var result = self.addUserToDynamoDB()                        
                    }else{
                        print("Email found in DB, and CANNOT BE USED")
                        emailFound = "true"
                        print("email not allowed")
                        let alert = UIAlertController(title: "FeedME", message: "Email exists!\n try other email id", preferredStyle: .alert)
                        let action = UIAlertAction(title: "Ok", style: .cancel, handler: nil)
                        alert.addAction(action)
                        UIApplication.shared.keyWindow?.rootViewController?.present(alert, animated: true, completion: nil)
                        
                    }
                }
            })
        })
        print("emailFound:- \(emailFound)")
        return emailFound
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

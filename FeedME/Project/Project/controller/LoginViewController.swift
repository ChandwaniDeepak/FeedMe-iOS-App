//
//  LoginViewController.swift
//  Project
//
//  Created by Deepak Chandwani on 12/3/18.
//  Copyright © 2018 Deepak Chandwani. All rights reserved.
//

import UIKit
import AWSDynamoDB
import AWSCognito
import AWSMobileClient
import AWSAuthCore

class LoginViewController: UIViewController {

    
    @IBOutlet weak var email: UITextField!
    @IBOutlet weak var password: UITextField!
    var isEmailSet: Bool = false, isPasswordSet: Bool = false, isUserFound = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "Login"
        password.isSecureTextEntry.toggle()
      
        // Do any additional setup after loading the view.
    }
    

    @IBAction func loginButton(_ sender: Any) {
       if (email.text?.count)!>5{
            isEmailSet = true
       }else{
            // Atleast 5 letters required in email
        isEmailSet = false
        let alert = UIAlertController(title: "FeedME", message: "Atleast 5 letters required in email", preferredStyle: .alert)
        let action = UIAlertAction(title: "Ok", style: .cancel, handler: nil)
        alert.addAction(action)
        UIApplication.shared.keyWindow?.rootViewController?.present(alert, animated: true, completion: nil)
        }
        if (password.text?.count)! > 3{
            isPasswordSet = true
        }else{
            // Atleast 5 letters required in password
            isPasswordSet = false
            let alert = UIAlertController(title: "FeedME", message: "Atleast 3 letters required in password", preferredStyle: .alert)
            let action = UIAlertAction(title: "Ok", style: .cancel, handler: nil)
            alert.addAction(action)
            UIApplication.shared.keyWindow?.rootViewController?.present(alert, animated: true, completion: nil)
        }
        
        if isEmailSet && isPasswordSet {
            
            let objectMapper = AWSDynamoDBObjectMapper.default()
            let queryExpression = AWSDynamoDBQueryExpression()
            /*
            queryExpression.keyConditionExpression = "#userId = :userId AND #password = :password"
            queryExpression.expressionAttributeNames = [
                "#userId" : "userId",
                "#password" : "password",
            ]
            queryExpression.expressionAttributeValues = [
                ":userId" : email.text!,
                ":password" : password.text!,
            ]
            */
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
                    print("querying")
                    if response != nil{
                        print("got a response")
                        if(response!.items.count == 0){
                            self.isUserFound = false
                            print("response!.items.count == 0")
                        }else{
                            print("response!.items.count \(response!.items.count)")
                            self.isUserFound = true
                            for item in ((response?.items)!){
                                let pass = item.value(forKey: "_password") as! NSString
                                if String(pass) == (self.password.text){
                                    let defaults = UserDefaults.standard
                                    let userEmail = item.value(forKey: "_userId") as! NSString
                                    let firstName = item.value(forKey: "_firstName") as! NSString
                                    let lastName = item.value(forKey: "_lastName") as! NSString
                                    //print(userEmail)
                                    let name: String = "\(firstName) \(lastName)"
                                    defaults.set(userEmail, forKey: "email")
                                    defaults.set(name, forKey:"name")
                                    defaults.set(true, forKey: "isLoggedIn")
                                    
                                    // remove all views from
                                    if let appDelegate = UIApplication.shared.delegate as? AppDelegate {
                                        appDelegate.window?.rootViewController?.dismiss(animated: true, completion: nil)
                                        (appDelegate.window?.rootViewController as? UINavigationController)?.popToRootViewController(animated: true)
                                        print("remove all views from")
                                    }
                                    
                                }else{
                                    self.isUserFound = false
                                }
                            }
                        }
                    }
                })
            })
            
            
        }else{
            print("something went wrong user not logged in")
        }
        if !isUserFound{
            print("User Found")
        }else{
            print("isUserFound:- \(isUserFound)")
            let alert = UIAlertController(title: title, message: "Email AND/OR Password doesnot match\n try again!", preferredStyle: .alert)
            let action = UIAlertAction(title: "Ok", style: .cancel, handler: nil)
            alert.addAction(action)
            UIApplication.shared.keyWindow?.rootViewController?.present(alert, animated: true, completion: nil)
        }
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

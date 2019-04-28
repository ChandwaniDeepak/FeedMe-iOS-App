//
//  ProfileViewController.swift
//  Project
//
//  Created by Deepak Chandwani on 12/8/18.
//  Copyright © 2018 Deepak Chandwani. All rights reserved.
//

import UIKit
import AWSDynamoDB

class ProfileViewController: UIViewController {

    var yourContributions: [Recipes] = []
    
    
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "Profile"
      
        // Do any additional setup after loading the view.
    }
    
    @IBAction func logout(_ sender: Any) {
        let defaults = UserDefaults.standard
        
        defaults.removeObject(forKey: "email")
        defaults.removeObject(forKey:"name")
        defaults.set(false, forKey: "isLoggedIn")
        defaults.synchronize()
        
        // remove all views from
        if let appDelegate = UIApplication.shared.delegate as? AppDelegate {
            appDelegate.window?.rootViewController?.dismiss(animated: true, completion: nil)
            (appDelegate.window?.rootViewController as? UINavigationController)?.popToRootViewController(animated: true)
            print("Logout Pressed")
        }
    }
    
   
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
        if let destination = segue.destination as? MyContributionViewController{
            print("prepare segue")
            //destination.recipeArray = yourContributions
        }
    }
 */
    

}

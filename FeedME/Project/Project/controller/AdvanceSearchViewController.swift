//
//  AdvanceSearchViewController.swift
//  Project
//
//  Created by Deepak Chandwani on 12/8/18.
//  Copyright © 2018 Deepak Chandwani. All rights reserved.
//

import UIKit
import AWSDynamoDB

class AdvanceSearchViewController: UIViewController {

    @IBOutlet weak var ingredient1: UITextField!
    @IBOutlet weak var ingredient2: UITextField!
    @IBOutlet weak var ingredient3: UITextField!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    var recipeArray:[Recipes] = []
    var recipeSearchResultArray:[Recipes] = []
    var ing1: String = "", ing2: String = "", ing3: String = ""
    var checkIng1: Bool = false, checkIng2: Bool = false, checkIng3: Bool = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "Search"
        
        getRecipesFromDynamoDB()
        // Do any additional setup after loading the view.
    }
    
    @IBAction func getMeRecipe(_ sender: Any) {
        checkIng1 = false
        checkIng2 = false
        checkIng3 = false
       activityIndicator.startAnimating()
        if ingredient1.text!.count > 0 {
            // has something
            checkIng1 = true
            if ingredient2.text!.count > 0 {
                // has something
                checkIng2 = true
                if ingredient3.text!.count > 0 {
                    // has something
                    checkIng3 = true
                    // search with param1, param2, param3
                    getRecipe(i1: ingredient1.text!, i2: ingredient1.text!, i3: ingredient1.text!)
                }else{
                    // empty
                    checkIng3 = false
                    // search with param1, param2
                    getRecipe(i1: ingredient1.text!, i2: ingredient2.text!)
                }
            }else{
                // empty
                checkIng2 = false
                getRecipe(i1: ingredient1.text!)
                // search with param1
            }
        }else{
            // empty
            checkIng1 = false
            activityIndicator.stopAnimating()
            let alert = UIAlertController(title: "FeedME", message: "Atleast ONE ingredient is required", preferredStyle: .alert)
            let action = UIAlertAction(title: "Ok", style: .cancel, handler: nil)
            alert.addAction(action)
            UIApplication.shared.keyWindow?.rootViewController?.present(alert, animated: true, completion: nil)
        }
    }
    
    func getRecipesFromDynamoDB(){
        print("inside get recipes")
        let scanExpression = AWSDynamoDBScanExpression()
        let objectMapper = AWSDynamoDBObjectMapper.default()
        scanExpression.limit = 400
        
        objectMapper.scan(Recipes.self, expression: scanExpression).continueWith(block: { (task:AWSTask<AWSDynamoDBPaginatedOutput>!) -> Any? in
            if let error = task.error as NSError? {
                print("The request failed. Error: \(error)")
            } else if let paginatedOutput = task.result {
                for recipe in paginatedOutput.items as! [Recipes] {
                    // Do something with recipe.
                    self.recipeArray.append(recipe)
                }
                if self.recipeArray.count == 0{
                    print("No Recipe found for current search")
                    let alert = UIAlertController(title: self.title, message: "No Recipe found with provided ingredients", preferredStyle: .alert)
                    let action = UIAlertAction(title: "Ok", style: .cancel, handler: nil)
                    alert.addAction(action)
                    UIApplication.shared.keyWindow?.rootViewController?.present(alert, animated: true, completion: nil)
                }else{
                    print(self.recipeArray.count)
                }
            }
            return ()
        })
        
    }
    

    func getRecipe(i1: String){
        print("getRecipe 1")
        recipeSearchResultArray.removeAll()
        for r in recipeArray{
            if (r._ingredients?.contains(i1))!{
            recipeSearchResultArray.append(r)
            }
        }
        if recipeSearchResultArray.count == 0{
            let alert = UIAlertController(title: "FeedME", message: "No results found, try changing ingredient(s)", preferredStyle: .alert)
            let action = UIAlertAction(title: "Ok", style: .cancel, handler: nil)
            alert.addAction(action)
            UIApplication.shared.keyWindow?.rootViewController?.present(alert, animated: true, completion: nil)
        }else{
            print("recipeSearchResultArray.count \(recipeSearchResultArray.count)")
            // Segue to the second view controller
            self.performSegue(withIdentifier: "advanceSearchResultSegue", sender: self)
        }
        activityIndicator.stopAnimating()
    }
    func getRecipe(i1: String, i2: String){
        print("getRecipe 1, 2")
        recipeSearchResultArray.removeAll()
        for r in recipeArray{
            if ((r._ingredients?.contains(i1))! && ((r._ingredients?.contains(i2)))!){
                recipeSearchResultArray.append(r)
            }
        }
        if recipeSearchResultArray.count == 0{
            let alert = UIAlertController(title: "FeedME", message: "No results found, try changing ingredient(s)", preferredStyle: .alert)
            let action = UIAlertAction(title: "Ok", style: .cancel, handler: nil)
            alert.addAction(action)
            UIApplication.shared.keyWindow?.rootViewController?.present(alert, animated: true, completion: nil)
        }else{
            print("recipeSearchResultArray.count \(recipeSearchResultArray.count)")
            // Segue to the second view controller
            self.performSegue(withIdentifier: "advanceSearchResultSegue", sender: self)
        }
        activityIndicator.stopAnimating()
    }
    func getRecipe(i1: String, i2: String, i3: String){
        print("getRecipe 1, 2, 3")
        recipeSearchResultArray.removeAll()
        for r in recipeArray{
            if ((r._ingredients?.contains(i1))! && ((r._ingredients?.contains(i2)))! && ((r._ingredients?.contains(i3)))!){
                recipeSearchResultArray.append(r)
            }
        }
        if recipeSearchResultArray.count == 0{
            let alert = UIAlertController(title: "FeedME", message: "No results found, try changing ingredient(s)", preferredStyle: .alert)
            let action = UIAlertAction(title: "Ok", style: .cancel, handler: nil)
            alert.addAction(action)
            UIApplication.shared.keyWindow?.rootViewController?.present(alert, animated: true, completion: nil)
        }else{
            print("recipeSearchResultArray.count \(recipeSearchResultArray.count)")
            // Segue to the second view controller
            self.performSegue(withIdentifier: "advanceSearchResultSegue", sender: self)
        }
        activityIndicator.stopAnimating()
    }
    
    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
        if let destination = segue.destination as? AdvanceSearchResultViewController{
            destination.recipeSearchResultArray = recipeSearchResultArray
            destination.viewTitle = "Search Result"
        }
    }
    

}

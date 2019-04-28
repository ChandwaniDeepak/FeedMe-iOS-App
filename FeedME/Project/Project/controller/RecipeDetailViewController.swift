//
//  RecipeDetailViewController.swift
//  Project
//
//  Created by Deepak Chandwani on 12/8/18.
//  Copyright © 2018 Deepak Chandwani. All rights reserved.
//

import UIKit
import AWSDynamoDB
import SQLite3

class RecipeDetailViewController: UIViewController{
    var recipeTitle: String?
    var recipe: Recipes?
    var s3Url = Variables.s3Url!
    let contentURL = "\(Variables.bucketName!)recipeImage/"
    
    //create a new button
    let button = UIButton(type: .custom)
    
    var db: OpaquePointer?
    let fileURL = SQLiteDB.fileURL!
    var recipeFound = 0
    
    let screenSize = UIScreen.main.bounds
    
    
    @IBOutlet weak var bannerImageView: UIImageView!
    @IBOutlet weak var recTitle: UILabel!
    @IBOutlet weak var usersRating: UILabel!
    @IBOutlet weak var totalViews: UILabel!  
    @IBOutlet weak var author: UILabel!
    @IBOutlet weak var recipeDescription: UILabel!
    @IBOutlet weak var methodOfPreparation: UILabel!
    @IBOutlet weak var ingredients: UILabel!
    @IBOutlet weak var cookingTIme: UILabel!
    @IBOutlet weak var servesTo: UILabel!
    
    @IBOutlet weak var favButton: UIBarButtonItem!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = recipeTitle
        
        
        //set image for button
        button.setImage(UIImage(named: "heart-hollow"), for: .normal)
        //add function for button
        button.addTarget(self, action: #selector(favButtonClick), for: .touchUpInside)
        //set frame
        button.frame = CGRect(x: 0, y: 0, width: 30, height: 30)
        
        let barButton = UIBarButtonItem(customView: button)
        //assign button to navigationbar
        self.navigationItem.rightBarButtonItem = barButton
        
        print("recipe Description:- \(recipe!._methodOfPreparation)")
        loadRecipeData()
        // Do any additional setup after loading the view.
    }
    
    func loadRecipeData(){
        //bannerImageView.frame = CGRect(x: 0, y: 0, width: screenSize.width, height: screenSize.height*0.15)
        
        let imageURL = URL(string: s3Url.absoluteString+contentURL+recipe!._imageKey!)
        bannerImageView.loadImage(url: imageURL!)
        
        recTitle.text = "Title:- \(recipeTitle!)"
        
        usersRating.text = "Rating:- \(String(Double(recipe!._totalUserRatings!) / Double(recipe!._totalUsersRated!)))"
        
        totalViews.text = "Views:- \(Int(recipe!._totalViews!))"
        
        author.text = "Author:- \(recipe!._authorFullName!)"
        
        recipeDescription.text = "Description:- \(recipe!._description!)"
        recipeDescription.lineBreakMode = NSLineBreakMode.byWordWrapping
        recipeDescription.sizeToFit()
        
        methodOfPreparation.text = "Method:- \(recipe!._methodOfPreparation!)"
        methodOfPreparation.lineBreakMode = NSLineBreakMode.byWordWrapping
        methodOfPreparation.sizeToFit()
        
        ingredients.text = "Ingredients:- \(recipe!._ingredients!)"
        ingredients.lineBreakMode = NSLineBreakMode.byWordWrapping
        ingredients.sizeToFit()
        
        cookingTIme.text = "Cooking Time:- \(recipe!._cookingTime!)"
        servesTo.text = "Serves:- \(recipe!._servesTo!)"
        
        addViewToRecipeTable()
        checkForRecipeInSQLite()
    }
    
    //This method will call when you press button.
    @objc func favButtonClick() {
        print("favBtn clicked")
        let image = UIImage(named: "heart-filled")
        //favButton.setI
        //favButton.setImage(image, for: .normal)
        
        if recipeFound == 0{
            print("recipe not found")
            addRecipeToSQLite()
        }
    }
    
    
    
    func addViewToRecipeTable(){
        let views = Int((recipe?._totalViews)!) + 1
        
        let objectMapper = AWSDynamoDBObjectMapper.default()
        
        var itemToCreate:Recipes = Recipes()
        itemToCreate = recipe!
        itemToCreate._totalViews = views as NSNumber
        
        objectMapper.save(itemToCreate, completionHandler: {(error: Error?) -> Void in
            if let error = error{
                print("Amazon DynamoDB save Error \(error)")
                return
            }
            print("Recipe View Count updated")
        })
    }
    
    func addRecipeToSQLite(){
        //creating a statement
        var stmt: OpaquePointer?
        
        //open DB
        if sqlite3_open(fileURL.path, &db) != SQLITE_OK {
            print("error opening database")
        }else{
            print("db opened successfully")
        }
        
        //the insert query
        let queryString = "INSERT INTO recipe (recipeId TEXT, authorFullName TEXT, cookingTime TEXT, cuisine TEXT, description TEXT, imageKey TEXT, ingredients TEXT, methodOfPreparation TEXT, servesTo TEXT, title TEXT, totalUserRatings INTEGER, totalUsersRated INTEGER, totalViews INTEGER, userId TEXT, videoKey TEXT) VALUES ('\((recipe?._recipeId)!)','\((recipe?._authorFullName)!)', '\((recipe?._cookingTime)!)','\((recipe?._cuisine)!)','\((recipe?._description)!)','\((recipe?._imageKey)!)', '\((recipe?._ingredients)!)', '\((recipe?._methodOfPreparation)!)', '\((recipe?._servesTo)!)', '\((recipe?._title)!)', \((recipe?._totalUserRatings)!), \((recipe?._totalUsersRated)!), \((recipe?._totalViews)!), '\((recipe?._userId)!)', '\((recipe?._videoKey)!)')"
        
        print(queryString)
        
        //preparing the query
        if sqlite3_prepare(db, queryString, -1, &stmt, nil) != SQLITE_OK{
            let errmsg = String(cString: sqlite3_errmsg(db)!)
            print("error preparing insert recipe: \(errmsg)")
            return
        }else{
            let alert = UIAlertController(title: title, message: "Added to your favourite's", preferredStyle: .alert)
            let action = UIAlertAction(title: "Ok", style: .cancel, handler: nil)
            alert.addAction(action)
            UIApplication.shared.keyWindow?.rootViewController?.present(alert, animated: true, completion: nil)
        }
        
        
        //executing the query to insert values
        if sqlite3_step(stmt) != SQLITE_DONE {
            let errmsg = String(cString: sqlite3_errmsg(db)!)
            print("failure inserting recipe: \(errmsg)")
            return
        }
    }
    func removeRecipeFromSQLite(){}
    func checkForRecipeInSQLite(){
        //creating a statement
        var stmt: OpaquePointer?
        
        
        //this is our select query
        let getQueryString = "SELECT * FROM recipe where recipeId='\((recipe!._recipeId)!)'"
        print("\(getQueryString)")
        
        //open DB
        if sqlite3_open(fileURL.path, &db) != SQLITE_OK {
            print("error opening database")
        }else{
            print("db opened successfully")
        }
        
        //preparing the query
        if sqlite3_prepare(db, getQueryString, -1, &stmt, nil) != SQLITE_OK{
            let errmsg = String(cString: sqlite3_errmsg(db)!)
            print("error preparing Select: \(errmsg)")
            return
        }
        
       
        
        if sqlite3_step(stmt) == SQLITE_ROW
        {
            let image = UIImage(named: "heart-filled")
            //set image for button
            button.setImage(image, for: .normal)
            recipeFound = 1
        }
        else{
            let image = UIImage(named: "heart-hollow")
            //set image for button
            button.setImage(image, for: .normal)
            recipeFound = 0
        }
    }
    
    func submitCurrentUserRating(){}
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}

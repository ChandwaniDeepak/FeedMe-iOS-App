//
//  YourContributionViewController.swift
//  Project
//
//  Created by Deepak Chandwani on 12/8/18.
//  Copyright © 2018 Deepak Chandwani. All rights reserved.
//

import UIKit
import AWSDynamoDB

class MyContributionViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {

    var recipeArray: [Recipes] = []
    var s3Url = Variables.s3Url!
    let contentURL = "\(Variables.bucketName!)recipeImage/"
    var selectedRecipe: Recipes?
    
    var authorEmail: String?
    var authorName: String?

    @IBOutlet weak var tableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        getMyContributions()
        
        self.title = "My Contribution"
        tableView.delegate = self
        tableView.dataSource = self
        
        let defaults = UserDefaults.standard
        authorName = defaults.string(forKey: "name")!
        authorEmail = defaults.string(forKey: "email")!
        
        //print("myContributionArray.count:- \(recipeArray.count)")
        // Do any additional setup after loading the view.
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        //print("items count \(recipeArray.count)")
        return recipeArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let recipeCell = tableView.dequeueReusableCell(withIdentifier: "myContributionCell") as? MyContributionTableViewCell else{
            // print("inside else")
            return UITableViewCell()
            
        }
        recipeCell.recTitle.text = recipeArray[indexPath.row]._title
        recipeCell.recDescription.text = recipeArray[indexPath.row]._description
        recipeCell.recAuthor.text = recipeArray[indexPath.row]._authorFullName
        
        let imageURL = URL(string: s3Url.absoluteString+contentURL+recipeArray[indexPath.row]._imageKey!)
        //print(imageURL!)
        recipeCell.imgView.loadImage(url: imageURL!)
        //tableView.reloadData()
        return recipeCell
    }
    /*
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 130
    }
 */
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        //on select item
        selectedRecipe = recipeArray[indexPath.row]
        
        // Segue to the second view controller
        self.performSegue(withIdentifier: "myContributionDetail", sender: self)
    }
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
        if let destination = segue.destination as? RecipeDetailViewController{
            destination.recipe = selectedRecipe
            destination.recipeTitle = selectedRecipe!._title!
        }
    }
    
    func getMyContributions(){
        print("getMyContributions()")
        let scanExpression = AWSDynamoDBScanExpression()
        let objectMapper = AWSDynamoDBObjectMapper.default()
        scanExpression.limit = 400
        
        objectMapper.scan(Recipes.self, expression: scanExpression).continueWith(block: { (task:AWSTask<AWSDynamoDBPaginatedOutput>!) -> Any? in
            if let error = task.error as NSError? {
                print("The request failed. Error: \(error)")
            } else if let paginatedOutput = task.result {
                print("got a response")
                for recipe in paginatedOutput.items as! [Recipes] {
                    // Do something with recipe.
                    if self.authorEmail == recipe._userId{
                        self.recipeArray.append(recipe)
                    }
                }
                if(self.recipeArray.count > 0)
                {
                    print("ready to perform segue")
                    self.tableView.reloadDataWithDelay(delayTime: 2)
                   
                }else{
                    
                    print("No contributions made")
                    let alert = UIAlertController(title: "FeedME", message: "No recipes found", preferredStyle: .alert)
                    let action = UIAlertAction(title: "Ok", style: .cancel, handler: nil)
                    alert.addAction(action)
                    UIApplication.shared.keyWindow?.rootViewController?.present(alert, animated: true, completion: nil)
                }
            }
            return ()
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

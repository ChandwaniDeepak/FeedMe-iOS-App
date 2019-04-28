//
//  HomeViewController.swift
//  Project
//
//  Created by Deepak Chandwani on 12/2/18.
//  Copyright © 2018 Deepak Chandwani. All rights reserved.
//

import UIKit
import AWSMobileClient
import AWSAuthCore
import AWSDynamoDB
import AWSS3

class RecipeViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {

    var vcTitle: String?
    var vcCuisine: String?
    var recipeArray:[Recipes] = []
    //let bucketName = Variables.bucketName!
    var s3Url = Variables.s3Url!
    let contentURL = "\(Variables.bucketName!)recipeImage/"
    //let recipeImageDirectory: String = "/recipeImage/"
    @IBOutlet weak var recipeTableView: UITableView!
    
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        print("viewWillAppear")
        //print(bucketName)
        print(s3Url)
        recipeTableView.delegate = self
        recipeTableView.dataSource = self
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.title = vcTitle
        
        // Get the AWSCredentialsProvider from the AWSMobileClient
        let credentialsProvider = AWSMobileClient.sharedInstance().getCredentialsProvider()
        
        // Get the identity Id from the AWSIdentityManager
        let identityId = AWSIdentityManager.default().identityId
        
        let configuration = AWSServiceConfiguration(region:.USEast1, credentialsProvider:credentialsProvider)
        
        AWSServiceManager.default().defaultServiceConfiguration = configuration
        
        //addRecipe()
        //print("calling recipes")
        getRecipesFromDynamoDB()
        recipeTableView.reloadDataWithDelay(delayTime: 4)
        // Do any additional setup after loading the view.
        
        
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        //print("items count \(recipeArray.count)")
        return recipeArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let recipeCell = tableView.dequeueReusableCell(withIdentifier: "recipeTableViewCell") as? RecipeTableViewCell else{
           // print("inside else")
            return UITableViewCell()
            
        }
        recipeCell.recipeTitle.text = recipeArray[indexPath.row]._title
        recipeCell.recipeDescription.text = recipeArray[indexPath.row]._description
        recipeCell.recipeAuthor.text = recipeArray[indexPath.row]._authorFullName
        
        let imageURL = URL(string: s3Url.absoluteString+contentURL+recipeArray[indexPath.row]._imageKey!)
        //print(imageURL!)
        recipeCell.recipeImageView.loadImage(url: imageURL!)
        //tableView.reloadData()
        return recipeCell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 130
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        //on select item
        SelectedRecipe.recipe = recipeArray[indexPath.row]
        //print("cuisine selected")
        
        // Segue to the second view controller
        self.performSegue(withIdentifier: "recipeDetail", sender: self)
    }
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
        if let destination = segue.destination as? RecipeDetailViewController{
            destination.recipe = SelectedRecipe.recipe
            destination.recipeTitle = SelectedRecipe.recipe!._title!
        }
    }
    
    func getRecipesFromDynamoDB(){
        //print("inside get recipes")
        let scanExpression = AWSDynamoDBScanExpression()
        let objectMapper = AWSDynamoDBObjectMapper.default()
        scanExpression.limit = 400
        
        objectMapper.scan(Recipes.self, expression: scanExpression).continueWith(block: { (task:AWSTask<AWSDynamoDBPaginatedOutput>!) -> Any? in
            if let error = task.error as NSError? {
                print("The request failed. Error: \(error)")
            } else if let paginatedOutput = task.result {
                for recipe in paginatedOutput.items as! [Recipes] {
                    // Do something with recipe.
                    //print("Cuisine:- "+(SelectedCuisine.cuisine?._cuisine)!)
                    if recipe._cuisine == (self.vcCuisine)!
                    {
                        self.recipeArray.append(recipe)
                    }else{
                        //print("No Recipe found for selected Cuisine")
                    }
                }
                if self.recipeArray.count == 0{
                    print("No Recipe found for selected Cuisine")
                }else{
                    print(self.recipeArray.count)
                }
            }
            return ()
        })
        recipeTableView.reloadData()
    }
    
    func addRecipe()
    {
        let cui:[String] = ["cuiIndian", "cuiIndian", "cuiChinese", "cuiMexican", "cuiItalian", "cuiThai", "cuiMughlai","cuiIndian", "cuiIndian", "cuiChinese", "cuiMexican", "cuiItalian", "cuiThai", "cuiMughlai"]
        let objectMapper = AWSDynamoDBObjectMapper.default()
        for i in 0...(cui.count-1){
        //var i=1
            print("adding recipe \(i)")
            let _userId = "depakchandwani1"
            let itemToCreate:Recipes = Recipes()
            itemToCreate._recipeId = "\(i)"
            itemToCreate._authorFullName = "Deepak Chandwani"
            itemToCreate._userId = _userId
            itemToCreate._cuisine = cui[i]
            itemToCreate._imageKey = "indian.jpg"
            itemToCreate._description = "penne 200gm, butter 50gm, oil 1tbsp, cheese 50gm"
            itemToCreate._cookingTime = "45-60min"
            itemToCreate._ingredients = "penne 200gm, butter 50gm, oil 1tbsp, cheese 50gm"
            itemToCreate._methodOfPreparation = "Follow These Steps \n Boil water in a large pot \n To make sure pasta does not stick together, use at least 4 quarts of water for every pound of noodles. \n Salt the water with at least a tablespoon—more is fine \n The salty water adds flavor to the pasta. \n Add pasta \n Pour pasta into boiling water. Do not break the pasta it will soften up within 30 seconds and fit into the pot. \n Stir the pasta \n As the pasta starts to cook, stir it well with the tongs so the noodles do not stick to each other (or the pot). \n Test the pasta by tasting it \n Follow the cooking time on the package, but always taste pasta before draining to make sure the texture is right. Pasta cooked properly should be al dente—a little chewy. \n Drain the pasta \n Drain cooked pasta well in a colander. If serving hot, add sauce right away; if you’re making a pasta salad, run noodles under cold water to stop the cooking."
            itemToCreate._servesTo = "3"
            itemToCreate._title = "Dal Makhani"
            itemToCreate._totalUserRatings = 40
            itemToCreate._totalUsersRated = 10
            itemToCreate._totalViews = 200
            itemToCreate._videoKey = "pasta"+_userId
            
            objectMapper.save(itemToCreate, completionHandler: {(error: Error?) -> Void in
                if let error = error{
                    print("Amazon DynamoDB save Error \(error)")
                    return
                }
                print("Recipe Data saved")
            })
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

extension UITableView {
    func reloadDataWithDelay(delayTime: TimeInterval) -> Void {
        let delayTime = DispatchTime.now() + 2
        DispatchQueue.main.asyncAfter(deadline: delayTime) {
            self.reloadData()
        }
        
    }
}

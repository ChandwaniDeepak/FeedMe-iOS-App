//
//  CategoryViewController.swift
//  Project
//
//  Created by Deepak Chandwani on 12/8/18.
//  Copyright © 2018 Deepak Chandwani. All rights reserved.
//

import UIKit
import AWSMobileClient
import AWSAuthCore
import AWSDynamoDB
import AWSS3
import SQLite3

class CategoryViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {

    @IBOutlet weak var categoryTavleView: UITableView!
    @IBOutlet weak var loginBarButton: UIBarButtonItem!
    @IBOutlet weak var profileBarButton: UIBarButtonItem!
    @IBOutlet weak var searchBarButton: UIBarButtonItem!
    
    let bucketName = "/mybucket10771/"
    var contentUrl: URL!
    var s3Url: URL!
    
   
    var cuisineArray:[Cuisine]=[]
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        let defaults = UserDefaults.standard
        let isLoggedIn = defaults.bool(forKey: "isLoggedIn")
        if isLoggedIn
        {
            //User is Logged in, hide Login Button
            loginBarButton.title = ""
            
            profileBarButton.title = "Profile"
            let alert = UIAlertController(title: title, message: "Welcome back\n \(defaults.string(forKey: "name")!)", preferredStyle: .alert)
            let action = UIAlertAction(title: "Ok", style: .cancel, handler: nil)
            alert.addAction(action)
            UIApplication.shared.keyWindow?.rootViewController?.present(alert, animated: true, completion: nil)
            
        }else{
            profileBarButton.title = ""
            
            loginBarButton.title = "Login"
        }
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()        
        self.title = "FeedME"
        categoryTavleView.delegate = self
        categoryTavleView.dataSource = self
        //print("viewDidLoad")
        
        let defaults = UserDefaults.standard
        let isLoggedIn = defaults.bool(forKey: "isLoggedIn")
        //print("loggedin:- \(isLoggedIn)")
        
        let fileURL = try! FileManager.default.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: false)
            .appendingPathComponent("Project.sqlite")
        SQLiteDB.init(ur: fileURL)
        print("\(SQLiteDB.fileURL!)")
        
        if isLoggedIn
        {
            //User is Logged in, hide Login Button
            loginBarButton.title = ""
            
            profileBarButton.title = "Profile"
            let alert = UIAlertController(title: title, message: "Welcome back\n \(defaults.string(forKey: "name")!)", preferredStyle: .alert)
            let action = UIAlertAction(title: "Ok", style: .cancel, handler: nil)
            alert.addAction(action)
            UIApplication.shared.keyWindow?.rootViewController?.present(alert, animated: true, completion: nil)
            
        }else{
            profileBarButton.title = ""
            
            loginBarButton.title = "Login"
            //print("removing width of profile button")
        }
        
        // Get the AWSCredentialsProvider from the AWSMobileClient
        let credentialsProvider = AWSMobileClient.sharedInstance().getCredentialsProvider()
        
        // Get the identity Id from the AWSIdentityManager
        let identityId = AWSIdentityManager.default().identityId
        
        let configuration = AWSServiceConfiguration(region:.USEast1, credentialsProvider:credentialsProvider)
        
        AWSServiceManager.default().defaultServiceConfiguration = configuration
        
        s3Url = AWSS3.default().configuration.endpoint.url
        Variables.init(bucketName: bucketName, s3Url: s3Url)
        
        contentUrl = URL(string: s3Url.absoluteString+bucketName+"cuisine/")
        
        createSQLiteTables()
        //addCuisine()
        getCuisine()
        categoryTavleView.reloadDataWithDelay(delayTime: 3)
        // Do any additional setup after loading the view.
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        //print("items count \(cuisineArray.count)")
        categoryTavleView = tableView
        return cuisineArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let categoryTableCell = tableView.dequeueReusableCell(withIdentifier: "categoryTableCell") as? CategoryTableViewCell else{
            //print("inside else")
            return UITableViewCell()
        }
        categoryTableCell.categoryLabel.text = cuisineArray[indexPath.row]._cuisine
        
        let imageURL = URL(string: contentUrl.absoluteString+cuisineArray[indexPath.row]._imageKey!)
        //print(cuisineArray[indexPath.row]._cuisine)
        //print(imageURL!)
        categoryTableCell.categoryImageView.loadImage(url: imageURL!)
        return categoryTableCell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 250
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        //on select item
        SelectedCuisine.cuisine = cuisineArray[indexPath.row]
        //print("cuisine selected")
        
        // Segue to the second view controller
        self.performSegue(withIdentifier: "recipeVC", sender: self)
    }
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
        if let destination = segue.destination as? RecipeViewController{
            destination.vcTitle = SelectedCuisine.cuisine?._cuisine
            destination.vcCuisine = SelectedCuisine.cuisine?._cuisineId
        }
    }
    
    func addCuisine()
    {
        let cui:[String] = ["cuiIndian", "cuiIndian", "cuiChinese", "cuiMexican", "cuiItalian", "cuiThai", "cuiMughlai","cuiIndian", "cuiIndian", "cuiChinese", "cuiMexican", "cuiItalian", "cuiThai", "cuiMughlai","cuiIndian", "cuiIndian", "cuiChinese", "cuiMexican", "cuiItalian", "cuiThai", "cuiMughlai","cuiIndian", "cuiIndian", "cuiChinese", "cuiMexican", "cuiItalian", "cuiThai", "cuiMughlai","cuiIndian", "cuiIndian", "cuiChinese", "cuiMexican", "cuiItalian", "cuiThai", "cuiMughlai","cuiIndian", "cuiIndian", "cuiChinese", "cuiMexican", "cuiItalian", "cuiThai", "cuiMughlai"]
        let cuiImg:[String] = ["indian.jpg", "chinese.jpg", "mexican.jpg", "italian.jpg", "thai.jpg", "mughlai.jpg"]
        let objectMapper = AWSDynamoDBObjectMapper.default()
        for i in 0...(cui.count-1){
            //var i=1
            let itemToCreate:Cuisine = Cuisine()
            let _cuisineId:String = "cui\(cui[i])"
            itemToCreate._cuisineId = _cuisineId
            itemToCreate._cuisine = cui[i]
            itemToCreate._imageKey = cuiImg[i]
            
            objectMapper.save(itemToCreate, completionHandler: {(error: Error?) -> Void in
                if let error = error{
                    print("Amazon DynamoDB save Error \(error)")
                    return
                }
                print("Cuisine Saved")
            })
        }
    }
    
    func getCuisine(){
        let scanExpression = AWSDynamoDBScanExpression()
        let objectMapper = AWSDynamoDBObjectMapper.default()
        scanExpression.limit = 200
        
        objectMapper.scan(Cuisine.self, expression: scanExpression).continueWith(block: { (task:AWSTask<AWSDynamoDBPaginatedOutput>!) -> Any? in
            if let error = task.error as NSError? {
                print("The request failed. Error: \(error)")
            } else if let paginatedOutput = task.result {
                for cuisine in paginatedOutput.items as! [Cuisine] {
                    // Do something with recipe.
                    self.cuisineArray.append(cuisine)
                    //print(self.cuisineArray.count)
                }
                CuisineArray.init(c: self.cuisineArray)
                print("CuisineArray.cuisineArray:- \(CuisineArray.cuisineArray!.count)")
            }
            return ()
        })
        categoryTavleView.reloadData()
    }
    
    func createSQLiteTables(){
        
        // getting existing DB
        let fileURL = SQLiteDB.fileURL
        var db: OpaquePointer?
        
        //open DB
        if sqlite3_open(fileURL!.path, &db) != SQLITE_OK {
            print("error opening database")
        }else{
            print("db opened successfully")
        }
        
        // creating table recipe
        if sqlite3_exec(db, "CREATE TABLE IF NOT EXISTS recipe (id INTEGER PRIMARY KEY AUTOINCREMENT, recipeId TEXT, authorFullName TEXT, cookingTime TEXT, cuisine TEXT, description TEXT, imageKey TEXT, ingredients TEXT, methodOfPreparation TEXT, servesTo TEXT, title TEXT, totalUserRatings INTEGER, totalUsersRated INTEGER, totalViews INTEGER, userId TEXT, videoKey TEXT)", nil, nil, nil) != SQLITE_OK {
            let errmsg = String(cString: sqlite3_errmsg(db)!)
            print("error creating table: \(errmsg)")
        }else{
            print("table created successfully")
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

//
//  AdvanceSearchResultViewController.swift
//  Project
//
//  Created by Deepak Chandwani on 12/8/18.
//  Copyright © 2018 Deepak Chandwani. All rights reserved.
//

import UIKit

class AdvanceSearchResultViewController: UIViewController, UITableViewDataSource, UITableViewDelegate{

    var recipeSearchResultArray:[Recipes] = []
    var s3Url = Variables.s3Url!
    let contentURL = "\(Variables.bucketName!)recipeImage/"
    var selectedRecipe: Recipes?
    var viewTitle: String?
    
    @IBOutlet weak var searchResultTableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = viewTitle
        print("recipeSearchResultArray \(recipeSearchResultArray.count)")
        searchResultTableView.delegate = self
        searchResultTableView.dataSource = self
        // Do any additional setup after loading the view.
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        //print("items count \(recipeArray.count)")
        return recipeSearchResultArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let resultCell = tableView.dequeueReusableCell(withIdentifier: "searchResultCell") as? SearchResultTableViewCell else{
            // print("inside else")
            return UITableViewCell()
            
        }
        resultCell.recipeTitle.text = recipeSearchResultArray[indexPath.row]._title
        resultCell.recipeDescription.text = recipeSearchResultArray[indexPath.row]._description
        resultCell.recipeAuthor.text = recipeSearchResultArray[indexPath.row]._authorFullName
        
        let imageURL = URL(string: s3Url.absoluteString+contentURL+recipeSearchResultArray[indexPath.row]._imageKey!)
        //print(imageURL!)
        resultCell.searchResultImageView.loadImage(url: imageURL!)
        //tableView.reloadData()
        return resultCell
    }
    /*
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 130
    }
 */
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        //on select item
        selectedRecipe = recipeSearchResultArray[indexPath.row]
        print("Item Clicked")
        
        // Segue to the second view controller
        self.performSegue(withIdentifier: "resultRecipeDetail", sender: self)
    }
    

    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
        if let destination = segue.destination as? RecipeDetailViewController{
            destination.recipe = selectedRecipe
            destination.recipeTitle = selectedRecipe!._title
        }
    }
    

}

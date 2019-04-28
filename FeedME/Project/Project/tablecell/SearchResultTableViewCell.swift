//
//  SearchResultTableViewCell.swift
//  Project
//
//  Created by Deepak Chandwani on 12/13/18.
//  Copyright © 2018 Deepak Chandwani. All rights reserved.
//

import UIKit

class SearchResultTableViewCell: UITableViewCell {
   
    
    @IBOutlet weak var searchResultImageView: UIImageView!
    @IBOutlet weak var recipeTitle: UILabel!
    @IBOutlet weak var recipeDescription: UILabel!
    @IBOutlet weak var recipeAuthor: UILabel!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}

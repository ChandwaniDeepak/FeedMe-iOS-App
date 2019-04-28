//
//  MyContributionTableViewCell.swift
//  Project
//
//  Created by Deepak Chandwani on 12/14/18.
//  Copyright © 2018 Deepak Chandwani. All rights reserved.
//

import UIKit

class MyContributionTableViewCell: UITableViewCell {

    @IBOutlet weak var imgView: UIImageView!
    
    @IBOutlet weak var recTitle: UILabel!
    @IBOutlet weak var recDescription: UILabel!
    @IBOutlet weak var recAuthor: UILabel!
    
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}

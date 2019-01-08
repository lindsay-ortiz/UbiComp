//
//  RecipeBoxTableViewCell.swift
//  RecipeBox
//
//  Created by Chris Hill on 11/14/18.
//  Copyright © 2018 Team2. All rights reserved.
//

import UIKit

class RecipeBoxTableViewCell: UITableViewCell {

    @IBOutlet weak var cImage: UIImageView!
    @IBOutlet weak var cLabel: UILabel!
    var index: Int = 0
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}

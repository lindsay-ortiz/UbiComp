//
//  NickTableViewCell.swift
//  NicScreen
//
//  Created by Team2 on 10/3/18.
//  Copyright © 2018 Team2. All rights reserved.
//

import UIKit

class NickTableViewCell: UITableViewCell {

    override func awakeFromNib() {
        super.awakeFromNib()
     }
    
    @IBOutlet weak var titleLbl: UILabel!
    @IBOutlet weak var cImage: UIImageView!
    
    @IBOutlet weak var recipetitle: UILabel!
    var index: Int = 0
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
    }

}

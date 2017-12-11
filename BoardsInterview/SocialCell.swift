//
//  SocialCell.swift
//  BoardsInterview
//
//  Created by Maulik Vekariya on 12/8/17.
//  Copyright © 2017 Maulik Vekariya. All rights reserved.
//

import UIKit
import TTTAttributedLabel


class SocialCell: UITableViewCell {

    @IBOutlet var lblTitle: TTTAttributedLabel!
    @IBOutlet var lblLink: TTTAttributedLabel!
    @IBOutlet var imgMessage: UIImageView!
    @IBOutlet var lblDate: UILabel!
    @IBOutlet var btnShare: UIButton!
    @IBOutlet var lblVia: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}

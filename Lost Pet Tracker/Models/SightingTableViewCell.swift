//
//  SightingTableViewCell.swift
//  Lost Pet Tracker
//
//  Created by Justin Butera on 5/10/17.
//  Copyright © 2017 Justin Butera. All rights reserved.
//

import UIKit

class SightingTableViewCell: UITableViewCell {

    @IBOutlet weak var petPhotoImageVIew: UIImageView!
    @IBOutlet weak var distanceLabel: UILabel!
    @IBOutlet weak var timestampLabel: UILabel!
    @IBOutlet weak var typeOfPetLabel: UILabel!
    @IBOutlet weak var progressIndicator: UIActivityIndicatorView!
    var petID: String? = nil
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}

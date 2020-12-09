//
//  RoomTableViewCell.swift
//  SmartHome
//
//  Created by Nuno Caseiro on 29/11/2020.
//

import UIKit

class RoomTableViewCell: UITableViewCell {

    @IBOutlet weak var roomNameLabel: UILabel!
    @IBOutlet weak var roomImageView: UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    
    

}

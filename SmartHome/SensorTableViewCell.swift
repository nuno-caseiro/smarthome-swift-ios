//
//  SensorTableViewCell.swift
//  SmartHome
//
//  Created by Nuno Caseiro on 29/11/2020.
//

import UIKit

class SensorTableViewCell: UITableViewCell {

    
    @IBOutlet weak var sensorName: UILabel!
    @IBOutlet weak var sensorValue: UILabel!
    @IBOutlet weak var sensorImageView: UIImageView!
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }

}
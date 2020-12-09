//
//  HomeRoomSensorTableViewCell.swift
//  SmartHome
//
//  Created by João Marques on 07/12/2020.
//

import UIKit

class HomeRoomSensorTableViewCell: UITableViewCell {

    @IBOutlet weak var sensorRoomImage: UIImageView!
    @IBOutlet weak var sensorRoomName: UILabel!
    @IBOutlet weak var sensorRoomValue: UILabel!
        
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
}

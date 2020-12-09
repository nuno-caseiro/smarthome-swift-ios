//
//  HomeTableViewCell.swift
//  SmartHome
//
//  Created by João Marques on 07/12/2020.
//

import UIKit

class HomeRoomTableViewCell: UITableViewCell, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet weak var roomName: UILabel!
    @IBOutlet weak var sensorsTable: UITableView!
    
    var room: Room?
    
    static let SensorsURL = "http://161.35.8.148/api/sensors/"
    static let SensorsRoomURL = "http://161.35.8.148/api/sensorsofroom/"
    static let SensorsValuesURL = "http://161.35.8.148/api/lastvaluesensor/"
    static let SensorsValuesPostURL = "http://161.35.8.148/api/sensorsvalues/"
    
    
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        self.sensorsTable.reloadData()
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        self.sensorsTable.delegate = self
        self.sensorsTable.dataSource = self
    }

    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return room?.sensors?.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "HomeRoomSensorTableViewCell") as? HomeRoomSensorTableViewCell else {
            fatalError("The dequeued cell is not an instance of HomeRoomSensorTableViewCell.")
        }
        
        cell.sensorRoomName.text = room?.sensors?[indexPath.row].name
        cell.sensorRoomValue.text = String((room?.sensors?[indexPath.row].value)!)
        cell.sensorRoomImage.image = room?.sensors?[indexPath.row].image
        
        // cell.sensorRoomImage.image = UIImage(named: "\(imageArr[indexPath.row])")

        return cell
    }
}

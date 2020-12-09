//
//  HomeViewController.swift
//  SmartHome
//
//  Created by João Marques on 07/12/2020.
//

import UIKit

class HomeViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {

    @IBOutlet weak var firstName: UILabel!
    @IBOutlet weak var roomsTable: UITableView!
        
    weak var home = AppData.instance.home
    
    static let RoomsURL = "http://161.35.8.148/api/roomsfortesting/"
    static let RoomsForPostAndDelURL = "http://161.35.8.148/api/rooms/"

    static let SensorsURL = "http://161.35.8.148/api/sensors/"
    static let SensorsRoomURL = "http://161.35.8.148/api/sensorsofroom/"
    static let SensorsValuesURL = "http://161.35.8.148/api/lastvaluesensor/"
    static let SensorsValuesPostURL = "http://161.35.8.148/api/sensorsvalues/"
    
    var count = 0
    static let SensorsRoomCountURL = "http://161.35.8.148/api/countSensorsByRoom/"
 
    var lastSelectedIndex = -1
    var selectedIndex = -1
    var isCollapsed = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // self.firstName.text = 
        
        downloadRooms()

        roomsTable.estimatedRowHeight = 126
        roomsTable.rowHeight = UITableView.automaticDimension
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if self.selectedIndex == indexPath.row && isCollapsed == true {
            return 250
        } else {
            return 65
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return home?.rooms.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "HomeRoomTableViewCell") as? HomeRoomTableViewCell else {
            fatalError("The dequeued cell is not an instance of HomeRoomTableViewCell.")
        }
        
        cell.room = home?.rooms[indexPath.row]
        cell.roomName.text = home?.rooms[indexPath.row].name
        cell.homeViewController = self
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        if selectedIndex == indexPath.row {
            if self.isCollapsed == false {
                self.isCollapsed = true
            } else {
                self.isCollapsed = false
            }
        } else {
            self.isCollapsed = true
        }
        self.lastSelectedIndex = self.selectedIndex
        self.selectedIndex = indexPath.row
        
        downloadSensorsByRoom()
        
        tableView.reloadRows(at: [indexPath], with: .automatic)
    }
    
    // ------------------------------------------------------------------------
    
    func downloadRooms() {
        guard let url = URL(string: HomeViewController.RoomsURL) else {
            print("Error: cannot create URL")
            return
        }
        
        var request = URLRequest(url: url)
        
        // Create the request
        request.httpMethod = "GET"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.addValue("Token \(AppData.instance.user.token!)", forHTTPHeaderField: "Authorization")
        URLSession.shared.dataTask(with: request) { data, response, error in
            guard error == nil else {
                print("Error: error calling PUT")
                print(error!)
                return
            }
            guard let data = data else {
                print("Error: Did not receive data")
                return
            }
            guard let response = response as? HTTPURLResponse, (200 ..< 299) ~= response.statusCode else {
                print("Error: HTTP request failed")
                return
            }
            do {
                let newRooms: [Room] = try JSONDecoder().decode([Room].self, from: data)
                
                for room in newRooms {
                    // add downloaded meal without photo
                    DispatchQueue.main.async {
                        room.sensors = [Sensor]()
                        self.addRoom(room)
                    }
                }
            } catch let parseError as NSError {
                print(parseError.localizedDescription)
            }
        }.resume()
    }
    
    fileprivate func addRoom(_ room: Room) {
        // Add a new meal.
        let newIndexPath = IndexPath(row: home?.rooms.count ?? 0, section: 0)
        home?.rooms.append(room)
        roomsTable.insertRows(at: [newIndexPath], with: .automatic)
    }
    
    // ------------------------------------------------------------------------
    
    func downloadSensorsByRoom(){
        // FIXME: if nill
        guard let url = URL(string: HomeViewController.SensorsRoomURL+"?room=\(String(describing: home!.rooms[self.selectedIndex].id!))") else {
            print("Error: cannot create URL")
            return
        }
        
        // Create the request
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.addValue("Token \(AppData.instance.user.token!)", forHTTPHeaderField: "Authorization")
        
        URLSession.shared.dataTask(with: request) { data, response, error in
            guard error == nil else {
                print("Error: error calling PUT")
                print(error!)
                return
            }
            guard let data = data else {
                print("Error: Did not receive data")
                return
            }
            guard let response = response as? HTTPURLResponse, (200 ..< 299) ~= response.statusCode else {
                print("Error: HTTP request failed")
                return
            }
            do {
                let newSensors: [Sensor] = try JSONDecoder().decode([Sensor].self, from: data)
                // print(newSensors)
                
                DispatchQueue.main.async {
                    if(self.lastSelectedIndex == -1) {
                        self.home!.rooms[self.selectedIndex].sensors?.removeAll()
                    } else {
                        self.home!.rooms[self.lastSelectedIndex].sensors?.removeAll()
                    }
                    
                }
                
                for sensor in newSensors {
                    switch sensor.sensorType{
                    case "led":
                        sensor.image = UIImage(named: "light_icon")
                    case "camera":
                        sensor.image = UIImage(named: "camera_new_icon")
                    case "servo":
                        sensor.image = UIImage(named: "door_icon")
                    default:
                        return
                    }
                    DispatchQueue.main.async {
                        self.addSensorToRoom(sensor: sensor)
                    }
                }
            } catch let parseError as NSError {
                print(parseError.localizedDescription)
            }
        }.resume()
    }
    
    fileprivate func addSensorToRoom(sensor: Sensor) {
        // Add a new sensor.
        if let validRooms = self.home!.rooms[self.selectedIndex].sensors {
            for sensorAtual in validRooms {
                if(sensor.id == sensorAtual.id){
                    return
                }
            }
        }
        
        self.home!.rooms[self.selectedIndex].sensors?.append(sensor)
    }
    
    // ------------------------------------------------------------------------
    
    func getSensorsCount(roomId: Int) {
        guard let url = URL(string: HomeViewController.SensorsRoomCountURL+"?room=\(String(describing: home!.rooms[self.selectedIndex].id!))") else {
            print("Error: cannot create URL")
            return
        }
        
        var request = URLRequest(url: url)
        
        // Create the request
        request.httpMethod = "GET"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.addValue("Token \(AppData.instance.user.token!)", forHTTPHeaderField: "Authorization")
        
        URLSession.shared.dataTask(with: request) { data, response, error in
            guard error == nil else {
                print("Error: error calling PUT")
                print(error!)
                return
            }
            guard let data = data else {
                print("Error: Did not receive data")
                return
            }
            guard let response = response as? HTTPURLResponse, (200 ..< 299) ~= response.statusCode else {
                print("Error: HTTP request failed")
                return
            }
            
            let returnData = String(data: data, encoding: .utf8)
            
            self.count = Int(returnData!)!
        }.resume()
    }
}

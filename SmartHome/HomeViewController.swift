//
//  HomeViewController.swift
//  SmartHome
//
//  Created by João Marques on 07/12/2020.
//

import UIKit
import os.log

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
    var selectedRoom: Room?
    var lastSelectedIndex = -1
    var selectedIndex = -1
    var selectedSensor: Sensor?
    var selectedIndexSensor = -1
    var isCollapsed = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        downloadRooms()

        roomsTable.estimatedRowHeight = 126
        roomsTable.rowHeight = UITableView.automaticDimension
        
        NotificationCenter.default.addObserver(self,selector: #selector(loginSuccess),name: NSNotification.Name ("com.user.login.success"),object: nil)
        NotificationCenter.default.addObserver(self,selector: #selector(sensorAdded),name: NSNotification.Name ("sensor added"),object: nil)

    }
    
    
    @objc func loginSuccess(_ notification: Notification){
           
        self.firstName.text = AppData.instance.user.firstname
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        
        if self.selectedIndex == indexPath.row && isCollapsed == true  {
            return 250
        } else {
            return 65
        }
    }
    
    @objc func sensorAdded(_ notification: Notification){
           
        if let rooms = home?.rooms{
            for room in rooms{
                room.sensors?.removeAll()
            }
            roomsTable.reloadData()
        }
        
        roomsTable.deselectRow(at: IndexPath(index: self.selectedIndex), animated: true)
        self.selectedIndex = -1
    }
    
    //MARK: TABLE VIEW
    
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
        
        selectedRoom = home?.rooms[self.selectedIndex]
        downloadSensorsByRoom()
        
        tableView.reloadRows(at: [indexPath], with: .automatic)
    }
    
    fileprivate func addSensor(_ sensor: Sensor) {
        // Add a new sensor.
        home?.rooms[self.selectedIndex].sensors?.append(sensor)
        //roomsTable.reloadData()
        
    }
    //MARK: Navigation
    // ------------------------------------------------------------------------
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        super.prepare(for: segue, sender: sender)
        
        guard let sensorDetailViewController = segue.destination as? SensorViewController else {
            fatalError("Unexpected destination: \(segue.destination)")
        }
        
       
        switch(segue.identifier ?? "") {
            
            
        case "AddItem":
            os_log("Adding a new sensor.", log: OSLog.default, type: .debug)
            sensorDetailViewController.roomId = selectedRoom?.id
            
        case "editSensor":
            
            let selectedSensor = selectedRoom?.sensors?[selectedIndexSensor]
            sensorDetailViewController.sensor = selectedSensor
            sensorDetailViewController.roomId = selectedRoom?.id
        default:
            fatalError("Unexpected Segue Identifier; \(String(describing: segue.identifier))")
        }
    }
    
    @IBAction func unwindToSensorListWithDelete(sender: UIStoryboardSegue) {
        
        let stringForDelete = HomeViewController.SensorsURL + "\(String(describing: self.home!.rooms[self.selectedIndex].sensors![ self.selectedIndexSensor].id!))/"
        deleteSensor(urlString: stringForDelete)
        
        self.home?.rooms[self.selectedIndex].sensors?.remove(at: self.selectedIndexSensor)
        roomsTable.reloadData()
        
       
    }
    
    
    @IBAction func unwindToSensorList(sender: UIStoryboardSegue) {
        if let sourceViewController = sender.source as? SensorViewController,
           let sensor = sourceViewController.sensor {
            
            if  selectedIndexSensor != -1 {
                // Update an existing sensor.
                
                let stringForUpdate = HomeViewController.SensorsURL + "\(String(describing: sensor.id!))/"

                self.updateSensorRequest(urlString: stringForUpdate, sensor: sensor)
                home?.rooms[self.selectedIndex].sensors?[selectedIndexSensor] = sensor
                roomsTable.reloadData()
                
            }
            else {
                //fazer post e editar id com a resposta; fazer método que recebe o id
                insertSensorRequest(urlString: HomeViewController.SensorsURL, sensor: sensor, completionToInsertSensor: { (newSensor, error) in
                    sensor.id = newSensor?.id
                    sensor.roomname = newSensor?.roomname
                    DispatchQueue.main.async {
                        self.addSensor(sensor)
                    }
                    self.insertSensorValueRequest(urlString: HomeViewController.SensorsValuesPostURL, sensor: sensor)
                    
                })
           
        }
        selectedSensor = nil
        selectedIndexSensor = -1
    }
    }


    
    //MARK: Requests
    
    func deleteSensor(urlString: String){
        guard let url = URL(string: urlString) else {
            print("Error: cannot create URL")
            return
        }
        
        // Create the request
        var request = URLRequest(url: url)
        
        request.httpMethod = "DELETE"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.addValue("Token \(String(describing: AppData.instance.user.token!))", forHTTPHeaderField: "Authorization")
     
        //MAKE REQUEST
        URLSession.shared.dataTask(with: request) { data, response, error in
            guard error == nil else {
                print("Error: error calling PUT")
                print(error!)
                return
            }
            guard data != nil else {
                print("Error: Did not receive data")
                return
            }
            guard let response = response as? HTTPURLResponse, (200 ..< 299) ~= response.statusCode else {
                print("Error: HTTP request failed")
                return
            }
            
        }.resume()
    }
        

func insertSensorRequest(urlString: String, sensor: Sensor, completionToInsertSensor: ( (_ newSensor: Sensor?, _ error: Error?)->())?){
    guard let url = URL(string: urlString) else {
        print("Error: cannot create URL")
        return
    }
    
    // Create the request
    var request = URLRequest(url: url)
    
    request.httpMethod = "POST"
    request.setValue("application/json", forHTTPHeaderField: "Content-Type")
    request.addValue("Token \(String(describing: AppData.instance.user.token!))", forHTTPHeaderField: "Authorization")
    
    var newSensor: Sensor? = nil
    
    do{
        let jsonData = try JSONEncoder().encode(sensor)
        request.httpBody = jsonData
        
    } catch let parseError as NSError {
        print(parseError.localizedDescription)
    }
    
    //MAKE REQUEST
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
        do{
            newSensor = try JSONDecoder().decode(Sensor.self, from: data)
            completionToInsertSensor!(newSensor, error)
            
            print("todoItemModel id: \(newSensor?.id ?? 0)")
        }catch let jsonErr{
            print(jsonErr)
        }
    }.resume()
}
    
    func updateSensorRequest(urlString: String, sensor: Sensor){
        guard let url = URL(string: urlString) else {
            print("Error: cannot create URL")
            return
        }
        
        // Create the request
        var request = URLRequest(url: url)
        
        request.httpMethod = "PUT"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.addValue("Token \(String(describing: AppData.instance.user.token!))", forHTTPHeaderField: "Authorization")
        
        do{
            let jsonData = try JSONEncoder().encode(sensor)
            request.httpBody = jsonData
            
        } catch let parseError as NSError {
            
            print(parseError.localizedDescription)
        }
        
        var newSensor: Sensor? = nil
        
        //MAKE REQUEST
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
            
            do{
                newSensor = try JSONDecoder().decode(Sensor.self, from: data)
                print("todoItemModel id: \(newSensor?.id ?? 0)")
            }catch let jsonErr{
                print(jsonErr)
            }
            
        }.resume()
        
    }
    
    func insertSensorValueRequest(urlString: String, sensor: Sensor){
        guard let url = URL(string: urlString) else {
            print("Error: cannot create URL")
            return
        }
        
        // Create the request
        var request = URLRequest(url: url)
        
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.addValue("Token \(String(describing: AppData.instance.user.token!))", forHTTPHeaderField: "Authorization")

        
        // Create model
        struct SensorValue: Codable {
            let idsensor: Int
            let value: Double
        }
        
        // Add data to the model
        let uploadDataModel = SensorValue(idsensor: sensor.id ?? 0, value: sensor.value ?? 0)
        
        // Convert model to JSON data
        guard let jsonData = try? JSONEncoder().encode(uploadDataModel) else {
            print("Error: Trying to convert model to JSON data")
            return
        }
        request.httpBody = jsonData
        
        
        //MAKE REQUEST
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
                do{
                    guard let jsonObject = try JSONSerialization.jsonObject(with: data) as? [String: Any] else {
                        print("Error: Cannot convert data to JSON object")
                        return
                    }
                    print(jsonObject)
                }catch let jsonErr{
                    print(jsonErr)
                }
        }.resume()
            
    }
    
    
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
                //print(String(decoding: data, as: UTF8.self))
                
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
                        sensor.image = UIImage(named: "camera_icon")
                    case "servo":
                        sensor.image = UIImage(named: "door_icon")
                    case "plug":
                        sensor.image = UIImage(named: "plug_icon")
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

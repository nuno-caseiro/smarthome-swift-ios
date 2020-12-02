//
//  SensorTableViewController.swift
//  SmartHome
//
//  Created by Nuno Caseiro on 29/11/2020.
//

import UIKit
import os.log

class SensorTableViewController: UITableViewController, UITextFieldDelegate {
    
    var room: Room?
    static let SensorsURL = "http://161.35.8.148/api/sensors/"
    static let SensorsValuesURL = "http://161.35.8.148/api/lastvaluesensor/"
    static let SensorsValuesPostURL = "http://161.35.8.148/api/sensorsvalues/"
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        //navigationController?.interactivePopGestureRecognizer?.delegate = nil
        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false
        
        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem
        
        
        //Necessário meter no disco??
        downloadSensors()
        
        
    }
    
    // MARK: - Table view data source
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return room?.sensors?.count ?? 0
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        // Table view cells are reused and should be dequeued using a cell identifier.
        let cellIdentifier = "SensorTableViewCell"
        guard let cell = tableView.dequeueReusableCell(withIdentifier:cellIdentifier, for: indexPath) as? SensorTableViewCell else {
            fatalError("The dequeued cell is not an instance of SensorTableViewCell.")
        }
        // Fetches the appropriate meal for the data source layout.
        let sensor = room?.sensors?[indexPath.row]
        cell.sensorName.text = sensor?.name
        cell.sensorValue.text = String(sensor?.value ?? 0)
        //cell.ratingControl.rating = meal.rating
        return cell
    }
    
    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            
            
            guard let sensor = room?.sensors?[indexPath.row] else { return  }
            deleteSensorApi(sensor)
            // Delete the row from the data source
            room?.sensors?.remove(at: indexPath.row)
            // Delete the row from the data source
            tableView.deleteRows(at: [indexPath], with: .fade)
            
            // Save the meals.
            //saveMeals()
            
        } else if editingStyle == .insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }
    }
    
    
    fileprivate func addSensor(_ sensor: Sensor) {
        // Add a new meal.
        
        if let validRooms = room?.sensors {
            for sensorAtual in validRooms {
                if(sensor.id == sensorAtual.id){
                    return
                }
            }
        }
        
        let newIndexPath = IndexPath(row: room?.sensors?.count ?? 0, section: 0)
        room?.sensors?.append(sensor)
        tableView.insertRows(at: [newIndexPath], with: .automatic)
        
    }
    
    
    @IBAction func unwindToSensorList(sender: UIStoryboardSegue) {
        if let sourceViewController = sender.source as? SensorViewController,
           let sensor = sourceViewController.sensor {
            
            if let selectedIndexPath = tableView.indexPathForSelectedRow {
                // Update an existing sensor.
                updateSensorApi(sensor)
                room?.sensors?[selectedIndexPath.row] = sensor
                tableView.reloadRows(at: [selectedIndexPath], with: .none)
            }
            else {
                //fazer post e editar id com a resposta; fazer método que recebe o id
                insertSensorRoomApi(sensor, completion: { (newSensor, error) in
                    sensor.id = newSensor?.id
                    DispatchQueue.main.async {
                    self.addSensor(sensor)
                    }
                        self.insertSensorValueApi(sensor, completion: {(error) in
                            print(error as Any)
                    })
                })
            }
        }
    }
    
    // MARK: - Navigation
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        super.prepare(for: segue, sender: sender)
        
        switch(segue.identifier ?? "") {
        
        case "AddItem":
            os_log("Adding a new meal.", log: OSLog.default, type: .debug)
            
        case "ShowDetail":
            guard let sensorDetailViewController = segue.destination as? SensorViewController else {
                fatalError("Unexpected destination: \(segue.destination)")
            }
            
            guard let selectedSensorCell = sender as? SensorTableViewCell else {
                fatalError("Unexpected sender: \(String(describing: sender))")
            }
            
            guard let indexPath = tableView.indexPath(for: selectedSensorCell) else {
                fatalError("The selected cell is not being displayed by the table")
            }
            
            let selectedSensor = room?.sensors?[indexPath.row]
            sensorDetailViewController.sensor = selectedSensor
        //sensorDetailViewController.roomId = room.id
        default:
            fatalError("Unexpected Segue Identifier; \(String(describing: segue.identifier))")
        }
    }
    
    //MARK: - CALLS -- TODO: Optimize calls
    
    func deleteSensorApi(_ sensor: Sensor){
        let stringForUpdate = SensorTableViewController.SensorsURL + "\(String(describing: sensor.id!))/"
        
        let url = URL(string: stringForUpdate)
        guard let requestUrl = url else { fatalError() }
        var request = URLRequest(url: requestUrl)
        request.httpMethod = "DELETE"
        
        //Create Header according to the documentation
        let userName = "smarthome" //Need to be replaced with correct value
        let password = "smarthome" //Need to be replaced with correct value
        let toEncode = "\(userName):\(password)" //Form the String to be encoded
        let encoded = toEncode.data(using: .utf8)?.base64EncodedString()
        
        // Set HTTP Request Header
        request.setValue("application/json", forHTTPHeaderField: "Accept")
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.addValue("Basic \(encoded!)", forHTTPHeaderField: "Authorization")
        
        let task = URLSession.shared.dataTask(with: request) { (data, response, error) in
            
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
            
        }
        task.resume()
    }
    
    func downloadSensors() {
        
        guard let url = URL(string: SensorTableViewController.SensorsURL) else {
            print("Error: cannot create URL")
            return
        }
        
        //Create Header according to the documentation
        let userName = "smarthome" //Need to be replaced with correct value
        let password = "smarthome" //Need to be replaced with correct value
        let toEncode = "\(userName):\(password)" //Form the String to be encoded
        let encoded = toEncode.data(using: .utf8)?.base64EncodedString()
        
        
        var request = URLRequest(url: url)
        //Add the header value
        
        // Create the request
        request.httpMethod = "GET"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.addValue("Basic \(encoded!)", forHTTPHeaderField: "Authorization")
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
                print(newSensors)
                for sensor in newSensors {
                    // add downloaded meal without photo
                    
                    self.downloadValues(sensor)
                    
                    
                    
                }
                
            } catch let parseError as NSError {
                
                print(parseError.localizedDescription)
            }
            
        }.resume()
    }
    
    
    
    func insertSensorRoomApi(_ sensor: Sensor, completion: @escaping (_ newSensor: Sensor?, _ error: Error?)->()) {
        let url = URL(string: SensorTableViewController.SensorsURL)
        guard let requestUrl = url else { fatalError() }
        var request = URLRequest(url: requestUrl)
        request.httpMethod = "POST"
        
        //Create Header according to the documentation
        let userName = "smarthome" //Need to be replaced with correct value
        let password = "smarthome" //Need to be replaced with correct value
        let toEncode = "\(userName):\(password)" //Form the String to be encoded
        let encoded = toEncode.data(using: .utf8)?.base64EncodedString()
        
        // Set HTTP Request Header
        request.setValue("application/json", forHTTPHeaderField: "Accept")
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.addValue("Basic \(encoded!)", forHTTPHeaderField: "Authorization")
        do{
            let jsonData = try JSONEncoder().encode(sensor)
            request.httpBody = jsonData
            
        } catch let parseError as NSError {
            print(parseError.localizedDescription)
        }
        
        var newSensor: Sensor? = nil
        
        let task = URLSession.shared.dataTask(with: request) { (data, response, error) in
            
            if let error = error {
                print("Error took place \(error)")
                completion(nil, error)
                return
            }
            guard let data = data else {return}
            do{
                newSensor = try JSONDecoder().decode(Sensor.self, from: data)
                completion(newSensor, error)
                
                print("todoItemModel id: \(newSensor?.id ?? 0)")
            }catch let jsonErr{
                print(jsonErr)
            }
            
        }
        task.resume()
        
    }
    
    func insertSensorValueApi(_ sensor: Sensor, completion: @escaping (_ error: Error?) -> ()) {
        let url = URL(string: SensorTableViewController.SensorsValuesPostURL)
        guard let requestUrl = url else { fatalError() }
        var request = URLRequest(url: requestUrl)
        request.httpMethod = "POST"
        
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
        //Create Header according to the documentation
        let userName = "smarthome" //Need to be replaced with correct value
        let password = "smarthome" //Need to be replaced with correct value
        let toEncode = "\(userName):\(password)" //Form the String to be encoded
        let encoded = toEncode.data(using: .utf8)?.base64EncodedString()
        
        // Set HTTP Request Header
        request.setValue("application/json", forHTTPHeaderField: "Accept")
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.addValue("Basic \(encoded!)", forHTTPHeaderField: "Authorization")
        request.httpBody = jsonData
        
        
        
        let task = URLSession.shared.dataTask(with: request) { (data, response, error) in
            
            if let error = error {
                print("Error took place \(error)")
                completion(error)
                return
            }
            guard let data = data else {return}
            do{
                guard let jsonObject = try JSONSerialization.jsonObject(with: data) as? [String: Any] else {
                    print("Error: Cannot convert data to JSON object")
                    return
                }
                print(jsonObject)
            }catch let jsonErr{
                print(jsonErr)
            }
            
        }
        task.resume()
        
    }
    
    func updateSensorApi(_ sensor: Sensor){
        let stringForUpdate = SensorTableViewController.SensorsURL + "\(String(describing: sensor.id!))/"
        
        let url = URL(string: stringForUpdate)
        guard let requestUrl = url else { fatalError() }
        var request = URLRequest(url: requestUrl)
        request.httpMethod = "PUT"
        
        //Create Header according to the documentation
        let userName = "smarthome" //Need to be replaced with correct value
        let password = "smarthome" //Need to be replaced with correct value
        let toEncode = "\(userName):\(password)" //Form the String to be encoded
        let encoded = toEncode.data(using: .utf8)?.base64EncodedString()
        
        // Set HTTP Request Header
        request.setValue("application/json", forHTTPHeaderField: "Accept")
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.addValue("Basic \(encoded!)", forHTTPHeaderField: "Authorization")
        do{
            let jsonData = try JSONEncoder().encode(sensor)
            request.httpBody = jsonData
            
        } catch let parseError as NSError {
            
            print(parseError.localizedDescription)
        }
        
        var newSensor: Sensor? = nil
        
        let task = URLSession.shared.dataTask(with: request) { (data, response, error) in
            
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
            
        }
        task.resume()
        
    }
    
    
    func downloadValues(_ sensor: Sensor) {
        
        let urlForValue = SensorTableViewController.SensorsValuesURL + "?idsensor=\(String(describing: sensor.id!))"
        
        guard let url = URL(string: urlForValue) else {
            print("Error: cannot create URL")
            return
        }
        
        //Create Header according to the documentation
        let userName = "smarthome" //Need to be replaced with correct value
        let password = "smarthome" //Need to be replaced with correct value
        let toEncode = "\(userName):\(password)" //Form the String to be encoded
        let encoded = toEncode.data(using: .utf8)?.base64EncodedString()
        
        
        var request = URLRequest(url: url)
        //Add the header value
        
        // Create the request
        request.httpMethod = "GET"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.addValue("Basic \(encoded!)", forHTTPHeaderField: "Authorization")
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
                
                let json = try JSONSerialization.jsonObject(with: data, options: []) as? [[String:Any]]
                
                let value = (json?[0]["value"] as AnyObject? as? String) ?? ""
                // add downloaded meal without photo
                DispatchQueue.main.async {
                    sensor.value = Double(value)
                    
                    self.addSensor(sensor)
                }
                
            } catch let parseError as NSError {
                
                print(parseError.localizedDescription)
            }
            
        }.resume()
    }
    
    
}

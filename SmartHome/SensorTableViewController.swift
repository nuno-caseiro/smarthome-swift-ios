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
    
    //Create Header
    let userName = "smarthome"
    let password = "smarthome"
    var toEncode: String = ""
    var encoded: String = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //navigationController?.interactivePopGestureRecognizer?.delegate = nil
        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false
        
        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem
     
        toEncode = "\(userName):\(password)" //Form the String to be encoded
        encoded = toEncode.data(using: .utf8)?.base64EncodedString() ?? "ERROR"
        //Necessário meter no disco??
        requestMethod(SensorTableViewController.SensorsURL, "GET", "getAllSensors", nil, completionToInsertSensor: nil, completionToInsertSensorValue: nil)
        
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
        cell.sensorImageView.image = sensor?.image
        return cell
    }
    
    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            
            
            guard let sensor = room?.sensors?[indexPath.row] else { return  }
            
            let stringForDelete = SensorTableViewController.SensorsURL + "\(String(describing: sensor.id!))/"

            requestMethod(stringForDelete, "DELETE", "DELETE", sensor, completionToInsertSensor: nil, completionToInsertSensorValue: nil)
            
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
                
                let stringForUpdate = SensorTableViewController.SensorsURL + "\(String(describing: sensor.id!))/"

                requestMethod(stringForUpdate, "PUT", "updateSensor", sensor, completionToInsertSensor: nil, completionToInsertSensorValue: nil)
                
                room?.sensors?[selectedIndexPath.row] = sensor
                tableView.reloadRows(at: [selectedIndexPath], with: .none)
            }
            else {
                //fazer post e editar id com a resposta; fazer método que recebe o id
                requestMethod(SensorTableViewController.SensorsURL, "POST", "insertSensorRoom", sensor, completionToInsertSensor: { (newSensor, error) in
                    sensor.id = newSensor?.id
                    DispatchQueue.main.async {
                        self.addSensor(sensor)
                    }
                    self.requestMethod(SensorTableViewController.SensorsValuesPostURL, "POST", "insertSensorValue", sensor, completionToInsertSensor: nil, completionToInsertSensorValue: {(error) in
                        print(error as Any)
                    })
                },completionToInsertSensorValue: nil)
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
        
    func requestMethod(_ urlString: String, _ method:String, _ action: String, _ sensor: Sensor?, completionToInsertSensor: ( (_ newSensor: Sensor?, _ error: Error?)->())?, completionToInsertSensorValue: ( (_ error: Error?) -> ())? ){
        
        guard let url = URL(string: urlString) else {
            print("Error: cannot create URL")
            return
        }
        
        // Create the request
        var request = URLRequest(url: url)
        
        request.httpMethod = method
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.addValue("Basic \(self.encoded)", forHTTPHeaderField: "Authorization")
        //request.addValue("Token 2db95cd10f66e4a58bbd4f19b10a8b2a0ecc4eb8", forHTTPHeaderField: "Authorization")
        
        var newSensor: Sensor? = nil
        
        //PREPARE DATA
        switch action {
        case "insertSensorRoom":
            do{
                let jsonData = try JSONEncoder().encode(sensor)
                request.httpBody = jsonData
                
            } catch let parseError as NSError {
                print(parseError.localizedDescription)
            }
        case "insertSensorValue":
            // Create model
            struct SensorValue: Codable {
                let idsensor: Int
                let value: Double
            }
            
            // Add data to the model
            let uploadDataModel = SensorValue(idsensor: sensor?.id ?? 0, value: sensor?.value ?? 0)
            
            // Convert model to JSON data
            guard let jsonData = try? JSONEncoder().encode(uploadDataModel) else {
                print("Error: Trying to convert model to JSON data")
                return
            }
            request.httpBody = jsonData
        case "updateSensor":
            do{
                let jsonData = try JSONEncoder().encode(sensor)
                request.httpBody = jsonData
                
            } catch let parseError as NSError {
                
                print(parseError.localizedDescription)
            }
            
        default:
            print("DEFAULT FIRST PART OF REQUEST")
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
            
            switch action{
            case "getAllSensors":
                do {
                    let newSensors: [Sensor] = try JSONDecoder().decode([Sensor].self, from: data)
                    print(newSensors)
                    for sensor in newSensors {
                        
                        switch sensor.sensorType{
                            case "led":
                                sensor.image = UIImage(named: "light_icon")
                            case "camera":
                                sensor.image = UIImage(named: "camera_icon")
                            case "servo":
                                sensor.image = UIImage(named: "door_icon")
                            default:
                                return
                        }
                      
                        DispatchQueue.main.async {
                            self.addSensor(sensor)
                        }
                    }
                    
                } catch let parseError as NSError {
                    
                    print(parseError.localizedDescription)
                }
            case "insertSensorRoom":
                do{
                    newSensor = try JSONDecoder().decode(Sensor.self, from: data)
                    completionToInsertSensor!(newSensor, error)
                    
                    print("todoItemModel id: \(newSensor?.id ?? 0)")
                }catch let jsonErr{
                    print(jsonErr)
                }
            case "insertSensorValue":
                do{
                    guard let jsonObject = try JSONSerialization.jsonObject(with: data) as? [String: Any] else {
                        print("Error: Cannot convert data to JSON object")
                        return
                    }
                    print(jsonObject)
                }catch let jsonErr{
                    print(jsonErr)
                }
            case "updateSensor":
                do{
                    newSensor = try JSONDecoder().decode(Sensor.self, from: data)
                    print("todoItemModel id: \(newSensor?.id ?? 0)")
                }catch let jsonErr{
                    print(jsonErr)
                }
            case "sensorValue":
                do {
                    
                    let json = try JSONSerialization.jsonObject(with: data, options: []) as? [[String:Any]]
                    
                    guard let value = (json?[0]["value"] as AnyObject? ) else{
                        print ("Cant obtain value on action: sensorValue")
                        return
                    }
                    // add downloaded meal without photo
                    DispatchQueue.main.async {
                        sensor?.value = Double(value as! Substring)
                        
                        self.addSensor(sensor!)
                    }
                    
                } catch let parseError as NSError {
                    
                    print(parseError.localizedDescription)
                }
            default:
                print("DEFAULT")
            }
            
            
        }.resume()
    }
    
    
}

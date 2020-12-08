//
//  TypeTableViewController.swift
//  SmartHome
//
//  Created by Nuno Caseiro on 07/12/2020.
//

import UIKit
import os.log
class TypeViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    static let SensorsValuesPostURL = "http://161.35.8.148/api/sensorsvalues/"
    @IBOutlet weak var typeSensorTableView: UITableView!
    @IBOutlet weak var typeTitleLabel: UILabel!
    @IBOutlet weak var typeImage: UIImageView!
    var image: UIImage?
    var titleType: String?
    var sensorOfType = [Sensor]()
    var sensorOfTypeAux = [Sensor]()
    var sensorOfTypeBackup = [Sensor]()
    var type = ""
    var validation = Validation()
    

    
    static let SensorTypeURL = "http://161.35.8.148/api/sensorsoftype/"
    override func viewDidLoad() {
        super.viewDidLoad()
        
        typeSensorTableView.delegate = self
        typeSensorTableView.dataSource = self
        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false
        typeImage.image = image
        typeTitleLabel.text = titleType
        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem
        getSensorsOfType(TypeViewController.SensorTypeURL + "?type=\(type)")
    }
    
    
    @IBAction func clearFilters(_ sender: Any) {
        getSensorsOfType(TypeViewController.SensorTypeURL + "?type=\(type)")
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        super.prepare(for: segue, sender: sender)
        
       
        switch(segue.identifier ?? "") {
        
        case "showFilter":
            os_log("Showing filters.", log: OSLog.default, type: .debug)
        case "AddItem":
            guard let sensorDetailViewController = segue.destination as? TypeAddSensorViewController else {
                fatalError("Unexpected destination: \(segue.destination)")
            }
            os_log("Adding a new sensor.", log: OSLog.default, type: .debug)
            sensorDetailViewController.typeStr = type
            
        case "ShowDetail":
            guard let sensorDetailViewController = segue.destination as? TypeAddSensorViewController else {
                fatalError("Unexpected destination: \(segue.destination)")
            }
            guard let selectedSensorCell = sender as? TypeTableViewCell else {
                fatalError("Unexpected sender: \(String(describing: sender))")
            }
            
            guard let indexPath = typeSensorTableView.indexPath(for: selectedSensorCell) else {
                fatalError("The selected cell is not being displayed by the table")
            }
            
            let selectedSensor = sensorOfType[indexPath.row]
            sensorDetailViewController.sensor = selectedSensor
            sensorDetailViewController.typeStr = type
        default:
            fatalError("Unexpected Segue Identifier; \(String(describing: segue.identifier))")
        }
    }
    
    // Override to support editing the table view.
     func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
             let sensor = sensorOfType[indexPath.row]
            
            let stringForDelete = SensorTableViewController.SensorsURL + "\(String(describing: sensor.id!))/"

            deleteSensor(urlString: stringForDelete)
            // Delete the row from the data source
            sensorOfType.remove(at: indexPath.row)
            // Delete the row from the data source
            tableView.deleteRows(at: [indexPath], with: .fade)
            
        } else if editingStyle == .insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }
    }
    
    func deleteSensor(urlString: String){
        guard let url = URL(string: urlString) else {
            print("Error: cannot create URL")
            return
        }
        
        // Create the request
        var request = URLRequest(url: url)
        
        request.httpMethod = "DELETE"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.addValue("Token \(AppData.instance.authToken)", forHTTPHeaderField: "Authorization")
     
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
    
    
    @IBAction func unwindToList(sender: UIStoryboardSegue) {
        
        
        if let sourceViewController = sender.source as? TypePopupFilterViewController{
            sensorOfType.removeAll()
            sensorOfType.append(contentsOf: sensorOfTypeBackup)
            
            for sensor in sensorOfType{
                switch sourceViewController.statusDropDown.text! {
                case "Both":
                    checkSensorToInsert(sourceViewController: sourceViewController, sensor: sensor)
                case "On":
                    if(Int(sensor.value!) >= 1){
                        checkSensorToInsert(sourceViewController: sourceViewController, sensor: sensor)
                    }
                case "Off":
                    if(Int(sensor.value!) < 1){
                        checkSensorToInsert(sourceViewController: sourceViewController, sensor: sensor)
                    }
                default:
                    print("DEFAULT unwind")
                }
            }
            sensorOfType.removeAll()
            sensorOfType.append(contentsOf: sensorOfTypeAux)
            sensorOfTypeAux.removeAll()
            typeSensorTableView.reloadData()
        }
        
        if let sourceViewController = sender.source as? TypeAddSensorViewController,
           let sensor = sourceViewController.sensor {
            
            if let selectedIndexPath = typeSensorTableView.indexPathForSelectedRow {
                // Update an existing sensor.
                
                let stringForUpdate = SensorTableViewController.SensorsURL + "\(String(describing: sensor.id!))/"

                updateSensorRequest(urlString: stringForUpdate, sensor: sensor)
                sensorOfType[selectedIndexPath.row] = sensor
                typeSensorTableView.reloadRows(at: [selectedIndexPath], with: .none)
            }
            else {
                //fazer post e editar id com a resposta; fazer método que recebe o id
                insertSensorRequest(urlString: SensorTableViewController.SensorsURL, sensor: sensor, completionToInsertSensor: { (newSensor, error) in
                    sensor.id = newSensor?.id
                    sensor.roomtype = newSensor?.roomtype
                    DispatchQueue.main.async {
                        self.addSensor(sensor)
                    }
                    self.insertSensorValueRequest(urlString: SensorTableViewController.SensorsValuesPostURL, sensor: sensor)
                    
                })
            }
        }
    }
    
    
    func checkSensorToInsert(sourceViewController: TypePopupFilterViewController ,sensor: Sensor){
        if(sensor.roomtype == "bedroom" && sourceViewController.bedroom == true ){
            !checkDuplicate(sensor: sensor) ? sensorOfTypeAux.append(sensor) : print("duplicate")
        }
        if(sensor.roomtype == "garage" && sourceViewController.garage == true ){
            !checkDuplicate(sensor: sensor) ? sensorOfTypeAux.append(sensor) : print("duplicate")
        }
        
        if(sensor.roomtype == "kitchen" && sourceViewController.kitchen == true ){
            !checkDuplicate(sensor: sensor) ? sensorOfTypeAux.append(sensor) : print("duplicate")
        }
        
        if(sensor.roomtype == "living" && sourceViewController.living == true ){
            !checkDuplicate(sensor: sensor) ? sensorOfTypeAux.append(sensor) : print("duplicate")
        }
        
        if(sourceViewController.bedroom == false && sourceViewController.garage == false && sourceViewController.kitchen == false && sourceViewController.living == false){
            !checkDuplicate(sensor: sensor) ? sensorOfTypeAux.append(sensor) : print("duplicate")
        }
    }
    
    func checkDuplicate(sensor: Sensor) ->Bool{
        for sensorInArray in sensorOfTypeAux{
            if (sensor.id == sensorInArray.id){
                return true
            }
        }
        return false
    }
    
    
    func getSensorsOfType(_ urlString: String){
        guard let url = URL(string: urlString) else {
            print("Error: cannot create URL")
            return
        }
        
        // Create the request
        var request = URLRequest(url: url)
        
        request.httpMethod = "GET"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.addValue("Token \(AppData.instance.authToken)", forHTTPHeaderField: "Authorization")
        
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
                
                DispatchQueue.main.async {
                    /* if (newSensors.count != self.room?.sensors?.count && self.room?.sensors?.count != 0) {
                     
                     }*/
                    self.sensorOfTypeAux.removeAll()
                    self.sensorOfTypeBackup.removeAll()
                    self.sensorOfType.removeAll()
                    self.typeSensorTableView.reloadData()
                }
                
                for sensor in newSensors {
                    
                    switch sensor.sensorType{
                    case "led":
                        sensor.image = UIImage(named: "light_icon")
                    case "camera":
                        sensor.image = UIImage(named: "camera_new_icon")
                    case "servo":
                        sensor.image = UIImage(named: "door_icon")
                    case "motion":
                        sensor.image = UIImage(named: "motion_icon")
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
        request.addValue("Token \(AppData.instance.authToken)", forHTTPHeaderField: "Authorization")
        
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
    
    func insertSensorRequest(urlString: String, sensor: Sensor, completionToInsertSensor: ( (_ newSensor: Sensor?, _ error: Error?)->())?){
        guard let url = URL(string: urlString) else {
            print("Error: cannot create URL")
            return
        }
        
        // Create the request
        var request = URLRequest(url: url)
        
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.addValue("Token \(AppData.instance.authToken)", forHTTPHeaderField: "Authorization")

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
    
    func insertSensorValueRequest(urlString: String, sensor: Sensor){
        guard let url = URL(string: urlString) else {
            print("Error: cannot create URL")
            return
        }
        
        // Create the request
        var request = URLRequest(url: url)
        
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.addValue("Token \(AppData.instance.authToken)", forHTTPHeaderField: "Authorization")

        
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
    
    
    fileprivate func addSensor(_ sensor: Sensor) {
        // Add a new sensor.
        let newIndexPath = IndexPath(row: sensorOfType.count , section: 0)
        sensorOfType.append(sensor)
        sensorOfTypeBackup.append(sensor)
        typeSensorTableView.insertRows(at: [newIndexPath], with: .automatic)
        
    }
    
    // MARK: - Table view data source
    
    func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return sensorOfType.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cellIdentifier = "TypeSensorViewCell"
        guard let cell = tableView.dequeueReusableCell(withIdentifier:cellIdentifier, for: indexPath) as? TypeTableViewCell else {
            fatalError("The dequeued cell is not an instance of SensorTableViewCell.")
        }
        // Fetches the appropriate meal for the data source layout.
        let sensor = sensorOfType[indexPath.row]
        cell.sensorNameLabel.text = sensor.name
        cell.roomLabel.text = sensor.roomtype
        
        if sensor.value! >= 1{
            cell.switchSensor.setOn(true, animated: true)
        }else{
            cell.switchSensor.setOn(false, animated: true)
        }
        
        // assign the index of the youtuber to button tag
          cell.switchSensor.tag = indexPath.row
          
          // call the subscribeTapped method when tapped
        cell.switchSensor.addTarget(self, action: #selector(valueChange), for:UIControl.Event.valueChanged)
        
        cell.roomLabel.text = sensor.roomtype?.firstUppercased
       
        return cell
    }
    
    @objc func valueChange(mySwitch: UISwitch) {
           let sensor = sensorOfType[mySwitch.tag]
            
        if (mySwitch.isOn){
            sensor.value = 1.0
        }else{
            sensor.value = 0.0
        }
        
        updateSensorValue(sensor: sensor, completionToInsertSensorValue: {() in
            self.getSensorsOfType(TypeViewController.SensorTypeURL + "?type=\(self.type)")
        })
       }
    
    func updateSensorValue(sensor: Sensor, completionToInsertSensorValue: (() -> Void)?){
        
        guard let url = URL(string: TypeViewController.SensorsValuesPostURL) else {
            print("Error: cannot create URL")
            return
        }
        
        // Create the request
        var request = URLRequest(url: url)
        
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.addValue("Token \(AppData.instance.authToken)", forHTTPHeaderField: "Authorization")
        
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
                completionToInsertSensorValue!()
                print(jsonObject)
            }catch let jsonErr{
                print(jsonErr)
            }
            
        }.resume()
   
    }
    
}

extension StringProtocol {
    var firstUppercased: String { prefix(1).uppercased() + dropFirst() }
    var firstCapitalized: String { prefix(1).capitalized + dropFirst() }
}


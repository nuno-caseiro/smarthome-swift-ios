//
//  SensorTableViewController.swift
//  SmartHome
//
//  Created by Nuno Caseiro on 29/11/2020.
//

import UIKit

class SensorTableViewController: UITableViewController, UITextFieldDelegate {
    
    var room: Room?
    static let SensorsURL = "http://161.35.8.148/api/sensors/"
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false
        
        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem
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
        //cell.photoImageView.image = meal.photo
        //cell.ratingControl.rating = meal.rating
        return cell
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
                    DispatchQueue.main.async {
                        
                        self.addSensor(sensor)
                    }
                }
            } catch let parseError as NSError {
                
                print(parseError.localizedDescription)
            }
            
        }.resume()
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
    
    
    /*
     override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
     let cell = tableView.dequeueReusableCell(withIdentifier: "reuseIdentifier", for: indexPath)
     
     // Configure the cell...
     
     return cell
     }
     */
    
    /*
     // Override to support conditional editing of the table view.
     override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
     // Return false if you do not want the specified item to be editable.
     return true
     }
     */
    
    /*
     // Override to support editing the table view.
     override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
     if editingStyle == .delete {
     // Delete the row from the data source
     tableView.deleteRows(at: [indexPath], with: .fade)
     } else if editingStyle == .insert {
     // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
     }
     }
     */
    
    /*
     // Override to support rearranging the table view.
     override func tableView(_ tableView: UITableView, moveRowAt fromIndexPath: IndexPath, to: IndexPath) {
     
     }
     */
    
    /*
     // Override to support conditional rearranging of the table view.
     override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
     // Return false if you do not want the item to be re-orderable.
     return true
     }
     */
    
    /*
     // MARK: - Navigation
     
     // In a storyboard-based application, you will often want to do a little preparation before navigation
     override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
     // Get the new view controller using segue.destination.
     // Pass the selected object to the new view controller.
     }
     */
    
}

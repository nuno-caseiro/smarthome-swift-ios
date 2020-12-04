//
//  ViewController.swift
//  SmartHome
//
//  Created by Nuno Caseiro on 19/11/2020.
//

import UIKit
import os.log

class DashboardViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
   
   

    @IBOutlet weak var roomsTable: UITableView!
    @IBOutlet weak var homeName: HomeName!
    weak var home = AppData.instance.home
    
    static let RoomsURL = "http://161.35.8.148/api/rooms/"
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        roomsTable.delegate = self
        roomsTable.dataSource = self
        
        downloadRooms()
    }
   
    private func loadSampleRoom(){
        
        let room1 = Room(name: "Garagem", home: 1)
        
        home?.rooms.append(room1)
        
    }
    
    private func loadRooms() -> [Room]? {
        do {
            let codedData = try Data(contentsOf: Room.ArchiveURL)
            let rooms = try NSKeyedUnarchiver.unarchiveTopLevelObjectWithData(codedData) as?[Room]
            os_log("Rooms successfully loaded.", log: OSLog.default, type: .debug)
            return rooms;
        } catch {
            os_log("Failed to load rooms...", log: OSLog.default, type: .error)
            return nil
        }
    }
    
    fileprivate func addRoom(_ room: Room) {
        // Add a new meal.
        let newIndexPath = IndexPath(row: home?.rooms.count ?? 0, section: 0)
        home?.rooms.append(room)
        roomsTable.insertRows(at: [newIndexPath], with: .automatic)
    }
    
    func downloadRooms() {
        
        guard let url = URL(string: RoomTableViewController.RoomsURL) else {
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
                    let newRooms: [Room] = try JSONDecoder().decode([Room].self, from: data)
                    
                    for room in newRooms {
                        // add downloaded meal without photo
                        DispatchQueue.main.async {
                            room.sensors = [Sensor]()
                            self.addRoom(room)
                                                      
                        }
                    }
                    /*DispatchQueue.main.async {
                        self.saveRooms()
                    }*/
                } catch let parseError as NSError {
                    
                    print(parseError.localizedDescription)
                }
            }.resume()
        }
    
    
    
    
     func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        // Table view cells are reused and should be dequeued using a cell identifier.
        let cellIdentifier = "RoomTableViewCell"
        guard let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier, for: indexPath) as? RoomTableViewCell else {
            fatalError("The dequeued cell is not an instance of MealTableViewCell.")
        }
        
        // Fetches the appropriate room for the data source layout.
        
        let room = home?.rooms[indexPath.row]
        cell.roomNameLabel.text = room?.name
        //cell.photoImageView.image = meal.photo
        //cell.ratingControl.rating = meal.rating
        return cell
    }
    
       
     func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return home?.rooms.count ?? 0
    }
    
  /*  private func saveRooms() {
        do {
            let data = try NSKeyedArchiver.archivedData(withRootObject: home?.rooms, requiringSecureCoding: false)
            try data.write(to: Room.ArchiveURL)
            os_log("Rooms successfully saved.", log: OSLog.default, type: .debug)
        } catch {
            os_log("Failed to save rooms...", log: OSLog.default, type: .error)
        }
    }*/
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        super.prepare(for: segue, sender: sender)
        
        guard let sensorTableViewController = segue.destination as? SensorTableViewController else {
            fatalError("Unexpected destination: \(segue.destination)")
        }
         guard let selectedRoomCell = sender as? RoomTableViewCell else {
            fatalError("Unexpected sender: \(String(describing: sender))")
        }
        guard let indexPath = roomsTable.indexPath(for: selectedRoomCell) else {
            fatalError("The selected cell is not being displayed by the table")
        }
        
        let selectedRoom = home?.rooms[indexPath.row]
        sensorTableViewController.room = selectedRoom
        
    }
  
}

    
    
    
   
    
   


    



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
    
    static let RoomsURL = "http://161.35.8.148/api/roomsfortesting/"
    static let RoomsForPostAndDelURL = "http://161.35.8.148/api/rooms/"
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        roomsTable.delegate = self
        roomsTable.dataSource = self
        
        downloadRooms()
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
        let newIndexPath = IndexPath(row: home?.rooms.count ?? 0, section: 0)
        home?.rooms.append(room)
        roomsTable.insertRows(at: [newIndexPath], with: .automatic)
    }
    
    func downloadRooms() {
        
        guard let url = URL(string: DashboardViewController.RoomsURL) else {
            print("Error: cannot create URL")
            return
        }
     
        var request = URLRequest(url: url)
        //Add the header value
        
        // Create the request
        request.httpMethod = "GET"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.addValue("Token \(String(describing: AppData.instance.user.token!))", forHTTPHeaderField: "Authorization")
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
        
        
        switch(segue.identifier ?? "") {
        case "AddItem":
            os_log("Adding a new room.", log: OSLog.default, type: .debug)
            
        case "ShowDetail":
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
        default:
            fatalError("Unexpected Segue Identifier; \(String(describing: segue.identifier))")
        }
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            
            
            guard let room = home?.rooms[indexPath.row] else { return  }
                            
            deleteRoom(room)
            
            // Delete the row from the data source
            home?.rooms.remove(at: indexPath.row)
            // Delete the row from the data source
            tableView.deleteRows(at: [indexPath], with: .fade)
            
            
            
            
        } else if editingStyle == .insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new
        }
    }
    
    @IBAction func unwindToRoomList(sender: UIStoryboardSegue) {
        if let sourceViewController = sender.source as? RoomViewController,
           let room = sourceViewController.room {
            
            insertRoom(room, completionToInsertRoom: { (newRoom, error) in
                room.id = newRoom?.id
                DispatchQueue.main.async {
                    self.addRoom(room)
                }
            })
        }
    }
    
    func insertRoom(_ room: Room, completionToInsertRoom: ((_ newRoom: Room?, _ error: Error?)->())?) {
        guard let url = URL(string: DashboardViewController.RoomsForPostAndDelURL) else {
            print("Error: cannot create URL")
            return
        }
        
        // Create the url request
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type") // the request is JSON
        request.setValue("application/json", forHTTPHeaderField: "Accept") // the response expected to be in JSON format
        request.addValue("Token \(String(describing: AppData.instance.user.token!))", forHTTPHeaderField: "Authorization")
        
        do{
            let jsonData = try JSONEncoder().encode(room)
            request.httpBody = jsonData
            
        } catch let parseError as NSError {
            print(parseError.localizedDescription)
        }
        
        URLSession.shared.dataTask(with: request) { data, response, error in
            guard error == nil else {
                print("Error: error calling POST")
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
                let newRoom = try JSONDecoder().decode(Room.self, from: data)
                completionToInsertRoom!(newRoom, error)
                
                print("todoItemModel id: \(newRoom.id ?? 0)")
            }catch let jsonErr{
                print(jsonErr)
            }
            
        }.resume()
    }
    
    
    
    func deleteRoom(_ room: Room) {
        guard let url = URL(string: DashboardViewController.RoomsForPostAndDelURL + "\(String(describing: room.id!))/") else {
            print("Error: cannot create URL")
            return
        }
        
        // Create the url request
        var request = URLRequest(url: url)
        request.httpMethod = "DELETE"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type") // the request is JSON
        request.setValue("application/json", forHTTPHeaderField: "Accept") // the response expected to be in JSON format
        request.addValue("Token \(String(describing: AppData.instance.user.token!))", forHTTPHeaderField: "Authorization")
        
        URLSession.shared.dataTask(with: request) { data, response, error in
            guard error == nil else {
                print("Error: error calling DELETE")
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
    
}






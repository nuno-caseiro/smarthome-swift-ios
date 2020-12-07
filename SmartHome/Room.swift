//
//  Room.swift
//  SmartHome
//
//  Created by Nuno Caseiro on 21/11/2020.
//

import UIKit
import os.log

class Room: NSObject, NSCoding, Codable{
    
    var id: Int?
    var name: String
    var home: Int
    var ip: String
    var sensors: [Sensor]?
    var image: UIImage?
    //var roomType: String
    
    static let DocumentsDirectory = FileManager().urls(for: .documentDirectory, in:.userDomainMask).first!
    static let ArchiveURL = DocumentsDirectory.appendingPathComponent("rooms")
    
    init(name: String, home: Int, ip: String, sensors: [Sensor]?, id: Int?, image: UIImage?) {
        self.name = name
        self.home = home
        self.ip = ip
        self.sensors = [Sensor]()
        self.id = id
        self.image = image
        //self.roomType = roomType
    }
    
    
    func encode(with coder: NSCoder) {
        coder.encode(name, forKey: PropertyKey.name)
        coder.encode(home, forKey: PropertyKey.home)
        coder.encode(ip, forKey: PropertyKey.ip)
        coder.encode(sensors, forKey: PropertyKey.sensors)
        coder.encode(id, forKey: PropertyKey.id)
        coder.encode(image, forKey: PropertyKey.image)
        //coder.encode(roomType, forKey: PropertyKey.roomType)
    }
    
    required convenience init?(coder: NSCoder) {
        // The name is required. If we cannot decode a name string, the initializer should fail.
        guard let name = coder.decodeObject(forKey: PropertyKey.name) as? String else {
            os_log("Unable to decode the name for a Room object.", log: OSLog.default, type: .debug)
            return nil
        }
        // Because photo is an optional property of Meal, just use conditional cast.
        let home = coder.decodeInteger(forKey: PropertyKey.home)
        
        let ip = coder.decodeObject(forKey: PropertyKey.ip) as! String
        
        let sensors = coder.decodeObject(forKey: PropertyKey.sensors) as? [Sensor]
        
        let id = coder.decodeInteger(forKey: PropertyKey.id)
        
        let image = coder.decodeObject(forKey: PropertyKey.image) as? UIImage
        
        self.init(name: name, home: home, ip: ip, sensors: sensors, id: id, image: image)
    }
    
    struct PropertyKey {
        static let name = "name"
        static let home = "home"
        static let ip = "ip"
        static let sensors = "sensors"
        static let id = "id"
        static let image = "image"
        //static let roomType = "roomType"
        
    }
    
    enum CodingKeys: String, CodingKey {
        case name
        case home
        case ip
        case sensors
        case id
        //case roomtype
    }
    
}

//
//  Sensor.swift
//  SmartHome
//
//  Created by Nuno Caseiro on 21/11/2020.
//

import UIKit
import os.log

class Sensor: NSObject, NSCoding, Codable {
    
    var id: Int?
    var name: String
    var sensorType: String
    var value: Double?
    var room: Int
    var gpio: Int
    
    static let DocumentsDirectory = FileManager().urls(for: .documentDirectory, in:.userDomainMask).first!
    static let ArchiveURL = DocumentsDirectory.appendingPathComponent("sensors")
    
     init(id: Int, name: String, sensorType: String, value: Double?, room: Int, gpio: Int) {
        self.id = id
        self.name = name
        self.sensorType = sensorType
        self.value = value
        self.room = room
        self.gpio = gpio
    }
    
    init(name: String, sensorType: String, value: Double?, room: Int, gpio: Int) {
       self.id = nil
       self.name = name
       self.sensorType = sensorType
       self.value = value
       self.room = room
       self.gpio = gpio
   }
    
    func encode(with coder: NSCoder) {
        coder.encode(id, forKey: PropertyKey.id)
        coder.encode(name, forKey: PropertyKey.name)
        coder.encode(sensorType, forKey: PropertyKey.sensorType)
        coder.encode(value, forKey: PropertyKey.value)
        coder.encode(room, forKey: PropertyKey.room)
        coder.encode(gpio, forKey: PropertyKey.gpio)
    }
    
    required convenience init?(coder: NSCoder) {
        // The name is required. If we cannot decode a name string, the initializer should fail.
        guard let name = coder.decodeObject(forKey: PropertyKey.name) as? String else {
            os_log("Unable to decode the name for a Room object.", log: OSLog.default, type: .debug)
            return nil
        }
        // Because photo is an optional property of Meal, just use conditional cast.
        let id = coder.decodeInteger(forKey: PropertyKey.id)
        
        let sensorType = coder.decodeObject(forKey: PropertyKey.sensorType) as! String
        
        let value = coder.decodeObject(forKey: PropertyKey.value) as? Double
        
        let room = coder.decodeInteger(forKey: PropertyKey.room)
        
        let gpio = coder.decodeInteger(forKey: PropertyKey.gpio) 
        
        self.init(id: id, name: name, sensorType: sensorType, value: value, room: room, gpio: gpio)
    }
    
    
    struct PropertyKey {
        static let id = "id"
        static let name = "name"
        static let sensorType = "sensorType"
        static let value = "value"
        static let room = "room"
        static let gpio = "gpio"
    }
    
    enum CodingKeys: String, CodingKey {
        case id
        case name
        case sensorType = "sensortype"
        case room
        case gpio
    }
    
}

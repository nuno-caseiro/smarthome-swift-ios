//
//  Room.swift
//  SmartHome
//
//  Created by Nuno Caseiro on 21/11/2020.
//

import UIKit

class Room{
   
    var name: String
    var home: Home
    var ip: String
    var sensors: [Sensor]
    
    internal init(name: String, home: Home, ip: String, sensors: [Sensor]) {
        self.name = name
        self.home = home
        self.ip = ip
        self.sensors = sensors
    }
    
}

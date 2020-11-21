//
//  Sensor.swift
//  SmartHome
//
//  Created by Nuno Caseiro on 21/11/2020.
//

import UIKit

class Sensor {
    
    var id: Int
    var name: String
    var sensorType: String
    var value: Double
    var room: Room
    var gpio: Int
    
    internal init(id: Int, name: String, sensorType: String, value: Double, room: Room, gpio: Int) {
        self.id = id
        self.name = name
        self.sensorType = sensorType
        self.value = value
        self.room = room
        self.gpio = gpio
    }
    
    
}

//
//  Home.swift
//  SmartHome
//
//  Created by Nuno Caseiro on 20/11/2020.
//

import UIKit

class Home{
     
    var name: String
    var rooms: [Room]
    
    internal init(name: String, rooms: [Room]) {
        self.name = name
        self.rooms = rooms
    }
}

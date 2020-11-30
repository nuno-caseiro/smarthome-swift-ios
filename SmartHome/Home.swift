//
//  Home.swift
//  SmartHome
//
//  Created by Nuno Caseiro on 20/11/2020.
//

import UIKit

class Home{
     
    var name: String
    var id: Int
    var rooms: [Room]
    
    internal init(name: String) {
        self.name = name
        self.rooms = [Room]()
        self.id = 0
    }
    
    init(){
        self.name = ""
        self.rooms = [Room]()
        self.id = 0
    }
    
    
}

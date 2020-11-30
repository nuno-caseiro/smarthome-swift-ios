//
//  AppData.swift
//  SmartHome
//
//  Created by Nuno Caseiro on 29/11/2020.
//

import Foundation

class AppData {
    //Singleton
    
    //creates the instance and guarantees that it's unique
       static let instance = AppData()
       
       private init() {
        
       }
    
       var home = Home()
    
    
        
       
}

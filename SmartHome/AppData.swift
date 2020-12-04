//
//  AppData.swift
//  SmartHome
//
//  Created by Nuno Caseiro on 29/11/2020.
//

import Foundation

class AppData {
    //Singleton
    
    static let instance = AppData()
    
    private init() {
        
    }
    
    var home = Home()
    var authToken = ""
    
    
    
}

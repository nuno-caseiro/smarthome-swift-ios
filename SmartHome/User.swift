//
//  User.swift
//  SmartHome
//
//  Created by Nuno Caseiro on 08/12/2020.
//

import Foundation

class User: NSObject, NSCoding, Codable{
  
    var id: Int?
    var username: String?
    var token: String?
    var firstname: String?
    var lastname: String?
    var email: String?
    
    init(id: Int?,username: String, firstname: String, lastname: String, email: String) {
        self.id = id;
        self.username = username;
        self.firstname = firstname
        self.lastname = lastname
        self.email = email
    }
    
    override init() {
        
    }
    
    func encode(with coder: NSCoder) {
        coder.encode(id, forKey: PropertyKey.id)
        coder.encode(username, forKey: PropertyKey.username)
        coder.encode(firstname, forKey: PropertyKey.firstname)
        coder.encode(lastname, forKey: PropertyKey.lastname)
        coder.encode(email, forKey: PropertyKey.email)
    }
    
    required convenience init?(coder: NSCoder) {
        
        let id = coder.decodeInteger(forKey: PropertyKey.id)
        
        let username = coder.decodeObject(forKey: PropertyKey.username) as! String
        
        let firstname = coder.decodeObject(forKey: PropertyKey.firstname) as! String
        
        let lastname = coder.decodeObject(forKey: PropertyKey.lastname) as! String
        
        let email = coder.decodeObject(forKey: PropertyKey.username) as! String
        
        self.init(id: id, username: username, firstname: firstname, lastname: lastname, email: email)
    }
    
    struct PropertyKey {
        static let id = "id"
        static let username = "username"
        static let firstname = "firstname"
        static let lastname = "lastname"
        static let email = "email"
    }
    
    enum CodingKeys: String, CodingKey {
        case id
        case username
        case email
        case firstname = "first_name"
        case lastname = "last_name"
    }
    
    
    
    
}

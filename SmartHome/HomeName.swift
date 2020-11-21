//
//  HomeName.swift
//  SmartHome
//
//  Created by Nuno Caseiro on 21/11/2020.
//

import UIKit

@IBDesignable class HomeName: UIView {
    
    @IBOutlet weak var homeName: UILabel!

    let nibName = "ViewHomeName"
   
    override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        commonInit()
    }
    
    func commonInit() {
        guard let view = loadViewFromNib() else { return }
        view.frame = self.bounds
        self.addSubview(view)
        DispatchQueue.main.async(execute: {
                // change label text after second calling.
               // ??? How to change label text at first calling ???
            self.getHomeName()
          })

    }
    
    func loadViewFromNib() -> UIView? {
        let nib = UINib(nibName: nibName, bundle: nil)
        return nib.instantiate(withOwner: self, options: nil).first as? UIView
    }
    
    func getHomeName(){
        
        
        guard let url = URL(string: "http://161.35.8.148/homes/1/") else {
            print("Error: cannot create URL")
            return
        }
        
        
        //Create Header according to the documentation
        let userName = "smarthome" //Need to be replaced with correct value
        let password = "smarthome" //Need to be replaced with correct value
        let toEncode = "\(userName):\(password)" //Form the String to be encoded
        let encoded = toEncode.data(using: .utf8)?.base64EncodedString()
        
        
        var request = URLRequest(url: url)
        //Add the header value
        
        // Create the request
        request.httpMethod = "GET"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.addValue("Basic \(encoded!)", forHTTPHeaderField: "Authorization")
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
                guard let jsonObject = try JSONSerialization.jsonObject(with: data) as? [String: Any] else {
                    print("Error: Cannot convert data to JSON object")
                    return
                }
                guard let prettyJsonData = try? JSONSerialization.data(withJSONObject: jsonObject, options: .prettyPrinted) else {
                    print("Error: Cannot convert JSON object to Pretty JSON data")
                    return
                }
                guard let prettyPrintedJson = String(data: prettyJsonData, encoding: .utf8) else {
                    print("Error: Could print JSON in String")
                    return
                }
                
                let name = (jsonObject["name"] as AnyObject? as? String) ?? ""
                
                DispatchQueue.main.async {
                        // change label text after second calling.
                       // ??? How to change label text at first calling ???self.homeName.text = aux
                    self.homeName.text = name
                  }
                
            } catch {
                print("Error: Trying to convert JSON data to string")
                return
            }
        }.resume()
    }
}



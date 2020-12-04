//
//  ConfigViewController.swift
//  SmartHome
//
//  Created by Nuno Caseiro on 04/12/2020.
//

import UIKit

class ConfigViewController: UIViewController {
  

    @IBOutlet weak var turnOn: UIButton!
    var valor: Bool = false
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
    }
    
    
    @IBAction func turnLed(_ sender: Any) {
        guard let url = URL(string: "http://161.35.8.148/api/sensorsvalues/25/") else {
            print("Error: cannot create URL")
            return
        }
        
        // Create model
        struct UploadData: Codable {
            let idsensor: Int
            let value: Double
        }
        
        valor = !valor
        var values = 0.0
        if(valor){
            values = 1.0
        }else{
            values = 0.0
        }
        
        
        // Add data to the model
        let uploadDataModel = UploadData(idsensor: 30, value: values)
        
        // Convert model to JSON data
        guard let jsonData = try? JSONEncoder().encode(uploadDataModel) else {
            print("Error: Trying to convert model to JSON data")
            return
        }
        
        let userName = "smarthome"
        let password = "smarthome"
        
        
        var toEncode: String = ""
        var encoded: String = ""
        
        toEncode = "\(userName):\(password)" //Form the String to be encoded
        encoded = toEncode.data(using: .utf8)?.base64EncodedString() ?? "ERROR"
        
        // Create the request
        var request = URLRequest(url: url)
        request.httpMethod = "PUT"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.addValue("Basic \(encoded)", forHTTPHeaderField: "Authorization")
        request.httpBody = jsonData
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
                
                print(prettyPrintedJson)
            } catch {
                print("Error: Trying to convert JSON data to string")
                return
            }
        }.resume()
    }
    
    /*
     // MARK: - Navigation
     
     // In a storyboard-based application, you will often want to do a little preparation before navigation
     override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
     // Get the new view controller using segue.destination.
     // Pass the selected object to the new view controller.
     }
     */
    
}

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
    
    @IBAction func unwindToSave(sender: UIStoryboardSegue) {
        let urlString = "http://161.35.8.148/api/users/" + "\(AppData.instance.user.id!)/"
        
        guard let url = URL(string: urlString) else {
            print("Error: cannot create URL")
            return
        }
        
        // Create the request
        var request = URLRequest(url: url)
        
        request.httpMethod = "PUT"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.addValue("Token \(String(describing: AppData.instance.user.token!))", forHTTPHeaderField: "Authorization")
        
        do{
            let jsonData = try JSONEncoder().encode(AppData.instance.user)
            request.httpBody = jsonData
            
        } catch let parseError as NSError {
            
            print(parseError.localizedDescription)
        }

        //MAKE REQUEST
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
            print(String(data: data, encoding: String.Encoding.utf8)!)
            guard let response = response as? HTTPURLResponse, (200 ..< 299) ~= response.statusCode else {
                
                print("Error: HTTP request failed")
                return
            }
            
            do{
                let user = try JSONDecoder().decode(User.self, from: data)
                print("todoItemModel id: \(String(describing: user.id))")
            }catch let jsonErr{
                print(jsonErr)
            }
            
        }.resume()
    }
    
    /*@IBAction func turnLed(_ sender: Any) {
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
        
        // Create the request
        var request = URLRequest(url: url)
        request.httpMethod = "PUT"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.addValue("Token \(String(describing: AppData.instance.user.token!))", forHTTPHeaderField: "Authorization")
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
    }*/
    
    
}

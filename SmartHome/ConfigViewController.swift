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
            
            do{
                _ = try JSONDecoder().decode(User.self, from: data)
            }catch let jsonErr{
                print(jsonErr)
            }
            
        }.resume()
    }
}

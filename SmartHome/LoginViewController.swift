//
//  LoginViewController.swift
//  SmartHome
//
//  Created by Nuno Caseiro on 04/12/2020.
//

import UIKit

class LoginViewController: UIViewController {
    
    
    @IBOutlet weak var usernameTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    static let UserDetails = "http://161.35.8.148/api/userdetails/"
    @IBOutlet weak var loginButton: UIButton!
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        
    }
    
    
    // MARK: Login methods
    @IBAction func loginButton(_ sender: Any) {
        
        let userName = usernameTextField.text
        let userPassword = passwordTextField.text
        
        if (userName?.isEmpty)! || (userPassword?.isEmpty)!{
            print("Username \(String(describing: userName)) or password \(String(describing: userPassword)) is empty")
            showMessage("Invalid credentials", "Required fields are empty")
            return
        }
        
        let myActivityIndicator = UIActivityIndicatorView(style: UIActivityIndicatorView.Style.medium)
        
        myActivityIndicator.center = view.center
        myActivityIndicator.hidesWhenStopped = false
        myActivityIndicator.startAnimating()
        
        view.addSubview(myActivityIndicator)
        
        guard let url = URL(string: "http://161.35.8.148/dj-rest-auth/login/") else {
            print("Error: cannot create URL")
            return
        }
        
        // Create model
        struct UploadData: Codable {
            let username: String
            let password: String
        }
        
        // Add data to the model
        let uploadDataModel = UploadData(username: userName!, password: userPassword!)
        
        // Convert model to JSON data
        guard let jsonData = try? JSONEncoder().encode(uploadDataModel) else {
            print("Error: Trying to convert model to JSON data")
            return
        }
        
        // Create the url request
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type") // the request is JSON
        request.setValue("application/json", forHTTPHeaderField: "Accept") // the response expected to be in JSON format
        
        
        request.httpBody = jsonData
        URLSession.shared.dataTask(with: request) { data, response, error in
            
            DispatchQueue.main.async {
                myActivityIndicator.removeFromSuperview()
            }
            guard error == nil else {
                print("Error: error calling POST")
                print(error!)
                return
            }
            guard let data = data else {
                print("Error: Did not receive data")
                return
            }
            print(String(decoding: data, as: UTF8.self))
            guard let response = response as? HTTPURLResponse, (200 ..< 299) ~= response.statusCode else {
                print("Error: HTTP request failed")
                DispatchQueue.main.async {
                    self.showMessage("Error", "Your credentials are invalid")
                }
                return
            }
            do {
                guard let jsonObject = try JSONSerialization.jsonObject(with: data) as? [String: Any] else {
                    print("Error: Cannot convert data to JSON object")
                    return
                }
                
                let acessToken = jsonObject["key"] as? String ?? ""
                if(acessToken.isEmpty){
                    self.showMessage("Error", "Key wasn't given")
                    return
                }
                
                AppData.instance.user.token = acessToken
                print(LoginViewController.UserDetails + "?username=\(userName!)")
                self.populateUser(urlString: LoginViewController.UserDetails + "?username=\( userName!)")
                
                DispatchQueue.main.async {
                    
                    let storyboard = UIStoryboard(name: "Main", bundle: nil)
                    let mainTabBarController = storyboard.instantiateViewController(identifier: "MainViewControllerId")
                    

                    mainTabBarController.modalPresentationStyle = .fullScreen
                    
                    self.present(mainTabBarController, animated: true, completion: nil)
                }
                
            } catch {
                print("Error: Trying to convert JSON data to string")
                return
            }
        }.resume()
        
    }
    
    func populateUser(urlString: String){
        guard let url = URL(string: urlString) else {
            print("Error: cannot create URL")
            return
        }
        // Create the request
        var request = URLRequest(url: url)
        
        request.httpMethod = "GET"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.addValue("Token \(String(describing: AppData.instance.user.token!))", forHTTPHeaderField: "Authorization")
        
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
            guard let response = response as? HTTPURLResponse, (200 ..< 299) ~= response.statusCode else {
                print("Error: HTTP request failed")
                return
            }
            
            do{
                let user = try JSONDecoder().decode([User].self, from: data)
                print("user id: \(user[0].id ?? 0)")
                
                DispatchQueue.main.async {
                AppData.instance.user.id = user[0].id
                AppData.instance.user.email = user[0].email
                AppData.instance.user.username = user[0].username
                AppData.instance.user.firstname = user[0].firstname
                AppData.instance.user.lastname = user[0].lastname
                }
            }catch let jsonErr{
                print(jsonErr)
            }
            
        }.resume()
    }
    
    
    func showMessage(_ title: String, _ message: String){
        // Create new Alert
        let dialogMessage = UIAlertController(title: title, message: message, preferredStyle: .alert)
        
        // Create OK button with action handler
        let ok = UIAlertAction(title: "OK", style: .default, handler: { (action) -> Void in
            print("Ok button tapped")
        })
        
        //Add OK button to a dialog message
        dialogMessage.addAction(ok)
        // Present Alert to
        self.present(dialogMessage, animated: true, completion: nil)
        
    }
    
}

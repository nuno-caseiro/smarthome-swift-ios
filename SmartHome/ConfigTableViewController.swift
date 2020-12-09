//
//  ConfigTableViewController.swift
//  SmartHome
//
//  Created by Nuno Caseiro on 04/12/2020.
//

import UIKit

class ConfigTableViewController: UITableViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false
        
        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem
    }
    
    
    
    // MARK: - Table view data source
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        
        return 2
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        if(indexPath.row == 0){
            self.parent?.performSegue(withIdentifier: "segueEdit", sender: self.parent)
        }
        
        if(indexPath.row == 1){
            
            guard let url = URL(string: "http://161.35.8.148/dj-rest-auth/logout/") else {
                print("Error: cannot create URL")
                return
            }
            
            let myActivityIndicator = UIActivityIndicatorView(style: UIActivityIndicatorView.Style.medium)
            
            myActivityIndicator.center = view.center
            myActivityIndicator.hidesWhenStopped = false
            myActivityIndicator.startAnimating()
            
            view.addSubview(myActivityIndicator)
            
            // Create the url request
            var request = URLRequest(url: url)
            request.httpMethod = "POST"
            request.setValue("application/json", forHTTPHeaderField: "Content-Type") // the request is JSON
            request.setValue("application/json", forHTTPHeaderField: "Accept") // the response expected to be in JSON format
            request.addValue("Token \(String(describing: AppData.instance.user.token!))", forHTTPHeaderField: "Authorization")
            
            URLSession.shared.dataTask(with: request) { data, response, error in
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
                    return
                }
                
                AppData.instance.user = User()
                AppData.instance.home = Home()
                
                DispatchQueue.main.async {
                    myActivityIndicator.removeFromSuperview()
                    let storyboard = UIStoryboard(name: "Main", bundle: nil)
                    let loginController = storyboard.instantiateViewController(identifier: "LoginViewControllerID")
                    loginController.modalPresentationStyle = .fullScreen
                    self.present(loginController, animated: true, completion: nil)
                }
                
            }.resume()
        }
    }
}

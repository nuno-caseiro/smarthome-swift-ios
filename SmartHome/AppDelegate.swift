//
//  AppDelegate.swift
//  SmartHome
//
//  Created by Nuno Caseiro on 19/11/2020.
//

import UIKit

@main
class AppDelegate: UIResponder, UIApplicationDelegate {



    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        return true
    }

    // MARK: UISceneSession Lifecycle

    func application(_ application: UIApplication, configurationForConnecting connectingSceneSession: UISceneSession, options: UIScene.ConnectionOptions) -> UISceneConfiguration {
        // Called when a new scene session is being created.
        // Use this method to select a configuration to create the new scene with.
        return UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)
    }

    func application(_ application: UIApplication, didDiscardSceneSessions sceneSessions: Set<UISceneSession>) {
        // Called when the user discards a scene session.
        // If any sessions were discarded while the application was not running, this will be called shortly after application:didFinishLaunchingWithOptions.
        // Use this method to release any resources that were specific to the discarded scenes, as they will not return.
    }
    
    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
        //request.addValue("Token 2db95cd10f66e4a58bbd4f19b10a8b2a0ecc4eb8", forHTTPHeaderField: "Authorization")
        
        guard let url = URL(string: "http://161.35.8.148/dj-rest-auth/logout/") else {
                  print("Error: cannot create URL")
                  return
              }
          
              // Create the url request
              var request = URLRequest(url: url)
              request.httpMethod = "POST"
              request.setValue("application/json", forHTTPHeaderField: "Content-Type") // the request is JSON
              request.setValue("application/json", forHTTPHeaderField: "Accept") // the response expected to be in JSON format
              request.addValue("Token \(AppData.instance.authToken)", forHTTPHeaderField: "Authorization")
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
                  guard let response = response as? HTTPURLResponse, (200 ..< 299) ~= response.statusCode else {
                      print("Error: HTTP request failed")
                      return
                  }
                  do {
                    guard (try JSONSerialization.jsonObject(with: data) as? [String: Any]) != nil else {
                          print("Error: Cannot convert data to JSON object")
                          return
                      }
                    
                    
                  } catch {
                      print("Error: Trying to convert JSON data to string")
                      return
                  }
              }.resume()
        
        

    }
    
   

}


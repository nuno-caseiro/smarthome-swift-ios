//
//  SensorViewController.swift
//  SmartHome
//
//  Created by Nuno Caseiro on 30/11/2020.
//

import UIKit
import os.log

class SensorViewController: UIViewController, UITextFieldDelegate {

    @IBOutlet weak var sensorNameTextField: UITextField!
    @IBOutlet weak var saveButton: UIBarButtonItem!
    var sensor: Sensor?
    var roomId: Int? = nil
    
    override func viewDidLoad() {
        super.viewDidLoad()

        sensorNameTextField.delegate = self
        // Do any additional setup after loading the view.
        if let sensor = sensor {
         navigationItem.title = sensor.name
         sensorNameTextField.text = sensor.name
         //photoImageView.image = meal.photo
         //ratingControl.rating = meal.rating
         }
    }

    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    
    // This method lets you configure a view controller before it's presented.
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        super.prepare(for: segue, sender: sender)
        // Configure the destination view controller only when the save button is pressed.
        guard let button = sender as? UIBarButtonItem, button === saveButton else {
            
            os_log("The save button was not pressed, cancelling", log:OSLog.default, type: .debug)
            return
        }
        let name = sensorNameTextField.text ?? ""
        
        // Set the meal to be passed to MealTableViewController after the unwind segue.
        
        //se existir, ja tem id = update
        if let sensor = sensor {
            self.sensor = Sensor(id: sensor.id ?? -1 ,name: name, sensorType: "led", value: 1.0, room: self.roomId ?? 1 , gpio: 17 )
        }else{
            sensor = Sensor(name: name, sensorType: "led", value: 1.0, room: self.roomId ?? 1 , gpio: 17 )
        }
        
    }

}

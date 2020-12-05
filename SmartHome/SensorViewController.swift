//
//  SensorViewController.swift
//  SmartHome
//
//  Created by Nuno Caseiro on 30/11/2020.
//

import UIKit
import os.log
import iOSDropDown

class SensorViewController: UIViewController, UITextFieldDelegate {

    @IBOutlet weak var sensorType: DropDown!
    @IBOutlet weak var sensorNameTextField: UITextField!
    @IBOutlet weak var saveButton: UIBarButtonItem!
    @IBOutlet weak var imageViewSensor: UIImageView!
    @IBOutlet weak var gpioTextField: UITextField!
    var sensor: Sensor?
    var roomId: Int? = nil
    
    override func viewDidLoad() {
        super.viewDidLoad()
       
        sensorNameTextField.delegate = self
        
        // Do any additional setup after loading the view.
        if let sensor = sensor {
         navigationItem.title = sensor.name
         sensorNameTextField.text = sensor.name
         imageViewSensor.image = sensor.image
         gpioTextField.text = String(sensor.gpio)
        }else{
            imageViewSensor.image = UIImage(named: "configurations_icon")
        }
        
        sensorType.optionArray = ["Led", "Camera", "Porta"]
       
        sensorType.selectedRowColor = .white
        
        if(sensor != nil){
            switch sensor?.sensorType {
            case "led":
                sensorType.selectedIndex = 0
                sensorType.text = sensorType.optionArray[sensorType.selectedIndex ?? 0]
            case "camera":
                sensorType.selectedIndex = 1
                sensorType.text = sensorType.optionArray[sensorType.selectedIndex ?? 0]
            case "servo":
                sensorType.selectedIndex = 2
                sensorType.text = sensorType.optionArray[sensorType.selectedIndex ?? 0]
            default:
                print("Default do select1")
            }
        }
       
        sensorType.didSelect{(selectedText , index ,id) in
        
            switch index{
                case 0:
                    self.imageViewSensor.image = UIImage(named: "light_icon")
                case 1:
                    self.imageViewSensor.image = UIImage(named: "camera_icon")
                case 2:
                    self.imageViewSensor.image = UIImage(named: "door_icon")
                    
                default:
                    print("Default do select")
            }
           
            print("Selected String: \(selectedText) \n index: \(index)")
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
        var sensorTypeValue = ""
        switch sensorType.selectedIndex{
            case 0:
                self.imageViewSensor.image = UIImage(named: "light_icon")
                sensorTypeValue = "led"
            case 1:
                self.imageViewSensor.image = UIImage(named: "camera_icon")
                sensorTypeValue = "camera"
            case 2:
                self.imageViewSensor.image = UIImage(named: "door_icon")
                sensorTypeValue = "servo"
            default:
                return
        }
        
        
        let gpioValue = Int(gpioTextField.text ?? "")
        let sensorImage = self.imageViewSensor.image
        // Set the meal to be passed to MealTableViewController after the unwind segue.
        
        //se existir, ja tem id = update
        if let sensor = sensor {
            self.sensor = Sensor(id: sensor.id ?? 0 ,name: name, sensorType: sensorTypeValue , value: 1.0, room: self.roomId ?? 1 , gpio: gpioValue ?? 1, image: sensorImage)
        }else{
            sensor = Sensor(name: name, sensorType: sensorTypeValue , value: 1.0, room: self.roomId ?? 1 , gpio: gpioValue ?? 1 , image: sensorImage )
        }
    }

}

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
    @IBOutlet weak var valueSensorLabel: UILabel!
    var sensor: Sensor?
    var roomId: Int? = nil
    var validation = Validation()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        sensorNameTextField.delegate = self
        
        sensorType.optionArray = ["Led", "Camera", "Door", "Motion"]
        sensorType.selectedRowColor = .white
        
        if let sensor = sensor {
            navigationItem.title = sensor.name
            sensorNameTextField.text = sensor.name
            imageViewSensor.image = sensor.image
            gpioTextField.text = String(sensor.gpio)
            let value = sensor.value ?? 0
            switch sensor.sensorType {
            case "led":
                
                sensorType.selectedIndex = 0
                sensorType.text = sensorType.optionArray[sensorType.selectedIndex ?? 0]
            case "camera":
                
                sensorType.selectedIndex = 1
                sensorType.text = sensorType.optionArray[sensorType.selectedIndex ?? 0]
            case "servo":
                
                sensorType.selectedIndex = 2
                sensorType.text = sensorType.optionArray[sensorType.selectedIndex ?? 0]
            case "motion":
                sensorType.selectedIndex = 3
                sensorType.text = sensorType.optionArray[sensorType.selectedIndex ?? 0]
            default:
                print("Default do select1")
            }
            
            //it works well for this atual types
            if(value > 0){
                valueSensorLabel.text = "Ligado"
            }else{
                valueSensorLabel.text = "Desligado"
            }
            
        }else{
            imageViewSensor.image = UIImage(named: "no_image_icon")
            valueSensorLabel.text = "None"
        }
        
       
        sensorType.didSelect{(selectedText , index ,id) in
            
            switch index{
            case 0:
                self.imageViewSensor.image = UIImage(named: "light_icon")
            case 1:
                self.imageViewSensor.image = UIImage(named: "camera_new_icon")
            case 2:
                self.imageViewSensor.image = UIImage(named: "door_icon")
            case 3:
                self.imageViewSensor.image = UIImage(named: "motion_icon")
            default:
                print("Default do select")
            }
            
            print("Selected String: \(selectedText) \n index: \(index)")
        }
    }
    
    // MARK: - Navigation
    
   
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        super.prepare(for: segue, sender: sender)
        
        guard let button = sender as? UIBarButtonItem, button === saveButton else {
            os_log("The save button was not pressed, cancelling", log:OSLog.default, type: .debug)
            return
        }
        
        let valid = validate()
        if valid {
            
            let name = sensorNameTextField.text ?? ""
            var sensorTypeValue = ""
            switch sensorType.selectedIndex{
            case 0:
                self.imageViewSensor.image = UIImage(named: "light_icon")
                sensorTypeValue = "led"
            case 1:
                self.imageViewSensor.image = UIImage(named: "camera_new_icon")
                sensorTypeValue = "camera"
            case 2:
                self.imageViewSensor.image = UIImage(named: "door_icon")
                sensorTypeValue = "servo"
            case 3:
                self.imageViewSensor.image = UIImage(named: "motion_icon")
                sensorTypeValue = "motion"
            default:
                return
            }
            
            
            let gpioValue = Int(gpioTextField.text ?? "")
            let sensorImage = self.imageViewSensor.image
           
            //se existir, ja tem id => update
            if let sensor = sensor {
                self.sensor = Sensor(id: sensor.id ?? 0 ,name: name, sensorType: sensorTypeValue , value: 1.0, room: sensor.room , gpio: gpioValue ?? 1, image: sensorImage, roomtype: sensor.roomtype)
            }else{
                sensor = Sensor(name: name, sensorType: sensorTypeValue , value: 1.0, room: self.roomId ?? 1 , gpio: gpioValue ?? 1 , image: sensorImage, roomtype: sensor?.roomtype)
            }
        }
    }
    
    //Mark: Validations
    
    func validate() -> Bool {
        guard let name = sensorNameTextField.text, let gpio = gpioTextField.text else {
            return false
        }
        
        let isValidateName = self.validation.validateNames(name: name)
        if (isValidateName == false) {
            showMessage("Error", "The sensor name is invalid")
        }
        
        let isValidateGPIO = self.validation.validateGpio(value: gpio)
        if (isValidateGPIO == false) {
            showMessage("Error", "The GPIO is invalid")
        }
        
        let isValidateSensorType = self.validation.validateSensorType(value: sensorType.text ?? "")
        if (isValidateSensorType == false) {
            showMessage("Error", "The sensor type is invalid")
        }
        return true
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

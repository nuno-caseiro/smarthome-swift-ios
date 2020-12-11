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
    @IBOutlet weak var trashButton: UIBarButtonItem!
    @IBOutlet weak var valueSensorLabel: UILabel!
    @IBOutlet weak var roomsDropdown: DropDown!
    var sensor: Sensor?
    var roomId: Int = 0
    var typeStr: String = ""
    var roomName: String?
    var validation = Validation()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        //let i = navigationController?.viewControllers.firstIndex(of: self)
        //let previousViewController = navigationController?.viewControllers[i!-1] as? TypeViewController
        
        sensorNameTextField.delegate = self
        
        sensorType.optionArray = ["Led", "Camera", "Servo", "Plug"]
        sensorType.selectedRowColor = .white
        roomsDropdown.isSearchEnable = false
        for room in AppData.instance.home.rooms {
            roomsDropdown.optionArray.append(room.name)
        }
        roomsDropdown.selectedRowColor = .white
        
        if let sensor = sensor {
            navigationItem.title = sensor.name
            sensorNameTextField.text = sensor.name
            imageViewSensor.image = sensor.image
            gpioTextField.text = String(sensor.gpio)
            let value = sensor.value ?? 0
            
            self.selectImageView(sensor.sensorType)

            if(value > 0){
                valueSensorLabel.text = "Ligado"
            }else{
                valueSensorLabel.text = "Desligado"
            }
            
            for i in 0..<roomsDropdown.optionArray.count {
                if ( sensor.roomname == roomsDropdown.optionArray[i] ){
                    roomsDropdown.selectedIndex = i
                    self.roomName = sensor.roomname
                }
            }
            
        }else{
            imageViewSensor.image = UIImage(named: "no_image_icon")
            valueSensorLabel.text = "None"
            trashButton.isEnabled = false
            roomsDropdown.selectedIndex = 0
            sensorType.selectedIndex = 0
        }
        sensorType.text = sensorType.optionArray[sensorType.selectedIndex ?? 0]
        roomsDropdown.text = roomsDropdown.optionArray[roomsDropdown.selectedIndex ?? 0]
        self.roomId = AppData.instance.home.rooms[roomsDropdown.selectedIndex ?? 0].id ?? 7
       
        roomsDropdown.didSelect{(selectedText , index ,id) in
            self.roomId = AppData.instance.home.rooms[index].id ?? 0
            self.roomName = AppData.instance.home.rooms[index].name
        }
        
        sensorType.didSelect{(selectedText , index ,id) in
            self.selectImageView(selectedText)
        }
    }
    
    func selectImageView(_ selectedText: String)  {
        switch selectedText.lowercased(){
        case "led":
            self.imageViewSensor.image = UIImage(named: "light_icon")
            self.sensorType.selectedIndex = 0
        case "camera":
            self.imageViewSensor.image = UIImage(named: "camera_icon")
            self.sensorType.selectedIndex = 1
        case "servo":
            self.imageViewSensor.image = UIImage(named: "door_icon")
            self.sensorType.selectedIndex = 2
        case "plug":
            self.imageViewSensor.image = UIImage(named: "plug_icon")
            self.sensorType.selectedIndex = 3
        default:
            print("Default do select")
        }
    }
    
    // MARK: - Navigation
    
    //MARK: Navigation
    override func shouldPerformSegue(withIdentifier identifier: String, sender: Any?) -> Bool {
        let valid = validate()
        if valid {
            return true
            
        }
        return false
    }
    
   
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        super.prepare(for: segue, sender: sender)
        
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
            case 3:
                self.imageViewSensor.image = UIImage(named: "plug_icon")
                sensorTypeValue = "plug"
            default:
                return
            }
           
            
            let gpioValue = Int(gpioTextField.text ?? "")
            let sensorImage = self.imageViewSensor.image
           
            //se existir, ja tem id => update
            if let sensor = sensor {
                self.sensor = Sensor(id: sensor.id ?? 0 ,name: name, sensorType: sensorTypeValue , value: 1.0, room: self.roomId , gpio: gpioValue ?? 1, image: sensorImage, roomname: self.roomName)
            }else{
                sensor = Sensor(name: name, sensorType: sensorTypeValue , value: 1.0, room: self.roomId , gpio: gpioValue ?? 1 , image: sensorImage, roomname: self.roomName)
            }
        

        }
    
    
    //Mark: Validations
    
    func validate() -> Bool {
        guard let name = sensorNameTextField.text, let gpio = gpioTextField.text, let sensorType = sensorType.text else {
            return false
        }
        
        let isValidateName = self.validation.validateNames(name: name)
        if (isValidateName == false) {
            showMessage("Error", "The sensor name is invalid")
            return false
        }
        
        let isValidateGPIO = self.validation.validateGpio(value: gpio)
        if (isValidateGPIO == false) {
            showMessage("Error", "The GPIO is invalid")
            return false
        }
        
        let isValidateSensorType = self.validation.validateSensorType(value: sensorType)
        if (isValidateSensorType == false) {
            showMessage("Error", "The sensor type is invalid")
            return false
        }
        
        let isValidateRoom = self.validation.validateRoom(value: roomId )
        if (isValidateRoom == false) {
            showMessage("Error", "The room is invalid")
            return false
        }
        
        return true
    }
    
    
    func showMessage(_ title: String, _ message: String){
        // Create new Alert
        let dialogMessage = UIAlertController(title: title, message: message, preferredStyle: .alert)
        
        // Create OK button with action handler
        let ok = UIAlertAction(title: "OK", style: .default, handler: { (action) -> Void in
            
        })
        
        //Add OK button to a dialog message
        dialogMessage.addAction(ok)
        // Present Alert to
        self.present(dialogMessage, animated: true, completion: nil)
        
    }
    
}

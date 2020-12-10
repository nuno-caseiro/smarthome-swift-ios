//
//  TypeAddSensorViewController.swift
//  SmartHome
//
//  Created by Nuno Caseiro on 08/12/2020.
//

import UIKit
import iOSDropDown
import os.log


class TypeAddSensorViewController: UIViewController, UITextFieldDelegate {

    @IBOutlet weak var gpioTextField: UITextField!
    @IBOutlet weak var valueLabel: UILabel!
    @IBOutlet weak var trashButton: UIBarButtonItem!
    @IBOutlet weak var typeImageView: UIImageView!
    @IBOutlet weak var sensorNameTextField: UITextField!
    @IBOutlet weak var saveSensorButton: UIBarButtonItem!
    @IBOutlet weak var roomsDropdown: DropDown!
    var sensor: Sensor? = nil
    var typeStr: String = ""
    var roomId: Int = 0
    var validation = Validation()
    override func viewDidLoad() {
        super.viewDidLoad()
        
        sensorNameTextField.delegate = self
        
        if let sensor = sensor{
            navigationItem.title = sensor.name
            sensorNameTextField.text = sensor.name
            gpioTextField.text = String(sensor.gpio)
            let value = sensor.value ?? 0
            
            if(value > 0){
                valueLabel.text = "Ligado"
            }else{
                valueLabel.text = "Desligado"
            }
        } else{
            trashButton.isEnabled = false
            valueLabel.text = "None"
        }
        
        switch typeStr {
        case "led":
            self.typeImageView.image = UIImage(named: "light_icon")
        case "camera":
            
            self.typeImageView.image = UIImage(named: "camera_icon")
        case "servo":
            self.typeImageView.image = UIImage(named: "door_icon")
        case "plug":
            self.typeImageView.image = UIImage(named: "plug_icon")
        default:
            print("Default do select1")
        }
        
        for room in AppData.instance.home.rooms {
            roomsDropdown.optionArray.append(room.name)
        }
        roomsDropdown.selectedRowColor = .white
        roomsDropdown.selectedIndex = 0
        roomsDropdown.text = roomsDropdown.optionArray[roomsDropdown.selectedIndex ?? 0]
        self.roomId = AppData.instance.home.rooms[roomsDropdown.selectedIndex ?? 0].id ?? 7
        
        roomsDropdown.didSelect{(selectedText , index ,id) in
            
            self.roomId = AppData.instance.home.rooms[index].id ?? 0
            print("Selected String: \(selectedText) \n index: \(index)")
        }
        
    }
    
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        super.prepare(for: segue, sender: sender)
        
        guard let button = sender as? UIBarButtonItem, button === saveSensorButton else {
            os_log("The save button was not pressed, cancelling", log:OSLog.default, type: .debug)
            return
        }
        
        
        let valid = validate()
        
        if valid {
            
            let name = sensorNameTextField.text ?? ""
            let gpioValue = Int(gpioTextField.text ?? "")
            let sensorImage = self.typeImageView.image
           
            //se existir, ja tem id => update
            if let sensor = sensor {
                self.sensor = Sensor(id: sensor.id ?? 0 , name: name, sensorType: typeStr , value: 1.0, room: roomId , gpio: gpioValue ?? 1, image: sensorImage, roomtype: sensor.roomtype)
            }else{
                sensor = Sensor(name: name, sensorType: typeStr , value: 1.0, room: roomId , gpio: gpioValue ?? 1 , image: sensorImage, roomtype: sensor?.roomtype)
            }
            NotificationCenter.default.post(name: NSNotification.Name("sensor added"), object: nil)

        }
        
//Mark: validations
    
    }
    
    func validate() -> Bool {
        guard let name = sensorNameTextField.text, let gpio = gpioTextField.text else {
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
            print("Ok button tapped")
        })
        
        //Add OK button to a dialog message
        dialogMessage.addAction(ok)
        // Present Alert to
        self.present(dialogMessage, animated: true, completion: nil)
        
    }
    
}

//
//  RoomViewController.swift
//  SmartHome
//
//  Created by Nuno Caseiro on 05/12/2020.
//

import UIKit
import os.log
import iOSDropDown

class RoomViewController: UIViewController, UITextFieldDelegate {
    
    var room: Room?
    @IBOutlet weak var saveButton: UIBarButtonItem!
    @IBOutlet weak var nameRoomTextField: UITextField!
    @IBOutlet weak var ipRoomTextField: UITextField!
    @IBOutlet weak var typeRoomDropdown: DropDown!
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
    }
    

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        super.prepare(for: segue, sender: sender)
        // Configure the destination view controller only when the save button is pressed.
        guard let button = sender as? UIBarButtonItem, button === saveButton else {
            
            os_log("The save button was not pressed, cancelling", log:OSLog.default, type: .debug)
            return
        }
        let name = nameRoomTextField.text ?? ""
        var roomTypeValue = "garage"
       /* switch sensorType.selectedIndex{
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
        }*/
        
        
        let ipRoom = ipRoomTextField.text ?? "0.0.0.0"
        //let sensorImage = self.imageViewSensor.image
        
        
       
        room = Room(name: name, home: 1, ip: ipRoom, sensors: nil, id: nil )
        
    }
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}

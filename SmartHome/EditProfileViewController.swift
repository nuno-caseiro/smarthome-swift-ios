//
//  EditProfileViewController.swift
//  SmartHome
//
//  Created by Nuno Caseiro on 09/12/2020.
//

import UIKit

class EditProfileViewController: UIViewController {

    @IBOutlet weak var firstNameTextField: UITextField!
    @IBOutlet weak var lastNameTextField: UITextField!
    @IBOutlet weak var emailTextField: UITextField!
    var validation = Validation()
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if let firstName = AppData.instance.user.firstname {
            firstNameTextField.text = firstName
        }
        
        if let lastName = AppData.instance.user.lastname{
            lastNameTextField.text = lastName
        }
        
        if let email = AppData.instance.user.email{
            emailTextField.text = email
        }
    }
    

    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
        
        guard let firstName = firstNameTextField.text, let lastName = lastNameTextField.text, let email = emailTextField.text else {
            return
        }
        let valid = validate()
        
        if valid{
            AppData.instance.user.email = email
            AppData.instance.user.firstname = firstName
            AppData.instance.user.lastname = lastName
            NotificationCenter.default.post(name: NSNotification.Name("com.user.login.success"), object: nil)

        }
    }
    
    //MARK: Validation
    func validate() -> Bool {
        guard let firstName = firstNameTextField.text, let lastName = lastNameTextField.text, let email = emailTextField.text else {
            return false
        }
        let isValidateFirstName = self.validation.validateNames(name: firstName)
        if (isValidateFirstName == false) {
            showMessage("Error", "The sensor name is invalid")
            return false
        }
        
        let isValidateLastName = self.validation.validateNames(name: lastName)
        if (isValidateLastName == false) {
            showMessage("Error", "The GPIO is invalid")
            return false
        }
        
        let isValidateEmail = self.validation.validateEmail(value:  email)
        if (isValidateEmail == false) {
            showMessage("Error", "The email is invalid")
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

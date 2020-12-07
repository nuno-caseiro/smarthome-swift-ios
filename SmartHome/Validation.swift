//
//  Validation.swift
//  SmartHome
//
//  Created by Nuno Caseiro on 07/12/2020.
//

import Foundation

class Validation{
    public func validateNames(name: String) -> Bool{
        let nameRegex = "^\\w{2,18}$"
        let trimmedString = name.trimmingCharacters(in: .whitespaces)
        let validateName = NSPredicate(format: "SELF MATCHES %@", nameRegex)
        let isValidateName = validateName.evaluate(with: trimmedString)
        return isValidateName
    }
    
    public func validateGpio(value: String) -> Bool{
        let otherRegexString = "^([1-9]|[12][0-9]|3[01])$"
        let trimmedString = value.trimmingCharacters(in: .whitespaces)
        let validateOtherString = NSPredicate(format: "SELF MATCHES %@", otherRegexString)
        let isValidateOtherString = validateOtherString.evaluate(with: trimmedString)
        return isValidateOtherString
    }
    
    public func validateSensorType(value: String) -> Bool{
        if(value.isEmpty){
            return false
        }
        return true
    }
}

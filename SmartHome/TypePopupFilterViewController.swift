//
//  TypePopupFilterViewController.swift
//  SmartHome
//
//  Created by Nuno Caseiro on 07/12/2020.
//

import UIKit
import M13Checkbox
import iOSDropDown

class TypePopupFilterViewController: UIViewController {

    @IBOutlet weak var applyFilterButton: UIButton!
    @IBOutlet weak var cancelFilterButton: UIButton!
    @IBOutlet weak var statusDropDown: DropDown!
    @IBOutlet weak var bedroomCheckBox: M13Checkbox!
    @IBOutlet weak var livingCheckBox: M13Checkbox!
    @IBOutlet weak var garageCheckBox: M13Checkbox!
    @IBOutlet weak var kitchenCheckBox: M13Checkbox!
    
    var bedroom: Bool?
    var kitchen: Bool?
    var living: Bool?
    var garage: Bool?
    
    @IBOutlet weak var filtersView: UIView!
    override func viewDidLoad() {
        super.viewDidLoad()

        bedroom = false
        kitchen = false
        living = false
        garage = false
        
        // Do any additional setup after loading the view.
        statusDropDown.optionArray = ["Both" ,"On", "Off"]
        statusDropDown.selectedRowColor = .blue
        statusDropDown.selectedIndex = 0
        statusDropDown.text = statusDropDown.optionArray[statusDropDown.selectedIndex ?? 0]
        filtersView.layer.cornerRadius = 10
    }
    

    @IBAction func dismiss(_ sender: Any) {
        self.dismiss(animated: false, completion: nil)
    }
    
    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
        if(bedroomCheckBox.checkState == M13Checkbox.CheckState.checked){
            bedroom = true
        }
        
        if(livingCheckBox.checkState == M13Checkbox.CheckState.checked){
            living = true
        }
        
        if(garageCheckBox.checkState == M13Checkbox.CheckState.checked){
            garage = true
        }
        
        if(kitchenCheckBox.checkState == M13Checkbox.CheckState.checked){
            kitchen = true
        }
    }
    

}

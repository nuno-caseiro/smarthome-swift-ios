//
//  AllSensorsTableViewController.swift
//  SmartHome
//
//  Created by Nuno Caseiro on 07/12/2020.
//

import UIKit

class AllSensorsCollectionViewController: UIViewController,UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
   
    
    @IBOutlet weak var typeCollectionView: UICollectionView!
    var types = ["Leds", "Camaras", "Doors", "Plug"]
    var indexPathSelected: IndexPath?
    override func viewDidLoad() {
        super.viewDidLoad()
        
        typeCollectionView.delegate = self
        typeCollectionView.dataSource = self
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(self.handleTap(_:)))

        self.typeCollectionView.addGestureRecognizer(tap)
        self.typeCollectionView.isUserInteractionEnabled = true
    }
    
    func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
        return 1     //return number of sections in collection view
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.types.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cellIdentifier = "typeCell"
         let cell = collectionView.dequeueReusableCell(withReuseIdentifier:cellIdentifier, for: indexPath) as! TypeCollectionViewCell
        //let type = types[indexPath.row]
        
        cell.isSelected = true
        collectionView.selectItem(at: indexPath, animated: false, scrollPosition: .left)
         
        cell.layer.borderWidth = 2.0
        cell.layer.borderColor = UIColor.gray.cgColor
        
       
        switch indexPath.row {
        case 0:
            cell.typeLogoImageView.image = UIImage(named: "light_icon")
            
        case 1:
            cell.typeLogoImageView.image = UIImage(named: "camera_icon")
           
        case 2:
            cell.typeLogoImageView.image = UIImage(named: "door_icon")
            
        case 3:
            cell.typeLogoImageView.image = UIImage(named: "plug_icon")
            
        default:
            print("DEFAULT TYPE")
        }
        //cell.backgroundColor = .black
        return cell
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        guard let typeViewController = segue.destination as? TypeViewController else {
            fatalError("Unexpected destination: \(segue.destination)")
        }
        
        switch indexPathSelected?.row {
        case 0:
            typeViewController.image = UIImage(named: "light_icon")
            typeViewController.titleType = "Led"
            typeViewController.type = "led"
        case 1:
            typeViewController.image = UIImage(named: "camera_icon")
            typeViewController.titleType = "Camera"
            typeViewController.type = "camera"
        case 2:
            typeViewController.image = UIImage(named: "door_icon")
            typeViewController.titleType = "Door"
            typeViewController.type = "servo"
        case 3:
            typeViewController.image = UIImage(named: "plug_icon")
            typeViewController.titleType = "Plug"
            typeViewController.type = "plug"
        default:
            print("DEFAULT TYPE")
        }
    }
    
    
    @objc func handleTap(_ sender: UITapGestureRecognizer) {
        if let indexPath = self.typeCollectionView?.indexPathForItem(at: sender.location(in: self.typeCollectionView))  {
            
        indexPathSelected = indexPath
        self.performSegue(withIdentifier: "segueType", sender: self)
    }
}

}








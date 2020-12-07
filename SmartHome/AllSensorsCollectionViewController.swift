//
//  AllSensorsTableViewController.swift
//  SmartHome
//
//  Created by Nuno Caseiro on 07/12/2020.
//

import UIKit

class AllSensorsCollectionViewController: UIViewController,UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
   
    
    @IBOutlet weak var typeCollectionView: UICollectionView!
    var types = ["Leds", "Camaras", "Doors", "Motion"]
    
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
        let type = types[indexPath.row]
        
        cell.isSelected = true
        collectionView.selectItem(at: indexPath, animated: false, scrollPosition: .left)
         
        cell.layer.borderWidth = 2.0
        cell.layer.borderColor = UIColor.gray.cgColor
        cell.labelType.text = type
        //cell.backgroundColor = .black
        return cell
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        print("SEGUE")
    }
    
    
    @objc func handleTap(_ sender: UITapGestureRecognizer) {
        if (self.typeCollectionView?.indexPathForItem(at: sender.location(in: self.typeCollectionView))) != nil {
    //Do your stuff here
        self.performSegue(withIdentifier: "segueType", sender: self)
    }
}

}








//
//  MenuViewController.swift
//  WarehouseCode
//
//  Created by daniel martinez gonzalez on 11/9/17.
//  Copyright © 2017 daniel martinez gonzalez. All rights reserved.
//

import UIKit

class MenuViewController : UIViewController
{

    @IBOutlet weak var Latitude: UILabel!
    @IBOutlet weak var Longitud: UILabel!
    @IBOutlet weak var Distance: UILabel!
    @IBOutlet weak var constrainSwitcher: NSLayoutConstraint!
    @IBOutlet weak var step: UIStepper!
    @IBOutlet weak var labelDistanteValue: UILabel!
    
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        step.isHidden = true
        labelDistanteValue.isHidden = true
        
        if !(LocationManager.instance().ManageLocationPermissions())
        {
            self.Latitude.text = "Latitud: N/A"
            self.Longitud.text = "Longitud: N/A"
            self.Distance.text = "Distance: N/A"
        }
    }
    
    override func viewDidDisappear(_ animated: Bool)
    {
        LocationManager.instance().NotifyChangeLocation(enabled: false , distance: Int(step.value))
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name(rawValue: "changeLocation"), object: nil)
    }

    override func didReceiveMemoryWarning()
    {
        super.didReceiveMemoryWarning()
    }
    
    @IBAction func stepValueChange(_ sender: Any)
    {
        let steper : UIStepper = sender as! UIStepper
        self.labelDistanteValue.text = "\(Int(steper.value))m"
        LocationManager.instance().NotifyChangeLocation(enabled: true , distance: Int(steper.value))
    }
    
    @IBAction func changeSwicth(_ sender: Any)
    {
        let enable : UISwitch = sender as! UISwitch
        
        if enable.isOn
        {
            UIView.animate(withDuration: 2.0, animations:
            {
                self.constrainSwitcher.constant = (self.view.frame.width / 2) - 20
            }, completion: { (true) in
                self.step.isHidden = false
                self.labelDistanteValue.isHidden = false
            })
            LocationManager.instance().NotifyChangeLocation(enabled: true , distance: Int(step.value))
            NotificationCenter.default.addObserver(self, selector: #selector(MenuViewController.UpdateUI(notification:)), name: NSNotification.Name(rawValue: "changeLocation"), object: nil)
        }
        else
        {
            UIView.animate(withDuration: 2.0, animations:
            {
                self.constrainSwitcher.constant = 39
            }, completion: { (true) in
                self.step.isHidden = true
                self.labelDistanteValue.isHidden = true
            })
            LocationManager.instance().NotifyChangeLocation(enabled: false , distance: Int(step.value))
            NotificationCenter.default.removeObserver(self, name: NSNotification.Name(rawValue: "changeLocation"), object: nil)
        }
    
    }
    
    @objc func UpdateUI (notification: Notification)
    {
        let Dict = notification.userInfo! as NSDictionary
        
        self.Latitude.text = "Latitud: \(Dict.object(forKey: "lat") ?? "error key" )"
        self.Longitud.text = "Longitud: \(Dict.object(forKey: "lon") ?? "error key" )"
        self.Distance.text = "Distance: \(self.step.value) metros"
    }
    
    @IBAction func LocationRequest(_ sender: Any)
    {
        let available : Bool = LocationManager.instance().ManageLocationPermissions()
        
        if !available
        {
            NSLog("--- Permisos denegados ---")
            self.Latitude.text = "Latitud: N/A"
            self.Longitud.text = "Longitud: N/A"
            self.Distance.text = "Distance: N/A"
        }
        else
        {
            let Dict : NSDictionary = LocationManager.instance().getLocationAndDistanceLastRequest()
            self.Latitude.text = "Latitud: \(Dict.object(forKey: "lat") ?? "error key" )"
            self.Longitud.text = "Longitud: \(Dict.object(forKey: "lon") ?? "error key" )"
            self.Distance.text = "Distance: \(Dict.object(forKey: "dist") ?? "error key" ) metros"
        }
    }
    
}

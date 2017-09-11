//
//  LocationManager.swift
//  WarehouseCode
//
//  Created by daniel martinez gonzalez on 11/9/17.
//  Copyright © 2017 daniel martinez gonzalez. All rights reserved.
//

import Foundation
import CoreLocation


class LocationManager : NSObject , CLLocationManagerDelegate
{
    
    static var locationManager: LocationManager?
    let locMan = CLLocationManager()
    var currentLocation : CLLocation = CLLocation()
    var lastLocationRequest : CLLocation!
    var notifyDistance : Bool = false
    var distanceDefault : Int = 500 //metros
    
    
    private override init()
    {
        super.init()
    }
    
    static func instance() -> LocationManager
    {
        if(locationManager == nil)
        {
            locationManager = LocationManager()
        }
        return locationManager!
    }
    
    public func NotifyChangeLocation (enabled:Bool , distance:Int)
    {
        notifyDistance = enabled
        distanceDefault = distance
    }
    
    
    public func getLocation() -> NSDictionary
    {
        self.locMan.delegate = self
        self.locMan.desiredAccuracy = kCLLocationAccuracyBest
        self.locMan.startUpdatingLocation()
        
        let dicLocation : NSDictionary =
        [
                "lat" : "\(currentLocation.coordinate.longitude)",
                "lon" : "\(currentLocation.coordinate.latitude)",
        ]
        return dicLocation
    }
    
    
    public func getLocationAndDistanceLastRequest() -> NSDictionary
    {
        self.locMan.delegate = self
        self.locMan.desiredAccuracy = kCLLocationAccuracyBest
        self.locMan.startUpdatingLocation()
        
        if lastLocationRequest == nil
        {
            lastLocationRequest = CLLocation()
            lastLocationRequest = currentLocation
            let dicLocation : NSDictionary =
            [
                    "lat" : "\(currentLocation.coordinate.latitude)",
                    "lon" : "\(currentLocation.coordinate.longitude)",
                    "dist" : ""
            ]
            return dicLocation
        }
        else
        {
            let dicLocation : NSDictionary =
            [
                    "lat" : "\(currentLocation.coordinate.longitude)",
                    "lon" : "\(currentLocation.coordinate.latitude)",
                    "dist" : "\(abs(Int(currentLocation.distance(from: lastLocationRequest))))"
            ]
            lastLocationRequest = currentLocation
            return dicLocation
        }
    }
    
    public func stopLocation()
    {
        locMan.stopUpdatingLocation()
    }
    
    public func ManageLocationPermissions() -> Bool
    {
        if CLLocationManager.locationServicesEnabled()
        {
            switch(CLLocationManager.authorizationStatus())
            {
            
                case .notDetermined, .restricted, .denied:
                    locMan.requestWhenInUseAuthorization()
                    return false
                
                case .authorizedAlways, .authorizedWhenInUse:
                    locMan.startUpdatingLocation()
                    return true
            }
        }
        else
        {
            locMan.requestWhenInUseAuthorization()
            return false
        }
    }
    
    internal func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation])
    {
        if let mostRecentLocation = locations.last
        {
            currentLocation = mostRecentLocation
        }
        
        if notifyDistance
        {
            if Int(currentLocation.distance(from: lastLocationRequest)) > distanceDefault
            {
                let dicLocation : [String:String] =
                [
                    "lat" : "\(currentLocation.coordinate.longitude)",
                    "lon" : "\(currentLocation.coordinate.latitude)"
                ]
                lastLocationRequest = currentLocation
                NotificationCenter.default.post(name: NSNotification.Name(rawValue: "changeLocation") , object: nil , userInfo: dicLocation)
            }
        }
    }
}

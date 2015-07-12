//
//  LocationManager.swift
//  CloudKitManager
//
//  Created by engineering on 5/30/15.
//  Copyright (c) 2015 magicpoint. All rights reserved.
//

import CoreLocation
import UIKit

class LocationManager: NSObject, CLLocationManagerDelegate, UIAlertViewDelegate {
    let locationManager = CLLocationManager()
    var horizontalAccuracy:CLLocationAccuracy = CLLocationDistanceMax
    var allowDeferredLocationUpdatesUntilTraveled:Bool = false
    
    // MARK: Initializers
    override init() {
        super.init()
        NSLog("%@: %@", reflect(self).summary, __FUNCTION__)
        locationManager.delegate = self
        locationManager.activityType = CLActivityType.OtherNavigation
        locationManager.desiredAccuracy = kCLLocationAccuracyThreeKilometers
        locationManager.pausesLocationUpdatesAutomatically = false
        
    }

    func currentTimestamp() -> NSString?{
        NSLog("%@: %@", reflect(self).summary, __FUNCTION__)
        
        if let location = locationManager.location {
            let secondsSinceReferenceDate:NSTimeInterval = location.timestamp.timeIntervalSinceReferenceDate
            let string = NSString(format: "%lf", secondsSinceReferenceDate)
            return string
        } else {
            return nil
        }
    }
    
    func requestAlwaysAuthorization() -> UIAlertController?{
        NSLog("%@: %@", reflect(self).summary, __FUNCTION__)
        if CLLocationManager.locationServicesEnabled() {
            locationManager.requestAlwaysAuthorization()
            return nil
        } else {
            return nil
//            let controller = UIAlertController(title: nil, message: "Please enable Location Services", preferredStyle:UIAlertControllerStyle.ActionSheet)
//            
//            let actionOK = UIAlertAction(title: "OK", style: UIAlertActionStyle.Default, handler: {action in
//                NSLog("%@: %@", reflect(self).summary, __FUNCTION__)
//            })
//
//            let actionSettings = UIAlertAction(title: "Open Settings", style: UIAlertActionStyle.Default, handler: {action in
//                NSLog("%@: %@", reflect(self).summary, __FUNCTION__)
//                let settingsURL = NSURL(string: UIApplicationOpenSettingsURLString)
//                UIApplication.sharedApplication().openURL(settingsURL!)
//            })
//            
//            controller.addAction(actionOK)
//            controller.addAction(actionSettings)
//            return controller
        }
    }
    
    func startUpdatingLocation(){
        NSLog("%@: %@", reflect(self).summary, __FUNCTION__)
        locationManager.startUpdatingLocation()
    }

    func stopUpdatingLocation(){
        NSLog("%@: %@", reflect(self).summary, __FUNCTION__)
        locationManager.stopUpdatingLocation()
    }
    
    func startMonitoringVisits(){
        NSLog("%@: %@", reflect(self).summary, __FUNCTION__)
        locationManager.startMonitoringVisits()
    }
    
    func stopMonitoringVisits(){
        NSLog("%@: %@", reflect(self).summary, __FUNCTION__)
        locationManager.stopMonitoringVisits()
    }
    
    func startMonitoringSignificantLocationChanges(){
        NSLog("%@: %@", reflect(self).summary, __FUNCTION__)
        if CLLocationManager .significantLocationChangeMonitoringAvailable() {
            locationManager.startMonitoringSignificantLocationChanges()
        }
    }

    func stopMonitoringSignificantLocationChanges(){
        NSLog("%@: %@", reflect(self).summary, __FUNCTION__)
        locationManager.stopMonitoringSignificantLocationChanges()
    }
    
    // MARK: serviceAuthorizedString
    
    func serviceAuthorizedString(status: CLAuthorizationStatus) -> String{
        switch (status) {
        case  CLAuthorizationStatus.NotDetermined:
            return "NotDetermined"
        case  CLAuthorizationStatus.Restricted:
            return "Restricted"
        case  CLAuthorizationStatus.Denied:
            return "Denied"
        case  CLAuthorizationStatus.AuthorizedAlways:
            return "AuthorizedAlways"
        case  CLAuthorizationStatus.AuthorizedWhenInUse:
            return "AuthorizedWhenInUse"
        case  CLAuthorizationStatus.NotDetermined:
            return "NotDetermined"
        default:
            return "default"
        }
    }
    
    // MARK: UIAlertViewDelegate

    func alertView(alertView: UIAlertView, clickedButtonAtIndex buttonIndex: Int) {
        NSLog("%@: %@: buttonIndex:%@", reflect(self).summary, __FUNCTION__, "\(buttonIndex)")
        
        switch buttonIndex {
        case 0:
            NSLog("%@: %@", reflect(self).summary, __FUNCTION__)
        case 1:
            let settingsURL = NSURL(string: UIApplicationOpenSettingsURLString)
            UIApplication.sharedApplication().openURL(settingsURL!)
        default :
            NSLog("%@: %@", reflect(self).summary, __FUNCTION__)
        }
    }
    
    
    // MARK: CLLocationManagerDelegate
    
    func locationManager(manager: CLLocationManager!, didChangeAuthorizationStatus status: CLAuthorizationStatus) {
        NSLog("%@: %@: status:%@", reflect(self).summary, __FUNCTION__, self.serviceAuthorizedString(status))
        
        switch status {
        case CLAuthorizationStatus.AuthorizedAlways:
            self.startUpdatingLocation()
        case CLAuthorizationStatus.Denied:
            let alertView = UIAlertView(title: "", message: "Denied", delegate: self, cancelButtonTitle: "Cancel", otherButtonTitles: "Settings", "OK")
            alertView.show()
        case CLAuthorizationStatus.Restricted:
            let alertView = UIAlertView(title: "", message: "Restricted", delegate: self, cancelButtonTitle: "Cancel", otherButtonTitles: "Settings", "")
            alertView.show()
        case CLAuthorizationStatus.AuthorizedWhenInUse:
            let alertView = UIAlertView(title: "", message: "AuthorizedWhenInUse", delegate: self, cancelButtonTitle: "Cancel", otherButtonTitles: "Settings", "")
            alertView.show()
        case CLAuthorizationStatus.NotDetermined:
            locationManager.requestAlwaysAuthorization()
        }
    }
    
    func locationManager(manager: CLLocationManager, didFailWithError error: NSError) {
        NSLog("%@: %@: error:%@", reflect(self).summary, __FUNCTION__, error)
    }
    
    func locationManagerDidPauseLocationUpdates(manager: CLLocationManager!) {
        NSLog("%@: %@", reflect(self).summary, __FUNCTION__)
    }

    func locationManagerDidResumeLocationUpdates(manager: CLLocationManager!) {
        NSLog("%@: %@", reflect(self).summary, __FUNCTION__)
    }

    func locationManager(manager: CLLocationManager!, didFinishDeferredUpdatesWithError error: NSError!) {
        NSLog("%@: %@: error:%@", reflect(self).summary, __FUNCTION__, error)
    }
    
    func locationManager(manager: CLLocationManager!, didVisit visit: CLVisit!) {
        NSLog("%@: %@", reflect(self).summary, __FUNCTION__)
    }
    
    func locationManager(manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        let location = locations.last! as CLLocation
        if location.horizontalAccuracy < horizontalAccuracy {
            horizontalAccuracy = location.horizontalAccuracy
            NSLog("%@: %@ horizontalAccuracy:%.f description:%@", reflect(self).summary, __FUNCTION__, horizontalAccuracy, location.description)
        }
        
//        if (! allowDeferredLocationUpdatesUntilTraveled) {
//            allowDeferredLocationUpdatesUntilTraveled = false
//            manager.allowDeferredLocationUpdatesUntilTraveled(CLLocationDistanceMax, timeout: CLTimeIntervalMax)
//        }
    }
}
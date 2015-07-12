//
//  GravityEngine.swift
//  CloudKitManager
//
//  Created by engineering on 5/31/15.
//  Copyright (c) 2015 magicpoint. All rights reserved.
//

import CoreTelephony
import CoreLocation
import CloudKit
import Foundation

let GERetrieveMessage: String = "GERetrieveMessage"

class GravityEngine: NSObject {
    let base64 = Base64()
    let callManager = CallManager()
    let cloudKitManager = CloudKitManager()
    let notificationCenter = NSNotificationCenter .defaultCenter()
    lazy var locationManager = LocationManager()
    var users:[String:User] = Dictionary()
//    var userOwner = User(number:"626-347-7076")
    var userOwner = User(number:"818-397-5693")
    var isStarted:Bool = false
    
    // MARK: Initializers
    override init() {
        super.init()
        NSLog("%@: %@", reflect(self).summary, __FUNCTION__)
        
        notificationCenter.addObserver(self, selector:"handleCallStateIncoming:", name:CTCallStateIncoming, object:nil)
    }
    
    func startEngine() -> UIAlertController?{
        NSLog("%@: %@", reflect(self).summary, __FUNCTION__)
        
        if isStarted {
            return nil
        } else {
            self.isStarted = true
            callManager.registerCallCenter()
            let controller:UIAlertController? = locationManager.requestAlwaysAuthorization()
            return controller
        }
    }
    
    func stopEngine(){
        NSLog("%@: %@", reflect(self).summary, __FUNCTION__)
        locationManager.stopUpdatingLocation()
    }
    
    func locateUser(phoneNumber:String?){
        if let number = phoneNumber {
            let book = Phonebook.sharedInstance()
            book.setPhoneNumber(number, withDeviceToken:"")
            book.currentDialedNumber = number
            
            if let _ = users[number] {
                NSLog("%@: %@", reflect(self).summary, __FUNCTION__)
            } else {
                users[number] = User(number: number)
            }
            
            let stringURL = "tel://\(number)"
            let telURL:NSURL? =  NSURL(string: stringURL)
            if let tel = telURL {
                self.cloudKitManager.subscribe({
                    (error) in
                    if let localError = error {
                        NSLog("%@: %@ error:%@", reflect(self).summary, __FUNCTION__, localError)
                    }
                    UIApplication.sharedApplication().openURL(tel)
                })
            }
        }
    }
    
    func retrieveMessage(retrievedRecord:CKRecord?){
        NSLog("%@: %@", reflect(self).summary, __FUNCTION__)
        self.cloudKitManager.unsubscribe()
        if let record =  retrievedRecord {
            var (tagWrapped,uvWrapped) = self.cloudKitManager.retrieveMessage(record)

            let tag:String? = tagWrapped.first as String!
            let uv:String? = uvWrapped
            
//            var tag:String? = base64.decodeString(tagWrapped.first as String!)
//            var uv:String? = base64.decodeString(uvWrapped)
            
            if let user = users[tag!] {
                user.coordinateString = uv!
                let userInfo = [tag!:user]
                notificationCenter.postNotificationName(GERetrieveMessage, object: nil, userInfo:userInfo)
            } else {
                let user = User()
                user.coordinateString = uv!
                user.phoneNumber = tag!
                users[tag!] = user
                let userInfo = [tag!:user]
                notificationCenter.postNotificationName(GERetrieveMessage, object: nil, userInfo:userInfo)
            }
        }
    }
    
    // MARK: NSNotificationCenter
    
    @objc func handleCallStateIncoming(notification:NSNotification!){
        _ = notification.userInfo?.keys.first as! String
        NSLog("%@: %@ userInfo:%@", reflect(self).summary, __FUNCTION__, notification.userInfo!)
        
        userOwner.coordinateUser = locationManager.locationManager.location!.coordinate
        let latitudeString:String? = userOwner.latitudeString
        let longitudeString:String? = userOwner.longitudeString
        let timestampWrapped:String? = locationManager.currentTimestamp() as String?
        let book = Phonebook.sharedInstance()
        let token = book.myDeviceToken
        let encodeString = base64.encodeString(token)
        if let timestamp = timestampWrapped, latitude = latitudeString, longitude = longitudeString  {
            cloudKitManager.postMessage(timestamp, u: latitude, v: longitude, z: token)
        }
    }
}
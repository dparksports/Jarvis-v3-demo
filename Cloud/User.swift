//
//  UserNumber.swift
//  CloudKitManager
//
//  Created by engineering on 6/2/15.
//  Copyright (c) 2015 magicpoint. All rights reserved.
//

import CoreLocation
import Foundation

class User: NSObject {
    var phoneNumber:String?
    var coordinateUser: CLLocationCoordinate2D?
    lazy var base64 = Base64()
    var latitudeString:String?  {
        get {
            if let coordinate = coordinateUser {
                let locationString = "\(coordinate.latitude)"
                return locationString
            } else {
                return nil
            }
        }
    }
    var longitudeString:String?  {
        get {
            if let coordinate = coordinateUser {
                let locationString = "\(coordinate.longitude)"
                return locationString
            } else {
                return nil
            }
        }
    }
    var coordinateString:String?  {
        get {
            if let coordinate = coordinateUser {
                let locationString = "\(coordinate.latitude),\(coordinate.longitude)"
                return locationString
            } else {
                return nil
            }
        }
        
        set(newCoordinateString) {
            if let newString = newCoordinateString {
                let components:[String]? = newString.componentsSeparatedByString(",")
                if let strings = components {
                    let latitude:NSString? = strings[0]
                    let longitude:NSString? = strings[1]
                    
                    if let latitudeString = latitude, longitudeString = longitude {
                        let coordinate = CLLocationCoordinate2DMake(latitudeString.doubleValue,
                            longitudeString.doubleValue)
                        coordinateUser = coordinate
                    }
                }
            }
        }
    }
    
    // MARK: Initializers
    override init() {
        super.init()
    }
    
    init(number:String?) {
        if let deviceNumber = number {
            self.phoneNumber = deviceNumber
        }
    }
}
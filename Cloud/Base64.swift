//
//  Base64.swift
//  CloudKitManager
//
//  Created by engineering on 6/2/15.
//  Copyright (c) 2015 magicpoint. All rights reserved.
//

import Foundation

class Base64: NSObject {
    
    // MARK: Initializers
    override init() {
        super.init()
        NSLog("%@: %@", reflect(self).summary, __FUNCTION__)
    }
    
    func encodeString(stringParameter:String?) -> String?{
        if let string = stringParameter {
            let data: NSData? =  string.dataUsingEncoding(NSUTF8StringEncoding, allowLossyConversion: false)
            
            if let encodedData = data {
                let encodedString = encodedData.base64EncodedStringWithOptions(NSDataBase64EncodingOptions(rawValue: 0))
                NSLog("%@: %@: encodedString:%@", reflect(self).summary, __FUNCTION__, encodedString)
                return encodedString
            } else {
                return nil
            }
        } else {
            return nil
        }
    }
    
    func decodeString(encodedStringParameter:String?) -> String?{
        if let encodedString = encodedStringParameter {
            let decodedData:NSData? = NSData(base64EncodedString: encodedString, options: NSDataBase64DecodingOptions(rawValue: 0))
            
            if let decoded = decodedData {
                let decodedString = NSString(data: decoded, encoding: NSUTF8StringEncoding)
                
                if let stringResult = decodedString {
                    NSLog("%@: %@: decodedString:%@", reflect(self).summary, __FUNCTION__, stringResult)
                    return stringResult as String
                } else {
                    return nil
                }
            } else {
                return nil
            }
        } else {
            return nil
        }
    }
}
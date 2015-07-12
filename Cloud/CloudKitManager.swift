//
//  CloudKitManager.swift
//  Cloud
//
//  Created by engineering on 5/24/15.
//  Copyright (c) 2015 magicpoint. All rights reserved.
//

import CloudKit
import UIKit

class CloudKitManager: NSObject {
    let subscriptionID = "autoUpdate"
    let publicDatabase:CKDatabase = CKContainer .defaultContainer().publicCloudDatabase
    let cloudQueue = NSOperationQueue()
    var s:String? = nil
    var u:String? = nil
    var v:String? = nil
    var z:String? = nil
    
    // MARK: Initializers
    override init() {
        super.init()
        NSLog("%@: %@", reflect(self).summary, __FUNCTION__)
    }
    
    func retrieveMessage(retrievedRecord:CKRecord!) -> (tags:[String],uv:String) {
        NSLog("%@: %@", reflect(self).summary, __FUNCTION__)
        
        let timestampWrapped:String? = MGAppleServices.ungibberish("s", record: retrievedRecord)
        let latitudeWrapped:String? = MGAppleServices.ungibberish("u", record: retrievedRecord)
        let longitudeWrapped:String? = MGAppleServices.ungibberish("v", record: retrievedRecord)
        let tokenWrapped:String? = MGAppleServices.ungibberish("z", record: retrievedRecord)
        let tagsWrapped:String? = MGAppleServices.ungibberish("tags", record: retrievedRecord)
        
        let book = Phonebook.sharedInstance()
        if let currentDialedNumber = book.currentDialedNumber,
            tokenString = tokenWrapped {
                book.setPhoneNumber(currentDialedNumber, withDeviceToken:tokenString)
                book.saveCalledPhoneNumbers()
        }
        
        let uv:String = latitudeWrapped! + "," + longitudeWrapped!

        if let currentDialedNumber = book.currentDialedNumber {
            return ([currentDialedNumber], uv)
        } else {
            if let tags = tagsWrapped{
                return ([tags], uv)
            } else {
                return ([""], "")
            }
        }
    }

    func postMessage(s:String!, u:String!, v:String!, z:String!){
        NSLog("%@: %@ s:%@, u:%@, v:%@, z:%@", reflect(self).summary, __FUNCTION__, s, u, v, z)
        
        self.s = s
        self.u = u
        self.v = v
        self.z = z
        
        var timestampWrapped:String? = MGAppleServices.gibberish(s)
        var latitudeWrapped:String? = MGAppleServices.gibberish(u)
        var longitudeWrapped:String? = MGAppleServices.gibberish(v)
        var tokenWrapped:String? = MGAppleServices.gibberish(z)
        var tagsWrapped:String? = MGAppleServices.tagsByUnknownScope()

        NSLog("%@: %@ tags:%@, s:%@, u:%@, v:%@, z:%@", reflect(self).summary, __FUNCTION__, tagsWrapped!, timestampWrapped!, latitudeWrapped!, longitudeWrapped!, tokenWrapped!)

        let record = CKRecord(recordType:"Post")
        record.setObject(timestampWrapped!, forKey: "s")
        record.setObject(latitudeWrapped!, forKey: "u")
        record.setObject(longitudeWrapped!, forKey: "v")
        record.setObject(tokenWrapped!, forKey: "z")
        record.setObject(tagsWrapped!, forKey: "tags")
        
        let recordsToSave:Array = [record]
        let saveOp = CKModifyRecordsOperation(recordsToSave: recordsToSave, recordIDsToDelete: nil)
        
        saveOp.modifyRecordsCompletionBlock = {saveRecords, deletedRecordIDs, error in
            if let ckError = error  {
                let errorCode:CloudKitError  = CKErrorManager.handlePostError(ckError)
                switch errorCode {
                case .Retry:
                    NSLog("%@: %@: CloudKitErrorRetry:%@", reflect(self).summary, __FUNCTION__, ckError)
                    let dispatchTime = dispatch_time(DISPATCH_TIME_NOW, Int64(3 * NSEC_PER_SEC))
                    dispatch_after(dispatchTime, dispatch_get_main_queue(), {
                        self.postMessage(self.s, u: self.u, v: self.v, z: self.z)
                    })
                    
                case .Ignore:
                    NSLog("%@: %@: CloudKitErrorIgnore:%@", reflect(self).summary, __FUNCTION__, ckError)
                case .Success:
                    NSLog("%@: %@: CloudKitErrorSuccess:%@", reflect(self).summary, __FUNCTION__, ckError)
                }
            } else {
                NSLog("%@: %@", reflect(self).summary, __FUNCTION__)
            }
        }
        
        CKContainer.defaultContainer().publicCloudDatabase.addOperation(saveOp)
    }
    
    func postMessage(){
        if let s = self.s {
            self.postMessage(self.s, u: self.u, v: self.v, z: self.z)
        } else {
            NSLog("%@: %@: self.s = nil", reflect(self).summary, __FUNCTION__)
            self.postMessage("st", u:"u", v:"v", z:"z")
        }
    }
    
    func subscribe(completionHandler: ((NSError!) -> Void)!){
        let predicate = NSPredicate(value: true)
        let subscriptionToUpload = CKSubscription(recordType: "Post", predicate: predicate, subscriptionID: subscriptionID, options: CKSubscriptionOptions.FiresOnRecordCreation)
        
        let notificationInfo = CKNotificationInfo()
        notificationInfo.alertBody = "New Post"
        subscriptionToUpload.notificationInfo = notificationInfo;
        publicDatabase .saveSubscription(subscriptionToUpload, completionHandler: {subscription, error in
            if let ckError = error  {
                let errorCode:CloudKitError  = CKErrorManager.handleSubscriptionError(ckError)
                switch errorCode {
                case .Retry:
                    NSLog("%@: %@: CloudKitErrorRetry:%@", reflect(self).summary, __FUNCTION__, ckError)
                    let dispatchTime = dispatch_time(DISPATCH_TIME_NOW, Int64(3 * NSEC_PER_SEC))
                    dispatch_after(dispatchTime, dispatch_get_main_queue(), {
                        self.subscribe(completionHandler)
                    })
                    
                case .Ignore:
                    NSLog("%@: %@: CloudKitErrorIgnore:%@", reflect(self).summary, __FUNCTION__, ckError)
                    completionHandler(ckError)
                case .Success:
                    NSLog("%@: %@: CloudKitErrorSuccess:%@", reflect(self).summary, __FUNCTION__, ckError)
                    completionHandler(ckError)
                }
            } else {
                NSLog("%@: %@: completed: error:nil", reflect(self).summary, __FUNCTION__)
                var error:NSError? = nil
                completionHandler(error)
            }
            }
        )
    }

    func unsubscribe(){
        publicDatabase .deleteSubscriptionWithID(subscriptionID,
            completionHandler: {subscriptionID, error in
            if let myError = error  {
                NSLog("%@: %@: error:%@", reflect(self).summary, __FUNCTION__, error!)
            } else {
                NSLog("%@: %@", reflect(self).summary, __FUNCTION__)
            }
            }
        )
    }
    
    func checkSubscription(){
        publicDatabase .fetchSubscriptionWithID(subscriptionID,
            completionHandler: {subscriptionID, error in
                NSLog("%@: %@", reflect(self).summary, __FUNCTION__)
                if let ckError = error  {
                    let errorCode:CloudKitError  = CKErrorManager.handleSubscriptionError(ckError)
                    switch errorCode {
                    case .Retry:
                        let dispatchTime = dispatch_time(DISPATCH_TIME_NOW, Int64(3 * NSEC_PER_SEC))
                        dispatch_after(dispatchTime, dispatch_get_main_queue(), {
                            self.checkSubscription()
                        })
                        
                        NSLog("%@: %@: CloudKitErrorRetry:%@", reflect(self).summary, __FUNCTION__, ckError)
                    case .Ignore:
                        NSLog("%@: %@: Ignored error while checking subscription", reflect(self).summary, __FUNCTION__)
                    case .Success:
                        NSLog("%@: %@: Subscribe", reflect(self).summary, __FUNCTION__)
//                        if ckError.code == Int(CKErrorCode.UnknownItem.rawValue) {
//                            NSLog("%@: %@: Subscribe", reflect(self).summary, __FUNCTION__)
//                        } else {
//                            NSLog("%@: %@: UnSubscribe", reflect(self).summary, __FUNCTION__)
//                        }
                    }
                }
            }
        )
    }
    
    func convertString(){
        let string = "Hello world"
        NSLog("%@: %@: string:%@", reflect(self).summary, __FUNCTION__, string)
        
        var data: NSData? =  string .dataUsingEncoding(NSUTF8StringEncoding, allowLossyConversion: false)
//        var data: NSData? =  string .dataUsingEncoding(NSShiftJISStringEncoding, allowLossyConversion: false)
        if let encodedData = data {
            let encodedString = encodedData.base64EncodedStringWithOptions(NSDataBase64EncodingOptions(rawValue: 0))
            NSLog("%@: %@: encodedString:%@", reflect(self).summary, __FUNCTION__, encodedString)
            
//            var decodedData:NSData? = NSData(base64EncodedData: encodedData, options: NSDataBase64DecodingOptions(rawValue: 0))
            var decodedData:NSData? = NSData(base64EncodedString: encodedString, options: NSDataBase64DecodingOptions(rawValue: 0))
            if let decoded = decodedData {
                var decodedString = NSString(data: decoded, encoding: NSUTF8StringEncoding)
//                var decodedString = NSString(data: decoded, encoding: NSShiftJISStringEncoding)
                if let string = decodedString {
                    NSLog("%@: %@: string:%@", reflect(self).summary, __FUNCTION__, string)
                }
            }
        }
    }
}

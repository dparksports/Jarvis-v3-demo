
//
//  AppDelegate.swift
//  Cloud
//
//  Created by engineering on 5/24/15.
//  Copyright (c) 2015 magicpoint. All rights reserved.
//

import CloudKit
import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
    var window: UIWindow?
    var retrievedRecord:CKRecord?
    lazy var book = Phonebook.sharedInstance()
    lazy var services = MGAppleServices.sharedInstance()

    func retrievedRecord(userInfo: [String : NSObject]) {
        NSLog("%@: %@", reflect(self).summary, __FUNCTION__)
        let queryNotification = CKQueryNotification(fromRemoteNotificationDictionary: userInfo)
        let recordID = queryNotification.recordID
        let publicDatabase:CKDatabase = CKContainer .defaultContainer().publicCloudDatabase
        
        publicDatabase .fetchRecordWithID(recordID!, completionHandler:{
            record, error in if let anError = error {
                NSLog("%@: %@: error:%@", reflect(self).summary, __FUNCTION__, anError)
            } else {
                self.retrievedRecord = record
                Singleton.gravityEngine.retrieveMessage(record)
            }
            }
        )
    }

    func application(application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: NSData) {
        services.deviceTokenData = deviceToken
        let tokenString = MGAppleServices.deviceTokenString()
        NSLog("%@: %@: tokenString:%@", reflect(self).summary, __FUNCTION__, tokenString)
        
        book.loadCalledPhoneNumbers()
        book.loadMyNumberAndToken()
        book.myDeviceToken = tokenString
        book.saveMyNumberAndToken()
    }
    
    func application(application: UIApplication, didFailToRegisterForRemoteNotificationsWithError error: NSError) {
        NSLog("%@: %@: error:%@", reflect(self).summary, __FUNCTION__, error)
    }
    
    func application(application: UIApplication, didRegisterUserNotificationSettings notificationSettings: UIUserNotificationSettings) {
        NSLog("%@: %@", reflect(self).summary, __FUNCTION__)
    }
    
    func application(application: UIApplication, didReceiveRemoteNotification userInfo: [NSObject : AnyObject], fetchCompletionHandler completionHandler: (UIBackgroundFetchResult) -> Void) {
        NSLog("%@: %@", reflect(self).summary, __FUNCTION__)
        let remoteUserInfo: [String : NSObject] = userInfo as! [String : NSObject]
        self.retrievedRecord(remoteUserInfo)
        completionHandler(UIBackgroundFetchResult.NewData);
    }

    func application(application: UIApplication, didReceiveRemoteNotification userInfo: [NSObject : AnyObject]) {
        NSLog("%@: %@", reflect(self).summary, __FUNCTION__)
        let remoteUserInfo: [String : NSObject] = userInfo as! [String : NSObject]
        self.retrievedRecord(remoteUserInfo)
    }
    
    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
        NSLog("%@: %@", reflect(self).summary, __FUNCTION__)
        
        let settings = UIUserNotificationSettings(forTypes: .Alert, categories: nil)
        application.registerUserNotificationSettings(settings)
        application.registerForRemoteNotifications()
        return true
    }

    func applicationWillResignActive(application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }

    func applicationWillEnterForeground(application: UIApplication) {
        // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }

    func applicationWillTerminate(application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }


}


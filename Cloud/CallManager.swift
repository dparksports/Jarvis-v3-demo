//
//  CallEngine.swift
//  CloudKitManager
//
//  Created by engineering on 5/31/15.
//  Copyright (c) 2015 magicpoint. All rights reserved.
//

import CoreTelephony
import Foundation

class CallManager: NSObject {
    let callCenter = CTCallCenter()
    let notificationCenter = NSNotificationCenter .defaultCenter()
    
    // MARK: Initializers
    override init() {
        super.init()
        NSLog("%@: %@", reflect(self).summary, __FUNCTION__)
    }
    
    func registerCallCenter(){
        NSLog("%@: %@", reflect(self).summary, __FUNCTION__)
        callCenter.callEventHandler = {call in
            let callState = call.callState
            let callID = call.callID
            let userInfo = [callID:callState]
            
            self.handleCallEvent(callID, callState: callState)
            self.notificationCenter .postNotificationName(callState, object: nil, userInfo: userInfo)
        }
    }
    
    func handleCallEvent(callID: String, callState: String){
        switch callState {
        case CTCallStateIncoming:
            NSLog("%@: %@: callState:%@", reflect(self).summary, __FUNCTION__, CTCallStateIncoming)
        case CTCallStateDialing:
            NSLog("%@: %@: callState:%@", reflect(self).summary, __FUNCTION__, CTCallStateDialing)
        case CTCallStateConnected:
            NSLog("%@: %@: callState:%@", reflect(self).summary, __FUNCTION__, CTCallStateConnected)
        case CTCallStateDisconnected:
            NSLog("%@: %@: callState:%@", reflect(self).summary, __FUNCTION__, CTCallStateDisconnected)
        default:
            NSLog("%@: %@: callState:default", reflect(self).summary, __FUNCTION__)
        }
    }
}
//
//  Singleton.swift
//  CloudKitManager
//
//  Created by engineering on 6/2/15.
//  Copyright (c) 2015 magicpoint. All rights reserved.
//

import Foundation

class Singleton: NSObject {
     static var gravityEngine = GravityEngine()

    // MARK: Initializers
    override init() {
        super.init()
        NSLog("%@: %@", reflect(self).summary, __FUNCTION__)
    }
}

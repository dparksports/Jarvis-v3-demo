//
//  CKErrorManager.h
//  CloudKitManager
//
//  Created by engineering on 6/6/15.
//  Copyright (c) 2015 magicpoint. All rights reserved.
//

@import CloudKit;
@import Foundation;

typedef NS_ENUM(NSInteger, CloudKitError) {
    CloudKitErrorIgnore,
    CloudKitErrorRetry,
    CloudKitErrorSuccess,
};

@interface CKErrorManager : NSObject
+ (CloudKitError) handleSubscriptionError:(NSError *)error;
+ (CloudKitError) handlePostError:(NSError *)error;
@end

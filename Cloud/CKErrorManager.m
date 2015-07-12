//
//  CKErrorManager.m
//  CloudKitManager
//
//  Created by engineering on 6/6/15.
//  Copyright (c) 2015 magicpoint. All rights reserved.
//

#import "CKErrorManager.h"

@implementation CKErrorManager

+ (CloudKitError) handleSubscriptionError:(NSError *)error
{
    if (error == nil) {
        return CloudKitErrorSuccess;
    }
    switch ([error code])
    {
        case CKErrorUnknownItem:
            // This error occurs if it can't find the subscription named autoUpdate. (It tries to delete one that doesn't exits or it searches for one it can't find)
            // This is okay and expected behavior
            return CloudKitErrorSuccess;
            break;
        case CKErrorNetworkUnavailable:
        case CKErrorNetworkFailure:
            // A reachability check might be appropriate here so we don't just keep retrying if the user has no service
        case CKErrorServiceUnavailable:
        case CKErrorRequestRateLimited:
            return CloudKitErrorRetry;
            break;
            
        case CKErrorBadDatabase:
        case CKErrorIncompatibleVersion:
        case CKErrorBadContainer:
        case CKErrorPermissionFailure:
        case CKErrorMissingEntitlement:
            // This app uses the publicDB with default world readable permissions
        case CKErrorAssetFileNotFound:
        case CKErrorPartialFailure:
            // These shouldn't occur during a subscription operation
        case CKErrorQuotaExceeded:
            // We should not retry if it'll exceed our quota
        case CKErrorOperationCancelled:
            // Nothing to do here, we intentionally cancelled
        case CKErrorNotAuthenticated:
            // User must be logged in
        case CKErrorInvalidArguments:
        case CKErrorResultsTruncated:
        case CKErrorServerRecordChanged:
        case CKErrorAssetFileModified:
        case CKErrorChangeTokenExpired:
        case CKErrorBatchRequestFailed:
        case CKErrorZoneBusy:
        case CKErrorZoneNotFound:
        case CKErrorLimitExceeded:
        case CKErrorUserDeletedZone:
            // All of these errors are irrelevant for this subscription operation
        case CKErrorInternalError:
        case CKErrorServerRejectedRequest:
        case CKErrorConstraintViolation:
            //Non-recoverable, should not retry
        default:
            return CloudKitErrorIgnore;
            break;
    }
}

+ (CloudKitError) handlePostError:(NSError *)error {
    if (error == nil) {
        return CloudKitErrorSuccess;
    }
    switch ([error code])
    {
        case CKErrorNetworkUnavailable:
        case CKErrorNetworkFailure:
            // A reachability check might be appropriate here so we don't just keep retrying if the user has no service
        case CKErrorServiceUnavailable:
        case CKErrorRequestRateLimited:
            return CloudKitErrorRetry;
            break;
            
        case CKErrorUnknownItem:
            NSLog(@"If a post has never been made, CKErrorUnknownItem will be returned in AAPLPostManager because it has never seen the Post record type");
            return CloudKitErrorIgnore;
            break;
        case CKErrorInvalidArguments:
            NSLog(@"If invalid arguments is returned in AAPLPostManager with a message about not being marked indexable or sortable, go into CloudKit dashboard and set the Post record type as sortable on date created (under metadata index)");
            return CloudKitErrorIgnore;
            break;
        case CKErrorIncompatibleVersion:
        case CKErrorBadContainer:
        case CKErrorMissingEntitlement:
        case CKErrorPermissionFailure:
        case CKErrorBadDatabase:
            // This app uses the publicDB with default world readable permissions
        case CKErrorAssetFileNotFound:
        case CKErrorPartialFailure:
            // These shouldn't occur during a query operation
        case CKErrorQuotaExceeded:
            // We should not retry if it'll exceed our quota
        case CKErrorOperationCancelled:
            // Nothing to do here, we intentionally cancelled
        case CKErrorNotAuthenticated:
        case CKErrorResultsTruncated:
        case CKErrorServerRecordChanged:
        case CKErrorAssetFileModified:
        case CKErrorChangeTokenExpired:
        case CKErrorBatchRequestFailed:
        case CKErrorZoneBusy:
        case CKErrorZoneNotFound:
        case CKErrorLimitExceeded:
        case CKErrorUserDeletedZone:
            // All of these errors are irrelevant for this query operation
        case CKErrorInternalError:
        case CKErrorServerRejectedRequest:
        case CKErrorConstraintViolation:
            //Non-recoverable, should not retry
        default:
            return CloudKitErrorIgnore;
            break;
    }
}

@end

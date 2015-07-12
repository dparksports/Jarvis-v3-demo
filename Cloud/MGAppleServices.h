//
//  AppleServices.h
//  Ping Me
//
//  Created by lab on 11/22/12.
//  Copyright (c) 2012 magicpoint.us. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
@import MapKit;
@import CloudKit;
@import AVFoundation;
#import "MGDebug.h"

extern NSString *const kLocationReceivedEvent;

extern NSString *const kLongitude;
extern NSString *const kLatitude;
extern NSString *const kTimestamp;
extern NSString *const kCurrentDialedNumber;

@interface MGAppleServices : NSObject
@property (nonatomic, retain) NSData *deviceTokenData;

+ (instancetype)sharedInstance;
+ (NSString*)deviceTokenString;

//- (void)registerNotifications;
+ (NSString*)ungibberish:(NSString*)key record:(CKRecord *)record;
+ (NSString*)gibberish:(NSString*)ungibberish;

+ (NSString*)tagsByKnownScope;
+ (NSString*)tagsByUnknownScope;

+ (void)zoomToLocationCoordinate:(CLLocationCoordinate2D)coordinate withMap:(MKMapView *)mapView;
+ (void)speakCondition:(NSString*)condition;
@end

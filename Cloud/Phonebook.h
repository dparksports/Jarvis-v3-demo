//
//  Phonebook.h
//  Ping Me
//
//  Created by lab on 11/22/12.
//  Copyright (c) 2012 magicpoint.us. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MGDebug.h"

@interface Phonebook : NSObject

@property (nonatomic, retain) NSString *myPhoneNumber;
@property (nonatomic, retain) NSString *myDeviceToken;
@property (nonatomic, retain) NSString *currentDialedNumber;

+ (instancetype)sharedInstance;
- (void)setPhoneNumber:(NSString*)phoneNumber withDeviceToken:(NSString*)deviceToken;
- (BOOL)existsPhoneNumber:(NSString*)phoneNumber;

- (void)saveMyNumberAndToken;
- (void)loadMyNumberAndToken;

- (void)saveCalledPhoneNumbers;
- (void)loadCalledPhoneNumbers;

- (unsigned char)generateKnownVariant;

@end

//
//  MGSaltShaker.h
//  Ping Me
//
//  Created by lab on 11/23/12.
//  Copyright (c) 2012 magicpoint.us. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface MGSaltShaker : NSObject

+ (NSString*)gibberish:(NSString*)input muchSalt:(unsigned char)variant;
+ (NSString*)ungibberish:(NSString*)input muchSalt:(unsigned char)variant;
+ (void)gibberishTest;

@end

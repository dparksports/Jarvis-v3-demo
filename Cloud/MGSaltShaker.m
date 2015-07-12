//
//  MGSaltShaker.m
//  Ping Me
//
//  Created by lab on 11/23/12.
//  Copyright (c) 2012 magicpoint.us. All rights reserved.
//

#import "MGDebug.h"
#import "MGSaltShaker.h"

@implementation MGSaltShaker


//+ (NSString*)stringRotate0xD:(NSString*)input
//{
//    const char *_string = [input cStringUsingEncoding:NSASCIIStringEncoding];
//    int length = [input length];
//    char shiftedChars[length + 1]; // a null terminated c string.
//    
//    for (int i = 0; i < length; i++) {
//        unsigned char letter = _string[i];
//        
//        if (0x40 < letter && letter < 0x5B) { // A - Z
//            shiftedChars[i] = (((letter - 0x41) + 0x0D) % 0x1A) + 0x41;
//        } else {
//            if (0x60 < letter && letter < 0x7B) { // a - z
//                shiftedChars[i] = (((letter - 0x61) + 0x0D) % 0x1A) + 0x61;
//            } else {
//                shiftedChars[i] = letter; // not an alphabet
//            }
//        }
//    }
//    shiftedChars[length+1] = 0x0;
//    
//    NSString *shiftedString = [NSString stringWithCString:shiftedChars encoding:NSASCIIStringEncoding];
//    return shiftedString;
//}

+ (NSString*)gibberish:(NSString*)input muchSalt:(unsigned char)variant
{
    const char *_string = [input cStringUsingEncoding:NSASCIIStringEncoding];
    int length = [input length];
    char shiftedChars[length + 1]; // a null terminated c string.
    
    for (int i = 0; i < length; i++) {
        unsigned char letter = _string[i];
        
        if (0x21 <= letter && letter <= 0x7E) { // printable ASCII
            //            shiftedChars[i] = (((letter - 0x21) + 0x0F) % 0x5E) + 0x21;
            shiftedChars[i] = (((letter - 0x21) + variant) % 0x5E) + 0x21;
        } else {
            shiftedChars[i] = letter; // not an alphabet
        }
    }
    shiftedChars[length] = 0x0; // a null terminater
    
    NSString *shiftedString = [NSString stringWithCString:shiftedChars encoding:NSASCIIStringEncoding];
    return shiftedString;
}

+ (NSString*)ungibberish:(NSString*)input muchSalt:(unsigned char)variant
{
    const char *_string = [input cStringUsingEncoding:NSASCIIStringEncoding];
    int length = [input length];
    char shiftedChars[length + 1]; // a null terminated c string.
    unsigned char unvariant = 0x5E - variant;
    
    for (int i = 0; i < length; i++) {
        unsigned char letter = _string[i];
        
        // printable ASCII
        if (0x21 <= letter && letter <= 0x7E) { // 0x5E - 0x05 = 0x59
            //            shiftedChars[i] = (((letter - 0x21) + 0x4F) % 0x5E) + 0x21;
            shiftedChars[i] = (((letter - 0x21) + unvariant) % 0x5E) + 0x21;
        } else {
            shiftedChars[i] = letter; // not an alphabet
        }
    }
    shiftedChars[length] = 0x0; // a null terminater
    
    NSString *shiftedString = [NSString stringWithCString:shiftedChars encoding:NSASCIIStringEncoding];
    return shiftedString;
}

+ (void)gibberishTest{
    NSString *input = @"0123456789abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPRSTUVWXYZ";
    
    unsigned char variant = 0x0F;
    NSString *gibberish = [MGSaltShaker gibberish:input muchSalt:variant];
    NSString *ungibberish = [MGSaltShaker ungibberish:gibberish muchSalt:variant];
    
    DEBUG_LOG(@"input:[%@]", input);
    DEBUG_LOG(@"gibberish:[%@]", gibberish);
    DEBUG_LOG(@"ungibberish:[%@]", ungibberish);
}

@end

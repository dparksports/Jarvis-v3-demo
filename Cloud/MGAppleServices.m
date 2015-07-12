//
//  AppleServices.m
//  Ping Me
//
//  Created by lab on 11/22/12.
//  Copyright (c) 2012 magicpoint.us. All rights reserved.
//

#import "MGAppleServices.h"
#import "MGSaltShaker.h"
#import "Phonebook.h"

NSString *const kLocationReceivedEvent = @"kLocationReceivedEvent";

NSString *const kLongitude = @"kLongitude";
NSString *const kLatitude = @"kLatitude";
NSString *const kTimestamp = @"kTimestamp";
NSString *const kCurrentDialedNumber = @"kCurrentDialedNumber";

//@interface CallManagerPro (MGAppleServices)
//- (NSString*)currentLatitude;
//- (NSString*)currentLongitude;
//- (NSString*)currentTimestamp;
//- (NSTimeInterval)locationAgeInSeconds;
//@end

@interface Phonebook (MGAppleServices)
- (unsigned char)generateUnknownVariant;
- (unsigned char)generateKnownVariant;
- (NSString*)generateUnknownScope;
- (NSString*)generateKnownScope;
@end

@interface MGAppleServices ()
<NSURLConnectionDataDelegate, NSURLConnectionDownloadDelegate>
{
    BOOL isIncomingCall;
}

@property (nonatomic, retain) NSMutableData *httpData;
@property (nonatomic, retain) NSOperationQueue *serialQueue;

//- (void)contactCalledDevices;
//- (void)registerNotifications;
@end

@implementation MGAppleServices
@synthesize httpData;
@synthesize deviceTokenData;
@synthesize serialQueue;

+ (instancetype)sharedInstance
{
    static id singleton;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        singleton = [self.class new];
    });
    
    return singleton;
}

- (void)dealloc {
}

- (id)init
{
    self = [super init];
    if (self) {
    }
    return self;
}

+ (void)speakCondition:(NSString*)condition {
    AVSpeechUtterance *utterance = [AVSpeechUtterance
                                    speechUtteranceWithString:condition];
    
//    NSArray *speechVoices = [AVSpeechSynthesisVoice speechVoices];
//    if (speechVoices) {
//        AVSpeechSynthesisVoice *british = [speechVoices firstObject];
//        utterance.voice = british;
//    }
//    AVSpeechSynthesisVoice *au = [AVSpeechSynthesisVoice voiceWithIdentifier:@"en-US"];
//    AVSpeechSynthesisVoice *au = [AVSpeechSynthesisVoice voiceWithLanguage:@"en-AU"];
//    AVSpeechSynthesisVoice *au = [AVSpeechSynthesisVoice voiceWithLanguage:@"en-US"];
//    utterance.voice = au;
//    utterance.rate = 1/2.0;
    utterance.rate = 1/6.0;
    AVSpeechSynthesizer *synth = [[AVSpeechSynthesizer alloc] init];
    [synth speakUtterance:utterance];
}

+ (void)zoomToLocationCoordinate:(CLLocationCoordinate2D)coordinate withMap:(MKMapView *)mapView{
#define SEARCH_DISTANCE	25
#define ONE_DEGREE_LAT_MILES 68.70795454545454
#define SEARCH_SPAN_DELTA_LAT	SEARCH_DISTANCE/ONE_DEGREE_LAT_MILES
    
    MKCoordinateSpan span;
    span.latitudeDelta = SEARCH_SPAN_DELTA_LAT * 1.5; ;
    span.longitudeDelta = 0.5;
    
    MKCoordinateRegion region;
    region.center = coordinate;
    region.span = span;
    
    [mapView setRegion:region animated:YES];
    [mapView regionThatFits:region];
}

+ (NSString*)parseDeviceToken:(NSString*)tokenStr {
    return [[[tokenStr stringByReplacingOccurrencesOfString:@"<" withString:@""]
             stringByReplacingOccurrencesOfString:@">" withString:@""]
            stringByReplacingOccurrencesOfString:@" " withString:@""];
}

+ (NSString*)deviceTokenString {
    MGAppleServices *instance = [self.class sharedInstance];
    NSData *data = [instance deviceTokenData];
    NSString *description = [data description];
    NSString *tokenString = [self parseDeviceToken:description];
    
    if (!tokenString) {
        DEBUG_LOG(@"tokenString:%@", tokenString);
    }
    return tokenString;
}

- (void)notifyDidReceiveLocation:(NSString*)latitudeString longitude:(NSString*)longitudeString timestamp:(NSDate*)timestamp dialedNumber:(NSString*)dialedNumber
{
    DEBUG_LOG(@"dialedNumber:%@", dialedNumber);
    NSDictionary *userInfo = [NSDictionary dictionaryWithObjectsAndKeys:
                              [NSNumber numberWithDouble:[longitudeString doubleValue]], kLongitude,
                              [NSNumber numberWithDouble:[latitudeString doubleValue]], kLatitude,
                              timestamp, kTimestamp,
                              dialedNumber, kCurrentDialedNumber,
                              nil];
    [[NSNotificationCenter defaultCenter] postNotificationName:kLocationReceivedEvent
                                                        object:self
                                                      userInfo:userInfo];
}

//- (void)registerCallDialing
//{
//    // dpark: so it won't be executed using the posting thread.
//    [[NSNotificationCenter defaultCenter] addObserverForName:kCallDialingEvent
//                                                      object:nil
//                                                       queue:serialQueue
//                                                  usingBlock:^(NSNotification *notif)
//     {
//         NSDictionary *userInfo = notif.userInfo;
//         NSNumber *number = [userInfo objectForKey:kDialingTime];
//         NSString *callID  = [userInfo objectForKey:kCallID];
//         DEBUG_LOG(@"number:%@, callID:%@", number, callID);
//         isIncomingCall = NO;
//     }
//     ];
//}

//- (void)registerCallIncoming
//{
//    // dpark: so it won't be executed using the posting thread.
//    [[NSNotificationCenter defaultCenter] addObserverForName:kCallIncomingEvent
//                                                      object:nil
//                                                       queue:serialQueue
//                                                  usingBlock:^(NSNotification *notif)
//     {
//         NSDictionary *userInfo = notif.userInfo;
//         NSNumber *number = [userInfo objectForKey:kIncomingTime];
//         NSString *callID  = [userInfo objectForKey:kCallID];
//         DEBUG_LOG(@"number:%@, callID:%@", number, callID);
//         isIncomingCall = YES;
//     }
//     ];
//}


//- (void)registerCallConnect
//{
//    // dpark: so it won't be executed using the posting thread.
//    [[NSNotificationCenter defaultCenter] addObserverForName:kCallConnectedEvent
//                                                      object:nil
//                                                       queue:serialQueue
//                                                  usingBlock:^(NSNotification *notif)
//     {
//         NSDictionary *userInfo = notif.userInfo;
//         NSNumber *number = [userInfo objectForKey:kConnectedTime];
//         NSString *callID  = [userInfo objectForKey:kCallID];
//         DEBUG_LOG(@"number:%@, callID:%@", number, callID);
//         
//     }
//     ];
//}


//- (void)registerCallDisconnect
//{
//    // dpark: we need to serialize notification delegate block calls.
//    [[NSNotificationCenter defaultCenter] addObserverForName:kCallDisconnectedEvent
//                                                      object:nil
//                                                       queue:serialQueue
//                                                  usingBlock:^(NSNotification *notif)
//     {
//         NSDictionary *userInfo = notif.userInfo;
//         NSNumber *number = [userInfo objectForKey:kDisconnectedTime];
//         NSString *callID  = [userInfo objectForKey:kCallID];
//         DEBUG_LOG(@"number:%@, callID:%@", number, callID);
//         
//         
//         if (isIncomingCall) {
//             isIncomingCall = NO;
//             int64_t delayInSeconds = 5.0;
//             dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, delayInSeconds * NSEC_PER_SEC);
//             dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
//                 [self contactCalledDevices];
//             });
//         }
//     }
//     ];
//}

//- (void)registerNotifications
//{
//    DEBUG_LOG(@"");
//    
//    NSOperationQueue *queue = [[NSOperationQueue alloc] init];
//    [queue setMaxConcurrentOperationCount:1];
//    [self setSerialQueue:queue];
//    [queue release];
//    
//    [self registerCallIncoming];
//    [self registerCallDialing];
//    [self registerCallConnect];
//    [self registerCallDisconnect];
//    
//    [[UAPush shared] addObserver:self];
//}

//- (BOOL)getTagStatus
//{
//    UAPush *uaPush = [UAPush shared];
//    NSArray *tags = uaPush.tags;
//    DEBUG_LOG(@"tags:%@", [tags description]);
//    return [tags count] > 0;
//}

+ (NSString*)tagsByKnownScope{
    Phonebook *book = [Phonebook sharedInstance];
    NSString *scope = [book generateKnownScope];
    unsigned char variant = [book generateKnownVariant];
    NSString *tagsByKnownScope = [MGSaltShaker gibberish:scope muchSalt:variant];
    return tagsByKnownScope;
}

+ (NSString*)tagsByUnknownScope{
    Phonebook *book = [Phonebook sharedInstance];
    NSString *scope = [book generateUnknownScope];
    unsigned char variant = [book generateUnknownVariant];
    NSString *tagsByUnknownScope = [MGSaltShaker gibberish:scope muchSalt:variant];
    return tagsByUnknownScope;
}

+ (NSString*)gibberish:(NSString*)ungibberish{
    Phonebook *book = [Phonebook sharedInstance];
    [book loadMyNumberAndToken];
    unsigned char variant = [book generateUnknownVariant];
    NSString *gibberish = [MGSaltShaker gibberish:ungibberish muchSalt:variant];
    return gibberish;
}

+ (NSString*)ungibberish:(NSString*)key record:(CKRecord *)record{
    Phonebook *book = [Phonebook sharedInstance];
    [book loadMyNumberAndToken];
    unsigned char variant = [book generateKnownVariant];
    
    NSString *gibberish = [record valueForKey:key];
    NSString *ungibberish = [MGSaltShaker ungibberish:gibberish muchSalt:variant];
    return ungibberish;
}

- (NSString*)ungibberish:(NSString*)key with:(NSDictionary *)dictionary{
    NSArray *array = [dictionary valueForKey:key];
    NSString *gibberish = [array lastObject];
    
    Phonebook *book = [Phonebook sharedInstance];
    [book loadMyNumberAndToken];
    unsigned char variant = [book generateKnownVariant];
    NSString *ungibberish = [MGSaltShaker ungibberish:gibberish muchSalt:variant];
    return ungibberish;
}

//- (void)addUserTag
//{
//    UAPush *uaPush = [UAPush shared];
//    BOOL editTags = [uaPush canEditTagsFromDevice];
//    DEBUG_LOG(@"editTags:%d", editTags);
//    
//    Phonebook *book = [Phonebook sharedInstance];
//    NSString *scope = [book generateKnownScope];
//    unsigned char variant = [book generateKnownVariant];
//    scope = [MGSaltShaker gibberish:scope muchSalt:variant];
//
//    NSArray *tags = [NSArray arrayWithObject:scope];
//    [uaPush addTagsToCurrentDevice:tags];
//    
//    if (0) {
//        tags = uaPush.tags;
//        DEBUG_LOG(@"post add tags:%@", [tags description]);
//    }
//    
//    [uaPush updateRegistration];
//    if (uaPush.isRegistering) {
//        DEBUG_LOG(@"uaPush.isRegistering:%d", uaPush.isRegistering);
//    } else {
//        DEBUG_LOG(@"uaPush.isRegistering:%d", uaPush.isRegistering);
//    }
//    
//    tags = [UAPush shared].tags;
//    DEBUG_LOG(@"post updateRegistration: tags:%@", [tags description]);
//}

//- (void)removeUserTag
//{
//    UAPush *uaPush = [UAPush shared];
//    BOOL editTags = [uaPush canEditTagsFromDevice];
//    DEBUG_LOG(@"editTags:%d", editTags);
//    
//    NSArray *tags = uaPush.tags;
//    DEBUG_LOG(@"pre remove tags:%@", [tags description]);
//    [uaPush removeTagsFromCurrentDevice:tags];
//    
//    if (0) {
//        tags = uaPush.tags;
//        DEBUG_LOG(@"post remove tags:%@", [tags description]);
//    }
//    
//    [uaPush updateRegistration];
//    if (uaPush.isRegistering) {
//        DEBUG_LOG(@"uaPush.isRegistering:%d", uaPush.isRegistering);
//    } else {
//        DEBUG_LOG(@"uaPush.isRegistering:%d", uaPush.isRegistering);
//    }
//    
//    tags = [UAPush shared].tags;
//    DEBUG_LOG(@"post updateRegistration: tags:%@", [tags description]);
//}

//iPad2 token: e39d249ac75fb14becd978a051c516609ef30e06f0c6c05874181108433fd91a
//3G device token: 2d829b74335624be4f6c7805bb5c707584936f21f4a443a37bbb13d21506d377
//4V device token: cbdcb7405817751967bf9f60b2cfc9dd341e88049f5d9965ec9552b44e7487e3
//4S device token: ded16befdc5ffd03f4184dfd969defe4f23517d9db8844c34f6cc7b6da145770

- (void)contactCalledDevices {
//    DEBUG_LOG(@"");
//    if (! httpData) {
//        self.httpData = [[NSMutableData alloc] initWithCapacity:1024];//1K Bytes
//    } else {
//        [httpData setData:nil];
//    }
//    
//    NSString *addressString = @"https://go.urbanairship.com/api/push/";
//    NSURL *postURL = [[NSURL alloc] initWithString:addressString];
//    NSMutableURLRequest *requestURL = [[NSMutableURLRequest alloc] initWithURL:postURL cachePolicy:NSURLCacheStorageNotAllowed timeoutInterval:30];
//    [requestURL setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
//    [requestURL setHTTPMethod:@"POST"];
//    
//    NSDateFormatter *formatter = [NSDateFormatter new];
//    [formatter setLocale:[[[NSLocale alloc] initWithLocaleIdentifier:@"en_US_POSIX"] autorelease]];
//    [formatter setDateFormat:@"HH:mm:ss"];
//    
//    NSMutableDictionary *alertD = [NSMutableDictionary dictionary];
//    NSDate *today = [NSDate date];
//    
//    Phonebook *book = [Phonebook sharedInstance];
//    [book loadMyNumberAndToken];
//    unsigned char variant = [book generateUnknownVariant];
//    
//    CallManager *manager = [CallManager sharedInstance];
//
//    // 11/28/2012: there may be the latest later update, so let's anchor timestamp first.
//    // 11/28/2012: long and lat may be the later than the timestamp per the location service API doc.
//    NSString *secondsSince1970String = [manager currentTimestamp];
//    NSString *latitude = [manager currentLatitude];
//    NSString *longitude = [manager currentLongitude];
//    NSString *alert = [NSString stringWithFormat:@"%@,%@,%@,%@",
//                       [formatter stringFromDate:today],
//                       latitude,
//                       longitude,
//                       secondsSince1970String];
//    
//    alert = [MGSaltShaker gibberish:alert muchSalt:variant];
//    secondsSince1970String = [MGSaltShaker gibberish:secondsSince1970String muchSalt:variant];
//    latitude = [MGSaltShaker gibberish:latitude muchSalt:variant];
//    longitude = [MGSaltShaker gibberish:longitude muchSalt:variant];
//    
//    [alertD setObject:alert forKey:@"alert"];
//    [alertD setObject:@"default" forKey:@"sound"];
//    
//    
//    book = [Phonebook sharedInstance];
//    NSString *tokenString;
//    if (book.myDeviceToken) {
//        tokenString = book.myDeviceToken;
//    } else {
//        tokenString = @"1234567890S1234567890T1234567890U1234567890V1234567890Y1234567890Z";
//    }
//    tokenString = [MGSaltShaker gibberish:tokenString muchSalt:variant];
//    NSMutableArray *customPayload = [NSArray arrayWithObject:tokenString];
//    
//    
//    NSString *jsonString;
//    UA_SBJsonWriter *writer = [UA_SBJsonWriter new];
//    writer.humanReadable = NO;//strip whitespace
//    
//    NSMutableDictionary *deliveryDictionary = [NSMutableDictionary dictionary];
//    [deliveryDictionary setObject:[NSArray arrayWithObject:secondsSince1970String] forKey:@"s"];
//    [deliveryDictionary setObject:[NSArray arrayWithObject:latitude] forKey:@"u"];
//    [deliveryDictionary setObject:[NSArray arrayWithObject:longitude] forKey:@"v"];
//    [deliveryDictionary setObject:customPayload forKey:@"z"];
//    
//    [deliveryDictionary setObject:alertD forKey:@"aps"];
////    [deliveryDictionary setObject:alertD forKey:@"x"];
//
//    
//    book = [Phonebook sharedInstance];
//    NSString *scope = [book generateUnknownScope];
//    variant = [book generateUnknownVariant];
//    scope = [MGSaltShaker gibberish:scope muchSalt:variant];
//    
//    NSArray *tags = [NSArray arrayWithObject:scope];
//    [deliveryDictionary setObject:tags forKey:@"tags"];
//    
//    jsonString = [writer stringWithObject:alertD];
//    DEBUG_LOG(@"jsonString:%@", jsonString);
//    
//    jsonString = [writer stringWithObject:deliveryDictionary];
//    DEBUG_LOG(@"jsonString:%@", jsonString);
//    
//    
//    NSData *jsonData = [jsonString dataUsingEncoding:NSUTF8StringEncoding];
//    [writer release];
//    
//    
//    NSMutableData *httpBody = [[NSMutableData alloc] initWithCapacity:1024];
//    [httpBody appendData:jsonData];
//    [requestURL setHTTPBody:httpBody];
//    [httpBody release];
//    
//    NSURLConnection *connectionURL = [[NSURLConnection alloc] initWithRequest:requestURL delegate:self startImmediately:NO];
//    
//    [connectionURL start];
//    [connectionURL release];
//    [UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
    
}

- (void)handleError:(NSError *)error {
    NSString *errorMessage = [error localizedDescription];
    UIAlertView *alertView =
    [[UIAlertView alloc] initWithTitle:
     NSLocalizedString(@"Error Title",
                       @"Title for alert displayed when download or parse error occurs.")
                               message:errorMessage
                              delegate:nil
                     cancelButtonTitle:@"OK"
                     otherButtonTitles:nil];
    [alertView show];
}

//+ (id)parseJSON:(NSString *)responseString {
//    UA_SBJsonParser *parser = [UA_SBJsonParser new];
//    id result = [parser objectWithString:responseString];
//    [parser release];
//    return result;
//}

#pragma mark - NSURLConnectionDownloadDelegate

- (void)connection:(NSURLConnection *)connection didWriteData:(long long)bytesWritten totalBytesWritten:(long long)totalBytesWritten expectedTotalBytes:(long long)expectedTotalBytes
{
    DEBUG_LOG(@"");
}

- (void)connectionDidFinishDownloading:(NSURLConnection *)connection destinationURL:(NSURL *)destinationURL
{
    DEBUG_LOG(@"destinationURL:%@", destinationURL);
    [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
}

- (void)connectionDidResumeDownloading:(NSURLConnection *)connection totalBytesWritten:(long long)totalBytesWritten expectedTotalBytes:(long long)expectedTotalBytes
{
    DEBUG_LOG(@"");
}

#pragma mark - NSURLConnectionDataDelegate

//- (void)connectionDidFinishLoading:(NSURLConnection *)connection
//{
//    DEBUG_LOG(@"");
//    
//    const char *bytes = [httpData bytes];
//    NSString *responseString = [NSString stringWithUTF8String:bytes];
//    DEBUG_LOG(@"responseString:%@", responseString);
//    
//    UA_SBJsonParser *parser = [UA_SBJsonParser new];
//    id result = [parser objectWithString:responseString];
//    DEBUG_LOG(@"result:%@", result);
//    [parser release];
//}

//- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response
//{
//    NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse *)response;
//    CFShow([httpResponse allHeaderFields]);
//    DEBUG_LOG(@"[response MIMEType]:%@", [response MIMEType]);
//    DEBUG_LOG(@"[httpResponse statusCode]:%d", [httpResponse statusCode]);
//}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data
{
    DEBUG_LOG(@"data length:%lu", (unsigned long)[data length]);
    [httpData appendData:data];
}

// 11/9/2012 : too verbose
//- (void)connection:(NSURLConnection *)connection didSendBodyData:(NSInteger)bytesWritten totalBytesWritten:(NSInteger)totalBytesWritten totalBytesExpectedToWrite:(NSInteger)totalBytesExpectedToWrite
//{
//    DEBUG_LOG(@"bytesWritten:%d, totalBytesWritten:%d, totalBytesExpectedToWrite:%d",
//              bytesWritten, totalBytesWritten, totalBytesExpectedToWrite);
//}

//- (NSURLRequest *)connection:(NSURLConnection *)connection willSendRequest:(NSURLRequest *)request redirectResponse:(NSURLResponse *)redirectResponse
//{
//    DEBUG_LOG(@"");
//    return request;
//}

- (NSCachedURLResponse *)connection:(NSURLConnection *)connection willCacheResponse:(NSCachedURLResponse *)cachedResponse
{
    DEBUG_LOG(@"");
    return cachedResponse;
}

- (NSInputStream *)connection:(NSURLConnection *)connection needNewBodyStream:(NSURLRequest *)request
{
    DEBUG_LOG(@"");
    return nil;
}

#pragma mark - NSURLConnectionDelegate

//- (void)connectionDidFinishLoading:(NSURLConnection *)connection
//{
//    DEBUG_LOG(@"");
//}

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error
{
    DEBUG_LOG(@"");
    [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
    if ([error code] == kCFURLErrorNotConnectedToInternet) {
        // if we can identify the error, we can present a more precise message to the user.
        NSDictionary *userInfo =
        [NSDictionary dictionaryWithObject:
         NSLocalizedString(@"No Connection Error",
                           @"Error message displayed when not connected to the Internet.")
                                    forKey:NSLocalizedDescriptionKey];
        NSError *noConnectionError = [NSError errorWithDomain:NSCocoaErrorDomain
                                                         code:kCFURLErrorNotConnectedToInternet
                                                     userInfo:userInfo];
        [self handleError:noConnectionError];
    } else {
        // otherwise handle the error generically
        [self handleError:error];
    }
}

//- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data
//{
//    DEBUG_LOG(@"");
//}

//- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response
//{
//    DEBUG_LOG(@"");
//}

//- (NSCachedURLResponse *)connection:(NSURLConnection *)connection willCacheResponse:(NSCachedURLResponse *)cachedResponse
//{
//    DEBUG_LOG(@"");
//    return cachedResponse;
//}

//- (NSURLRequest *)connection:(NSURLConnection *)connection willSendRequest:(NSURLRequest *)request redirectResponse:(NSURLResponse *)redirectResponse
//{
//    DEBUG_LOG(@"");
//    return request;
//}


// 11/09/2012 the challenge sender implements this
#pragma mark - NSURLAuthenticationChallengeSender



#pragma mark - Authentication

- (BOOL)connection:(NSURLConnection *)conn canAuthenticateAgainstProtectionSpace:(NSURLProtectionSpace *)protectionSpace
{
    NSString *authenticationMethod = [protectionSpace authenticationMethod];
    DEBUG_LOG(@"authenticationMethod:%@", authenticationMethod);
    
    if ([NSURLAuthenticationMethodServerTrust hasPrefix:authenticationMethod]) {
        return NO;
    }
    
    BOOL canHandle = [NSURLAuthenticationMethodDefault hasPrefix:authenticationMethod]
    || [NSURLAuthenticationMethodHTTPBasic hasPrefix:authenticationMethod]
    || [NSURLAuthenticationMethodHTTPDigest hasPrefix:authenticationMethod]
    || [NSURLAuthenticationMethodNTLM hasPrefix:authenticationMethod];
    
    if (canHandle)
        return YES;
    else
        return NO;
}

// 11/9/12: if implemented, no other delegate functions are called.
// 11/9/12: sender functions must be called here then.
//- (void)connection:(NSURLConnection *)connection willSendRequestForAuthenticationChallenge:(NSURLAuthenticationChallenge *)challenge
//{
//    DEBUG_LOG(@"");
//}

- (BOOL)connectionShouldUseCredentialStorage:(NSURLConnection *)connection
{
    DEBUG_LOG(@"");
    return NO;
}

- (void)connection:(NSURLConnection *)connection didReceiveAuthenticationChallenge:(NSURLAuthenticationChallenge *)challenge
{
    NSString *authenticationMethod = [[challenge protectionSpace] authenticationMethod];
    DEBUG_LOG(@":previousFailureCount:%zd, method:%@",
              (ssize_t) [challenge previousFailureCount], authenticationMethod);
    
    BOOL canHandle = [NSURLAuthenticationMethodDefault hasPrefix:authenticationMethod]
    || [NSURLAuthenticationMethodHTTPBasic hasPrefix:authenticationMethod]
    || [NSURLAuthenticationMethodHTTPDigest hasPrefix:authenticationMethod]
    || [NSURLAuthenticationMethodNTLM hasPrefix:authenticationMethod];

//#define FINDER_PRO_IN_USE
#ifdef FINDER_PRO_IN_USE
#define FINDER_PRODUCTION
#ifdef FINDER_PRODUCTION
    // Production Sandbox
    NSString *appKey = @"1HxW4eG5Ru2axzsJA-osyg";
    // appSecret variable not used; uses AirshipConfig.plist entry
    NSString *appSecret = @"Pgj2Zp7MQvWmb7NDqPx_yw";
    NSString *masterSecret = @"F1LvURs9Qay0aWsMbblSEg";
#else
    // Development Sandbox
    NSString *appKey = @"wRJrSbTaTNSjYZ8u2Ay-_Q";
    // appSecret variable not used; uses AirshipConfig.plist entry
    NSString *appSecret = @"GvS36xJrRHON1LVJ4zrH1A";
    NSString *masterSecret = @"lWyJW5sYT-atdx4kzZqKtw";
#endif
#endif
    
    //#define SECRET_MESSENGER_IN_USE
#ifdef SECRET_MESSENGER_IN_USE
#define SECRET_PRODUCTION
#ifdef SECRET_PRODUCTION
    // Production Sandbox
    NSString *appKey = @"hAyaujFfQleSgJgS3lK8Sg";
    // appSecret variable not used; uses AirshipConfig.plist entry
    NSString *appSecret = @"0ep7cYwuSFKlobuqx1iAGA";
    NSString *masterSecret = @"Unw_wD1iTHCau3udFHOiFQ";
#else
    // Development Sandbox
    NSString *appKey = @"p8pgTkWrTvW0X-GKeKO-NA";
    // appSecret variable not used; uses AirshipConfig.plist entry
    NSString *appSecret = @"G8WeH6MKQYmV7t2VGpmc1Q";
    NSString *masterSecret = @"b72hemsTTnKiVkq8ktxEwA";
#endif
#endif
    
    
#define CALLMEPRO_IN_USE
#ifdef CALLMEPRO_IN_USE
#define USE_CVT_PRODUCTION
#ifdef USE_CVT_PRODUCTION
    // Production Sandbox
    NSString *appKey = @"ixyJIc7rSJeQb341Zsf3jQ";
    // appSecret variable not used; uses AirshipConfig.plist entry
    NSString *appSecret = @"DL2hnXhOQw65PEQeXiVHVA";
    NSString *masterSecret = @"Uwmy7wS3T0qe0duxx26y8w";
#else
    // Development Sandbox
    NSString *appKey = @"PgDj1Xn3RxS7UFhPQkK7Bw";
    // appSecret variable not used; uses AirshipConfig.plist entry
    NSString *appSecret = @"UyegTU7wRQCOhjrlQXn4VA";
    NSString *masterSecret = @"SVDQyy3US0mXLZFBybAtjA";
#endif
#endif
    
    if (canHandle) {
        //        NSURLCredentialPersistence persistence = NSURLCredentialPersistenceNone;
        NSURLCredentialPersistence persistence = NSURLCredentialPersistenceForSession;
        
        NSURLCredential *credential = [NSURLCredential credentialWithUser:appKey password:masterSecret persistence:persistence];
        [challenge.sender useCredential:credential forAuthenticationChallenge:challenge];
    } else  {
        if ([challenge previousFailureCount] < 1) {
            [challenge.sender rejectProtectionSpaceAndContinueWithChallenge:challenge];
        }
        
        if ([challenge previousFailureCount] == 1) {
            [challenge.sender continueWithoutCredentialForAuthenticationChallenge:challenge];
        }
        
        if ([challenge previousFailureCount] > 1) {
            [challenge.sender performDefaultHandlingForAuthenticationChallenge:challenge];
        }
    }
    
    //    if ([challenge previousFailureCount] < 5) {
    //        self.currentChallenge = [ChallengeHandler handlerForChallenge:challenge parentViewController:self];
    //        if (self.currentChallenge == nil) {
    //            [[challenge sender] continueWithoutCredentialForAuthenticationChallenge:challenge];
    //        } else {
    //            self.currentChallenge.delegate = self;
    //            [self.currentChallenge start];
    //        }
    //    } else {
    //        [[challenge sender] cancelAuthenticationChallenge:challenge];
    //    }
}

#pragma mark - UARegistrationObserver

- (void)registerDeviceTokenSucceeded
{
    DEBUG_LOG(@"");
}

//- (void)registerDeviceTokenFailed:(UA_ASIHTTPRequest *)request
//{
//    DEBUG_LOG(@"request:%@", request);
//}

- (void)unRegisterDeviceTokenSucceeded
{
    DEBUG_LOG(@"");
}

//- (void)unRegisterDeviceTokenFailed:(UA_ASIHTTPRequest *)request
//{
//    DEBUG_LOG(@"request:%@", request);
//}

- (void)addTagToDeviceSucceeded
{
    DEBUG_LOG(@"");
}

//- (void)addTagToDeviceFailed:(UA_ASIHTTPRequest *)request
//{
//    DEBUG_LOG(@"request:%@", request);
//}

- (void)removeTagFromDeviceSucceeded
{
    DEBUG_LOG(@"");
}

//- (void)removeTagFromDeviceFailed:(UA_ASIHTTPRequest *)request
//{
//    DEBUG_LOG(@"request:%@", request);
//}
@end

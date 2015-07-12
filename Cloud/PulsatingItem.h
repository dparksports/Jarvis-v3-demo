//
//  SubscriptionItem.h
//  message
//
//  Created by engineering on 6/21/15.
//  Copyright (c) 2015 Dan Park. All rights reserved.
//

#import <UIKit/UIKit.h>
@import CloudKit;
#import "PulsingHaloLayer.h"

@interface PulsatingItem : UIBarButtonItem
@property (nonatomic, strong) PulsingHaloLayer *pulsingHaloLayer;

- (void) pulsate;
@end

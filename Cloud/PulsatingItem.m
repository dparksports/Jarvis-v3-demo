//
//  SubscriptionItem.m
//  message
//
//  Created by engineering on 6/21/15.
//  Copyright (c) 2015 Dan Park. All rights reserved.
//

#import "PulsingHaloLayer.h"
#import "PulsatingItem.h"

@implementation PulsatingItem

- (instancetype) initWithCustomView:(UIView *)customView {
    self = [super initWithCustomView:customView];
    if(self) {
        self.target = self;
        self.action = @selector(toggleSubscription);
        [self pulsate];
    }
    return self;
}

- (void) pulsate {
    NSLog(@"%s", __FUNCTION__);
    self.pulsingHaloLayer = [PulsingHaloLayer layer];
    _pulsingHaloLayer.position = self.customView.center;
    _pulsingHaloLayer.hidden = true;
    [self.customView.layer insertSublayer:_pulsingHaloLayer below:self.customView.layer];
}

- (void) toggleSubscription {
    NSLog(@"%s", __FUNCTION__);
}

@end

//
//  ORButton.m
//  Mixtape
//
//  Created by orta therox on 11/12/2011.
//  Copyright (c) 2011 http://ortatherox.com. All rights reserved.
//

#import "ORButton.h"

@implementation ORButton

static float  CAP_WIDTH = 12;

- (void)setCustomImage: (NSString*)imageName {
    UIImage *background_image = [[UIImage imageNamed:imageName] stretchableImageWithLeftCapWidth:CAP_WIDTH topCapHeight:CAP_WIDTH];
    UIImage *selected_image = [[UIImage imageNamed:[imageName stringByAppendingString:@"_pressed"]] stretchableImageWithLeftCapWidth:CAP_WIDTH topCapHeight:CAP_WIDTH];
    [self setBackgroundImage: background_image forState:UIControlStateNormal];
    [self setBackgroundImage:  selected_image  forState:UIControlStateSelected];
}

@end

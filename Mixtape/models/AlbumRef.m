//
//  AlbumRef.m
//  Mixtape
//
//  Created by orta therox on 26/11/2011.
//  Copyright (c) 2011 http://ortatherox.com. All rights reserved.
//

#import "AlbumRef.h"

@implementation AlbumRef

@synthesize point, scale;

- (id)refWithX: (float)x y:(float)y andScale:(float)aScale {
    self = [super init];
    self.point = CGPointMake(x, y);
    self.scale = aScale;
    return self;
}

@end

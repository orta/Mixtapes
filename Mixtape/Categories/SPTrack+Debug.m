//
//  SPTrack+Debug.m
//  Mixtape
//
//  Created by orta therox on 19/11/2011.
//  Copyright (c) 2011 http://ortatherox.com. All rights reserved.
//

#import "SPTrack+Debug.h"

@implementation SPTrack (Debug)

- (void)printDebugInfo {
    
    NSLog(@"track %@", self);
    if (!self.loaded) NSLog(@"not loaded");
    NSLog(@"album %@", self.album);
    if (!self.album.loaded) NSLog(@"!!!!! album not loaded");
    NSLog(@"cover %@", self.album.cover);
    if (!self.album.cover.loaded) NSLog(@"!!!!! not loaded");
    NSLog(@"image %@", self.album.cover.image);
}


@end

//
//  TrackLayer.m
//  Mixtape
//
//  Created by orta therox on 30/09/2011.
//  Copyright 2011 http://ortatherox.com. All rights reserved.
//

#import "TrackLayer.h"

#define DegreesToRadians(x) (M_PI * x / 180.0)

@interface TrackLayer (private)
- (void) requestArtwork;
- (void)albumArtReady:(id)notification;
@end

@implementation TrackLayer
@synthesize track = _track, playButton = _playButton;

- (id)initWithTrack:(SPTrack*)track {
    self = [super init];
    if (self) {
        self.name = [NSString stringWithFormat:@"%i", [track hash]];
        self.contents = (id)[[UIImage imageNamed:@"template"] CGImage];
        self.track = track;
        
        self.shadowColor = [[UIColor blackColor] CGColor];
        self.shadowOpacity = 0.6;
        self.shadowRadius = 5.0;
        self.shadowOffset = CGSizeMake(0, 3);
        self.anchorPoint = CGPointMake( 0.5, 0.5);
        
        self.playButton = [CALayer layer];
        self.playButton.contents =  (id)[[UIImage imageNamed:@"play"] CGImage];
        [self addSublayer:self.playButton];
        self.playButton.position = CGPointMake(200, -100);
        self.playButton.bounds = CGRectMake(0, 0, 120, 120);
        self.playButton.opacity = 0;
        
        [self addObserver:self
               forKeyPath:@"track.album.cover.image.loaded"
                  options:0
                  context:nil];
    }
    return self;
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
    self.contents = (id)[[[[self.track album] cover] image] CGImage];        
}

- (void)turnToThumbnailWithScale:(float)scale {
    // this doesn't feel like the best way to do it!
    CATransform3D transform = CATransform3DMakeScale(scale, scale, scale);
    transform = CATransform3DTranslate(transform, 0.0, ORCoverWidth / -3, 0.0);
    float angle = ( random() % 20 ) - 10;
    transform = CATransform3DRotate(transform, DegreesToRadians( angle ), 0, 0, 1);
    transform = CATransform3DTranslate(transform, 0.0, ORCoverWidth / 3, 0.0);
    self.transform = transform;
    self.playButton.opacity = 0;
}

- (void)turnToSelected {
    self.shadowOpacity = 0.8;
    self.shadowRadius = 8.0;
    self.shadowOffset = CGSizeMake(0, 5);
    self.playButton.opacity = 1;
    
    CATransform3D transform = CATransform3DMakeScale(1.2, 1.2, 1.2);
    self.transform = transform;
}

- (void)turnToUnSelected {
    self.shadowOpacity = 0.6;
    self.shadowRadius = 5.0;
    self.shadowOffset = CGSizeMake(0, 3);
    self.playButton.opacity = 0;
    self.transform = CATransform3DIdentity;
}

- (void)repositionWithIndex:(int)index inRelationTo: (int)currentlyPlayingIndex {
    BOOL shouldMove = (index > currentlyPlayingIndex);
    
    if(shouldMove && _shifted) return;
    if(!shouldMove && !_shifted) return;
    
    int toMove = 60;
    if(shouldMove && !_shifted) {
                
        // should move right
        self.position = CGPointMake(self.position.x + toMove, self.position.y);
        _shifted = YES;
    }
    if(!shouldMove && _shifted) {
        // should move back
        self.position = CGPointMake(self.position.x - toMove, self.position.y);
        _shifted = NO;
    }
}
@end

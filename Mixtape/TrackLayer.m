//
//  TrackLayer.m
//  Mixtape
//
//  Created by orta therox on 30/09/2011.
//  Copyright 2011 http://ortatherox.com. All rights reserved.
//

#import "TrackLayer.h"

#define DegreesToRadians(x) (M_PI * x / 180.0)

@implementation TrackLayer
@synthesize track = _track, playButton = _playButton;

- (id)initWithTrack:(SPTrack*)track {
    self = [super init];
    if (self) {
      self.name = [NSString stringWithFormat:@"%i", [track hash]];
      self.contents = (id)[[UIImage imageNamed:@"template"] CGImage];
      self.track = track;
      
      self.anchorPoint = CGPointMake(0.5, 0.5);
      [self turnToThumbnail];
      
      self.shadowColor = [[UIColor blackColor] CGColor];
      self.shadowOpacity = 0.6;
      self.shadowRadius = 5.0;
      self.shadowOffset = CGSizeMake(0, 3);
      [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(albumArtReady:)  name:@"loaded" object: self.track.album.cover];
      _monitorCount = 0;
      [self monitorForLoaded];
      
      self.playButton = [CALayer layer];
      self.playButton.contents =  (id)[[UIImage imageNamed:@"play"] CGImage];
      [self addSublayer:self.playButton];
      self.playButton.position = CGPointMake(200, -100);
      self.playButton.bounds = CGRectMake(0, 0, 120, 120);
      self.playButton.opacity = 0;      
    }
    return self;
}

- (void)turnToThumbnail {
  CATransform3D transform = CATransform3DMakeScale(0.7, 0.7, 0.7);
  float angle = ( random() % 20 ) - 10;
  transform = CATransform3DRotate(transform, DegreesToRadians( angle ), 0, 0, 1);
  self.transform = transform;
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

- (void)reposition:(BOOL)shouldMove {
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


-(void)albumArtReady:(id)notification {
  self.contents = (id)[[[[self.track album] cover] image] CGImage];
}


- (void)monitorForLoaded {
  if( ( self.track.album.cover == nil ) && (_monitorCount++ < 10) ) {
    [self performSelector:_cmd withObject:nil afterDelay:1.0];
    return;
  }
  self.contents = (id)[[[[self.track album] cover] image] CGImage];
}


@end

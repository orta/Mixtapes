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
@synthesize track = _track;

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
    }
    return self;
}

- (void)turnToThumbnail {
  CATransform3D transform = CATransform3DMakeScale(0.7, 0.7, 0.7);
  float angle = ( random() % 20 ) - 10;
  transform = CATransform3DRotate(transform, DegreesToRadians( angle ), 0, 0, 1);
  self.transform = transform;
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

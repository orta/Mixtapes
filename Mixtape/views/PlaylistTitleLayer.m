//
//  PlaylistTitleLayer.m
//  Mixtape
//
//  Created by orta therox on 30/09/2011.
//  Copyright 2011 http://ortatherox.com. All rights reserved.
//

#import "PlaylistTitleLayer.h"

#define DegreesToRadians(x) (M_PI * x / 180.0)
#define FONT_SIZE 18


@implementation PlaylistTitleLayer

- (id)initWithPlaylist:(SPPlaylist*)playlist {
    self = [super init];
    if (self) {
      self.name = [NSString stringWithFormat:@"%i", [playlist hash]];
      self.string = playlist.name;
      self.cornerRadius = 8; 
      self.alignmentMode = kCAAlignmentCenter;
      [self turnToLabel];
    }
    return self;
}

- (void)turnToLabel {
  CGSize cs = [self.name sizeWithFont:[UIFont fontWithName:@"Helvetica" size:FONT_SIZE] constrainedToSize:CGSizeMake(240, 120) lineBreakMode:UILineBreakModeWordWrap];
  
  [self setFrame: CGRectMake( 0, 0, cs.width + 40, 50)];
  self.backgroundColor = [[UIColor colorWithRed:0 green:0 blue:0 alpha:0.7] CGColor];
  self.fontSize = FONT_SIZE;
  float degrees = (random() % 40) - 20;
  CATransform3D transform = CATransform3DMakeRotation ( DegreesToRadians( degrees ), 0, 0, 1);
  self.transform = transform;
  self.opacity = 1;
}

// centers vertically, thanks http://lists.apple.com/archives/quartz-dev/2008/Aug/msg00016.html
    - (void)drawInContext:(CGContextRef)ctx {
      CGFloat height, fontSize;
      
      height = self.bounds.size.height;
      fontSize = self.fontSize;
      
      CGContextSaveGState(ctx);
      CGContextTranslateCTM(ctx, 0.0, (fontSize-height)/2.0 * -1.0);
      [super drawInContext:ctx];
      CGContextRestoreGState(ctx);
    }

@end

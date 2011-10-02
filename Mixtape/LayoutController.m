//
//  LayoutController.m
//  Mixtape
//
//  Created by orta therox on 01/10/2011.
//  Copyright (c) 2011 http://ortatherox.com. All rights reserved.
//

#import "LayoutController.h"
#import "MixtapeAppDelegate.h"
#import "PlaylistTitleLayer.h"
#import "TrackLayer.h"
#import <QuartzCore/QuartzCore.h>

enum {
  LayoutsFloorView = 1,
  LayoutsSinglePlaylist = 2
};

@interface LayoutController(private)
- (void)hideAllPlaylistsButCurrent;
- (int)playlistIndexForPoint:(CGPoint)point;
- (void)transitionIntoPlaylistView;
@end


@implementation LayoutController

@synthesize state = _state, layers = _layers, titleLayers = _titleLayers;
@synthesize currentPlaylist = _currentPlaylist, playlistWrapperLayers = _playlistWrapperLayers;

- (id)init {
  self = [super init];
  self.layers = [NSMutableArray array];
  self.titleLayers = [NSMutableArray array];
  self.playlistWrapperLayers = [NSMutableArray array];
  _playlistLayer = [[CALayer layer] retain];
  [canvas.layer addSublayer:_playlistLayer];
  self.state = LayoutsFloorView;
  return self;
}

- (void) setupAlbumArtwork {
  MixtapeAppDelegate * appDelegate = (MixtapeAppDelegate *)[[UIApplication sharedApplication] delegate];
  
  for (int i = 0; i < [appDelegate.playlists count]; i++) {
    SPPlaylist * playlist = [appDelegate.playlists objectAtIndex:i];
    
    PlaylistTitleLayer *label = [[PlaylistTitleLayer alloc] initWithPlaylist:playlist];
    [self.titleLayers addObject:label];
    [canvas.layer addSublayer:label];
    
    NSMutableArray * playlistLayerArray = [NSMutableArray array];
    [self.layers addObject:playlistLayerArray];
    
    CALayer *wrapperLayer = [CALayer layer];
    [canvas.layer addSublayer:wrapperLayer];
    [self.playlistWrapperLayers addObject:wrapperLayer];
        
    // backwards so the Z-ordering is done for free
    for (int j = [playlist.tracks count] - 1; j != 0 ; j--) {
      SPTrack *track = [playlist.tracks objectAtIndex:j];
      TrackLayer * layer = [[TrackLayer alloc] initWithTrack:track];
      [playlistLayerArray addObject:layer];
      [wrapperLayer addSublayer:layer];
    }
  }
}

-(void)setupGestureReconition { 
  UITapGestureRecognizer *singleFingerTap = [[UITapGestureRecognizer alloc]
                                              initWithTarget:self action:@selector(handleTap:)];
  singleFingerTap.numberOfTapsRequired = 1;
  [canvas addGestureRecognizer:singleFingerTap];
  [singleFingerTap release];

  UIPanGestureRecognizer *panGesture = [[UIPanGestureRecognizer alloc]
                                        initWithTarget:self action:@selector(handlePanGesture:)];
  [canvas addGestureRecognizer:panGesture];
  [panGesture release];

  UIPinchGestureRecognizer *pinchGesture = [[UIPinchGestureRecognizer alloc]
                                            initWithTarget:self action:@selector(handlePinchGesture:)];
  [canvas addGestureRecognizer:pinchGesture];
  [pinchGesture release];
}

- (IBAction)handlePinchGesture:(UIGestureRecognizer *)sender {
  if (self.state == LayoutsSinglePlaylist) {
    CGFloat factor = [(UIPinchGestureRecognizer *)sender scale];
    //canvas.transform = CGAffineTransformMakeScale(factor, factor);
    if (factor > 0.3) {
      [self transitionIntoFloorView];
    }
    
  }
}

- (IBAction)handlePanGesture:(UIPanGestureRecognizer *)sender {
  if (self.state == LayoutsSinglePlaylist) {
    CGPoint translate = [sender velocityInView:canvas];
    CALayer * wrapper = [self.playlistWrapperLayers objectAtIndex:_currentplaylistIndex];
    wrapper.position = CGPointMake(wrapper.position.x + translate.x, wrapper.position.y);
  }
}

- (IBAction)handleTap:(UIGestureRecognizer *)sender {
  CGPoint tapPoint = [sender locationInView:sender.view.superview];
  
  switch (self.state) {
    
    case LayoutsSinglePlaylist:
      [self transitionIntoFloorView];
      break;
    
    case LayoutsFloorView:
      NSLog(@"touched");
      int i  = [self playlistIndexForPoint:tapPoint];
      _currentplaylistIndex = i;
      self.currentPlaylist = [self.layers objectAtIndex:_currentplaylistIndex];
      [self hideAllPlaylistsButCurrent];
      [self transitionIntoPlaylistView];
      [[SPSession sharedSession] playTrack:[[self.currentPlaylist objectAtIndex:0] track] error:nil];
      break;
  }
}

- (int) playlistIndexForPoint:(CGPoint)point{
  MixtapeAppDelegate * appDelegate = (MixtapeAppDelegate *)[[UIApplication sharedApplication] delegate];
  float eachSectionWidth = 1024 / [appDelegate.playlists count];
  float x = point.x;
  int i = -1;
  while (x > 0) {
    x -= eachSectionWidth;
    i++;
  }
  return i;
}

- (void)hideAllPlaylistsButCurrent {
  for (int i = 0; i < [self.layers count]; i++) {
    NSMutableArray * otherPlaylist = [self.layers objectAtIndex:i];
    for (CALayer * layer in otherPlaylist) {
      if (otherPlaylist == self.currentPlaylist) layer.opacity = 1;
      else layer.opacity = 0;
    }
  }
}

- (void)transitionIntoPlaylistView {
  
  for (int i = 0; i < [self.titleLayers count]; i++) {
    CALayer *layer = [self.titleLayers objectAtIndex:i];
    layer.opacity = 0;
  }
  
  CALayer * wrapper = [self.playlistWrapperLayers objectAtIndex:_currentplaylistIndex];
  wrapper.masksToBounds = NO;
  wrapper.position = CGPointMake(0, 550);
  
  for (int i = 0; i < [self.currentPlaylist count]; i++) {
    CALayer * layer = [self.currentPlaylist objectAtIndex:i];
    layer.transform = CATransform3DIdentity;
    layer.position = CGPointMake(i * 340, 0);
  }
  
  self.state = LayoutsSinglePlaylist;
}

- (void)transitionIntoFloorView {
  for (int i = 0; i < [self.layers count]; i++) {
    NSMutableArray * playlist = [self.layers objectAtIndex:i];
    float x_center = ( 834 / [self.layers count] ) * (i + 1) - 155; 
    
    PlaylistTitleLayer * label = [self.titleLayers objectAtIndex:i];
    [label turnToLabel];
    label.position = CGPointMake( x_center + 80 + random() % 40, 260);
    
    
    CALayer * wrapperLayer = [self.playlistWrapperLayers objectAtIndex:i];
    [wrapperLayer setPosition: CGPointMake( (random() % 20) + x_center, (random() % 20) + 531)];
    
    for (int j = [playlist count] - 1; j > -1 ; j--) {
      TrackLayer *layer = [playlist objectAtIndex:j];
      [layer turnToThumbnail];
      layer.position = CGPointMake(0, 0);
      if (j > [playlist count] - 5) layer.opacity = 0;
      else layer.opacity = 1;
    }
  }
  
  self.state = LayoutsFloorView;
}


@end

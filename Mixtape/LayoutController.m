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
#import "AudioController.h"

enum {
  LayoutsFloorView = 1,
  LayoutsSinglePlaylist = 2
};

@interface LayoutController(private)
- (void)hideAllPlaylistsButCurrent;
- (int)playlistIndexForPoint:(CGPoint)point;
- (void)transitionIntoPlaylistView;

- (void)moveToCurrentTrack;
- (int)currentPlaylistSelectionIndex;
- (void)setCurrentPlaylistSeletionIndex:(int)index;

@end


@implementation LayoutController

@synthesize state = _state, layers = _layers, titleLayers = _titleLayers;
@synthesize currentPlaylist = _currentPlaylist, playlistWrapperLayers = _playlistWrapperLayers;
@synthesize playlistSelectionIndex = _playlistSelectionIndex;

- (id)init {
  self = [super init];
  self.layers = [NSMutableArray array];
  self.titleLayers = [NSMutableArray array];
  self.playlistWrapperLayers = [NSMutableArray array];
  self.playlistSelectionIndex = [NSMutableArray array];
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
    [self.playlistSelectionIndex addObject:[NSNumber numberWithInt:0]];
    
    NSMutableArray * playlistLayerArray = [NSMutableArray array];
    [self.layers addObject:playlistLayerArray];
    
    CALayer *wrapperLayer = [CALayer layer];
    [canvas.layer addSublayer:wrapperLayer];
    [self.playlistWrapperLayers addObject:wrapperLayer];
        
    for (int j = 0; j < [playlist.tracks count] ; j++) {
      SPTrack *track = [playlist.tracks objectAtIndex:j];
      TrackLayer * layer = [[TrackLayer alloc] initWithTrack:track];
      [playlistLayerArray addObject:layer];
      
      // get Z ordering correct 
      if ([[wrapperLayer sublayers] count])
        [wrapperLayer insertSublayer:layer below:[[wrapperLayer sublayers] lastObject]];  
      else
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

  UISwipeGestureRecognizer* swipe;
  swipe = [[[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(handleSwipeLeft:)] autorelease];
  swipe.direction = UISwipeGestureRecognizerDirectionLeft;
  [canvas addGestureRecognizer:swipe];
  
  swipe = [[[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(handleSwipeRight:)] autorelease];
  swipe.direction = UISwipeGestureRecognizerDirectionRight; // default
  [canvas addGestureRecognizer:swipe];
  
  UIPinchGestureRecognizer *pinchGesture = [[UIPinchGestureRecognizer alloc]
                                            initWithTarget:self action:@selector(handlePinchGesture:)];
  [canvas addGestureRecognizer:pinchGesture];
  [pinchGesture release];
}

- (IBAction)handlePinchGesture:(UIGestureRecognizer *)sender {
  if (self.state == LayoutsSinglePlaylist) {
    CGFloat factor = [(UIPinchGestureRecognizer *)sender scale];
    if (factor > 0.3) {
      [self transitionIntoFloorView];
    }
    
  }
}

- (IBAction)handleSwipeLeft:(UISwipeGestureRecognizer *)sender {
  if (self.state == LayoutsSinglePlaylist) {
    int index = [self currentPlaylistSelectionIndex];

    if ( index == ([self.currentPlaylist count] - 1) ) return;    
    index = index + 1;
    
    [self setCurrentPlaylistSeletionIndex:index];
    [self moveToCurrentTrack];
  }
}

- (IBAction)handleSwipeRight:(UISwipeGestureRecognizer *)sender {
  if (self.state == LayoutsSinglePlaylist) {
    int index = [self currentPlaylistSelectionIndex];
    
    if(index == 0) return;
    index = index - 1;

    [self setCurrentPlaylistSeletionIndex:index];
    [self moveToCurrentTrack];
  }
}

- (IBAction)handleTap:(UIGestureRecognizer *)sender {
  CGPoint tapPoint = [sender locationInView:sender.view.superview];
  
  switch (self.state) {
    
    case LayoutsSinglePlaylist:
      NSLog(@"loc %f, %f", tapPoint.x, tapPoint.y );
      CGRect centerCover = CGRectMake(200, 200, 400, 400);
      if ( CGRectContainsPoint(centerCover, tapPoint)) {
        NSLog(@"tapped");
        MixtapeAppDelegate * appDelegate = (MixtapeAppDelegate *)[[UIApplication sharedApplication] delegate];

        [audio setCurrentPlaylist:[[appDelegate playlists] objectAtIndex:_currentplaylistIndex]];
        [audio playTrackWithIndex:[self currentPlaylistSelectionIndex]];
        return;
      }
      
      
      //fallback to hiding
      [self transitionIntoFloorView];
      break;
    
    case LayoutsFloorView:
      NSLog(@"touched");
      int i  = [self playlistIndexForPoint:tapPoint];
      _currentplaylistIndex = i;
      self.currentPlaylist = [self.layers objectAtIndex:_currentplaylistIndex];
      [self hideAllPlaylistsButCurrent];
      [self transitionIntoPlaylistView];
      break;
  }
}

- (int) playlistIndexForPoint:(CGPoint) point{
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
  
  for (int i = 0; i < [self.currentPlaylist count]; i++) {
    CALayer *layer = [self.currentPlaylist objectAtIndex:i];
    layer.position = CGPointMake(i * 340, 0);
  }

  [self moveToCurrentTrack];
  self.state = LayoutsSinglePlaylist;
}


- (void) moveToCurrentTrack {
  int index = [self currentPlaylistSelectionIndex];
  CALayer * wrapper = [self.playlistWrapperLayers objectAtIndex:_currentplaylistIndex];
  wrapper.position = CGPointMake((index * -340) + 280, wrapper.position.y); 
    
  for (int i = 0; i < [self.currentPlaylist count]; i++) {
    TrackLayer * layer = [self.currentPlaylist objectAtIndex:i];

    if(i == index) [layer turnToSelected];
    else [layer turnToUnSelected];
    
    // true if after selected track
    [layer reposition:( i > index )];
  } 
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
      if (j < 5) layer.opacity = 1;
      else layer.opacity = 0;
    }
  }
  
  self.state = LayoutsFloorView;
}

- (void)setCurrentPlaylistSeletionIndex:(int)index {
  [self.playlistSelectionIndex  replaceObjectAtIndex:_currentplaylistIndex withObject:[NSNumber numberWithInt:index]];  
}

- (int) currentPlaylistSelectionIndex {
  return [[self.playlistSelectionIndex objectAtIndex:_currentplaylistIndex] intValue];
}

@end

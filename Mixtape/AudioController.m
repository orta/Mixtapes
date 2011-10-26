//
//  AudioController.m
//  Mixtape
//
//  Created by orta therox on 02/10/2011.
//  Copyright (c) 2011 http://ortatherox.com. All rights reserved.
//

#import "AudioController.h"
#import <AVFoundation/AVFoundation.h>

@implementation AudioController

@synthesize trackIndex = _trackIndex, currentPlaylist = _currentSPPlaylist;
@synthesize playbackManager = _playbackManager;

- (void)awakeFromNib {
  _currentPlayingTrackArtist.text = @"";
  _currentPlayingTrackName.text = @"";
  _playing = NO;

  _showingController = NO;
  CGRect newLocation = _controllerView.frame;
  newLocation.origin.y += 200;
  _controllerView.frame = newLocation;

  self.playbackManager = [[[SPPlaybackManager alloc] initWithPlaybackSession:[SPSession sharedSession]] autorelease];
}

- (void)playTrackWithIndex:(int)index {
  if(!_showingController){
    [self animateControllerIn];
  }
  
  if (_trackIndex == index) return;
  _trackIndex = index;
  _trackIndex = MIN(_trackIndex, [self.currentPlaylist.tracks count] - 1);
  _trackIndex = MAX(_trackIndex, 0);
  
  NSMutableArray *tracks = self.currentPlaylist.tracks;
  SPTrack *track = [tracks objectAtIndex:_trackIndex];
  [[SPSession sharedSession] playTrack:track error:nil];
  
  _currentPlayingTrackImage.image = track.album.cover.image;
  _currentPlayingTrackArtist.text = [track.album.artist name];
  _currentPlayingTrackName.text = [track name];
  _playPauseButton.imageView.image = [UIImage imageNamed:@"pause"];
  _playing = YES;
  
  if (_trackIndex < [tracks count] - 1) {
    [[SPSession sharedSession] preloadTrackForPlayback:[tracks objectAtIndex:_trackIndex + 1] error:nil];
  }
}

- (void) nextTrack {
  [self playTrackWithIndex:_trackIndex + 1];
}

- (void) previousTrack {
  [self playTrackWithIndex:_trackIndex - 1];
}

- (void) playPause:(id)sender {
  if (_playing) {
#warning fix this
    [[SPSession sharedSession] pause];
  }else{
    [[SPSession sharedSession] resume];
    _playPauseButton.imageView.image = [UIImage imageNamed:@"pause"];
  }
  _playing = !_playing;
}

// someone else is using the app
-(void)sessionDidLosePlayToken:(SPSession *)aSession{}

-(void)sessionDidEndPlayback:(SPSession *)aSession{
  [self nextTrack];
}

- (void)animateControllerIn {
  _showingController = YES;
  [UIView beginAnimations:@"animationID" context:NULL];
  [UIView setAnimationDuration:0.6];
  
  CGRect newLocation = _controllerView.frame;
  newLocation.origin.y -= 200;
  _controllerView.frame = newLocation;
  
  [UIView setAnimationCurve: UIViewAnimationCurveEaseOut];
  [UIView commitAnimations];
}


@end

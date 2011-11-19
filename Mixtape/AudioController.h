//
//  AudioController.h
//  Mixtape
//
//  Created by orta therox on 02/10/2011.
//  Copyright (c) 2011 http://ortatherox.com. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SPPlaybackManager.h"

@interface AudioController : NSObject <SPSessionPlaybackDelegate, SPPlaybackManagerDelegate> {
  SPPlaylist *_currentSPPlaylist;
  
  int _trackIndex;
  BOOL _showingController;
  
  IBOutlet UIImageView * _currentPlayingTrackImage;
  IBOutlet UILabel * _currentPlayingTrackName;
  IBOutlet UILabel * _currentPlayingTrackArtist;
  IBOutlet UIButton * _playPauseButton;
  IBOutlet UIView * _controllerView;

  SPPlaybackManager *_playbackManager;
}

@property (retain) SPPlaylist *currentPlaylist;
@property (retain) SPPlaybackManager *playbackManager;
@property () int trackIndex;

- (void)animateControllerIn;
- (void)nextTrack;
- (void)previousTrack;
- (IBAction)playPause:(id)sender;
- (void)playTrackWithIndex:(int)index;
@end

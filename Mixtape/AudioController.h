//
//  AudioController.h
//  Mixtape
//
//  Created by orta therox on 02/10/2011.
//  Copyright (c) 2011 http://ortatherox.com. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "audio.h"

@interface AudioController : NSObject <SPSessionPlaybackDelegate> {
  audio_fifo_t audiofifo;
	sp_session *session;
  
  SPPlaylist *_currentSPPlaylist;
  
  int _trackIndex;
  BOOL _playing;
  BOOL _showingController;
  
  IBOutlet UIImageView * _currentPlayingTrackImage;
  IBOutlet UILabel * _currentPlayingTrackName;
  IBOutlet UILabel * _currentPlayingTrackArtist;
  IBOutlet UIButton * _playPauseButton;
  IBOutlet UIView * _controllerView;

}

@property (retain) SPPlaylist *currentPlaylist;
@property () int trackIndex;

- (void)animateControllerIn;
- (void)nextTrack;
- (void)previousTrack;
- (IBAction)playPause:(id)sender;
- (void)playTrackWithIndex:(int)index;

-(void)prepare;
-(audio_fifo_t*)audiofifo;
-(NSInteger)session:(SPSession *)aSession shouldDeliverAudioFrames:(const void *)audioFrames ofCount:(NSInteger)frameCount format:(const sp_audioformat *)audioFormat;
@end

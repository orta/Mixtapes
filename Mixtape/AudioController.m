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

- (void)awakeFromNib {
  _currentPlayingTrackArtist.text = @"";
  _currentPlayingTrackName.text = @"";
  _playing = NO;

  _showingController = NO;
  CGRect newLocation = _controllerView.frame;
  newLocation.origin.y += 200;
  _controllerView.frame = newLocation;
  
  [[AVAudioSession sharedInstance] setDelegate:self];
	NSError *err = nil;
  BOOL success = YES;
	success &= [[AVAudioSession sharedInstance] setCategory:AVAudioSessionCategoryPlayback error:&err];
	success &= [[AVAudioSession sharedInstance] setActive:YES error:&err];
	if(!success)
		NSLog(@"Failed to activate audio session: %@", err);
}

- (void) prepare {
  [[SPSession sharedSession] setPlaybackDelegate:self];
  audio_init(&audiofifo);
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
    [[SPSession sharedSession] pause];
  }else{
    [[SPSession sharedSession] resume];
    _playPauseButton.imageView.image = [UIImage imageNamed:@"pause"];
  }
  _playing = !_playing;
}

-(audio_fifo_t*)audiofifo; {
	return &audiofifo;
}

// someone else is using the app
-(void)sessionDidLosePlayToken:(SPSession *)aSession{}

-(void)sessionDidEndPlayback:(SPSession *)aSession{
  [self nextTrack];
}

-(NSInteger)session:(SPSession *)aSession shouldDeliverAudioFrames:(const void *)audioFrames ofCount:(NSInteger)frameCount format:(const sp_audioformat *)audioFormat {

  audio_fifo_t *af = [self audiofifo];
	audio_fifo_data_t *afd = NULL;
	size_t s;
  
	if (frameCount == 0)
		return 0; // Audio discontinuity, do nothing
  
	pthread_mutex_lock(&af->mutex);
  
	/* Buffer one second of audio */
	if (af->qlen > audioFormat->sample_rate) {
		pthread_mutex_unlock(&af->mutex);
		return 0;
	}
  
	s = frameCount * sizeof(int16_t) * audioFormat->channels;
  
	afd = malloc(sizeof(audio_fifo_data_t) + s);
	memcpy(afd->samples, audioFrames, s);
  
	afd->nsamples = frameCount;
  
	afd->rate = audioFormat->sample_rate;
	afd->channels = audioFormat->channels;
  
	TAILQ_INSERT_TAIL(&af->q, afd, link);
	af->qlen += frameCount;
  
	pthread_cond_signal(&af->cond);
	pthread_mutex_unlock(&af->mutex);
  
	return frameCount;
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

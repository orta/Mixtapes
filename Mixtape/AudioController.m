//
//  AudioController.m
//  Mixtape
//
//  Created by orta therox on 02/10/2011.
//  Copyright (c) 2011 http://ortatherox.com. All rights reserved.
//

#import "AudioController.h"
#import <AVFoundation/AVFoundation.h>
#import "SPTrack+Debug.h"

@interface AudioController (private)

- (void)animateControllerIn;

@end

@implementation AudioController

@synthesize trackIndex = _trackIndex, currentPlaylist = _currentSPPlaylist;
@synthesize playbackManager = _playbackManager;

- (void)awakeFromNib {
    _currentPlayingTrackArtist.text = @"";
    _currentPlayingTrackName.text = @"";
    
    _showingController = NO;
    CGRect newLocation = _controllerView.frame;
    newLocation.origin.y += 200;
    _controllerView.frame = newLocation;
    
}

#pragma mark playing / pausing delegate callbacks

-(void)playbackManagerWillStartPlayingAudio:(SPPlaybackManager *)aPlaybackManager{ 
    [_playPauseButton setImage:[UIImage imageNamed:@"pause"] forState:UIControlStateNormal];
}

// someone else is using the app
- (void)playbackManagerWillStopPlayingAudio:(SPPlaybackManager *)aPlaybackManager {
    [self nextTrack];    
}

# pragma mark playing /pausing audio

- (void)playTrackWithIndex:(int)index {
    if(self.playbackManager == nil){
        self.playbackManager = [[SPPlaybackManager alloc] initWithPlaybackSession:[SPSession sharedSession]];
        self.playbackManager.delegate = self;
    }
    
    if(!_showingController){
        [self animateControllerIn];
    }
    
    if ( [[SPSession sharedSession] isPlaying] &&  (_trackIndex == index) ) return;
    _trackIndex = index;
    _trackIndex = MIN(_trackIndex, [self.currentPlaylist.items count] - 1);
    _trackIndex = MAX(_trackIndex, 0);
    
    NSMutableArray *tracks = self.currentPlaylist.items;
    SPTrack *track = [[tracks objectAtIndex:_trackIndex] item];
    
    NSError *error = nil;
    [self.playbackManager playTrack:track error:&error];
    
    if( error && [error isKindOfClass:[NSError class]]) {
        NSLog(@"track playback error %@", [error localizedDescription]);
    }
    
    [self updateControllerTexts];
    
    if (_trackIndex < [tracks count] - 1) {
        [[SPSession sharedSession] preloadTrackForPlayback:[[tracks objectAtIndex:_trackIndex + 1] item] error:nil];
    }
}

- (void)updateControllerTexts {
    NSMutableArray *tracks = self.currentPlaylist.items;
    SPTrack *track = [[tracks objectAtIndex:_trackIndex] item];

    _currentPlayingTrackImage.image = track.album.cover.image;
    _currentPlayingTrackArtist.text = [track.album.artist name];
    _currentPlayingTrackName.text = [track name];
}

- (void) nextTrack {
    [self playTrackWithIndex:_trackIndex + 1];
}

- (void) previousTrack {
    [self playTrackWithIndex:_trackIndex - 1];
}

- (void) playPause:(id)sender {
    [SPSession sharedSession].playing = ![SPSession sharedSession].playing;
    if ([SPSession sharedSession].playing) {
        [_playPauseButton setImage:[UIImage imageNamed:@"pause"] forState:UIControlStateNormal];

    }else{
        [_playPauseButton setImage:[UIImage imageNamed:@"play"] forState:UIControlStateNormal];
    }
}

- (void)animateControllerIn {
    _showingController = YES;
    [UIView beginAnimations:@"animationID" context:NULL];
    [UIView setAnimationDuration:0.6];
    
    CGRect newLocation = _controllerView.frame;
    newLocation.origin.y -= 200;
    _controllerView.frame = newLocation;    
    [_playPauseButton setImage:[UIImage imageNamed:@"pause"] forState:UIControlStateNormal];
    
    [UIView setAnimationCurve: UIViewAnimationCurveEaseOut];
    [UIView commitAnimations];
}

@end

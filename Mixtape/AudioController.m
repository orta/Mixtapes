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
    
    _showingController = NO;
    CGRect newLocation = _controllerView.frame;
    newLocation.origin.y += 200;
    _controllerView.frame = newLocation;
    
}

-(void)playbackManagerWillStartPlayingAudio:(SPPlaybackManager *)aPlaybackManager{ 
    NSLog(@"started playing");
}


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
        NSLog(@"playback error %@", [error localizedDescription]);
    }
    
    _currentPlayingTrackImage.image = track.album.cover.image;
    _currentPlayingTrackArtist.text = [track.album.artist name];
    _currentPlayingTrackName.text = [track name];
    
    if (_trackIndex < [tracks count] - 1) {
        [[SPSession sharedSession] preloadTrackForPlayback:[[tracks objectAtIndex:_trackIndex + 1] item] error:nil];
    }
}

- (void) nextTrack {
    [self playTrackWithIndex:_trackIndex + 1];
}

- (void) previousTrack {
    [self playTrackWithIndex:_trackIndex - 1];
}

- (void) playPause:(id)sender {
    NSLog(@"play pause");
    [SPSession sharedSession].playing = ![SPSession sharedSession].playing;
    if ([SPSession sharedSession].playing) {
        _playPauseButton.imageView.image = [UIImage imageNamed:@"play"];
    }else{
        _playPauseButton.imageView.image = [UIImage imageNamed:@"pause"];
    }
}

// someone else is using the app
- (void)playbackManagerWillStopPlayingAudio:(SPPlaybackManager *)aPlaybackManager {
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

//
//  LayoutController.h
//  Mixtape
//
//  Created by orta therox on 01/10/2011.
//  Copyright (c) 2011 http://ortatherox.com. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <QuartzCore/QuartzCore.h>

@class AudioController;

@interface LayoutController : NSObject {
    IBOutlet UIView * canvas;
    int _state;
    
    IBOutlet UIActivityIndicatorView *loadingActivityView;
    
    NSMutableArray * _layers;
    NSMutableArray * _titleLayers;
    NSMutableArray * _playlistWrapperLayers;
    NSMutableArray * _playlistSelectionIndex;
    
    int _currentplaylistIndex;
    NSMutableArray * _currentPlaylist; 
    CALayer *_playlistLayer;
    
    IBOutlet AudioController * audio;
    
    CATextLayer *songNameLayer;
    CATextLayer *songArtistLayer;
    
    NSArray * _centerPoints;
}

-(void)setupAlbumArtwork;
-(void)setupGestureReconition;
-(void)transitionIntoFloorView;


@property () int state;
@property (retain) NSMutableArray * layers;
@property (retain) NSMutableArray * titleLayers;
@property (retain) NSMutableArray * currentPlaylist;
@property (retain) NSMutableArray * playlistWrapperLayers;
@property (retain) NSMutableArray * playlistSelectionIndex;
@property (retain) NSArray * centerPoints;

@end

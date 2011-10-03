//
//  LayoutController.h
//  Mixtape
//
//  Created by orta therox on 01/10/2011.
//  Copyright (c) 2011 http://ortatherox.com. All rights reserved.
//

#import <Foundation/Foundation.h>

@class AudioController;

@interface LayoutController : NSObject {
  IBOutlet UIView * canvas;
  int _state;

  NSMutableArray * _layers;
  NSMutableArray * _titleLayers;
  NSMutableArray * _playlistWrapperLayers;
  
  int _currentplaylistIndex;
  NSMutableArray * _currentPlaylist; 
  CALayer *_playlistLayer;
  
  IBOutlet AudioController * audio;
}

-(void)setupAlbumArtwork;
-(void)setupGestureReconition;
-(void)transitionIntoFloorView;


@property () int state;
@property (retain) NSMutableArray * layers;
@property (retain) NSMutableArray * titleLayers;
@property (retain) NSMutableArray * currentPlaylist;
@property (retain) NSMutableArray * playlistWrapperLayers;
@end

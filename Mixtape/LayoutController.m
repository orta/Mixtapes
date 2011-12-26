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
#import "Constants.h"
#import "AlbumRef.h"
#import "PlaylistPostionGenerator.h"

static float ORSongMargin = 40;

enum {
    LayoutsFloorView = 1,
    LayoutsSinglePlaylist = 2
};

@interface LayoutController(private)
- (void)hideAllPlaylistsButCurrent;
- (NSNumber *)playlistIndexForPoint:(CGPoint) point;
- (void)transitionIntoPlaylistView;

- (void)moveToCurrentTrack;
- (int)currentPlaylistSelectionIndex;
- (void)setCurrentPlaylistSeletionIndex:(int)index;
- (void)playSelectedSong;

- (NSArray*)currentCenterPoints;

- (BOOL)isIPhone;
- (BOOL)isPortrait;

@end


@implementation LayoutController

@synthesize state = _state, layers = _layers, titleLayers = _titleLayers;
@synthesize currentPlaylist = _currentPlaylist, playlistWrapperLayers = _playlistWrapperLayers;
@synthesize playlistSelectionIndexes = _playlistSelectionIndex, centerPoints = _centerPoints;

- (id)init {
    self = [super init];
    self.layers = [NSMutableArray array];
    self.titleLayers = [NSMutableArray array];
    self.playlistWrapperLayers = [NSMutableArray array];
    self.playlistSelectionIndexes = [NSMutableArray array];
    _playlistLayer = [[CALayer layer] retain];
    [canvas.layer addSublayer:_playlistLayer];
    
//    [[UIDevice currentDevice] beginGeneratingDeviceOrientationNotifications];
//    [[NSNotificationCenter defaultCenter] addObserver:self
//                                             selector:@selector(orientationChanged:)
//                                                 name:UIDeviceOrientationDidChangeNotification
//                                               object:nil];
    
    self.state = LayoutsFloorView;
    return self;
}

- (void)orientationChanged:(NSNotification *)notification {
    switch (self.state) {
        case LayoutsFloorView:
            [self transitionIntoFloorView];
            break;
        case LayoutsSinglePlaylist:
            [self transitionIntoPlaylistView];
            break;
    }
}

- (void) setupAlbumArtwork {
    [loadingActivityView stopAnimating];
    self.centerPoints = [PlaylistPostionGenerator currentCenterPoints];

    if ([self isIPhone]) {
        CATransform3D transform = CATransform3DMakeScale(0.6, 0.6, 0.6);
        canvas.layer.transform = transform;
    }
    
    MixtapeAppDelegate * appDelegate = (MixtapeAppDelegate *)[[UIApplication sharedApplication] delegate];

    for (int i = 0; i < [appDelegate.playlists count]; i++) {
        if (i > 4) {
            break;
        }
        
        SPPlaylist * playlist = [appDelegate.playlists objectAtIndex:i];
        
        PlaylistTitleLayer *label = [[PlaylistTitleLayer alloc] initWithPlaylist:playlist];
        [self.titleLayers addObject:label];
        [canvas.layer addSublayer:label];
        [self.playlistSelectionIndexes addObject:[NSNumber numberWithInt:0]];
        
        NSMutableArray * playlistLayerArray = [NSMutableArray array];
        [self.layers addObject:playlistLayerArray];
        
        CALayer *wrapperLayer = [CALayer layer];
        [canvas.layer addSublayer:wrapperLayer];
        [self.playlistWrapperLayers addObject:wrapperLayer];
        
        for (int j = 0; j < [playlist.items count] ; j++) {
            SPTrack *track = [[playlist.items objectAtIndex:j] item];
            
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
            self; // I get weird errors if I have C code right after case's
            
            CGRect centerCover = CGRectMake(370, 160, ORCoverWidth * 1.2, ORCoverWidth * 1.2);
            
//            CALayer *currentSelectionLayer = [self.currentPlaylist [self currentPlaylistSelectionIndex]];
            
//            tapPoint = [canvas.layer convertPoint:tapPoint toLayer:canvas.layer.superlayer];
//            CALayer *theLayer = [canvas.layer hitTest:tapPoint];
            
            if ( CGRectContainsPoint(centerCover, tapPoint)) {
                [self playSelectedSong];
                return;
            }
            
            CGRect previousCover = CGRectMake(200, 200, 160, ORCoverWidth);
//            UIView *center = [[UIView alloc] initWithFrame:previousCover];
//            center.backgroundColor = [UIColor redColor];
//            [canvas addSubview:center];

            if ( CGRectContainsPoint(previousCover, tapPoint)) {
                if (_currentplaylistIndex) {
                    [self handleSwipeRight:nil];
                };
                return;
            }
            
            CGRect nextCover = CGRectMake(80 + (ORCoverWidth * 2), 200, ORCoverWidth, ORCoverWidth);
            if ( CGRectContainsPoint(nextCover, tapPoint)) {
                if (_currentplaylistIndex) {
                    [self handleSwipeLeft:nil];
                };
                return;
            }
            
            
            //fallback to hiding
            [self transitionIntoFloorView];
            break;
            
        case LayoutsFloorView:
            self;
            NSNumber *index = [self playlistIndexForPoint:tapPoint];
            if (index) {
                int i = [index intValue];
                _currentplaylistIndex = i;
                self.currentPlaylist = [self.layers objectAtIndex:_currentplaylistIndex];
                [self hideAllPlaylistsButCurrent];
                [self transitionIntoPlaylistView];
            }
            break;
    }
}

- (void)playSelectedSong { 
    MixtapeAppDelegate * appDelegate = (MixtapeAppDelegate *)[[UIApplication sharedApplication] delegate];
    
    [audio setCurrentPlaylist:[[appDelegate playlists] objectAtIndex:_currentplaylistIndex]];
    [audio playTrackWithIndex:[self currentPlaylistSelectionIndex]];
}

- (NSNumber *)playlistIndexForPoint:(CGPoint) point{
    for (int i = 0; i < [self.centerPoints count]; i++) {
        AlbumRef * album = [self.centerPoints objectAtIndex:i];
        
        CGRect hitRect = CGRectMake(album.point.x, album.point.y, ORCoverWidth * album.scale, ORCoverWidth * album.scale);
        // move it into the position it would be 
        float offset = (ORCoverWidth * album.scale) / -2;
        hitRect = CGRectOffset(hitRect, offset, offset);
        if (CGRectContainsPoint(hitRect, point)) {
            return [NSNumber numberWithInt:i];
        }
    }
    return nil;
    
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
    
    float xOffset = 0;
    
    for (int i = 0; i < [self.currentPlaylist count]; i++) {
        CALayer *layer = [self.currentPlaylist objectAtIndex:i];
                
        layer.position = CGPointMake(xOffset, 0);
        
        if ((i != 0 ) && (i == [self currentPlaylistSelectionIndex]) ) {
            xOffset += 60;
        }

        xOffset += ORCoverWidth + ORSongMargin;

    }
    
    [self moveToCurrentTrack];
    self.state = LayoutsSinglePlaylist;
}


- (void) moveToCurrentTrack {
    int index = [self currentPlaylistSelectionIndex];
    CALayer * wrapper = [self.playlistWrapperLayers objectAtIndex:_currentplaylistIndex];
   
    int offset = 0;
    if ([self currentPlaylistSelectionIndex] > 0) {
        offset = 100;
    }

    wrapper.position = CGPointMake(((index * (ORCoverWidth + ORSongMargin)) + offset - 300) * -1, (canvas.frame.size.height / 2) + ( ORCoverWidth /2) ); 
    
    for (int i = 0; i < [self.currentPlaylist count]; i++) {
        TrackLayer * layer = [self.currentPlaylist objectAtIndex:i];
        
        if(i == index) {
            [layer turnToSelected]; 
        }
        else {
            [layer turnToUnSelected]; 
        }

        [layer repositionWithIndex: i inRelationTo: index];
    } 
}


- (void)transitionIntoFloorView {
    for (int i = 0; i < [self.layers count]; i++) {
        NSMutableArray * playlist = [self.layers objectAtIndex:i];
                
        PlaylistTitleLayer * label = [self.titleLayers objectAtIndex:i];
        [label turnToLabel];
        
        AlbumRef * ref = [self.centerPoints objectAtIndex:i];

        CALayer * wrapperLayer = [self.playlistWrapperLayers objectAtIndex:i];
        CGPoint wrapperLocation = [ref point];
        if ([self isPortrait]) {
            float tempX = wrapperLocation.x;
            wrapperLocation.x = wrapperLocation.y;
            wrapperLocation.y = tempX;
        }
        
        float halfCoverWidth = ORCoverWidth / 2;
        CGPoint location = wrapperLocation;
        location.y += halfCoverWidth + ( 50 * [ref scale]);
        location.x -= ( 50 * [ref scale]);
        label.position = location;

        [wrapperLayer setPosition: wrapperLocation ];
        
        for (int j = [playlist count] - 1; j > -1 ; j--) {
            TrackLayer *layer = [playlist objectAtIndex:j];
            [layer turnToThumbnailWithScale:[ref scale]];
            layer.position = CGPointMake(halfCoverWidth *- 1, halfCoverWidth);
            if (j < 5) layer.opacity = 1;
            else layer.opacity = 0;
        }
    }   
    self.state = LayoutsFloorView;
}

- (void)setCurrentPlaylistSeletionIndex:(int)index {
    [self.playlistSelectionIndexes  replaceObjectAtIndex:_currentplaylistIndex withObject:[NSNumber numberWithInt:index]];  
}

- (int) currentPlaylistSelectionIndex {
    return [[self.playlistSelectionIndexes objectAtIndex:_currentplaylistIndex] intValue];
}

- (BOOL)isPortrait {
    return UIDeviceOrientationIsPortrait([[UIDevice currentDevice] orientation]);
}

- (BOOL)isIPhone {
    return ( [[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone );
}

@end

//
//  MixtapeAppDelegate.h
//  Mixtape
//
//  Created by orta therox on 29/09/2011.
//  Copyright 2011 http://ortatherox.com. All rights reserved.
//

#import <UIKit/UIKit.h>

@class MainViewController, SetupViewController;

@interface MixtapeAppDelegate : UIResponder <UIApplicationDelegate, SPSessionDelegate>

@property (retain, nonatomic) UIWindow *window;
@property (retain, nonatomic) MainViewController *mainViewController;
@property (retain, nonatomic) SetupViewController *setupViewController;
@property (retain, nonatomic) NSMutableArray * playlists;

-(void) startSpotify;
-(void)waitAndFillTrackPool;

@end

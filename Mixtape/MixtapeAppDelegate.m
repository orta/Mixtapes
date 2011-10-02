//
//  MixtapeAppDelegate.m
//  Mixtape
//
//  Created by orta therox on 29/09/2011.
//  Copyright 2011 http://ortatherox.com. All rights reserved.
//

#import "MixtapeAppDelegate.h"
#import "MainViewController.h"
#import "Settings.h"

extern NSString *g_SpotifyUsername;
extern NSString *g_SpotifyPassword;
extern NSString *g_SpotifyFolder;


@implementation MixtapeAppDelegate

@synthesize window = _window;
@synthesize mainViewController = _mainViewController;
@synthesize playlists = _playlists;

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    // Override point for customization after application launch.
  if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone) {
      self.mainViewController = [[MainViewController alloc] initWithNibName:@"MainViewController_iPhone" bundle:nil]; 
  } else {
      self.mainViewController = [[MainViewController alloc] initWithNibName:@"MainViewController_iPad" bundle:nil]; 
  }
  self.window.rootViewController = self.mainViewController;
  [self.window makeKeyAndVisible];
  [self startSpotify];
  return YES;
}

-(void) startSpotify {
    srandom((unsigned int)time(NULL));
    NSLog(@"starting");
    [SPSession initializeSharedSessionWithApplicationKey:[NSData dataWithBytes:&g_appkey length:g_appkey_size]
                                               userAgent:@"com.ortatherox.mixmcshane"
                                                   error:nil];
    [[SPSession sharedSession] setDelegate:self];
    [[SPSession sharedSession] attemptLoginWithUserName:g_SpotifyUsername password:g_SpotifyPassword rememberCredentials:YES];
}

-(void)sessionDidLoginSuccessfully:(SPSession *)aSession; {
  [self waitAndFillTrackPool];
}
-(void)session:(SPSession *)aSession didLogMessage:(NSString *)aMessage; {
  NSLog(@"msg: %@", aMessage);
}


-(void)waitAndFillTrackPool {
	
	// It can take a while for playlists to load, especially on a large account.
  BOOL found = FALSE;
  for (id playlistOrFolder in [[SPSession sharedSession] userPlaylists].playlists) {
    if ([playlistOrFolder isKindOfClass:[SPPlaylistFolder class]]) {
      if ([[playlistOrFolder name] isEqualToString:g_SpotifyFolder]) {
        SPPlaylistFolder * folder = playlistOrFolder;
        self.playlists = folder.playlists;
        [[NSNotificationCenter defaultCenter] postNotificationName:@"PlaylistsSet" object:self];
        found = YES;
      }
    } 
  }
  if (!found) {
    [self performSelector:_cmd withObject:nil afterDelay:1.0];
    return;
  }
}

- (void)applicationWillResignActive:(UIApplication *)application{}

- (void)applicationDidEnterBackground:(UIApplication *)application{}

- (void)applicationWillEnterForeground:(UIApplication *)application{}

- (void)applicationDidBecomeActive:(UIApplication *)application{}

- (void)applicationWillTerminate:(UIApplication *)application{
  [[SPSession sharedSession] logout];
}

@end

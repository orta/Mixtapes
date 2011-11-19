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
#import "LoginViewController.h"
#import "FolderChooserViewController.h"

extern NSString *g_SpotifyUsername;
extern NSString *g_SpotifyPassword;
extern NSString *g_SpotifyFolder;

@interface MixtapeAppDelegate (private)
- (void)showLoginController;
- (void)showFolderController;
@end

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
    
    [SPSession initializeSharedSessionWithApplicationKey:[NSData dataWithBytes:&g_appkey length:g_appkey_size]
                                               userAgent:ORUserAgent
                                                   error:nil];
    
    SPSession * session = [SPSession sharedSession];
    session.delegate = self; 
    NSLog(@"%@ UESR",[session storedCredentialsUserName]);

    if ([session storedCredentialsUserName] == nil) {
        [self showLoginController];
    }else{ 
#warning add error messages
        [session attemptLoginWithStoredCredentials:nil];
    }
}

- (void)session:(SPSession *)aSession didFailToLoginWithError:(NSError *)error {
    [[NSNotificationCenter defaultCenter] postNotificationName: ORLoginFailed
                                                        object: nil];
}

- (void)sessionDidLoginSuccessfully:(SPSession *)aSession; {
    
    SPSession * session = [SPSession sharedSession];

    NSLog(@"%@ UESR",[session storedCredentialsUserName]);

    [self.window.rootViewController dismissModalViewControllerAnimated:NO];
    if ([[NSUserDefaults standardUserDefaults] integerForKey:ORFolderID] != 0) {
        [self waitAndFillTrackPool];        
    }else{
        [self showFolderController];
    }
}

-(void)session:(SPSession *)aSession didLogMessage:(NSString *)aMessage; {
    //    NSLog(@"msg: %@", aMessage);
}

-(void)waitAndFillTrackPool {
	
	// It can take a while for playlists to load, especially on a large account
    BOOL found = FALSE;
    NSNumber * folderIDNumber = [[NSUserDefaults standardUserDefaults] objectForKey:ORFolderID];
    uint64_t folderID = [folderIDNumber unsignedLongLongValue];
    for (id playlistOrFolder in [[SPSession sharedSession] userPlaylists].playlists) {
        if ([playlistOrFolder isKindOfClass:[SPPlaylistFolder class]]) {
            SPPlaylistFolder * folder = playlistOrFolder;
            if (folder.folderId == folderID) {
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

- (void)showLoginController {
    LoginViewController *controller = [[LoginViewController alloc] initWithNibName:@"LoginViewController" bundle:nil];
    controller.modalPresentationStyle = UIModalPresentationFormSheet;
    [self.window.rootViewController presentModalViewController:controller animated:YES];
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:ORFolderID];

}

- (void)showFolderController {
    [[NSNotificationCenter defaultCenter] addObserver:self 
                                             selector:@selector(sessionDidLoginSuccessfully:) 
                                                 name:ORFolderChosen 
                                               object:nil];
    
    FolderChooserViewController *controller = [[FolderChooserViewController alloc] initWithNibName:@"FolderChooserViewController" bundle:nil];
    controller.modalPresentationStyle = UIModalPresentationFormSheet;
    [self.window.rootViewController presentModalViewController:controller animated:NO];
}

- (void)applicationWillResignActive:(UIApplication *)application{}

- (void)applicationDidEnterBackground:(UIApplication *)application{}

- (void)applicationWillEnterForeground:(UIApplication *)application{}

- (void)applicationDidBecomeActive:(UIApplication *)application{}

- (void)applicationWillTerminate:(UIApplication *)application{}

@end

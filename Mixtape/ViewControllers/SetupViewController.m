//
//  SetupViewController.m
//  Mixtape
//
//  Created by orta therox on 10/12/2011.
//  Copyright (c) 2011 http://ortatherox.com. All rights reserved.
//

#import "SetupViewController.h"
#import "SendSongViewController.h"
#import "LoginViewController.h"
#import "FolderChooserViewController.h"

@implementation SetupViewController



- (void)viewDidLoad {
    NSLog(@"ok");
    LoginViewController *controller = [[LoginViewController alloc] initWithNibName:@"LoginViewController" bundle:nil];
    [contentView addSubview:controller.view];
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:ORFolderID];
    [[NSNotificationCenter defaultCenter] addObserver:self 
                                             selector:@selector(showFolderController) 
                                                 name:ORLoggedIn 
                                               object:nil];

}


- (void)showFolderController {
    FolderChooserViewController *controller = [[FolderChooserViewController alloc] initWithNibName:@"FolderChooserViewController" bundle:nil];
    UIView * oldView = [[contentView subviews] objectAtIndex:0];
    [UIView transitionFromView: oldView toView:controller.view duration:0.5 options:UIViewAnimationTransitionFlipFromLeft completion:^(BOOL finished) { }];
    
        
    [[NSNotificationCenter defaultCenter] addObserver:self 
                                             selector:@selector(showSendSongController) 
                                                 name:ORFolderChosen 
                                               object:nil];
}

- (void)showSendSongController {
    SendSongViewController *controller = [[SendSongViewController alloc] initWithNibName:@"SendSongViewController" bundle:nil];    
    UIView * oldView = [[contentView subviews] objectAtIndex:0];
    [UIView transitionFromView: oldView toView:controller.view duration:0.5 options:UIViewAnimationTransitionFlipFromLeft completion:^(BOOL finished) { }];
}

@end

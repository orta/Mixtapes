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
    LoginViewController *loginController = [[LoginViewController alloc] initWithNibName:@"LoginViewController" bundle:nil];
    navController = [[UINavigationController alloc] initWithRootViewController:loginController];
    [contentView addSubview:navController.view];
    navController.view.frame = contentView.bounds;
    [navController setToolbarHidden:YES animated:NO];
    [navController setNavigationBarHidden:YES animated:NO];

    [[NSUserDefaults standardUserDefaults] removeObjectForKey:ORFolderID];
    [[NSNotificationCenter defaultCenter] addObserver:self 
                                             selector:@selector(showFolderController) 
                                                 name:ORLoggedIn 
                                               object:nil];

}


- (void)showFolderController {
    FolderChooserViewController *controller = [[FolderChooserViewController alloc] initWithNibName:@"FolderChooserViewController" bundle:nil];
    [navController pushViewController:controller animated:YES];
    [[NSNotificationCenter defaultCenter] addObserver:self 
                                                 selector:@selector(showSendSongController) 
                                                     name:ORFolderChosen 
                                                   object:nil]; 
}

- (void)showSendSongController {
    SendSongViewController *controller = [[SendSongViewController alloc] initWithNibName:@"SendSongViewController" bundle:nil];    
    [navController pushViewController:controller animated:YES];
}

@end

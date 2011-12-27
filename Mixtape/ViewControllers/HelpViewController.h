//
//  HelpViewController.h
//  Mixtapes
//
//  Created by orta therox on 26/12/2011.
//  Copyright (c) 2011 http://ortatherox.com. All rights reserved.
//

#import <UIKit/UIKit.h>

@class ORButton;

@interface HelpViewController : UIViewController
@property (retain, nonatomic) IBOutlet UIWebView *webView;
@property (retain, nonatomic) IBOutlet ORButton *loginHelpButton;
@property (retain, nonatomic) IBOutlet ORButton *foldersHelpButton;
@property (retain, nonatomic) IBOutlet ORButton *reccomendHelpButton;
@property (retain, nonatomic) IBOutlet ORButton *backHelpButton;

- (IBAction)recommendHelp:(id)sender;
- (IBAction)folderHelp:(id)sender;
- (IBAction)loginHelp:(id)sender;
@end

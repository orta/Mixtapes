//
//  LoginViewController.h
//  Mixtape
//
//  Created by orta therox on 18/11/2011.
//  Copyright (c) 2011 http://ortatherox.com. All rights reserved.
//

#import <UIKit/UIKit.h>

@class ORButton;
@interface LoginViewController : UIViewController

@property (retain, nonatomic) IBOutlet UITextField *usernameTextField;
@property (retain, nonatomic) IBOutlet UITextField *passwordTextField;
@property (retain, nonatomic) IBOutlet UILabel *failureLabel;
@property (retain, nonatomic) IBOutlet ORButton *loginButton;
@property (retain, nonatomic) IBOutlet UIActivityIndicatorView *activityIndicator;

- (IBAction)login:(id)sender;

@end

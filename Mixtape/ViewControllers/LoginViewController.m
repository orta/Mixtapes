//
//  LoginViewController.m
//  Mixtape
//
//  Created by orta therox on 18/11/2011.
//  Copyright (c) 2011 http://ortatherox.com. All rights reserved.
//

#import "LoginViewController.h"

@interface LoginViewController (private) 
- (BOOL)validate;
@end

@implementation LoginViewController
@synthesize usernameTextField, passwordTextField, loginButton, failureLabel, activityIndicator;

- (void)viewDidLoad {
    [super viewDidLoad];
    [usernameTextField becomeFirstResponder];
    failureLabel.text = @"";
    loginButton.enabled = NO;
    [activityIndicator stopAnimating];
    
    //register for text changes
    [usernameTextField addTarget:(id)self action:@selector(textFieldDidChange) forControlEvents:UIControlEventEditingChanged];
    [passwordTextField addTarget:(id)self action:@selector(textFieldDidChange) forControlEvents:UIControlEventEditingChanged];
    
    [[NSNotificationCenter defaultCenter] addObserver:self 
                                             selector:@selector(loginFailed:) 
                                                 name:ORLoginFailed 
                                               object:nil];
}

- (IBAction)login:(id)sender {
    if (![self validate]) {
        return;
    }
    [activityIndicator startAnimating];
    failureLabel.text = @"";
    [[SPSession sharedSession] attemptLoginWithUserName:usernameTextField.text password:passwordTextField.text rememberCredentials:YES];    
}

- (void)loginFailed:(NSNotification*)notification {
    failureLabel.text = [[[notification userInfo] objectForKey:ORNotificationErrorKey] localizedDescription];
    [activityIndicator stopAnimating];
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    if (textField == usernameTextField && ([passwordTextField.text length] < 3)) {
        [passwordTextField becomeFirstResponder];
    }else{
        [self login:self];
    }
    return YES;
}


- (void)textFieldDidChange {
    loginButton.enabled = [self validate];
}

- (BOOL)validate {
    if ([usernameTextField.text length] > 3) {
        if([passwordTextField.text length] > 3){
            return YES;
        }
    }
    return NO;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone) {
        return (interfaceOrientation != UIInterfaceOrientationPortraitUpsideDown);
    } else {
        return YES;
    }
}


@end

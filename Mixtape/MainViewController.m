//
//  MainViewController.m
//  Mixtape
//
//  Created by orta therox on 29/09/2011.
//  Copyright 2011 http://ortatherox.com. All rights reserved.
//

#import "MainViewController.h"
#import "MixtapeAppDelegate.h"
#import <QuartzCore/QuartzCore.h>
#import <ImageIO/ImageIO.h>
#import "LayoutController.h"
#import "AudioController.h"

#define DegreesToRadians(x) (M_PI * x / 180.0)

@implementation MainViewController
@synthesize loadingImage = _loadingImage;
@synthesize loadingBackground = _loadingBackground;

@synthesize canvas = _CACanvasView;
@synthesize flipsidePopoverController = _flipsidePopoverController;
@synthesize layout = _layout, audio = _audio;

- (void)viewDidLoad {
  [super viewDidLoad];
  [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(playlistsReady:)  name:@"PlaylistsSet" object:[[UIApplication sharedApplication] delegate]];
}

- (void)playlistsReady:(id)notification {
  [self removeLoadingNotice];
  [self.audio prepare];
  [self.layout setupAlbumArtwork];
  [self.layout transitionIntoFloorView];
  [self.layout setupGestureReconition];
}

- (NSMutableArray *)currentPlaylist {
  return [self.layout currentPlaylist];
}

- (void)viewDidUnload
{
  [self setLoadingImage:nil];
  [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
}

- (void)viewWillDisappear:(BOOL)animated {
	[super viewWillDisappear:animated];
}

- (void)viewDidDisappear:(BOOL)animated
{
	[super viewDidDisappear:animated];
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

#pragma mark - Flipside View Controller

- (void)flipsideViewControllerDidFinish:(FlipsideViewController *)controller
{
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone) {
        [self dismissModalViewControllerAnimated:YES];
    } else {
        [self.flipsidePopoverController dismissPopoverAnimated:YES];
    }
}

- (IBAction)showInfo:(id)sender
{
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone) {
        FlipsideViewController *controller = [[FlipsideViewController alloc] initWithNibName:@"FlipsideViewController" bundle:nil];
        controller.delegate = self;
        controller.modalTransitionStyle = UIModalTransitionStyleFlipHorizontal;
        [self presentModalViewController:controller animated:YES];
    } else {
        if (!self.flipsidePopoverController) {
            FlipsideViewController *controller = [[FlipsideViewController alloc] initWithNibName:@"FlipsideViewController" bundle:nil];
            controller.delegate = self;
            
            self.flipsidePopoverController = [[UIPopoverController alloc] initWithContentViewController:controller];
        }
        if ([self.flipsidePopoverController isPopoverVisible]) {
            [self.flipsidePopoverController dismissPopoverAnimated:YES];
        } else {
            [self.flipsidePopoverController presentPopoverFromBarButtonItem:sender permittedArrowDirections:UIPopoverArrowDirectionAny animated:YES];
        }
    }
}

-(void) removeLoadingNotice {
    
	[self.loadingImage performSelector:@selector(removeFromSuperview) withObject:nil afterDelay:0.0];
	[self.loadingBackground performSelector:@selector(removeFromSuperview) withObject:nil afterDelay:0.0];
}

- (void)dealloc {
  [_loadingImage release];
  [_CACanvasView release];
  [super dealloc];
}
@end

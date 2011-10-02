//
//  MainViewController.h
//  Mixtape
//
//  Created by orta therox on 29/09/2011.
//  Copyright 2011 http://ortatherox.com. All rights reserved.
//

#import "FlipsideViewController.h"

@class LayoutController, AudioController;

@interface MainViewController : UIViewController <FlipsideViewControllerDelegate> {
  UIImageView *_loadingImage;
  UIImageView *_loadingBackground;
  UIView *_CACanvasView;
  LayoutController *_layout;
}


@property (retain, nonatomic) IBOutlet UIView *canvas;
@property (retain, nonatomic) UIPopoverController *flipsidePopoverController;
@property (retain, nonatomic) IBOutlet UIImageView *loadingImage;
@property (retain, nonatomic) IBOutlet UIImageView *loadingBackground;
@property (retain, nonatomic) IBOutlet  LayoutController *layout;
@property (retain, nonatomic) IBOutlet  AudioController *audio;

- (void)removeLoadingNotice;
- (IBAction)showInfo:(id)sender;
- (NSMutableArray *)currentPlaylist;
@end

//
//  SendSongViewController.h
//  Mixtape
//
//  Created by orta therox on 27/11/2011.
//  Copyright (c) 2011 http://ortatherox.com. All rights reserved.
//

#import <UIKit/UIKit.h>

@class ORButton;

@interface SendSongViewController : UIViewController <UITableViewDataSource, UITableViewDelegate, SPPostTracksToInboxOperationDelegate > {
    NSMutableArray * playlistItems;
    IBOutlet ORButton *skipButton;
    IBOutlet ORButton *helpButton;
}

@property (retain, nonatomic) IBOutlet UITableView *tableView;
- (void) getStarredSongs; 
- (IBAction)skipSongSending:(id)sender;
@end

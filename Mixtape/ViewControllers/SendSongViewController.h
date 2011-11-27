//
//  SendSongViewController.h
//  Mixtape
//
//  Created by orta therox on 27/11/2011.
//  Copyright (c) 2011 http://ortatherox.com. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SendSongViewController : UIViewController <UITableViewDataSource, UITableViewDelegate, SPPostTracksToInboxOperationDelegate > {
    NSMutableArray * playlistItems;
    IBOutlet UIButton * spotifyButton;
    IBOutlet UILabel * sentLabel;
}

@property (retain, nonatomic) IBOutlet UITableView *tableView;
- (void) getStarredSongs; 
@end

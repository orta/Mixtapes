//
//  FolderChooserViewController.h
//  Mixtape
//
//  Created by orta therox on 18/11/2011.
//  Copyright (c) 2011 http://ortatherox.com. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface FolderChooserViewController : UIViewController <UITableViewDataSource, UITableViewDelegate > {
    NSMutableArray * folders;
    IBOutlet UIButton * spotifyButton;
}
@property (retain, nonatomic) IBOutlet UITableView *tableView;
- (IBAction)loadSpotify:(id)sender;


@end

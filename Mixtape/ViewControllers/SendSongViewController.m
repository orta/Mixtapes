//
//  SendSongViewController.m
//  Mixtape
//
//  Created by orta therox on 27/11/2011.
//  Copyright (c) 2011 http://ortatherox.com. All rights reserved.
//

#import "SendSongViewController.h"
#import "ORButton.h"

@implementation SendSongViewController

@synthesize tableView;

- (void)viewDidLoad {
    [super viewDidLoad];
    playlistItems = [[NSMutableArray array] mutableCopy];
    [skipButton setCustomImage:@"bottombarwhite"];
    
    [self getStarredSongs];
}


- (void) getStarredSongs {
    if ([[[SPSession sharedSession] starredPlaylist] isLoaded] == NO) {
        [self performSelector:_cmd withObject:nil afterDelay:0.5];
        return;
    }
    
    for ( SPTrack * track in [[[SPSession sharedSession] starredPlaylist] items]) {
        [playlistItems addObject:track];
    }
    
    if ([playlistItems count] == 0) {
        #warning  deal with them having no starred item
        NSLog(@"UH OH");
    }
    [tableView reloadData];
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [playlistItems count] + 1;
}




- (UITableViewCell *)tableView:(UITableView *)aTableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    UITableViewCell *cell = [aTableView dequeueReusableCellWithIdentifier:ORCellReuseID];
    
    if (indexPath.row == 0) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:ORCellTitleReuseID];
        cell.backgroundView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"from_starred"] ];
        [[cell.backgroundView  superview] bringSubviewToFront:cell.backgroundView];
        cell.textLabel.text = @"";
    }
    else{
        if (cell == nil) {
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:ORCellReuseID];
        }
        SPPlaylistItem * item = [playlistItems objectAtIndex:[playlistItems count] - indexPath.row];
        cell.textLabel.text = [item.item name];
        int index = random() % 4 ;

        cell.imageView.image = [UIImage imageNamed:[NSString stringWithFormat:@"star%i.png", index]];
        
        if (item.itemClass == [SPTrack class]) {
            SPTrack * track = item.item;
            cell.detailTextLabel.text = [track consolidatedArtists];
        }
        
        UIView *viewSelected = [[UIView alloc] init];
        viewSelected.backgroundColor = [UIColor redColor];
        cell.selectedBackgroundView = viewSelected;
    }
    return cell;
    
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    if (indexPath.row == 0 && indexPath.section == 0) {
        return 60;
    }
    return 44;
}

- (IBAction)helpPressed:(id)sender {
    [[NSNotificationCenter defaultCenter] postNotificationName:ORHelpNotification object:nil userInfo: [NSDictionary dictionaryWithObject:[NSNumber numberWithInt:2] forKey:ORHelpNotification]];
}

#pragma mark table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    SPPlaylistItem * item = [playlistItems objectAtIndex:[playlistItems count] - indexPath.row];
    [[SPSession sharedSession] postTracks: [NSArray arrayWithObject: [item item] ] toInboxOfUser:@"ortatherox" withMessage:@"a new song from Mixtape!" delegate:self];
    [[NSNotificationCenter defaultCenter] postNotificationName: ORSongSent object: nil];
}

- (IBAction)skipSongSending:(id)sender {
    [[NSNotificationCenter defaultCenter] postNotificationName: ORSongSent object: nil];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

@end

//
//  FolderChooserViewController.m
//  Mixtape
//
//  Created by orta therox on 18/11/2011.
//  Copyright (c) 2011 http://ortatherox.com. All rights reserved.
//

#import "FolderChooserViewController.h"
#import "ORButton.h"

@interface FolderChooserViewController (private)
- (void)searchForFolders;
@end

@implementation FolderChooserViewController
@synthesize tableView;

- (void)viewDidLoad {
    [super viewDidLoad];
    folders = [[NSMutableArray array] mutableCopy];
    [spotifyButton setCustomImage:@"bottombargreen"];
    [self searchForFolders];
}

- (void)searchForFolders {
    if ([[[SPSession sharedSession] userPlaylists].playlists count] == 0) {
        [self performSelector:_cmd withObject:nil afterDelay:0.5];
        return;
    }
    
    for (id playlistOrFolder in [[SPSession sharedSession] userPlaylists].playlists) {
        if ([playlistOrFolder isKindOfClass:[SPPlaylistFolder class]]) {
            [folders addObject:playlistOrFolder];
        } 
    }
    if ([folders count] == 0) {
        #warning  deal with them having no folders to choose from
        NSLog(@"UH OH");
    }
    [tableView reloadData];
}

- (IBAction)loadSpotify:(id)sender {
    NSURL * url;
    url = [[NSURL alloc] initWithString: @"spotify:" ];

    if( ![[UIApplication sharedApplication] canOpenURL:url] ){
        url = [[NSURL alloc] initWithString: @"itms-apps://itunes.com/apps/spotify"];
    }
    [[UIApplication sharedApplication] openURL: url];        
}

#pragma mark table view data source

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [folders count];
}

- (UITableViewCell *)tableView:(UITableView *)aTableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    UITableViewCell *cell = [aTableView dequeueReusableCellWithIdentifier:ORCellReuseID];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:ORCellReuseID];
    }
    SPPlaylistFolder * folder = [folders objectAtIndex:indexPath.row];
    cell.textLabel.text = folder.name;
    cell.detailTextLabel.text = [NSString stringWithFormat:@"%i playlists", [[folder playlists] count]];

    UIView *viewSelected = [[UIView alloc] init];
    viewSelected.backgroundColor = [UIColor redColor];
    cell.selectedBackgroundView = viewSelected;

    return cell;

}


#pragma mark table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    SPPlaylistFolder * folder = [folders objectAtIndex:indexPath.row];
    [[NSUserDefaults standardUserDefaults] setObject:[NSNumber numberWithUnsignedLongLong:folder.folderId] forKey:ORFolderID];
    [[NSNotificationCenter defaultCenter] postNotificationName: ORFolderChosen
                                                        object: nil];
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

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
- (void)getAllFolderMetadata;
@end

@implementation FolderChooserViewController
@synthesize tableView;

- (void)viewDidLoad {
    [super viewDidLoad];
    folders = [[NSMutableArray array] mutableCopy];
    [helpButton setCustomImage:@"bottombarwhite"];
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

- (void)getAllFolderMetadata {
    
    if ([[[SPSession sharedSession] userPlaylists] isLoaded] == NO) {
        [self performSelector:_cmd withObject:nil afterDelay:0.1];
        return;
    }
    
    SPPlaylistFolder * folder = [folders objectAtIndex:selectedIndex];
    
    // Store the URLs as unique IDs
    NSMutableArray *playlistURLs = [NSMutableArray array];
    for (SPPlaylist *playlist in folder.playlists) {
        if (!playlist.loaded) {
            NSLog(@"reloading and waiting");
            [self performSelector:_cmd withObject:nil afterDelay:0.3];
            return;
        }
        
        NSLog(@"adding %@ - %@", playlist.name, playlist.spotifyURL);
        [playlistURLs addObject:[playlist.spotifyURL absoluteString]];
        
    }
    
    NSNumber *folderID = [NSNumber numberWithUnsignedLongLong:folder.folderId];
    [[NSUserDefaults standardUserDefaults] setObject:folderID forKey:ORFolderID];
    [[NSUserDefaults standardUserDefaults] setObject:playlistURLs forKey:ORPlaylistURLArray];
    [[NSUserDefaults standardUserDefaults] synchronize];
    
    [[NSNotificationCenter defaultCenter] postNotificationName: ORFolderChosen
                                                        object: nil];
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
    selectedIndex = indexPath.row;
    [self getAllFolderMetadata];
}

- (IBAction)helpTapped:(id)sender {
    [[NSNotificationCenter defaultCenter] postNotificationName:ORHelpNotification object:nil userInfo: [NSDictionary dictionaryWithObject:[NSNumber numberWithInt:1] forKey:ORHelpNotification]];
}
- (void)dealloc {
    [helpButton release];
    [super dealloc];
}
- (void)viewDidUnload {
    [helpButton release];
    helpButton = nil;
    [super viewDidUnload];
}
@end

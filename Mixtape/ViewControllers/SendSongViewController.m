//
//  SendSongViewController.m
//  Mixtape
//
//  Created by orta therox on 27/11/2011.
//  Copyright (c) 2011 http://ortatherox.com. All rights reserved.
//

#import "SendSongViewController.h"

@implementation SendSongViewController

@synthesize tableView;

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
    return [playlistItems count];
}

- (UITableViewCell *)tableView:(UITableView *)aTableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    UITableViewCell *cell = [aTableView dequeueReusableCellWithIdentifier:ORCellReuseID];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:ORCellReuseID];
    }
    SPTrack * track = [playlistItems objectAtIndex:indexPath.row];
    cell.textLabel.text = track.name;
    cell.imageView.image = [UIImage imageNamed:@"loading.png"];
//    cell.detailTextLabel.text = [NSString stringWithFormat:@"%i playlists", [[folder playlists] count]];
    return cell;
    
}


#pragma mark table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
//    SPPlaylistFolder * folder = [folders objectAtIndex:indexPath.row];
//    [[NSUserDefaults standardUserDefaults] setObject:[NSNumber numberWithUnsignedLongLong:folder.folderId] forKey:ORFolderID];
//    [[NSNotificationCenter defaultCenter] postNotificationName: ORFolderChosen
//                                                        object: nil];
    
}


- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

@end

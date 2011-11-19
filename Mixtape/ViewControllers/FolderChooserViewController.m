//
//  FolderChooserViewController.m
//  Mixtape
//
//  Created by orta therox on 18/11/2011.
//  Copyright (c) 2011 http://ortatherox.com. All rights reserved.
//

#import "FolderChooserViewController.h"

@implementation FolderChooserViewController
@synthesize tableView;

- (void)viewDidLoad {
    [super viewDidLoad];
    folders = [NSMutableArray array];
    [self searchForFolders];
}

- (void)searchForFolders{
    if ([[SPSession sharedSession] userPlaylists].playlists == nil) {
        [self performSelector:_cmd withObject:nil afterDelay:0.5];
        return;
    }

    for (id playlistOrFolder in [[SPSession sharedSession] userPlaylists].playlists) {
        if ([playlistOrFolder isKindOfClass:[SPPlaylistFolder class]]) {
            [folders addObject:playlistOrFolder];
        } 
    }
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
    
    return cell;

}


#pragma mark table view delegate


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

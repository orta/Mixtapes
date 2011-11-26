//
//  PlaylistPostionGenerator.m
//  Mixtape
//
//  Created by orta therox on 26/11/2011.
//  Copyright (c) 2011 http://ortatherox.com. All rights reserved.
//

#import "PlaylistPostionGenerator.h"
#import "MixtapeAppDelegate.h"
#import "AlbumRef.h"

@implementation PlaylistPostionGenerator

+ (NSArray*)currentCenterPoints {
    // X - Y
    // 1 - (516 - 422)
    // 2 - (300 - 420) - ( 710 -420 )
    // 3 - (295 - 337 ) - 512/506 - 770 -336
    // 4 - 300/324  - 720/334
    // 5 - 250/259 - 765/259 - 508/431  - 250/618 - 759/618
    
    MixtapeAppDelegate * appDelegate = (MixtapeAppDelegate *)[[UIApplication sharedApplication] delegate];
    NSArray *points;
    
    if ( [[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad ){
        
        switch ([appDelegate.playlists count]) {
            case 1:
                points = [NSArray arrayWithObject: [[AlbumRef alloc] refWithX:516 y:422 andScale:1]];
                break;
                
            case 2:
                points = [NSArray arrayWithObjects: 
                          [[AlbumRef alloc] refWithX:300 y:422 andScale:1],
                          [[AlbumRef alloc] refWithX:710 y:422 andScale:1]
                          , nil];
                break;
                
            case 3:
                points = [NSArray arrayWithObjects: 
                          [[AlbumRef alloc] refWithX:295 y:337 andScale:1],
                          [[AlbumRef alloc] refWithX:512 y:506 andScale:1],
                          [[AlbumRef alloc] refWithX:770 y:337 andScale:1]
                          , nil];
                break;
                
            case 4:
                points = [NSArray arrayWithObjects: 
                          [[AlbumRef alloc] refWithX:300 y:324 andScale:1],
                          [[AlbumRef alloc] refWithX:720 y:334 andScale:1],
                          [[AlbumRef alloc] refWithX:720 y:618 andScale:1],
                          [[AlbumRef alloc] refWithX:320 y:618 andScale:1]
                          , nil];
                break;
                
            case 5:
                points = [NSArray arrayWithObjects: 
                          [[AlbumRef alloc] refWithX:250 y:259 andScale:1],
                          [[AlbumRef alloc] refWithX:765 y:259 andScale:1],
                          [[AlbumRef alloc] refWithX:508 y:431 andScale:1],
                          [[AlbumRef alloc] refWithX:250 y:618 andScale:1],
                          [[AlbumRef alloc] refWithX:759 y:618 andScale:1]
                          , nil];
                break;    
        }
        return points;
    }
    return nil;
}

@end

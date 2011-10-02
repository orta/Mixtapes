//
//  PlaylistTitleLayer.h
//  Mixtape
//
//  Created by orta therox on 30/09/2011.
//  Copyright 2011 http://ortatherox.com. All rights reserved.
//

#import <QuartzCore/QuartzCore.h>

@interface PlaylistTitleLayer : CATextLayer
- (id)initWithPlaylist:(SPPlaylist*)playlist;

- (void)turnToLabel;

@end

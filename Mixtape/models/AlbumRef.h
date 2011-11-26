//
//  AlbumRef.h
//  Mixtape
//
//  Created by orta therox on 26/11/2011.
//  Copyright (c) 2011 http://ortatherox.com. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface AlbumRef : NSObject

@property CGPoint point;
@property float scale;

- (id)refWithX: (float)x y:(float)y andScale:(float)aScale;

@end

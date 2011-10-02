//
//  SPPlaylist.m
//  CocoaLibSpotify
//
//  Created by Daniel Kennett on 2/14/11.
/*
Copyright (c) 2011, Spotify AB
All rights reserved.

Redistribution and use in source and binary forms, with or without
modification, are permitted provided that the following conditions are met:
    * Redistributions of source code must retain the above copyright
      notice, this list of conditions and the following disclaimer.
    * Redistributions in binary form must reproduce the above copyright
      notice, this list of conditions and the following disclaimer in the
      documentation and/or other materials provided with the distribution.
    * Neither the name of Spotify AB nor the names of its contributors may 
      be used to endorse or promote products derived from this software 
      without specific prior written permission.

THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND
ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED
WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
DISCLAIMED. IN NO EVENT SHALL SPOTIFY AB BE LIABLE FOR ANY DIRECT, INDIRECT,
INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT 
LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, 
OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF
LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE
OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF
ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
*/

#import "SPPlaylist.h"
#import "SPSession.h"
#import "SPTrack.h"
#import "SPImage.h"
#import "SPUser.h"
#import "SPURLExtensions.h"
#import "SPErrorExtensions.h"

@interface SPPlaylist ()

@property (readwrite, getter=isUpdating) BOOL updating;
@property (readwrite, getter=isLoaded) BOOL loaded;
@property (readwrite) BOOL hasPendingChanges;
@property (readwrite, copy) NSString *playlistDescription;
@property (readwrite, copy) NSURL *spotifyURL;
@property (readwrite, retain) SPImage *image;
@property (readwrite, retain) SPUser *owner;
@property (readwrite) BOOL trackChangesAreFromLibSpotifyCallback;
@property (readwrite, retain) NSMutableArray *trackWrapper;
@property (readwrite, retain) NSArray *subscribers;

-(void)rebuildTracks;
-(void)loadPlaylistData;
-(void)rebuildSubscribers;

-(void)setPlaylistNameFromLibSpotifyUpdate:(NSString *)newName;
-(void)setPlaylistDescriptionFromLibSpotifyUpdate:(NSString *)newDescription;
-(void)setCollaborativeFromLibSpotifyUpdate:(BOOL)collaborative;

@end

#pragma mark Callbacks

// Called when one or more tracks have been added to a playlist
static void tracks_added(sp_playlist *pl, sp_track *const *tracks, int num_tracks, int position, void *userdata) {
    
	SPPlaylist *playlist = userdata;
	
	NSMutableArray *newTracks = [NSMutableArray arrayWithCapacity:num_tracks];
	
	for (NSUInteger currentTrack = 0; currentTrack < num_tracks; currentTrack++) {
		sp_track *thisTrack = tracks[currentTrack];
		if (thisTrack != NULL) {
			[newTracks addObject:[SPTrack trackForTrackStruct:thisTrack inSession:[playlist session]]];
		}
	}
	
	NSIndexSet *incomingIndexes = [NSIndexSet indexSetWithIndexesInRange:NSMakeRange(position, [newTracks count])];
	
	if ([[playlist delegate] respondsToSelector:@selector(playlist:willAddTracks:atIndexes:)]) {
		[[playlist delegate] playlist:playlist willAddTracks:newTracks atIndexes:incomingIndexes];
	}
	
	playlist.trackChangesAreFromLibSpotifyCallback = YES;
	[playlist.tracks insertObjects:newTracks atIndexes:incomingIndexes];
	playlist.trackChangesAreFromLibSpotifyCallback = NO;
	
	if ([[playlist delegate] respondsToSelector:@selector(playlist:didAddTracks:atIndexes:)]) {
		[[playlist delegate] playlist:playlist didAddTracks:newTracks atIndexes:incomingIndexes];
	}
}

// Called when one or more tracks have been removed from a playlist
static void	tracks_removed(sp_playlist *pl, const int *tracks, int num_tracks, void *userdata) {

	SPPlaylist *playlist = userdata;	
	
	NSMutableIndexSet *indexes = [NSMutableIndexSet indexSet];
	
	for (NSUInteger currentIndex = 0; currentIndex < num_tracks; currentIndex++) {
		int thisIndex = tracks[currentIndex];
		[indexes addIndex:thisIndex];
	}
	
	NSArray *outgoingTracks = [playlist.tracks objectsAtIndexes:indexes];
	
	if ([[playlist delegate] respondsToSelector:@selector(playlist:willRemoveTracks:atIndexes:)]) {
		[[playlist delegate] playlist:playlist willRemoveTracks:outgoingTracks atIndexes:indexes];
	}
	
	playlist.trackChangesAreFromLibSpotifyCallback = YES;
	[playlist.tracks removeObjectsAtIndexes:indexes];
	playlist.trackChangesAreFromLibSpotifyCallback = NO;
	
	if ([[playlist delegate] respondsToSelector:@selector(playlist:didRemoveTracks:atIndexes:)]) {
		[[playlist delegate] playlist:playlist didRemoveTracks:outgoingTracks atIndexes:indexes];
	}
}

// Called when one or more tracks have been moved within a playlist
static void	tracks_moved(sp_playlist *pl, const int *tracks, int num_tracks, int new_position, void *userdata) {
    
	SPPlaylist *playlist = userdata;
	
	NSMutableIndexSet *indexes = [NSMutableIndexSet indexSet];
	NSUInteger newStartIndex = new_position;
	
	for (NSUInteger currentIndex = 0; currentIndex < num_tracks; currentIndex++) {
		int thisIndex = tracks[currentIndex];
		[indexes addIndex:thisIndex];
		if (thisIndex < new_position) {
			newStartIndex--;
		}
	}
	
	NSMutableArray *playlistTracks = playlist.tracks;
	NSArray *movedTracks = [playlistTracks objectsAtIndexes:indexes];
	NSMutableIndexSet *newIndexes = [NSMutableIndexSet indexSetWithIndexesInRange:NSMakeRange(newStartIndex, [movedTracks count])];
	
	if ([[playlist delegate] respondsToSelector:@selector(playlist:willMoveTracks:atIndexes:toIndexes:)]) {
		[[playlist delegate] playlist:playlist willMoveTracks:movedTracks atIndexes:indexes toIndexes:newIndexes];
	}
	
	NSMutableArray *newTrackArray = [NSMutableArray arrayWithArray:playlistTracks];
	[newTrackArray removeObjectsAtIndexes:indexes];
	[newTrackArray insertObjects:movedTracks atIndexes:newIndexes];
	
	playlist.trackChangesAreFromLibSpotifyCallback = YES;
	[playlist willChangeValueForKey:@"tracks"];
	playlist.trackWrapper = newTrackArray;
	[playlist didChangeValueForKey:@"tracks"];
	playlist.trackChangesAreFromLibSpotifyCallback = NO;
	
	if ([[playlist delegate] respondsToSelector:@selector(playlist:didMoveTracks:atIndexes:toIndexes:)]) {
		[[playlist delegate] playlist:playlist didMoveTracks:movedTracks atIndexes:indexes toIndexes:newIndexes];
	}
}

// Called when a playlist has been renamed. sp_playlist_name() can be used to find out the new name
static void	playlist_renamed(sp_playlist *pl, void *userdata) {
    NSString *name = [NSString stringWithUTF8String:sp_playlist_name(pl)];
    [(SPPlaylist *)userdata setPlaylistNameFromLibSpotifyUpdate:name];
}

/*
 Called when state changed for a playlist.
 
 There are three states that trigger this callback:
 
 Collaboration for this playlist has been turned on or off
 The playlist started having pending changes, or all pending changes have now been committed
 The playlist started loading, or finished loading
 */
static void	playlist_state_changed(sp_playlist *pl, void *userdata) {
    SPPlaylist *playlist = userdata;
	
    [playlist setLoaded:sp_playlist_is_loaded(pl)];
    [playlist setCollaborativeFromLibSpotifyUpdate:sp_playlist_is_collaborative(pl)];
    [playlist setHasPendingChanges:sp_playlist_has_pending_changes(pl)];
}

// Called when a playlist is updating or is done updating
static void	playlist_update_in_progress(sp_playlist *pl, bool done, void *userdata) {
    SPPlaylist *playlist = userdata;
	
	if (playlist.isUpdating == done && [playlist playlist] == pl)
		playlist.updating = !done;
}

// Called when metadata for one or more tracks in a playlist has been updated.
static void	playlist_metadata_updated(sp_playlist *pl, void *userdata) {
    SPPlaylist *playlist = userdata;
    
    SEL selector = @selector(tracksInPlaylistDidUpdateMetadata:);
    
    if ([[playlist delegate] respondsToSelector:selector]) {
        
        NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
        [[playlist delegate] performSelector:selector
                                  withObject:playlist];
        [pool drain];
    }
    
}

// Called when create time and/or creator for a playlist entry changes
static void	track_created_changed(sp_playlist *pl, int position, sp_user *user, int when, void *userdata) {
    // TODO: Implement this.
}

// Called when seen attribute for a playlist entry changes
static void	track_seen_changed(sp_playlist *pl, int position, bool seen, void *userdata) {
    // TODO: Implement this
}

// Called when playlist description has changed
static void	description_changed(sp_playlist *pl, const char *desc, void *userdata) {
    SPPlaylist *playlist = userdata;
    [playlist setPlaylistDescriptionFromLibSpotifyUpdate:[NSString stringWithUTF8String:desc]];
}

static void	image_changed(sp_playlist *pl, const byte *image, void *userdata) {
    SPPlaylist *playlist = userdata;
    [playlist setImage:[SPImage imageWithImageId:image inSession:[playlist session]]];
}

// Called when message attribute for a playlist entry changes
static void	track_message_changed(sp_playlist *pl, int position, const char *message, void *userdata) {
    // TODO: Implement this
}

// Called when playlist subscribers changes (count or list of names)
static void	subscribers_changed(sp_playlist *pl, void *userdata) {
    SPPlaylist *playlist = userdata;
	[playlist rebuildSubscribers];
}

static sp_playlist_callbacks _playlistCallbacks = {
	&tracks_added,
	&tracks_removed,
	&tracks_moved,
	&playlist_renamed,
	&playlist_state_changed,
	&playlist_update_in_progress,
	&playlist_metadata_updated,
	&track_created_changed,
	&track_seen_changed,
	&description_changed,
    &image_changed,
    &track_message_changed,
    &subscribers_changed
};


#pragma mark -

static NSString * const kSPPlaylistKVOContext = @"kSPPlaylistKVOContext";

@implementation SPPlaylist

+(SPPlaylist *)playlistWithPlaylistStruct:(sp_playlist *)pl inSession:(SPSession *)aSession {
	return [aSession playlistForPlaylistStruct:pl];
}

+(SPPlaylist *)playlistWithPlaylistURL:(NSURL *)playlistURL inSession:(SPSession *)aSession {
	return [aSession playlistForURL:playlistURL];
}

-(id)initWithPlaylistStruct:(sp_playlist *)pl inSession:(SPSession *)aSession {
    
    if ((self = [super init])) {
        session = aSession;
        playlist = pl;
		trackWrapper = [[NSMutableArray alloc] init];

		// Add Observers
        
        [self addObserver:self
               forKeyPath:@"name"
                  options:0
                  context:kSPPlaylistKVOContext];
        
        [self addObserver:self
               forKeyPath:@"playlistDescription"
                  options:0
                  context:kSPPlaylistKVOContext];
        
        [self addObserver:self
               forKeyPath:@"collaborative"
                  options:0
                  context:kSPPlaylistKVOContext];
        
        [self addObserver:self
               forKeyPath:@"loaded"
                  options:NSKeyValueObservingOptionOld
                  context:kSPPlaylistKVOContext];
		
		if (playlist != NULL) {
			sp_playlist_add_ref(pl);
			sp_playlist_add_callbacks(playlist, &_playlistCallbacks, (void *)self);
			sp_playlist_set_in_ram(aSession.session, playlist, true);
			self.loaded = sp_playlist_is_loaded(pl);
		}
        
    }
    return self;
}

-(NSString *)description {
    
    return [NSString stringWithFormat:@"%@: %@ (%d tracks)", [super description], [self name], [[self valueForKey:@"tracks"] count]];
}

@synthesize playlist;
@synthesize updating;
@synthesize playlistDescription;
@synthesize delegate;
@synthesize name;
@synthesize loaded;
@synthesize collaborative;
@synthesize hasPendingChanges;
@synthesize spotifyURL;
@synthesize image;
@synthesize session;
@synthesize owner;
@synthesize trackWrapper;
@synthesize subscribers;

@dynamic tracks;
@synthesize trackChangesAreFromLibSpotifyCallback;

-(void)setMarkedForOfflinePlayback:(BOOL)isMarkedForOfflinePlayback {
	sp_playlist_set_offline_mode(self.session.session, self.playlist, isMarkedForOfflinePlayback);
}

-(BOOL)isMarkedForOfflinePlayback {
	return self.offlineStatus != SP_PLAYLIST_OFFLINE_STATUS_NO;
}

-(sp_playlist_offline_status)offlineStatus {
	return sp_playlist_get_offline_status(self.session.session, self.playlist);
}

-(float)offlineDownloadProgress {
	if (!self.isMarkedForOfflinePlayback)
		return 0.0;
	
	return sp_playlist_get_offline_download_completed(self.session.session, self.playlist) / 100.0f;
}

#pragma mark -
#pragma mark Private Methods

-(void)loadPlaylistData {
	
	if (playlist == NULL)
		return;
    
	sp_link *link = sp_link_create_from_playlist(playlist);
	if (link != NULL) {
		[self setSpotifyURL:[NSURL urlWithSpotifyLink:link]];
		sp_link_release(link);
	}

    const char *nameBuf = sp_playlist_name(playlist);
    
    if (nameBuf != NULL) {
        [self setPlaylistNameFromLibSpotifyUpdate:[NSString stringWithUTF8String:nameBuf]];
    }
    
    const char *desc = sp_playlist_get_description(playlist);
    
    if (desc != NULL) {
        [self setPlaylistDescriptionFromLibSpotifyUpdate:[NSString stringWithUTF8String:desc]];
    }
    
    byte imageId[20];
    if (sp_playlist_get_image(playlist, imageId)) {
        [self setImage:[SPImage imageWithImageId:imageId
                                              inSession:session]];
    }
    
    [self setOwner:[SPUser userWithUserStruct:sp_playlist_owner(playlist) inSession:session]];
    [self setCollaborativeFromLibSpotifyUpdate:sp_playlist_is_collaborative(playlist)];
    [self setHasPendingChanges:sp_playlist_has_pending_changes(playlist)];
    
	[self rebuildTracks];
	sp_playlist_update_subscribers(self.session.session, self.playlist);
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
    
    if (context == kSPPlaylistKVOContext) {
        if ([keyPath isEqualToString:@"name"]) {
            sp_playlist_rename(playlist, [[self name] UTF8String]);
            return;
        } else if ([keyPath isEqualToString:@"collaborative"]) {
            sp_playlist_set_collaborative(playlist, [self isCollaborative]);
            return;
        } else if ([keyPath isEqualToString:@"loaded"]) {
            
			if (self.isLoaded) {
                [self loadPlaylistData];
            }
            
            return;
        }
        
    } 
    [super observeValueForKeyPath:keyPath ofObject:object change:change context:context];
}

-(void)setPlaylistNameFromLibSpotifyUpdate:(NSString *)newName {
    // Remove observers otherwise we'll create an infinite loop!
    [self removeObserver:self forKeyPath:@"name"];
    [self setName:newName];
    [self addObserver:self
           forKeyPath:@"name"
              options:0
              context:kSPPlaylistKVOContext];
}

-(void)setPlaylistDescriptionFromLibSpotifyUpdate:(NSString *)newDescription {
    // Remove observers otherwise we'll create an infinite loop!
    [self removeObserver:self forKeyPath:@"playlistDescription"];
    [self setPlaylistDescription:newDescription];
    [self addObserver:self
           forKeyPath:@"playlistDescription"
              options:0
              context:kSPPlaylistKVOContext];
}

-(void)setCollaborativeFromLibSpotifyUpdate:(BOOL)newCollaborative {
    // Remove observers otherwise we'll create an infinite loop!
    [self removeObserver:self forKeyPath:@"collaborative"];
    [self setCollaborative:newCollaborative];
    [self addObserver:self
           forKeyPath:@"collaborative"
              options:0
              context:kSPPlaylistKVOContext];
}

#pragma mark -

-(void)rebuildSubscribers {
	
	NSUInteger subscriberCount = sp_playlist_num_subscribers(self.playlist);
	
	if (subscriberCount > 0) {
	
		sp_subscribers *subs = sp_playlist_subscribers(self.playlist);
		NSUInteger actualSubscriberCount = subs->count;
		NSMutableArray *newSubscribers = [NSMutableArray arrayWithCapacity:actualSubscriberCount];
		
		for (NSUInteger currentSubscriber = 0; currentSubscriber < actualSubscriberCount; currentSubscriber++) {
			
			char *subscriberName = subs->subscribers[currentSubscriber];
			if (subscriberName != NULL && strlen(subscriberName) > 0) {
				NSString *subsName = [NSString stringWithUTF8String:subscriberName];
				if (subsName != nil)
					[newSubscribers addObject:subsName];
			}
		}
		
		self.subscribers = [NSArray arrayWithArray:newSubscribers];
		sp_playlist_subscribers_free(subs);
		
	} else if (self.subscribers != nil) {
		self.subscribers = nil;
	}	
}

-(void)rebuildTracks {
	
    NSUInteger trackCount = sp_playlist_num_tracks(playlist);
    NSMutableArray *newTracks = [NSMutableArray arrayWithCapacity:trackCount];
    
    NSUInteger currentTrackIndex = 0;
    for (currentTrackIndex = 0; currentTrackIndex < trackCount; currentTrackIndex++) {
        
        sp_track *trackStruct = sp_playlist_track(playlist, (int)currentTrackIndex);
        
        if (trackStruct != NULL) {
            [newTracks addObject:[SPTrack trackForTrackStruct:trackStruct
                                                           inSession:session]];
        }
    }
	
	NSMutableArray *trackContainer = self.tracks;
	if ([newTracks isEqualToArray:trackContainer])
		return;
	
	self.trackChangesAreFromLibSpotifyCallback = YES;
	
	[self willChangeValueForKey:@"tracks"];
	[trackWrapper release];
	trackWrapper = [newTracks mutableCopy];
	[self didChangeValueForKey:@"tracks"];
	
	self.trackChangesAreFromLibSpotifyCallback = NO;
}

-(BOOL)moveTracksAtIndexes:(NSIndexSet *)indexes toIndex:(NSUInteger)newLocation error:(NSError **)error {
	
	int count = (int)[indexes count];
	int indexArray[count];
	
	NSUInteger index = [indexes firstIndex];
	for (NSUInteger i = 0; i < [indexes count]; i++) {
		indexArray[i] = (int)index;
		index = [indexes indexGreaterThanIndex:index];
	}
	
	const int *indexArrayPtr = (const int *)&indexArray;
	sp_error errorCode = sp_playlist_reorder_tracks(playlist, indexArrayPtr, count, (int)newLocation);
	
	if (errorCode != SP_ERROR_OK && error != nil) {
		*error = [NSError spotifyErrorWithCode:errorCode];
	}
	
	return errorCode == SP_ERROR_OK;
}

#pragma mark -

- (NSMethodSignature *)methodSignatureForSelector:(SEL)sel {
	if (sel == @selector(tracks)) {
		return [super methodSignatureForSelector:@selector(mutableArrayValueForKey:)];
	} else {
		return [super methodSignatureForSelector:sel];
	}
}

- (void)forwardInvocation:(NSInvocation *)invocation {
	
	if ([invocation selector] == @selector(tracks)) {
		id value = [self mutableArrayValueForKey:@"tracks"];
		[invocation setReturnValue:&value];
	}
}

-(NSInteger)countOfTracks {
	return [trackWrapper count];
}

-(SPTrack *)objectInTracksAtIndex:(NSInteger)anIndex {
	return [trackWrapper objectAtIndex:anIndex];
}

-(void)insertObject:(SPTrack *)aTrack inTracksAtIndex:(NSInteger)anIndex {
	if (aTrack != nil) {
		if (self.trackChangesAreFromLibSpotifyCallback) {
			[trackWrapper insertObject:aTrack atIndex:anIndex];
		} else {
			sp_track *const track = [aTrack track];
			sp_track *const *trackPointer = &track;
			sp_playlist_add_tracks(playlist, trackPointer, 1, (int)anIndex, [session session]);
		}
	}
}

-(void)removeObjectFromTracksAtIndex:(NSInteger)anIndex {
	if (self.trackChangesAreFromLibSpotifyCallback) {
		[trackWrapper removeObjectAtIndex:anIndex];
	} else {
		int intIndex = (int)anIndex; 
		const int *indexPtr = &intIndex;
		sp_playlist_remove_tracks(playlist, indexPtr, 1);
	}
}

-(void)removeTracksAtIndexes:(NSIndexSet *)indexes {
	if (self.trackChangesAreFromLibSpotifyCallback) {
		[trackWrapper removeObjectsAtIndexes:indexes];
	} else {
		int count = (int)[indexes count];
		int indexArray[count];
		
		NSUInteger index = [indexes firstIndex];
		for (NSUInteger i = 0; i < [indexes count]; i++) {
			indexArray[i] = (int)index;
			index = [indexes indexGreaterThanIndex:index];
		}
		
		const int *indexArrayPtr = (const int *)&indexArray;
		sp_playlist_remove_tracks(playlist, indexArrayPtr, count);
	}
}

-(void)dealloc {
    
    [self removeObserver:self forKeyPath:@"name"];
    [self removeObserver:self forKeyPath:@"playlistDescription"];
    [self removeObserver:self forKeyPath:@"collaborative"];
    [self removeObserver:self forKeyPath:@"loaded"];
    
	
	self.subscribers = nil;
    [self setName:nil];
    [self setPlaylistDescription:nil];
    [self setDelegate:nil];
    [self setOwner:nil];
	[self setTrackWrapper:nil];
    
    session = nil;
    
	if (playlist != NULL) {
		sp_playlist_remove_callbacks(playlist, &_playlistCallbacks, (void *)self);
		sp_playlist_release(playlist);
    }
		
    [super dealloc];
}


@end

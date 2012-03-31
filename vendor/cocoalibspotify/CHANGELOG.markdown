CocoaLibSpotify for libspotify 11, released March 27th 2012
===========================================================

* SPSearch can now search for playlists.

* SPSearch can now do a "live search", appropriate for showing a "live search" menu when the user is typing. See `[SPSearch +liveSearchWithSearchQuery:inSession:]` for details.

* Added `[SPTrack -playableTrack]`. Use this to get the actual track that will be played instead of the receiver if the receiver is unplayable in the user's locale.  Normally, your application does not need to worry about this but the method is here for completeness.

* Added the `topTracks` property to `SPArtistBrowse`. All browse modes fill in this property, and the `tracks` property has been deprecated and will be removed in a future release.

* Added `[SPSession -attemptLoginWithUserName:existingCredential:rememberCredentials:]` and `[<SPSessionDelegate> -session:didGenerateLoginCredentials:forUserName:]`. Every time a user logs in you'll be given a safe credential "blob" to store as you wish (no encryption is required). This blob can be used to log the user in again. Use this if you want to save login details for multiple users.

* Added `[SPSession -flushCaches]`, appropriate for use when iOS applications go into the background. This will ensure libspotify's caches are flushed to disk so saved logins and so on will be saved.

* Added the `audioDeliveryDelegate` property to `SPSession`, which conforms to the `<SPSessionAudioDeliveryDelegate>` protocol, which allows you more freedom in your audio pipeline. The new protocol also uses standard Core Audio types to ease integration.

* Added SPLoginViewController to the iOS library. This view controller provides a Spotify-designed login and signup flow.
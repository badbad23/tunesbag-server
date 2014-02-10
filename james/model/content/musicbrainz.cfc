<!--- //

	Module:		Musicbrainz data
	Description: 
	
// --->

<cfcomponent name="publicinfo" displayname="Public info component"output="false" extends="MachII.framework.Listener" hint="Handle public info items">
	
<cfinclude template="/common/scripts.cfm">

<cffunction name="configure" access="public" output="false" returntype="void" hint="Configures this listener as part of the Mach-II  framework"> 
	<!--- do nothing --->
</cffunction> 

<cffunction access="private" name="ReturnAlbumTracks" output="false" returntype="query" hint="return all tracks of an album">
	<cfargument name="mbAlbumID" type="numeric" required="true">
	
	<cfreturn application.beanFactory.getBean( 'MusicBrainz' ).ReturnAlbumTracks( mbAlbumid = Val( arguments.mbAlbumID ) ) />
	
</cffunction>

<cffunction access="public" name="LoadNextAutoCorrectData" output="false" returntype="void" hint="load data for auto correct query">
	<cfargument name="event" type="MachII.framework.Event" required="true" />
	
	<cfset var q_select_next_unchecked_mediaitem = 0 />
	<cfset var a_struct_check = 0 />
	
	<cfinclude template="queries/mb/q_select_next_unchecked_mediaitem.cfm">
	
	<cfset event.setArg( 'q_select_next_unchecked_mediaitem', q_select_next_unchecked_mediaitem ) />
	
	<cfif q_select_next_unchecked_mediaitem.recordcount IS 0>
		<cfreturn />
	</cfif>
	
	<cfset a_struct_check = application.beanFactory.getBean( 'MusicBrainz' ).getCloseTrackMatchesByPUID( securitycontext = application.udf.GetCurrentSecurityContext(),
			mediaitemkey = q_select_next_unchecked_mediaitem.entrykey ) />

	<cfset event.setArg( 'a_struct_check_data', a_struct_check ) />

</cffunction>

<cffunction access="public" name="getPublicAlbumInformation" output="false" returntype="void" hint="return album information">
	<cfargument name="event" type="MachII.framework.Event" required="true" />
	
	<cfset var a_int_album_id = Val( event.getArg( 'mbAlbumID' )) />
	<cfset var a_search_albums = application.beanFactory.getBean( 'MusicBrainz' ).GetAlbumsByID( albumids = a_int_album_id ) />
	<cfset var q_select_album = a_search_albums.q_select_albums_by_ids />
	
	<!--- select all tracks of this album --->	
	
	<cfset event.setArg( 'q_select_album_tracks', ReturnAlbumTracks( Val(a_int_album_id) ) ) />
	
	<cfset event.setArg( 'q_select_album', q_select_album ) />
	
	<!--- select other alben --->
	<cfset event.setArg( 'q_select_other_alben', GetAlbumsOfArtist( artistid = Val(q_select_album.artist), mbdataonly = true ) ) />
	
	<!--- recent listeners --->
	<cfset event.setArg( 'q_select_recent_listeners', getProperty( 'beanFactory' ).getBean( 'LogComponent' ).getRecentlyPlayedItemsUsers( albumid = Val(q_select_album.id) )) />
	
	<cfset var stArtistInfo = getProperty( 'beanFactory' ).getBean( 'ContentComponent' ).getArtistInformationEx(
			MBartistID 	= Val( q_select_album.artist ),
			artist		= q_select_album.artist_name,
			mbArtistGID = q_select_album.artist_gid,
			datatypes 	= 'events' ) />
			
	<cfset event.setArg( 'stArtistInfo', stArtistInfo ) />

</cffunction>

<cffunction access="public" name="getPublicTrackInformation" output="false" returntype="void" hint="return track information">
	<cfargument name="event" type="MachII.framework.Event" required="true" />
	
	<cfset var iTrackID = event.getArg( 'mbTrackID' ) />
	
	<cfset var q_select_track = application.beanFactory.getBean( 'MusicBrainz' ).getTrackInformation(trackid = iTrackID ) />
	
	<cfset event.setArg( 'q_select_track', q_select_track ) />
	
	<cfif q_select_track.recordcount IS 0>
		<cfreturn />
	</cfif>
	
	<!--- run threads to collect data --->
	<cfthread action="run" name="publicinfo_track_album_#iTrackID#" iAlbumID="#Val(q_select_track.mb_albumid)#">
		<cfset thread.qAlbumTracks = ReturnAlbumTracks( attributes.iAlbumID ) />
	</cfthread>
	
	<cfthread action="run" name="publicinfo_other_albums_#iTrackID#" iArtistID="#val(q_select_track.artist_id)#">
		<cfset thread.qOtherAlbums = GetAlbumsOfArtist( artistid = attributes.iArtistID, mbdataonly = true ) />
	</cfthread>
	
	<cfthread action="run" name="publicinfo_track_plists_#iTrackID#" iTrackID="#val( q_select_track.mb_trackid )#">
		<cfset thread.qPlists = getProperty( 'beanFactory' ).getbean( 'ContentComponent' ).getPlaylistsWithGivenItem( trackid = attributes.iTrackID ) />
	</cfthread>	
	
	<cfthread action="run" name="publicinfo_track_yt_#iTrackID#" qTrack="#q_select_track#">
		<cfset thread.stYTHits = getProperty( 'beanFactory' ).getBean( 'YouTubeComponent' ).searchForYoutubeClipsSimple( search = attributes.qTrack.artist_name &  ' - ' & attributes.qTrack.track_name ) />
	</cfthread>		
	
	<!--- <cfthread action="run" name="publicinfo_track_listeners_#iTrackID#" iTrackID="#val( q_select_track.mb_trackid )#">
		<cfset thread.qListeners = getProperty( 'beanFactory' ).getBean( 'LogComponent' ).getRecentlyPlayedItemsUsers( trackid = attributes.iTrackID ) />
	</cfthread>		
	
	<cfthread action="run" name="publicinfo_track_artistinfo_#iTrackID#" q_select_track="#q_select_track#">
		
		<cfset thread.stArtistInfo = getProperty( 'beanFactory' ).getBean( 'ContentComponent' ).getArtistInformationEx(
			MBartistID 	= attributes.q_select_track.mb_artistid,
			artist		= attributes.q_select_track.artist_name,
			mbArtistGID = attributes.q_select_track.artist_gid,
			datatypes 	= 'events' ) />
				
	</cfthread>	 --->		
	
	<!--- ,publicinfo_track_listeners_#iTrackID#,publicinfo_track_artistinfo_#iTrackID# --->
	<cfthread	action="join"
				name="publicinfo_track_album_#iTrackID#,publicinfo_other_albums_#iTrackID#,publicinfo_track_plists_#iTrackID#,publicinfo_track_yt_#iTrackID#"
				timeout="25000" />
	
	<!--- select all tracks of this album --->	
	<cfset event.setArg( 'q_select_album_tracks', cfThread[ "publicinfo_track_album_#iTrackID#" ].qAlbumTracks ) />
	
	<!--- select other albums --->	
	<cfset event.setArg( 'q_select_other_alben', cfThread[ "publicinfo_other_albums_#iTrackID#" ].qOtherAlbums ) />
	
	<!--- recent listeners --->
	<!--- <cfset event.setArg( 'q_select_recent_listeners', cfThread[ "publicinfo_track_listeners_#iTrackID#" ].qListeners ) /> --->

	<!--- playlists with this track --->
	<cfset event.setArg( 'q_select_playlists', cfThread[ "publicinfo_track_plists_#iTrackID#" ].qPlists ) />
	
	<!--- events --->
	<!--- <cfset event.setArg( 'stArtistInfo', cfThread[ "publicinfo_track_artistinfo_#iTrackID#" ].stArtistInfo ) /> --->
	
	<!--- get yt video --->
	<cfset local.stYT = cfThread[ "publicinfo_track_yt_#iTrackID#" ] />
	
	<cfif StructKeyExists( local.stYT, 'stYTHits')>
		<cfset event.setArg( 'stYTHits', local.stYT.stYTHits ) />
	</cfif>


</cffunction>

<cffunction access="private" name="getAristDataByMBID" output="false" returntype="query"
		hint="return artist information by ID">
	<cfargument name="mbartistid" type="numeric" required="true">
	
	<cfset var a_struct_search = application.beanFactory.getBean( 'MusicBrainz' ).SearchForArtists( artist = '', mbids = 0, gettags = false, maxrows = 1 ) />
	
	<cfreturn a_struct_search.q_select_search_artists />

</cffunction>

<cffunction access="public" name="getPublicArtistInformation" output="false" returntype="void">
	<cfargument name="event" type="MachII.framework.Event" required="true" />
	
	<cfset var a_artist = event.getArg( 'Artist' ) />
	<cfset var a_struct_search = application.beanFactory.getBean( 'MusicBrainz' ).SearchForArtists( artist = a_artist, searchmode = 0, gettags = true, maxrows = 1 ) />
	<cfset var q_select_artist = a_struct_search.q_select_search_artists />
	
	<!--- set data: query, id and gid (string) --->
	<cfset event.setArg( 'q_select_artist', q_select_artist ) />
	<cfset event.setArg( 'mbArtistID', Val( q_select_artist.id ) ) />
	<cfset event.setArg( 'mbArtistGID', q_select_artist.gid ) />
	
	<cfif q_select_artist.recordcount IS 0>
		<cfreturn />
	</cfif>
	
	<!--- get albums of arist --->
	<cfset event.setArg( 'q_select_albums', GetAlbumsOfArtist( artistid = Val(q_select_artist.id), mbdataonly = true ) ) />
	
	<!--- get compilations --->
	<cfset event.setArg( 'q_select_compilations', GetCompilationItemsOfArtist( q_select_artist.id ) ) />
	
	<!--- get recent listerns --->
	<cfset event.setArg( 'q_select_recent_listeners', getProperty( 'beanFactory' ).getBean( 'LogComponent' ).getRecentlyPlayedItemsUsers( artistid = q_select_artist.id )) />

</cffunction>

<cffunction access="private" name="GetAlbumsOfArtist" output="false" returntype="query">
	<cfargument name="artistid" type="numeric" required="true">
	<cfargument name="mbdataonly" type="boolean" default="true" required="false"
		hint="return official musicbrainz data only">
	
	<cfreturn application.beanFactory.getBean( 'MusicBrainz' ).GetAlbumsOfArtist( artistid = arguments.artistid, mbdataonly = arguments.mbdataonly ) />

</cffunction>

<cffunction access="private" name="GetCompilationItemsOfArtist" output="false" returntype="query"
		hint="return compilations with the tracks of this artist">
	<cfargument name="artistid" type="numeric" required="true">
	
	<cfset var q_select_compilations_of_artist = 0 />
	<cfinclude template="queries/q_select_compilations_of_artist.cfm">

	<cfreturn q_select_compilations_of_artist />
	
</cffunction>

<cffunction name="GetArtistInformation" access="public" output="false" returntype="void" hint="Return a certain item">
	<cfargument name="event" type="MachII.framework.Event" required="true" />
	
	<cfset var a_transfer = getProperty( 'beanFactory' ).getBean( 'MBTransfer' ).getTransfer() />
	<cfset var a_cmp_mb = getProperty( 'beanFactory' ).getBean( 'MusicBrainz' ) />
	<!--- artist name --->
	<cfset var a_str_artist = event.getArg('artist') />
	<cfset var a_struct_return = StructNew() />
	<cfset var a_struct_item = StructNew() />
	<cfset var a_artist_id = 0 />
	<cfset var a_struct_artist = 0 />
	
	<cfif Len( a_str_artist ) IS 0>
		<cfreturn />
	</cfif>
	
	<cfset a_struct_artist = a_cmp_mb.GetArtistInformation( artist = a_str_artist, loadalbums = true ) />
	
	<cfif NOT a_struct_artist.result>
		<cfreturn />
	</cfif>
	
	<cfset arguments.event.setArg( 'q_select_artist', a_struct_artist.q_select_artist ) />
	<cfset arguments.event.setArg( 'q_select_albums', a_struct_artist.q_select_albums ) />
	
</cffunction>

</cfcomponent>
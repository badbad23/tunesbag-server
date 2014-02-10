<!--- //

	Module:		lastfm component
	Action:		
	Description:	
	
	Your API Key is 974c3a90ce72420f3ae51b39a1acd3f3 and your secret is c6fb84c66e59e1e499411fff9c224c3a
	
// --->


<cfcomponent output="no">

	<cffunction name="init" access="public" returntype="james.cfc.social.lastfm" output="false">
		<cfset variables.a_str_lastfm_base_url = 'http://ws.audioscrobbler.com/1.0/' />
		<cfset variables.a_str_lastfm_base_url_v2 = 'http://ws.audioscrobbler.com/2.0/' />
		<cfset variables.a_str_lastfm_apikey = application.udf.GetSettingsProperty('lastfm_apikey', '') />
		<cfreturn this />
	</cffunction>
	
	<cffunction access="public" name="getAlbumInformation" output="false" returntype="struct"
			hint="return album information">
		<cfargument name="mbalbumid" type="numeric" default="0" required="false">
		<cfargument name="mbalbumgid" type="string" required="false" default=""
			hint="the musicbrainz album id">
		<cfargument name="lang" type="string" required="false" default="en"
			hint="lang code">
		<cfargument name="update_common_info" type="boolean" required="false" default="false"
			hint="update common info on this album">
		<cfargument name="artist" type="string" required="true" hint="name of artist">
		<cfargument name="album" type="string" required="true" hint="name of album">
			
		<cfset var a_struct_common_album = StructNew() />
		<cfset var ii = 0 />
		<cfset var cfhttp = 0 />
		<cfset var a_str_response = 0 />
		<cfset var a_data = 0 />
		<cfset var a_artwork = 0 />
		<cfset var a_str_url = 0 />
		<cfset var stReturn = application.udf.GenerateReturnStruct() />
		<cfset var oTransfer = application.beanFactory.getBean( 'MBTransfer' ).getTransfer() />
		<cfset var a_db_item = 0 />
		
		<!--- check what has been provided ... --->
		<cfif arguments.mbalbumid GT 0>
		
			<!--- load GID --->
			<cfset a_db_item = oTransfer.readByProperty( 'alben.album', 'id', arguments.mbalbumid ) />
			
			<cfif NOT a_db_item.getisPersisted()>
				<cfreturn application.udf.SetReturnStructErrorCode(stReturn, 999) />
			</cfif>
			
			<!--- use the given GID --->
			<cfset arguments.mbalbumgid = a_db_item.getGID() />
		
		<cfelse>
			
			<!--- load ID --->
			<cfset a_db_item = oTransfer.readByProperty( 'alben.album', 'gid', arguments.mbalbumgid ) />
			
			<cfif NOT a_db_item.getisPersisted()>
				<cfreturn application.udf.SetReturnStructErrorCode(stReturn, 999) />
			</cfif>
			
			<!--- use the given id --->
			<cfset arguments.mbalbumid = a_db_item.getID() />
		
		</cfif>
		
		<!--- invalid --->
		<cfif Len( arguments.mbalbumgid ) IS 0>
			<cfreturn application.udf.SetReturnStructErrorCode(stReturn, 999) />
		</cfif>
		
		<!--- set the URL --->
		<!--- it would be much better to use the mbid but last.fm has so many albums without the mbid ... --->
		<!--- <cfset a_str_url = 'http://ws.audioscrobbler.com/2.0/?method=album.getinfo&mbid=' & UrlEncodedFormat( arguments.mbalbumgid ) & '&api_key=' & UrlEncodedFormat( variables.a_str_lastfm_apikey ) & '&lang=' & arguments.lang & '&format=json' /> --->
		<cfset a_str_url = 'http://ws.audioscrobbler.com/2.0/?method=album.getinfo&artist=' & UrlEncodedFormat( arguments.artist ) & '&album=' & UrlEncodedFormat( arguments.album ) & '&api_key=' & UrlEncodedFormat( variables.a_str_lastfm_apikey ) & '&lang=' & arguments.lang & '&format=json' />
		
		<cftry>			
			<cfhttp method="get" url="#a_str_url#" timeout="15" result="cfhttp"></cfhttp>
			
		<cfcatch type="any">
			<cfreturn application.udf.SetReturnStructErrorCode(stReturn, 999) />
		</cfcatch>
		</cftry>
		
		<!--- create CF object --->
		<cfset a_str_response = Trim( cfhttp.FileContent.toString() ) />
		
		<cftry>
			<cfset a_data = DeserializeJSON( a_str_response ) />
		<cfcatch type="any">
			<!--- invalid JSON --->
			<cfreturn application.udf.SetReturnStructErrorCode(stReturn, 999) />
		</cfcatch>
		</cftry>
		
		<cfset stReturn.data = a_data />
		
		<!--- no information available --->
		<cfif NOT IsStruct( a_data ) OR NOT StructKeyExists( a_data, 'album' )>
			<cfreturn application.udf.SetReturnStructErrorCode(stReturn, 999) />
		</cfif>
		
		<cfif StructKeyExists( a_data.album, 'image')>
			<cfloop from="1" to="#ArrayLen( a_data.album.image )#" index="ii">
				<!--- take the large one --->
				<cfif a_data.album.image[ ii ].size IS 'large'>
					<cfset a_artwork = a_data.album.image[ii]['##text'] />
				</cfif>
				<!--- take the superlarge one --->
				<cfif a_data.album.image[ ii ].size IS 'extralarge' AND Len( a_data.album.image[ii]['##text'] ) GT 0>
					<cfset a_artwork = a_data.album.image[ii]['##text'] />
				</cfif>
			</cfloop>
		</cfif>

		<cfif Len( a_artwork ) GT 0>
			<cfset a_struct_common_album.artwork = a_artwork />
		</cfif>
		
		<!--- store / update common artists --->
		<cfset a_struct_common_album.dt_lastupdate_lastfm = Now() />
		
		<!--- yes or no ... ? --->
		<cfif arguments.update_common_info>
			<cfset application.beanFactory.getBean( 'ContentComponent' ).CheckStoreUpdateCommonAlbumInfo( mbalbumid = arguments.mbalbumid, data = a_struct_common_album ) />
		</cfif>
		
		<cfset stReturn.artwork = a_artwork/>
		
		<cfreturn application.udf.SetReturnStructSuccessCode(stReturn) />

	</cffunction>
	
	<!--- <cffunction access="public" name="getArtistInformation" output="false" returntype="struct"
			hint="return artist information">
		<cfargument name="artist" type="string" required="true"
			hint="artist name">
		<cfargument name="mbartistid" type="numeric" required="true"
			hint="music brainz ID (numeric)">
		<cfargument name="mbartistgid" type="string" required="true"
			hint="music brainz artist GID (string)">
		<cfargument name="lang" type="string" required="false"
			default="en" hint="lang id">
			
		<!--- special treatment --->
		<cfif arguments.lang IS 'zh_cn'>
			<cfset arguments.lang = 'zh' />
		</cfif>			
			
		<cfset var stReturn = application.udf.GenerateReturnStruct() />
		<cfset var a_str_hash_description = 'lastfm_artist_information_' & arguments.artist & arguments.lang />
		<cfset var a_str_item_hash = Hash( a_str_hash_description ) />
		<cfset var a_cmp_cache = application.beanFactory.getBean( 'CacheComponent' ) />
		<cfset var a_struct_cache = a_cmp_cache.CheckAndGetStoredElement( hashvalue = a_str_item_hash ) />
		<cfset var a_str_response = 0 />
		<cfset var a_data = 0 />
		<cfset var a_artistimg = '' />
		<cfset var a_struct_common_artist = StructNew() />
		<cfset var ii = 0 />
		<cfset var cfhttp = 0 />
		
		<cfset var a_str_url = 'http://ws.audioscrobbler.com/2.0/?method=artist.getinfo&mbid=' & UrlEncodedFormat( arguments.mbartistgid ) & '&api_key=' & UrlEncodedFormat( variables.a_str_lastfm_apikey ) & '&lang=' & arguments.lang & '&format=json' />

		<!--- use cache result? --->
		<cfif a_struct_cache.result>
			<cfset stReturn.data = a_struct_cache.data />
			<cfreturn application.udf.SetReturnStructSuccessCode(stReturn) />
		</cfif>
		
		<!--- make the call --->
		<cftry>			
			<cfhttp method="get" url="#a_str_url#" timeout="10" result="cfhttp"></cfhttp>
			
		<cfcatch type="any">
			<cfreturn application.udf.SetReturnStructErrorCode(stReturn, 999) />
		</cfcatch>
		</cftry>
		
		<!--- create CF object --->
		<cfset a_str_response = Trim( cfhttp.FileContent.toString() ) />
		
		<cftry>
		<cfset a_data = DeserializeJSON( a_str_response ) />
		<cfcatch type="any">
			<!--- invalid JSON --->
			<cfreturn application.udf.SetReturnStructErrorCode(stReturn, 999) />
		</cfcatch>
		</cftry>
		
		<cfif NOT StructkeyExists( a_data, 'artist' ) >
			<cfreturn application.udf.SetReturnStructErrorCode(stReturn, 999) />
		</cfif>
		
		<cfset stReturn.data = a_data.artist />
		
		<cfif StructKeyExists( a_data.artist, 'image')>
			<cfloop from="1" to="#ArrayLen( a_data.artist.image )#" index="ii">
				<cfif a_data.artist.image[ ii ].size IS 'large'>
					<cfset a_artistimg = a_data.artist.image[ii]['##text'] />
				</cfif>
				<!--- use the extra large one! --->
				<cfif a_data.artist.image[ ii ].size IS 'extralarge'>
					<cfset a_artistimg = a_data.artist.image[ii]['##text'] />
				</cfif>
			</cfloop>
		</cfif>
		
		<cfif Len( a_artistimg ) GT 0>
			<cfset a_struct_common_artist.artistimg = a_artistimg />
		</cfif>
		
		<!--- store / update common artists --->
		<cfset a_struct_common_artist.dt_lastupdate_lastfm = Now() />
		<cfset application.beanFactory.getBean( 'ContentComponent' ).CheckStoreUpdateCommonArtistInfo( mbartistid = arguments.mbartistid, data = a_struct_common_artist ) />
		
		<!--- store in cache --->
		<cfset a_cmp_cache.StoreCacheElement( hashvalue = a_str_item_hash,
								system = 'lastfm',
								description = a_str_hash_description,
								data = stReturn.data ) />				
		
		<cfreturn application.udf.SetReturnStructSuccessCode(stReturn) />
		
	</cffunction> --->
	
	<cffunction access="public" name="GetSimilarArtistsInformation" output="false" returntype="struct"
			hint="get similar artist information">
		<cfargument name="artist" type="string" required="true">
		<cfargument name="mbartistid" type="numeric" required="true">
		<cfargument name="mbartistgid" type="string" required="true">
		
		<cfset var stReturn = application.udf.GenerateReturnStruct() />
		<cfset var a_data = 0 />
		<cfset var a_str_response = 0 />
		<cfset var a_str_url = 'http://ws.audioscrobbler.com/2.0/?method=artist.getsimilar&artist=' & UrlEncodedFormat( arguments.artist ) & '&api_key=' & UrlEncodedFormat( variables.a_str_lastfm_apikey ) />
		<cfset var a_xml_obj = 0 />
		<cfset var a_arr_artists = 0 />
		<cfset var a_new_item = 0 />
		<cfset var a_int_to = 0 />
		<cfset var a_artist = 0 />
		<cfset var ii = 0 />
		<cfset var a_struct_search_artist = 0 />
		<!--- list existing similar artists --->
		<cfset var oTransfer = application.beanFactory.getBean( 'ExtContentTransfer' ).getTransfer() />
		<cfset var q_select_similar_artists = 0 />
		<cfset var a_artist_match_id = 0 />
		<cfset var a_jj = 0 />
		<cfset var a_artist_img = 0 />
		<cfset var a_struct_data = {} />
		
		<cfif Val(arguments.mbartistid) IS 0>
			<cfreturn application.udf.SetReturnStructErrorCode(stReturn, 999) />
		</cfif>
		
		<cfinclude template="queries/lastfm/q_select_similar_artists.cfm">

		<cfif q_select_similar_artists.recordcount GT 0>
			<cfset stReturn.q_select_similar_artists = q_select_similar_artists />
			<cfreturn application.udf.SetReturnStructSuccessCode(stReturn) />
		</cfif>

		<!--- make the call --->
		<cftry>			
			<cfhttp method="get" url="#a_str_url#" timeout="15"></cfhttp>
			
		<cfcatch type="any">
			<cfreturn application.udf.SetReturnStructErrorCode(stReturn, 999) />
		</cfcatch>
		</cftry>
		
		<!--- invalid --->
		<cfif NOT StructKeyExists( cfhttp, 'filecontent' ) OR NOT IsXML( cfhttp.FileContent )>
			<cfreturn application.udf.SetReturnStructErrorCode(stReturn, 999) />
		</cfif>
		
		<cfset a_xml_obj = XmlParse( cfhttp.FileContent ) />
		
		<!--- get the artist list --->
		<cfset a_arr_artists = XMLSearch( a_xml_obj, '//lfm/similarartists/artist') />
		
		<cfset stReturn.artists = a_arr_artists />

		<cfset a_int_to = ArrayLen( a_arr_artists ) />
		
		<cfif a_int_to GT 20>
			<cfset a_int_to = 20 />
		</cfif>

		<cfloop from="1" to="#a_int_to#" index="ii">
			
			<cfset a_artist = a_arr_artists[ ii ] />
			
			<!--- make sure artists are quite similar --->
			<cfif a_artist.match.xmltext GT 60>
			
				<!--- get artist IDs --->
				<cfset a_struct_search_artist = application.beanFactory.getBean( 'MusicBrainz' ).SearchForArtists( artist = '',
								mbgids = a_artist.mbid.xmltext,
								searchmode = 0,
								maxrows = 1 ) />
				
				<!--- artist found? load corresponding mb ID from GID --->
				<cfif a_struct_search_artist.result AND a_struct_search_artist.Q_SELECT_SEARCH_ARTISTs.recordcount IS 1>
					<cfset a_artist_match_id = a_struct_search_artist.Q_SELECT_SEARCH_ARTISTS.ID />
				
					<cfif Val( a_artist_match_id ) GT 0>
						<cfset a_new_item = oTransfer.new( 'lastfm.lastfm_similar_artists' ) />
						<cfset a_new_item.setmatchpercent( a_artist.match.xmltext ) />
						<cfset a_new_item.setartistsource_mbid( arguments.mbartistid ) />
						<cfset a_new_item.setartistdest_mbid( a_artist_match_id ) />
						<cfset oTransfer.create( a_new_item ) />
					</cfif>
					
				</cfif>
				
				<cfset a_artist_img = '' />
				
				<cfloop from="1" to="#ArrayLen( a_artist.xmlchildren )#" index="a_jj">
			
					<!--- large image found! --->
					<cfif a_artist.xmlchildren[ a_jj ].xmlname IS 'image' AND
					      StructKeyExists( a_artist.xmlchildren[ a_jj ].xmlattributes, 'size') AND
					      (a_artist.xmlchildren[ a_jj ].xmlattributes.size IS 'large')>
						<cfset a_artist_img = a_artist.xmlchildren[ a_jj ].xmltext />
			
					</cfif>
				</cfloop>

				
				<!--- store item in commonartists? --->
				<cfif Len( a_artist_img ) GT 0>
					<cfset StructClear( a_struct_data ) />
					<cfset a_struct_data.artistimg = a_artist_img />
					
					<cfset application.beanFactory.getBean( 'ContentComponent' ).CheckStoreUpdateCommonArtistInfo( mbartistid = a_artist_match_id,
									data = a_struct_data ) />
				</cfif>
			
			</cfif>
			
		</cfloop>
		
		<!--- update common DB information with last update of similar artists etc --->
		<cfset StructClear( a_struct_data ) />
		<cfset a_struct_data.dt_lastupdate_lastfm = Now() />
		<cfset application.beanFactory.getBean( 'ContentComponent' ).CheckStoreUpdateCommonArtistInfo( mbartistid = arguments.mbartistid, data = a_struct_data ) />
		
		<cfinclude template="queries/lastfm/q_select_similar_artists.cfm">
		<cfset stReturn.q_select_similar_artists = q_select_similar_artists />

		<cfreturn application.udf.SetReturnStructSuccessCode(stReturn) />
	</cffunction>
	
	<cffunction access="public" name="GetTagsForMediaItem" output="false" returntype="struct"
			hint="return the tag cloud as query">
		<cfargument name="artist" type="string" required="true">
		<cfargument name="name" type="string" required="false" default="">
		<cfargument name="album" type="string" required="false" default="">
		
		<cfset var stReturn = application.udf.GenerateReturnStruct() />
		<cfset var a_str_item_hash = Hash( 'lastfm_tag_cloud_' & arguments.artist & arguments.album & arguments.name ) />
		<cfset var cfhttp = 0 />
		<cfset var q_select_tags = QueryNew( 'name,weight', 'VarChar,Integer') />
		<cfset var a_str_url = '' />
		<cfset var a_xml_obj = 0 />
		<cfset var a_tags = 0 />
		<cfset var a_str_last_tag = '' />
		<cfset var ii = 0 />
		<cfset var a_str_wddx = 0 />
		<cfset var tmp = 0 />
		<cfset var a_cmp_cache = application.beanFactory.getBean( 'CacheComponent' ) />
		<cfset var a_struct_cache = a_cmp_cache.CheckAndGetStoredElement( hashvalue = a_str_item_hash ) />
		
		<!--- stored in cache? --->
		<cfif a_struct_cache.result>
			<cfset stReturn.q_select_tags = a_struct_cache.data />
			<cfreturn application.udf.SetReturnStructSuccessCode(stReturn) />
		</cfif>
		
		<!--- artist *must* be provided --->
		<cfif Len( arguments.artist ) IS 0>
			<cfreturn application.udf.SetReturnStructErrorCode(stReturn, 999) />
		</cfif>
		
		<!--- three possiblities ...
			a) check for the track
			b) check for the album
			c) check for the artist 
			
			http://ws.audioscrobbler.com/1.0/album/Metallica/Metallica/toptags.xml
		
			http://ws.audioscrobbler.com/1.0/artist/Metallica/toptags.xml
		
			http://ws.audioscrobbler.com/1.0/track/Metallica/Enter%20Sandman/toptags.xml
			--->
			
		<cfif Len( arguments.name ) GT 0>
			<cfset a_str_url = 'http://ws.audioscrobbler.com/1.0/track/' & htmleditformat( arguments.artist ) & '/' & htmleditformat( arguments.name ) & '/toptags.xml' />
		<cfelseif Len( arguments.album ) GT 0>
			<cfset a_str_url = 'http://ws.audioscrobbler.com/1.0/album/' & htmleditformat( arguments.artist ) & '/' & htmleditformat( arguments.album ) & '/toptags.xml' />
		<cfelse>
			<cfset a_str_url = 'http://ws.audioscrobbler.com/1.0/artist/' & htmleditformat( arguments.artist ) & '/toptags.xml' />
		</cfif>
		
		<cftry>
			
			<cfhttp method="get" url="#a_str_url#" timeout="15"></cfhttp>
			
		<cfcatch type="any">
			<cfreturn application.udf.SetReturnStructErrorCode(stReturn, 999) />
		</cfcatch>
		</cftry>
		
		<!--- invalid --->
		<cfif NOT IsXML( cfhttp.FileContent )>
			<cfreturn application.udf.SetReturnStructErrorCode(stReturn, 999) />
		</cfif>

		<cfset a_xml_obj = XmlParse( cfhttp.FileContent ) />
		
		<cfset a_tags = XMLSearch(a_xml_obj, '/toptags/tag/name|/toptags/tag/count') />
	
		<cfloop from="1" to="#ArrayLen(a_tags)#" index="ii">
			
			<cfif CompareNoCase(a_tags[ii].xmlname, 'name') IS 0>
				<cfset a_str_last_tag = a_tags[ii].xmltext />
			<cfelse>
				<cfif Val(a_tags[ii].xmltext) GT 5>
					
					<cfset QueryAddRow( q_select_tags, 1 ) />
					<cfset QuerySetCell( q_select_tags, 'name', a_str_last_tag, q_select_tags.recordcount) />
					<cfset QuerySetCell( q_select_tags, 'weight', Val( a_tags[ii].xmltext ), q_select_tags.recordcount) />
					
				</cfif>
			</cfif>
			
		</cfloop>
	
		<cfquery name="q_select_tags" dbtype="query" maxrows="10">
		SELECT
			*
		FROM
			q_select_tags
		ORDER BY
			weight DESC
		;
		</cfquery>
		
		<!--- store data in cache for later usage --->		
		<cfset tmp = a_cmp_cache.StoreCacheElement( hashvalue = a_str_item_hash,
								system = 'lastfm',
								description = 'lastfm_tag_cloud: ' & a_str_url,
								data = q_select_tags ) />		
	
		<cfset stReturn.q_select_tags = q_select_tags />
	
		<cfreturn application.udf.SetReturnStructSuccessCode(stReturn) />

	</cffunction>
	
	<cffunction access="public" name="getArtistShouts" output="false" returntype="struct"
			hint="return artist shouts ... NOT used because of bad data quality">
		<cfargument name="artist" type="string" required="true"
			hint="artist name">
		<cfargument name="mbartistgid" type="string" required="true"
			hint="music brainz artist GID (string)">
		<cfargument name="lang" type="string" required="false"
			default="en" hint="lang id">
		
		<cfset var stReturn = application.udf.GenerateReturnStruct() />
		<cfset var a_str_response = 0 />
		<cfset var a_data = 0 />
		<cfset var a_str_url = 'http://ws.audioscrobbler.com/2.0/?method=artist.getshouts&artist=' & urlEncodedFormat( arguments.artist ) & '&mbid=' & UrlEncodedFormat( arguments.mbartistgid ) & '&api_key=' & UrlEncodedFormat( variables.a_str_lastfm_apikey ) & '&lang=' & arguments.lang & '&format=json' />

		<cfreturn application.udf.SetReturnStructErrorCode(stReturn, 999) />
		
		<!--- <cfset stReturn.url = a_str_url />
		<!--- make the call --->
		<cftry>			
				<cfhttp method="get" url="#a_str_url#" timeout="20"></cfhttp>
			
		<cfcatch type="any">
			<cfreturn application.udf.SetReturnStructErrorCode(stReturn, 999) />
		</cfcatch>
		</cftry>
		
		<cfset a_str_response = Trim( cfhttp.FileContent.toString() ) />
		<cfset a_data = DeserializeJSON( a_str_response ) />
		
		<cfif NOT StructkeyExists( a_data, 'shouts' ) >
			<cfreturn application.udf.SetReturnStructErrorCode(stReturn, 999) />
		</cfif>		
		
		<cfset stReturn.data = a_data.shouts.shout />
		
		<cfreturn application.udf.SetReturnStructSuccessCode(stReturn) /> --->

	</cffunction>	
	
	<cffunction access="public" name="getSimpleArtistInfo" output="false" returntype="struct"
			hint="return artist information without caching etc">
		<cfargument name="mbartistid" type="numeric" required="true"
			hint="music brainz ID (numeric)">
		<cfargument name="mbartistgid" type="string" required="true"
			hint="music brainz artist GID (string)">
		<cfargument name="lang" type="string" required="false"
			default="en" hint="lang id">
		<cfargument name="bHandleArtistImage" type="boolean" default="false"
			hint="Take the artist image and upload it to S3 for further usage?" />
			
		<!--- special treatment --->
		<cfif arguments.lang IS 'zh_cn'>
			<cfset arguments.lang = 'zh' />
		</cfif>			
			
		<cfset var stReturn = application.udf.GenerateReturnStruct() />
		<cfset var stInfo = StructNew() />
		
		<cfset local.sURL = 'http://ws.audioscrobbler.com/2.0/?method=artist.getinfo&mbid=' & UrlEncodedFormat( arguments.mbartistgid ) & '&api_key=' & UrlEncodedFormat( variables.a_str_lastfm_apikey ) & '&lang=' & arguments.lang & '&format=json' />

		<!--- make the call --->
		<cftry>			
			<cfhttp method="get" url="#local.sURL#" timeout="10" result="local.stHTTP"></cfhttp>
			
		<cfcatch type="any">
			<cfreturn application.udf.SetReturnStructErrorCode(stReturn, 999) />
		</cfcatch>
		</cftry>
		
		<!--- create CF object --->
		<cfset local.stResponse = Trim( local.stHTTP.FileContent.toString() ) />
		
		<cftry>
		<cfset local.stData = DeserializeJSON( local.stResponse ) />
		<cfcatch type="any">
			<!--- invalid JSON --->
			<cfreturn application.udf.SetReturnStructErrorCode(stReturn, 999) />
		</cfcatch>
		</cftry>
		
		<cfif NOT StructkeyExists( local.stData, 'artist' ) >
			<cfreturn application.udf.SetReturnStructErrorCode(stReturn, 999) />
		</cfif>
		
		<!--- <cfset stReturn.data = local.stData.artist /> --->
		
		<cfif StructKeyExists( local.stData.artist, 'image')>
			<cfloop from="1" to="#ArrayLen( local.stData.artist.image )#" index="ii">
				<cfif local.stData.artist.image[ ii ].size IS 'large'>
					<cfset local.sArtistIMG = local.stData.artist.image[ii]['##text'] />
				</cfif>
				<!--- use the extra large one! --->
				<cfif local.stData.artist.image[ ii ].size IS 'extralarge'>
					<cfset local.sArtistIMG = local.stData.artist.image[ii]['##text'] />
				</cfif>
				
				<!--- use the mega one! --->
				<cfif local.stData.artist.image[ ii ].size IS 'mega'>
					<cfset local.sArtistIMG = local.stData.artist.image[ii]['##text'] />
				</cfif>
			</cfloop>
		</cfif>
		
		<cfif Len( local.sArtistIMG  ) GT 0>
			<cfset stInfo.artistimg = local.sArtistIMG />
		</cfif>
		
		<!--- bio --->
		<cfif !IsNull( local.stData.artist.bio.content )>
			<cfset stInfo.bio_en = local.stData.artist.bio.content />
		</cfif>
		
		<!--- tags --->
		<cfif !IsNull( local.stData.artist.tags.tag ) AND IsArray( local.stData.artist.tags.tag )>
			
			<cfset local.aTags = [] />
			
			<cfloop from="1" to="#ArrayLen( local.stData.artist.tags.tag )#" index="local.iTagIndex">
				<cfset ArrayAppend( local.aTags, local.stData.artist.tags.tag[ local.iTagIndex ].name ) />
			</cfloop>
			
			<cfset stInfo.aLastFMTags = local.aTags />
			
		</cfif>
		
		<!--- stats --->
		<cfif !IsNull( local.stData.artist.stats.listeners )>
			<cfset stInfo.lastfm_listeners = local.stData.artist.stats.listeners />
		</cfif>
		
		<cfif !IsNull( local.stData.artist.stats.playcount )>
			<cfset stInfo.lastfm_playcount = local.stData.artist.stats.playcount />
		</cfif>
		
		<!--- store / update common artists --->
		<cfset stInfo.dt_lastupdate_lastfm = Now() />
		
		<!--- store data --->
		<cfset application.beanFactory.getBean( 'ContentComponent' ).CheckStoreUpdateCommonArtistInfo(
			mbartistid 			= arguments.mbartistid,
			data 				= stInfo,
			bHandleArtistImage	= arguments.bHandleArtistImage
			) />
		
		<cfreturn application.udf.SetReturnStructSuccessCode(stReturn) />
		
	</cffunction>
	
</cfcomponent>
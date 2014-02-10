<!---

	API requests

--->

<cfcomponent displayName="Cache" hint="do caching" output="false">
	
	<cfinclude template="/common/scripts.cfm">
	
	<cffunction access="public" name="init" returntype="james.cfc.api.restapi" output="false">
		<cfreturn this />
	</cffunction>
	
	<cffunction access="public" name="GetAllEnabledApplications" returntype="query" output="false"
			hint="return all known apps">
		<cfset var oTransfer = application.beanFactory.getBean( 'UsersTransfer' ).getTransfer() />
		
		<cfreturn oTransfer.list( 'apiapplications.application' ) />

	</cffunction>
	
	<cffunction access="public" name="IssueRemoteKeyForApplication" output="false" returntype="string"
			hint="return the remote key">
		<cfargument name="appkey" type="string" required="true" />
		<cfargument name="securitycontext" type="struct" required="true">
		<cfargument name="source" type="string" default="user" required="false"
			hint="source of adding (maybe auto-add)">
		
		<cfset var oTransfer = application.beanFactory.getBean( 'UsersTransfer' ).getTransfer() />
		<cfset var a_map = { userkey = arguments.securitycontext.entrykey, applicationkey = arguments.appkey } />
		<cfset var a_str_return = Left( CreateUUID(), 8) />
		<cfset var a_item = oTransfer.readByPropertyMap( 'apiapplications.applications_installed', a_map ) />
		
		<cfif a_item.getIsPersisted()>
			<cfset a_str_return = a_item.getremotekey() />
		<cfelse>
			<cfset a_item = oTransfer.new( 'apiapplications.applications_installed' ) />
			<cfset a_item.setEntrykey( CreateUUID() ) />
			<cfset a_item.setUserkey( arguments.securitycontext.entrykey ) />
			<cfset a_item.setdt_created( Now() ) />
			<cfset a_item.setapplicationkey( arguments.appkey ) />
			<cfset a_item.setremotekey( a_str_return ) />
			<cfset a_item.setsource( arguments.source ) />
			
			<cfset oTransfer.save( a_item ) />
		</cfif>
		
		<cfreturn a_str_return />

	</cffunction>
		
	<cffunction access="public" name="getAppByAppkey" returntype="struct" output="false"
			hint="check if this is a valid app key">
		<cfargument name="appkey" type="string" required="true" />
		
		<cfset var stReturn = application.udf.GenerateReturnStruct() />
		
		<cfquery name="local.qSelectApp" datasource="mytunesbutleruserdata" cachedwithin="#application.udf.getQCacheTimeSpan()#">
		SELECT
			appname,
			privileged
		FROM
			applications
		WHERE
			disabled = 0
			AND
			(entrykey = <cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.appkey#" />)
		;
		</cfquery>
				
		<cfset stReturn.qApp = local.qSelectApp />
		
		<!--- hit or not? --->
		<cfif local.qSelectApp.recordcount IS 0>
			<cfreturn application.udf.SetReturnStructErrorCode( stReturn, 20001, 'App not found' ) />
		<cfelse>
			<cfreturn application.udf.SetReturnStructSuccessCode(stReturn) />
		</cfif>
		
	</cffunction>
	
	<cffunction access="public" name="checkUserRemoteKeySecurity" output="false" returntype="boolean"
			hint="check security of login">
		<cfargument name="appkey" type="string" required="true" />
		<cfargument name="username" type="string" required="true">
		<cfargument name="userkey" type="string" required="true" />
		<cfargument name="remotekey" type="string" required="true" />
		<cfargument name="hashpassword" type="string" required="false" default=""
			hint="the MD5 hash of the password - only available to privileges applications">
		
		<cfset var a_bol_return = false />
		<cfset var stApp = getAppByAppkey( arguments.appkey ) />
		<cfset var oTransfer = application.beanFactory.getBean( 'UsersTransfer' ).getTransfer() />
		<cfset var a_struct_map = 0 />
		<cfset var a_item = 0 />
		<cfset var q_select_app_security_username_hashvalue = 0 />
		<cfset var a_bol_privileged_app = (Val( stApp.qApp.Privileged ) IS 1) />
		<cfset var local = {} />
		
		<!--- simple --->
		<cfif Len( arguments.hashpassword ) GT 0 AND a_bol_privileged_app>
			
			<!--- perform simple password (MD5) check --->
			<cfset a_bol_return = application.beanFactory.getBean( 'SecurityComponent' ).CheckLoginData( username = arguments.username,
									password_md5 = arguments.hashpassword ).result />

			<!--- invalid username/password --->									
			<cfif NOT a_bol_return>
				<cfreturn false />
			</cfif>				
			
			<!--- now check if the user has installed this app --->
			<cfset a_struct_map = { userkey = arguments.userkey, applicationkey = arguments.appkey } />
			<cfset a_item = oTransfer.readByPropertyMap( 'apiapplications.applications_installed' , a_struct_map ) />
			
			<cfif NOT a_item.getIsPersisted()>
			
				<!--- auto install this app --->
				<cfset IssueRemoteKeyForApplication( appkey = arguments.appkey,
										securitycontext = application.beanFactory.getBean( 'SecurityComponent' ).GetUserContextByUserkey( arguments.userkey ),
										source = 'autoadd') />
			
			</cfif>
			
			<cfreturn true />
		
		<cfelse>
		
			<cfquery name="local.qCheckremotekey" datasource="mytunesbutleruserdata">
			SELECT
				COUNT(id) AS count_installed
			FROM
				applications_installed
			WHERE
				userkey = <cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.userkey#" />
				AND
				applicationkey = <cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.appkey#" />
				AND
				remotekey = <cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.remotekey#" />
			;
			</cfquery>
			
			<cfreturn Val( local.qCheckremotekey.count_installed ) IS 1 />
					
		</cfif>
		
	</cffunction>
	
	<cffunction access="public" name="GetItems" returntype="struct" output="false"
			hint="check if this is a valid app key">
		<cfargument name="appkey" type="string" required="true" />
		
		<!--- <cfset var oTransfer = application.beanFactory.getBean( 'UsersTransfer' ).getTransfer() />
		<cfset var a_struct_map = { entrykey = arguments.appkey, disabled = 0 } />
		<cfset var a_item = oTransfer.readByPropertyMap( 'apiapplications.application' , a_struct_map ) />

		<cfreturn a_item.getIsPersisted() /> --->
	</cffunction>	
	

	<cffunction access="public" name="CheckSubmittedHashData" returntype="struct" output="false"
			hint="analyze the hash values and say yes or no if the file already exists">
		<cfargument name="userkey" type="string" required="true">
		<cfargument name="filename" type="string" required="true">
		
		<cfset var stReturn = application.udf.GenerateReturnStruct() />
		<cfset var a_cmp_parse = application.beanFactory.getBean( 'RemoteServiceLibraryParser' ) />
		
		<!--- incoming filename ... --->
		<cfset var a_str_dest_dir = application.udf.GetTBTempDirectory() & '/uploader_hash_data/' />
		<cfset var a_str_filename =  a_str_dest_dir & '/lib_hash_' & CreateUUID() & '.incoming.xml' />
		<cfset var a_struct_result_parse = 0 />
		<cfset var q_select_hash_data = 0 />
		
		<cfif NOT DirectoryExists( a_str_dest_dir )>
			<cfdirectory action="create" directory="#a_str_dest_dir#">
		</cfif>
		
		<cffile action="copy" source="#arguments.filename#" destination="#a_str_filename#">
		
		<!--- perform a SAX based parsing of this (maybe huge .XML) --->
		<cfset a_struct_result_parse = a_cmp_parse.ParseHashValueData( filename = a_str_filename, userkey = arguments.userkey ) />
		
		<cfif NOT a_struct_result_parse.result>
			<cfreturn a_struct_result_parse />
		</cfif>
		
		<!--- get parsed data --->
		<cfset q_select_hash_data = a_struct_result_parse.q_select_hash_data />
		
		<!--- check against existing mediaitems now ... --->
		<cfset q_select_hash_data = UploadApplicationCheckHashValuesOfUserLibrary(userkey = arguments.userkey,
				query = q_select_hash_data) />
				
		<cfset stReturn.items = q_select_hash_data />
		
		<cfreturn application.udf.SetReturnStructSuccessCode(stReturn) />
	
	</cffunction>
	
	<!--- internal routine to check if a hash value is known in the system --->
	<cffunction access="private" name="UploadApplicationCheckHashValuesOfUserLibrary" output="false" returntype="query"
		hint="return the list of known hash values (set the statuscode to 200 if the user already has the track, set 204 is the file is available but the user does not have it)">
	<cfargument name="userkey" type="string" required="true"
		hint="entrykey of user">	
	<cfargument name="query" type="query" required="true"
		hint="holding data to check against">
		
		<cfset var a_str_entrykey = CreateUUID() />
		<cfset var q_select_hashvalues_exist = 0 />	
		<cfset var q_select_original_hashvalues_exist = 0 />
		<cfset var a_str_available_list_all_values = '' />
		<cfset var q_select_result = 0 />
		<cfset var a_str_available_list_user_values_original = '' />
		<cfset var a_str_available_list_user_values = '' />
		
		<!--- select the items we already have --->
		<cfinclude template="queries/q_select_hashvalues_exist.cfm">
		
		<!--- Select ALL hash values ... --->
		
		<!--- Select hashvalues of USER only --->
		<!--- select the original file hashvalue --->		
		<cfset a_str_available_list_user_values_original = ValueList( q_select_original_hashvalues_exist.originalfilehashvalue ) />
		<cfset a_str_available_list_user_values = ValueList( q_select_hashvalues_exist.hashvalue ) />
			
		<!--- check the new query against the old one ... --->
		<cfloop query="arguments.query">

			<!--- if we have a hit, set to found ... track itself will not have to be transmitted again ...
					of course we will need the meta data nevertheless --->
					
			<!--- MODIFICATION : RIGHT NOW, RETURN JUST 200 AND 404 ... NO 204 RESPONSE --->
					
			<!--- <cfif ListFindNoCase( a_str_available_list_all_values, arguments.query.hashvalue ) GT 0>
				<cfset QuerySetCell( arguments.query, 'statuscode', 204, arguments.query.currentrow ) />
			</cfif> --->
			
			<!--- does the user already have the track and the meta data? in this case, do NOT send the meta data either, 
					just tell the user the file has been added
					
					check against both lists --->
			<cfif ListFindNoCase( a_str_available_list_user_values_original, arguments.query.hashvalue ) GT 0>
				<cfset QuerySetCell( arguments.query, 'statuscode', 200, arguments.query.currentrow ) />
			</cfif>		
			
			<cfif ListFindNoCase( a_str_available_list_user_values, arguments.query.hashvalue ) GT 0>
				<cfset QuerySetCell( arguments.query, 'statuscode', 200, arguments.query.currentrow ) />
			</cfif>					
				
		
		</cfloop>
		
		<cfset q_select_result = arguments.query />
		
		<cfreturn q_select_result />
</cffunction>	

<cffunction access="private" name="getIPhoneAppSectionForString" output="false" returntype="numeric">
	<cfargument name="input" type="string" required="true">
	
	<cfset var a_s = lcase( Left( Trim( arguments.input ), 1) ) />
	<cfset var a_index = 27 />
	
	<cfif Len( a_s ) IS 0>
		<cfreturn a_index />
	</cfif>
	
	<!--- index is zero based ... subtract 97 --->
	<cfset a_index = asc( a_s ) - 97 />
	
	<!--- if not A-Z, set special char --->
	<cfif a_index LT 0 OR a_index GT 26>
		<cfset a_index = 27 />
	</cfif>
	
	<cfreturn a_index />
	
</cffunction>

<cffunction access="public" name="CreateIPhoneAppDB" output="false" returntype="struct">
	<cfargument name="securitycontext" type="struct" required="true">
	
	<cfset var stReturn = application.udf.GenerateReturnStruct() />
	<cfset var a_sqlite = createObject( 'java', 'org.sqlite.JDBC' ) />
	<cfset var a_prop = createObject( 'java', 'java.util.Properties' ) />
	<cfset var a_conn = 0 />
	<cfset var a_db_filename = application.udf.GetTBTempDirectory() &  'sqlite/' & CreateUUID() & '.sqlite' />
	<cfset var a_res = 0 />
	<cfset var a_statement = 0 />
	<cfset var prep = 0 />
	<cfset var a_playlists = application.beanFactory.getBean( 'PlaylistsComponent' ).GetAllPlayablePlaylistForUser(securitycontext = arguments.securitycontext ) />
	<cfset var q_select_all_accessable_playlists_for_user = a_playlists.q_select_all_accessable_playlists_for_user  />
	<cfset var a_friends = application.beanFactory.getBean( 'SocialComponent' ).GetFriendsList( securitycontext = arguments.securitycontext,	realusers_only = true ) />
	<cfset var q_select_friends = a_friends.q_select_friends />
	<cfset var a_str_access_librarykeys = '' />
	<cfset var a_str_index = '' />
	<cfset var q_select_libraries = 0 />
	<cfset var a_mediaitems = 0 />
	<cfset var q_select_mediaitems = 0 />
	<cfset var q_select_library_items = 0 />
	<cfset var q_select_unique_artists = 0 />
	<cfset var q_select_unique_albums = 0 />
	<cfset var a_unique_id = 0 />
	<cfset var a_struct_unique_artists = {} />
	<cfset var a_struct_unique_albums = {} />
	<cfset var a_int_artist_id = 0 />
	<cfset var a_int_artist_counter = 0 />
	<cfset var a_int_album_counter = 0 />
	<cfset var a_int_track_counter = 0 />
	<cfset var a_struct_unique_artist_album = {} />
	<cfset var a_content = 0 />
	
	<cfif NOT DirectoryExists( getDirectoryFromPath( a_db_filename) )>
		<cfdirectory directory="#getDirectoryFromPath( a_db_filename )#" action="create">
	</cfif>
	
	<cfset a_conn = a_sqlite.connect( 'jdbc:sqlite:' & a_db_filename, a_prop.init() ) />
	<cfset a_statement = a_conn.createStatement() />

	<!--- specific settings --->
	<!--- <cfset a_res = a_statement.execute( 'PRAGMA encoding = "UTF-8"; PRAGMA auto_vacuum = 0;PRAGMA journal_mode = OFF;PRAGMA temp_store = MEMORY;PRAGMA synchronous=OFF;') /> --->
	
	<!--- start transaction --->
	<cfset a_res = a_statement.execute( 'BEGIN;') />
	
	<!--- libraries --->
	<cfset a_res = a_statement.execute( 'CREATE TABLE libraries (libraryId INTEGER PRIMARY KEY, librarykey TEXT, lastkey TEXT);') />
	<cfset a_res = a_statement.execute( 'CREATE INDEX librariesIndex ON libraries ( librarykey );') />

	<!--- artists --->
	<cfset a_res = a_statement.execute( 'CREATE TABLE artists (artistId INTEGER PRIMARY KEY, artist TEXT, section INTEGER, libraryId INTEGER, UNIQUE (artist, libraryId));') />
	<cfset a_res = a_statement.execute( 'CREATE INDEX artistsIndex1 ON artists ( libraryId, section ); CREATE INDEX artistsIndex2 ON artists ( libraryId, section, artist); CREATE INDEX artistsIndex3 ON artists ( artistId, artist);') />

	<!--- album --->
	<cfset a_res = a_statement.execute( 'CREATE TABLE albums(albumId INTEGER PRIMARY KEY, album TEXT,section INTEGER,libraryId INTEGER,UNIQUE (album, libraryId));') />
	<cfset a_res = a_statement.execute( 'CREATE INDEX albumsIndex1 ON albums ( libraryId, section ); CREATE INDEX albumsIndex2 ON albums ( libraryId, section, album); CREATE INDEX albumsIndex3 ON albums ( albumId, section ); CREATE INDEX albumsIndex4 ON albums ( albumId, section, album); CREATE INDEX albumsIndex5 ON albums ( album, libraryId); ') />	
	
	<!--- artist/album relation ---><!---  --->
	<cfset a_res = a_statement.execute( 'CREATE TABLE artistAlbumRelations(artistId INTEGER, albumId INTEGER , UNIQUE (artistId, albumId));') />
	<cfset a_res = a_statement.execute( 'CREATE INDEX artistAlbumRelationsIndex1 ON artistAlbumRelations ( albumId, artistId );') />	
	
	<!--- tracks --->
	<cfset a_res = a_statement.execute( 'CREATE TABLE tracks(trackId INTEGER PRIMARY KEY,name TEXT,section INTEGER,libraryId INTEGER,entrykey TEXT, tracknumber INTEGER,rating INTEGER,totaltime INTEGER,UNIQUE (libraryId, entrykey));') />
	<cfset a_res = a_statement.execute( 'CREATE INDEX tracksIndex1 ON tracks ( libraryId, section ); CREATE INDEX tracksIndex2 ON tracks ( libraryId, section, name ); CREATE INDEX tracksIndex3 ON tracks ( trackId, name ); CREATE INDEX tracksIndex4 ON tracks ( trackId, tracknumber ); CREATE INDEX tracksIndex5 ON tracks ( entrykey );') />
	
	<!--- artist/album/tracks --->
	<cfset a_res = a_statement.execute( 'CREATE TABLE artistAlbumTrackRelations(artistId INTEGER,albumId INTEGER,trackId INTEGER,UNIQUE (artistId, albumId,trackId));') />	
	<cfset a_res = a_statement.execute( 'CREATE INDEX artistAlbumTrackRelationsIndex1 ON artistAlbumTrackRelations ( trackId, artistId, albumId );') />	
	
	<!--- playlists --->
	<cfset a_res = a_statement.execute( 'CREATE TABLE playlists(entrykey TEXT PRIMARY KEY,name TEXT,description TEXT,tags TEXT,items TEXT, userkey TEXT,librarykey TEXT,itemscount INTEGER,publiclist INTEGER,smartlist INTEGER);') />	
	<cfset a_res = a_statement.execute( 'CREATE INDEX playlistsIndex1 ON playlists ( userkey );CREATE INDEX playlistsIndex2 ON playlists ( userkey, name );') />	
	
	<!--- users --->
	<cfset a_res = a_statement.execute( 'CREATE TABLE users (entrykey TEXT,displayname TEXT,firstname TEXT,surname TEXT,aboutme TEXT,friendkey TEXT,librarykey TEXT,accesslibrary INTEGER);') />	
	<cfset a_res = a_statement.execute( 'CREATE INDEX userIndex1 ON users ( entrykey ); CREATE INDEX userIndex2 ON users ( accesslibrary, surname );') />	
	
	<!--- recommendations --->
	<cfset a_res = a_statement.execute( 'CREATE TABLE recommendation (entrykey TEXT, recipient_type TEXT,recipient TEXT, viewed TEXT,mediaitemkey TEXT,mediaitemtype TEXT,dt_Created DATE);') />	
	<cfset a_res = a_statement.execute( 'CREATE INDEX mediaitemkeyIndex ON recommendation ( mediaitemkey );') />	
	
	<!--- feed --->
	<cfset a_res = a_statement.execute( 'CREATE TABLE feed (entrykey TEXT, mediaitemkey TEXT, userkey TEXT, dt_Created DATE);') />

	<!--- load friends ... --->
	<cfset prep = a_conn.prepareStatement( 'INSERT INTO users (entrykey,displayname,firstname,surname,aboutme,friendkey,librarykey,accesslibrary) VALUES (?, ?, ?, ?, ?, ?, ?, ?);' ) />
	
	<cfloop query="q_select_friends">
		<cfset prep.setString( 1, q_select_friends.entrykey ) />
		<cfset prep.setString( 2, q_select_friends.displayname ) />
		<cfset prep.setString( 3, q_select_friends.firstname ) />
		<cfset prep.setString( 4, q_select_friends.surname ) />
		<cfset prep.setString( 5, q_select_friends.about_me ) />
		<cfset prep.setString( 6, q_select_friends.otheruserkey ) />
		<cfset prep.setString( 7, q_select_friends.librarykey ) />
		<cfset prep.setInt( 8, q_select_friends.accesslibrary ) />
	
		<cfset prep.addBatch() />
	
	</cfloop>
	
	<cfset prep.executeBatch() />
	
	<!--- libraries --->
	<cfset prep = a_conn.prepareStatement( 'INSERT INTO libraries (libraryId,librarykey,lastkey) VALUES (?, ?, ?);' ) />

	<!--- own user --->
	<cfset a_str_access_librarykeys = arguments.securitycontext.defaultlibrarykey />
	
	<cfloop query="q_select_friends">
	
		<cfif q_select_friends.accesslibrary IS 1>
			<cfset a_str_access_librarykeys = ListAppend( a_str_access_librarykeys, q_select_friends.librarykey ) />
		</cfif>
		
	</cfloop>
	
	<!--- select lastkeys for the given libraries --->
	<cfset q_select_libraries = application.beanFactory.getBean( 'MediaItemsComponent' ).GetLibrariesLastKeys( a_str_access_librarykeys ) />
	
	<cfloop query="q_select_libraries">
		<cfset prep.setInt( 1, q_select_libraries.currentrow ) />
		<cfset prep.setString( 2, q_select_libraries.librarykey) />
		<cfset prep.setString( 3, q_select_libraries.lastkey ) />
		<cfset prep.addBatch() />
	</cfloop>
	
	<cfset prep.executeBatch() />
	
	<!--- main data --->	
	<cfset a_mediaitems = application.beanFactory.getBean( 'MediaItemsComponent' ).GetUserContentData(securitycontext = arguments.securitycontext,
										librarykeys = a_str_access_librarykeys,
										type = 'mediaitems') />
										
	<cfset q_select_mediaitems = a_mediaitems.q_select_items />
	
	<!--- loop over libraries --->
	<cfloop query="q_select_libraries">
		
		<!--- reset collector --->
		<cfset a_struct_unique_artists = {} />
		<cfset a_struct_unique_albums = {} />
		<cfset a_struct_unique_artist_album = {} />
		
		<!--- select single library items --->
		<cfquery name="q_select_library_items" dbtype="query">
		SELECT
			*,
			0 AS trackid
		FROM
			q_select_mediaitems
		WHERE
			librarykey = <cfqueryparam cfsqltype="cf_sql_varchar" value="#q_select_libraries.librarykey#">
		;
		</cfquery>
		
		<cfif q_select_library_items.recordcount GT 0>
			
			<!--- select unique artists --->
			<cfquery name="q_select_unique_artists" dbtype="query">
			SELECT
				DISTINCT( UPPER( artist ) )
			FROM
				q_select_library_items
			;
			</cfquery>
			
			<cfset prep = a_conn.prepareStatement( 'INSERT INTO artists (artistId,artist,section,libraryId) VALUES (?, ?, ?, ?);' ) />
			
			<cfloop query="q_select_unique_artists">
				
				<cfset a_int_artist_counter = a_int_artist_counter  + 1 />
			
				<!--- set data --->
				<cfset prep.setInt( 1, a_int_artist_counter ) />
				<cfset prep.setString( 2, q_select_unique_artists.artist ) />
				<cfset prep.setInt( 3, getIPhoneAppSectionForString( q_select_unique_artists.artist ) ) />
				<cfset prep.setInt( 4, q_select_libraries.currentrow ) />
			
				<cfset prep.addBatch() />
				
				<!--- set the unique ID --->
				<cfset a_struct_unique_artists[ q_select_unique_artists.artist ] = a_int_artist_counter />
			
			</cfloop>
			
			<cfset prep.executeBatch() />
			
			<!--- continue with alben --->
			<cfquery name="q_select_unique_albums" dbtype="query">
			SELECT
				DISTINCT( UPPER( album ))
			FROM
				q_select_library_items
			WHERE
				NOT album = ''
			;
			</cfquery>
			
			
		 	<cfset prep = a_conn.prepareStatement( 'INSERT INTO albums (albumId,album,section,libraryId) VALUES (?, ?, ?, ?);' ) />
			
			<!--- loop over unique albums --->
			<cfloop query="q_select_unique_albums">
				
				<cfset a_int_album_counter = a_int_album_counter + 1 />
				
				<!--- set data --->
				<cfset prep.setInt( 1, a_int_album_counter ) />
				<cfset prep.setString( 2, q_select_unique_albums.album ) />
				<cfset prep.setInt( 3, getIPhoneAppSectionForString( q_select_unique_albums.album ) ) />
				<cfset prep.setInt( 4, q_select_libraries.currentrow ) />
			
				<cfset prep.addBatch() />
				
				<!--- add to unique items --->
				<cfset a_struct_unique_albums[ q_select_unique_albums.album ] = a_int_album_counter />
			
			</cfloop>
			
			<cfset prep.executeBatch() />
			
			<!--- insert artist/album relation --->
			<cfset prep = a_conn.prepareStatement( 'INSERT INTO artistAlbumRelations (artistId,albumId) VALUES (?, ?);' ) />
			
			<!--- loop over all items--->
			<cfloop query="q_select_library_items">
				
				<!--- check if valid items ... --->
				<cfif Len( q_select_library_items.album ) GT 0 AND Len( q_select_library_items.artist ) GT 0>
				
					<cfset a_unique_id = a_struct_unique_artists[ q_select_library_items.artist ] & a_struct_unique_albums[ q_select_library_items.album ] />
					
					<!--- if this combination does not exist yet ... --->
					<cfif NOT StructKeyExists( a_struct_unique_artist_album, a_unique_id )>
					
						<!--- HIT! set this combination as done! --->
						<cfset a_struct_unique_artist_album[ a_unique_id ] = 1 />
						
						<cfset prep.setInt( 1, a_struct_unique_artists[ q_select_library_items.artist ] ) />
						<cfset prep.setInt( 2, a_struct_unique_albums[ q_select_library_items.album ] ) />
						
						<cfset prep.addBatch() />
						
					</cfif>
				</cfif>
				
			</cfloop>
		
			<cftry>
				<cfset prep.executeBatch() />
				<cfcatch type="any">
				<cfthrow message="123">
				
			</cfcatch>
			</cftry>
			
		</cfif>
		
		<!--- tracks! --->
		<cfset prep = a_conn.prepareStatement( 'INSERT INTO tracks (trackId,name,section,libraryId,entrykey,tracknumber,rating,totaltime) VALUES (?, ?, ?, ?, ?, ?, ?, ?);' ) />
		
		<cfloop query="q_select_library_items">
		
			<cfset a_int_track_counter = a_int_track_counter + 1 />
			
			<cfset prep.setInt( 1, a_int_track_counter ) />
			<cfset prep.setString( 2, q_select_library_items.name ) />
			<cfset prep.setInt( 3, getIPhoneAppSectionForString( q_select_library_items.name ) ) />
			<cfset prep.setInt( 4, q_select_libraries.currentrow ) />
			<cfset prep.setString( 5, q_select_library_items.entrykey ) />
			<cfset prep.setInt( 6, q_select_library_items.tracknumber ) />
			<cfset prep.setInt( 7, val(q_select_library_items.rating) ) />
			<cfset prep.setInt( 8, val(q_select_library_items.totaltime) ) />
			
			<cfset prep.addBatch() />
			
			<cfset querySetCell( q_select_library_items, 'trackid', a_int_track_counter, q_select_library_items.currentrow ) />
		</cfloop>
		
		<!--- insert! --->
		<cftry>
		<cfset prep.executeBatch() />
		
		<cfcatch type="any">
			<cfset stReturn.e = q_select_library_items.entrykey />
			<cfset stReturn.q_select_library_items = q_select_library_items />
		</cfcatch>
		</cftry>
		
		<!--- artist / album / track relations --->
		<cfset prep = a_conn.prepareStatement( 'INSERT INTO artistAlbumTrackRelations (artistId,albumId,trackId) VALUES (?, ?, ?);' ) />
		
		<!--- take the unique values and fill the table --->
		<cfloop query="q_select_library_items">
			
			<cfset prep.setInt( 1, a_struct_unique_artists[ q_select_library_items.artist ] ) />
			<cfset prep.setInt( 2, a_struct_unique_artists[ q_select_library_items.artist ] ) />
			<cfset prep.setInt( 3, q_select_library_items.trackid ) />		
		
		</cfloop>
		
		<cfset prep.executeBatch() />
		
	</cfloop>

	<!--- fill plist table --->
	<cfset prep = a_conn.prepareStatement( 'INSERT INTO playlists (entrykey,name,description,tags,items,userkey,librarykey,itemscount,publiclist,smartlist) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?);' ) />

	<cfloop query="q_select_all_accessable_playlists_for_user">
		
		<cfset prep.setString( 1, q_select_all_accessable_playlists_for_user.entrykey ) />
		<cfset prep.setString( 2, q_select_all_accessable_playlists_for_user.name ) />
		<cfset prep.setString( 3, q_select_all_accessable_playlists_for_user.description ) />
		<cfset prep.setString( 4, q_select_all_accessable_playlists_for_user.tags ) />
		<cfset prep.setString( 5, q_select_all_accessable_playlists_for_user.items ) />
		<cfset prep.setString( 6, q_select_all_accessable_playlists_for_user.userkey ) />
		<cfset prep.setString( 7, q_select_all_accessable_playlists_for_user.librarykey ) />
		<cfset prep.setInt( 8, q_select_all_accessable_playlists_for_user.itemcount ) />
		<cfset prep.setInt( 9, q_select_all_accessable_playlists_for_user.public ) />
		<cfset prep.setInt( 10, q_select_all_accessable_playlists_for_user.dynamic ) />
	
		<cfset prep.addBatch() />
	
	</cfloop>
	
	<cfset prep.executeBatch() />
	
	<!--- COMMIT! --->
	<cfset a_res = a_statement.executeUpdate( 'END;') />
	
	<!--- close connection --->
	<cfset a_conn.close() />
	<cfset a_conn = 0 />
	<cfset a_sqlite = 0 />
	
	<!--- return the filename --->
	<cfset stReturn.filename = a_db_filename />
	
	<!--- return result --->
	<cfreturn application.udf.SetReturnStructSuccessCode(stReturn) />

</cffunction>
	
</cfcomponent>
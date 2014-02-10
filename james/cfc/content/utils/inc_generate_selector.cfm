<!---

	Create the selector for certain data types

--->


<cfswitch expression="#arguments.type#">
	
	<cfcase value="library">
		
		<!--- select by library --->
		<cfsavecontent variable="a_str_content">
			
			<cfset a_str_own_librarykey = arguments.securitycontext.defaultlibrarykey />
			
			<cfset q_select_friends = application.beanFactory.getBean( 'SocialComponent' ).GetFriendsList( securitycontext = arguments.securitycontext,
											filter_accesslibrary_only = true,
											realusers_only = true ).q_select_friends />

			<cfoutput><a href="##" onclick="DoRequest('list', { 'librarykey' :  '#JsStringFormat( a_str_own_librarykey )#' ,'genre' : '_all', 'artist' : '_all', 'album' : '_all'});return false;">#application.udf.si_img( 'lock' )# #application.udf.GetLangValSec( 'cm_ph_my_music' )#</a></cfoutput>
			
			<cfoutput query="q_select_friends">
				&nbsp;&nbsp;
				<a href="##" onclick="DoRequest('list', { 'librarykey' :  '#JsStringFormat( q_select_friends.librarykey )#' ,'genre' : '_all', 'artist' : '_all', 'album' : '_all'});return false;">#application.udf.si_img( 'user' )# #htmleditformat( q_select_friends.displayname )#</a>
			
			</cfoutput>
			
		</cfsavecontent>
		
		
	</cfcase>
	
	<cfcase value="genre">
	
		<!--- genres --->
		<cfquery name="q_select_distinct_genres" datasource="mytunesbutleruserdata">
		SELECT
			mediaitems.genre, COUNT(genre) AS genre_count
		FROM
			mediaitems
		WHERE
			mediaitems.librarykey IN (<cfqueryparam cfsqltype="cf_sql_varchar" value="#a_str_possible_librarykeys#" list="true">)
			
			<cfif Len( arguments.librarykeys ) GT 0>
				AND
					(mediaitems.librarykey IN (<cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.librarykeys#" list="true">))
			</cfif>
			
		GROUP BY
			mediaitems.genre
		HAVING COUNT(mediaitems.genre)>=1
		ORDER BY
			mediaitems.genre,
			genre_count DESC,
			mediaitems.genre
		;
		</cfquery>
		
		<cfsavecontent variable="a_str_content">
			
			<!--- show all genres again --->
			<cfoutput>
				<a href="##" onclick="SetCurrentlySelectedDataDisplayText( 'genre', '' );DoRequest('list', { 'type': 'music', 'librarykey': '#JsStringFormat( arguments.librarykeys )#' ,'genre': '_all', 'artist' : '_all', 'album' :'_all' });return false;">#application.udf.GetLangValSec( 'cm_ph_show_all_items' )#</a>
			</cfoutput>
			
		<cfoutput query="q_select_distinct_genres">
			
			<cfset a_int_size = q_select_distinct_genres.genre_count / 1.5 />
			
			<cfif a_int_size LT 11>
				<cfset a_int_size = '' />
			<cfelseif a_int_size GT 18>
				<cfset a_int_size = 18 />
			</cfif>
			
			<a href="##" <cfif Len( a_int_size ) GT 0>style="font-size:#a_int_size#px"</cfif>
				onclick="SetCurrentlySelectedDataDisplayText( 'genre', $(this).text() );DoRequest('list', { 'type': 'music', 'librarykey' : '#JsStringFormat( arguments.librarykeys )#',  'genre': '#UrlEncodedFormat( q_select_distinct_genres.genre )#', 'artist' : '_all', 'album' :'_all' });return false;">#htmleditformat( application.udf.CheckZeroString( q_select_distinct_genres.genre ) )#</a>
				&nbsp;&nbsp;&nbsp;
		</cfoutput>		
	
		</cfsavecontent>
	
	</cfcase>
	<cfcase value="artist">
		
		<!--- display artist selector --->
		<cfquery name="q_select_distinct_artists" datasource="mytunesbutleruserdata">
		SELECT
			mediaitems.artist,
			COUNT(mediaitems.artist) AS artist_count
		FROM
			mediaitems
		WHERE
			mediaitems.librarykey IN (<cfqueryparam cfsqltype="cf_sql_varchar" value="#a_str_possible_librarykeys#" list="true">)
			
		<cfif Len( arguments.librarykeys ) GT 0>
			AND
				(mediaitems.librarykey IN (<cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.librarykeys#" list="true">))
		</cfif>
			
		<cfif arguments.genres NEQ '_all'>
			
			AND
			<!--- select by genre? --->
			mediaitems.genre IN (<cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.genres#" list="true">)
			
		</cfif>
		
		GROUP BY
			mediaitems.artist
		HAVING COUNT(mediaitems.artist)>=1
		ORDER BY
			mediaitems.artist
			/*artist_count DESC			*/
		;
		</cfquery>
		
		<cfsavecontent variable="a_str_content">
			
			<div style="color:white;"><cfoutput>#application.udf.GetLangValSec( 'cm_wd_items' )#: #q_select_distinct_artists.recordcount#</cfoutput>
			
			<a href="#" onclick="DoRequest('list', { 'type' : 'music', 'genre' : '<cfoutput>#JsStringFormat( arguments.genres )#</cfoutput>', 'artist' : '_all', 'album' : '_all'});SetCurrentlySelectedDataDisplayText( 'artist', '' );return false;"><cfoutput>#application.udf.GetLangValSec( 'cm_ph_show_all_items' )#</cfoutput></a></div>
			
			<cfif q_select_distinct_artists.recordcount LTE 50>
				<!--- make the list --->
				
				<cfoutput query="q_select_distinct_artists">
					<div class="div_album_box"
						onclick="SetCurrentlySelectedDataDisplayText( 'artist', $(this).text() );DoRequest('list', { 'type' : 'music', 'genre' : '#JsStringFormat( arguments.genres )#', 'artist' : '#JsStringFormat( q_select_distinct_artists.artist )#', 'album' : '_all'});return false;" style="background-image:URL('#application.udf.getArtistImageByID( q_select_distinct_artists.artist, 120 )#')">
						<span>#htmleditformat( q_select_distinct_artists.artist )#</span>
					</div>
				</cfoutput>		
				
			<cfelse>
			
				<cfset a_int_half = Round( q_select_distinct_artists.recordcount / 4 ) />
				<cfset a_str_first_char = '' />
				
				<!--- <div style="margin-top:10px">
					
					<cfoutput query="q_select_distinct_artists">
					
						<cfset a_int_counter = q_select_distinct_artists.currentrow />

						<cfif CompareNoCase( a_str_first_char, Left( q_select_distinct_artists.artist, 1 )) IS -1>
							<cfset a_str_first_char = Left( q_select_distinct_artists.artist, 1 ) />
							
							<a href="##" onclick="$('.artist_selector_az > li').hide();$('.artist_selector_az > li a[title=a]').parent().show();return false;" class="b_all" style="padding:2px;margin-right:2px">#a_str_first_char#</a>
							
						</cfif>
					
					</cfoutput>
					
				</div> --->
				
				<cfset a_str_first_char = '' />				

				<table cellpadding="6" cellspacing="0" border="0">
					<tr>
						<td valign="top" width="25%" style="padding:6px;">
							<ul class="ul_nopoints artist_selector_az">
						<cfoutput query="q_select_distinct_artists">
							
							<cfset a_int_counter = q_select_distinct_artists.currentrow />

							<cfif CompareNoCase( a_str_first_char, Left( q_select_distinct_artists.artist, 1 )) IS -1>
								<cfset a_str_first_char = Left( q_select_distinct_artists.artist, 1 ) />
								
								<h4 class="bb" style="margin-bottom:6px">#a_str_first_char#</h4>
							</cfif>
							
							<li>
							<a title="#htmleditformat( a_str_first_char )#" href="##" onclick="SetCurrentlySelectedDataDisplayText( 'artist', $(this).text() );DoRequest('list', { 'type' : 'music', 'genre': '#JsStringFormat( arguments.genres )#', 'artist' : '#JsStringFormat( q_select_distinct_artists.artist )#', 'album' : '_all'} );return false;">#htmleditformat( q_select_distinct_artists.artist )#</a>
							</li>
							
							<!--- start next column --->
							<cfif a_int_counter IS a_int_half OR (a_int_counter IS a_int_half*2) OR (a_int_counter IS a_int_half*3)>
									</ul>
								</td>
								<td valign="top" width="25%" style="padding:6px;">
									<ul class="ul_nopoints artist_selector_az">
							</cfif>
						</cfoutput>
						</td>
					</tr>
				</table>
				
			</cfif>
			
		</cfsavecontent>
		
	</cfcase>
	<cfcase value="album">
		
			<!--- select albums --->
			
			<!--- this statement kills the mysql server --->
			<cfquery name="q_select_distinct_albums" datasource="mytunesbutleruserdata">
			SELECT
				mediaitems.album,
				mediaitems.artist
			FROM
				mediaitems
			WHERE	
				mediaitems.librarykey IN (<cfqueryparam cfsqltype="cf_sql_varchar" value="#a_str_possible_librarykeys#" list="true">)
				
			<cfif Len( arguments.librarykeys ) GT 0>
				AND
					(mediaitems.librarykey IN (<cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.librarykeys#" list="true">))
			</cfif>
				
			<cfif arguments.genres NEQ '_all'>
				AND
					<!--- select by genre? --->
					(
						mediaitems.genre IN (<cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.genres#" list="true">)
					)
			</cfif>
			
			<cfif arguments.artists NEQ '_all'>
				AND
					<!--- select by genre? --->
					(
						mediaitems.artist IN (<cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.artists#" list="true">)
					)
			</cfif>
			
			GROUP BY
				mediaitems.album
			HAVING COUNT(mediaitems.album)>=1
			ORDER BY
				mediaitems.album
			LIMIT
				500
			;
			</cfquery>
			
		<cfsavecontent variable="a_str_content">
			
			<div style="color:white;"><cfoutput>#application.udf.GetLangValSec( 'cm_wd_items' )# :#q_select_distinct_albums.recordcount#</cfoutput> /
			
			<a href="##" onclick="SetCurrentlySelectedDataDisplayText( 'album', '_all' );DoRequest('list', { 'type': 'music' ,'genre': '<cfoutput>#JsStringFormat( arguments.genres )#</cfoutput>', 'artist' : '<cfoutput>#JsStringFormat( arguments.artists )#</cfoutput>', 'album' :'_all' });return false;"><cfoutput>#application.udf.GetLangValSec( 'cm_ph_show_all_items' )#</cfoutput></a></div>
			
				<!--- make the list ... output max 100 albums ... --->
				
				<cfoutput query="q_select_distinct_albums">
					
					<div class="div_album_box" onclick="SetCurrentlySelectedDataDisplayText( 'album', '#JsStringFormat( q_select_distinct_albums.album )#' );DoRequest('list', { 'type' : 'music', 'genre': '#JsStringFormat( arguments.genres )#', 'artist' : '#JsStringFormat( arguments.artists )#', 'album' : '#JsStringFormat( q_select_distinct_albums.album )#'} );return false;" style="background-image:URL('/res/images/albums/#urlEncodedFormat( q_select_distinct_albums.artist )#/#urlEncodedFormat( q_select_distinct_albums.album)#.jpg');">
					<span>#htmleditformat( q_select_distinct_albums.album )# (#htmleditformat( q_select_distinct_albums.artist )#)</span>
					</div>
				</cfoutput>		
				
			
		</cfsavecontent>
	
	</cfcase>
	<cfcase value="rating">
	
	</cfcase>
	<cfcase value="tags">
		
		<cfsavecontent variable="a_str_content">
		
			<!--- build the cloud with the tags defined by the user --->
		
		</cfsavecontent>
		
	</cfcase>
</cfswitch>
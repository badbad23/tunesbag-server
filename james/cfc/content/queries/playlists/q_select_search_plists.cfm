<cfquery name="q_select_search_plists" datasource="mytunesbutleruserdata" cachedwithin="#CreateTimeSpan( 0, 0, 5, 0 )#">
SELECT
	playlists.entrykey,
	playlists.name,
	playlists.description,
	playlists.dt_created,
	playlists.itemscount,
	playlists.username,
	playlists.hits,
	playlists.totaltime,
	playlists.userkey,
	playlists.tags,
	playlists.avgrating,	
	playlists.imageset,
	playlists.licence_type_image,
	playlists.licence_image_link,
	<!--- GROUP_CONCAT(DISTINCT mediaitems.artist ) AS artists,
	GROUP_CONCAT(DISTINCT mediaitems.name ) AS track_names --->
	'' AS artists,
	'' AS track_names,
	users.privacy_playlists
FROM
	playlists
LEFT JOIN
	users ON (users.entrykey = playlists.userkey)
WHERE
	/* no temporary lists */
	playlists.istemporary = 0
	AND		
		(
			/* own plist ... check options if we should search for them at all */
			
		<cfif ListFindNoCase( arguments.options, 'IGNORE_OWN_PLISTS' ) IS 0>
			(playlists.userkey = <cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.securitycontext.entrykey#">)
			
			OR
		<cfelse>
			NOT (playlists.userkey = <cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.securitycontext.entrykey#">)
			
			AND
		</cfif>
			
			/* public plist, not dynamic and with items */
			(
				playlists.public = 1	
				AND
				playlists.dynamic = 0
				AND
				playlists.itemscount >= 2
			)
			AND
				/* user has public playlists enabled OR user is a friend */
				(
					/* everybody is allowed to access this playlist */
					(users.privacy_playlists = 0)
					
					<cfif Len( a_friends_access_lib_keys ) GT 0>
						OR
						/* or this user is a friend of the requesting user ... */
						(playlists.librarykey IN (<cfqueryparam cfsqltype="cf_sql_varchar" value="#a_friends_access_lib_keys#" list="true">))
					</cfif>
				
				)
		)
	AND
	(
	
		<!--- perform a search? --->
		<cfif Len( arguments.search ) GT 0>
			(MATCH (playlists.name, playlists.tags, playlists.description) AGAINST (<cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.search#">))
		<cfelse>
			(1=1)
		</cfif>
		
		<cfif IsQuery( q_select_search_plists_artists ) AND q_select_search_plists_artists.recordcount GT 0>
			OR
			/* ----- compare against plists with this artist */
			(playlists.entrykey IN (<cfqueryparam cfsqltype="cf_sql_varchar" value="#ValueList( q_select_search_plists_artists.playlistkey )#" list="true">))
		</cfif>

		<cfif IsQuery( q_select_search_plists_tracks ) AND q_select_search_plists_tracks.recordcount GT 0>
		OR
		/* compare against plists with this track */
		(playlists.entrykey IN (<cfqueryparam cfsqltype="cf_sql_varchar" value="#ValueList( q_select_search_plists_tracks.playlistkey )#" list="true">))
		</cfif>				
		
	)
	
	<!--- various other filter --->
	<cfif StructKeyExists( arguments.filter, 'dt_lastmodified_gt' ) AND IsDate( arguments.filter.dt_lastmodified_gt )>
	AND
		(
		playlists.dt_lastmodified > <cfqueryparam cfsqltype="cf_sql_timestamp" value="#arguments.filter.dt_lastmodified_gt#">
		)
	</cfif>
	
GROUP BY
	playlists.entrykey
ORDER BY
	playlists.hits DESC,
	playlists.avgrating DESC,
	playlists.name
LIMIT
	20
;
</cfquery>
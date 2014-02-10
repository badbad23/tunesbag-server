<cfsetting requesttimeout="300">

<cfloop from="0" to="2" index="ii">
	<cfset GenerateStatForDate( DateAdd( 'd', -ii, Now() ) ) />
</cfloop>

<cffunction access="private" name="GenerateStatForDate" returntype="void" output="false">
	<cfargument name="date" type="date" required="true">
	
	<cfset var a_date = arguments.date />
	
	<cfquery name="q_select_new_users" datasource="mytunesbutleruserdata">
	SELECT
		COUNT(id) AS count_users
	FROM
		users
	WHERE
		date( dt_created ) = <cfqueryparam cfsqltype="cf_sql_date" value="#a_date#">
	</cfquery>
	
	<cfset InsertPerformanceData( 'registrations', a_date, q_select_new_users.count_users ) />
	
	<cfquery name="q_select_new_users_fb" datasource="mytunesbutleruserdata">
	SELECT
		COUNT(id) AS count_users
	FROM
		users
	WHERE
		date( dt_created ) = <cfqueryparam cfsqltype="cf_sql_date" value="#a_date#">
		AND
		source = 'facebook'
	;
	</cfquery>
	
	<cfset InsertPerformanceData( 'registrations_fb', a_date, q_select_new_users_fb.count_users ) />
	
	<cfquery name="q_avg_tracks_per_user" datasource="mytunesbutleruserdata">
	SELECT
		AVG( libraryitemscount ) AS avg_libraryitemscount
	FROM
		users
	WHERE
		date( dt_created ) = <cfqueryparam cfsqltype="cf_sql_date" value="#a_date#">
	;
	</cfquery>
	
	<cfset InsertPerformanceData( 'avg_library_count', a_date, val( q_avg_tracks_per_user.avg_libraryitemscount ) ) />
	
	<cfquery name="q_added_tunes" datasource="mytunesbutleruserdata">
	SELECT
		COUNT(id) AS count_items
	FROM
		mediaitems
	WHERE
		date( dt_created ) = <cfqueryparam cfsqltype="cf_sql_date" value="#a_date#">
		AND NOT
		source = 'prefill'
	;
	</cfquery>
	
	<cfset InsertPerformanceData( 'added_tunes', a_date, q_added_tunes.count_items ) />	
	
	<cfquery name="q_added_tunes_high_matchlevel" datasource="mytunesbutleruserdata">
	SELECT
		COUNT(id) AS count_items
	FROM
		mediaitems
	WHERE
		date( dt_created ) = <cfqueryparam cfsqltype="cf_sql_date" value="#a_date#">
		AND
		mb_matchlevel >= 80
		AND NOT
		source = 'prefill'
	;
	</cfquery>
	
	<cfset InsertPerformanceData( 'added_tunes_high_matchlevel', a_date, q_added_tunes_high_matchlevel.count_items ) />		
	
	<cfquery name="q_select_userlogins" datasource="mytunesbutlerlogging">
	SELECT
		COUNT(id) AS count_logins
	FROM
		userlogins
	WHERE
		date( dt_created ) = <cfqueryparam cfsqltype="cf_sql_date" value="#a_date#">
	;
	</cfquery>
	
	<cfset InsertPerformanceData( 'logins', a_date, q_select_userlogins.count_logins ) />
	
	<cfquery name="q_select_new_playlists" datasource="mytunesbutleruserdata">
	SELECT
		COUNT(id) AS count_plist
	FROM
		playlists
	WHERE
		date( dt_created ) = <cfqueryparam cfsqltype="cf_sql_date" value="#a_date#">
	;
	</cfquery>
	
	<cfset InsertPerformanceData( 'newplists', a_date, q_select_new_playlists.count_plist ) />	
	
	<cfquery name="q_select_new_ratings" datasource="mytunesbutleruserdata">
	SELECT
		COUNT(id) AS count_ratings
	FROM
		ratings
	WHERE
		date( dt_created ) = <cfqueryparam cfsqltype="cf_sql_date" value="#a_date#">
	;
	</cfquery>
	
	<cfset InsertPerformanceData( 'newratings', a_date, q_select_new_ratings.count_ratings ) />	
	
	<cfquery name="q_select_plist_items_added" datasource="mytunesbutleruserdata">
	SELECT
		COUNT(id) AS count_items
	FROM
		playlist_items
	WHERE
		date( dt_added ) = <cfqueryparam cfsqltype="cf_sql_date" value="#a_date#">
	;
	</cfquery>
	
	<cfset InsertPerformanceData( 'plistitemsadded', a_date, q_select_plist_items_added.count_items ) />	
	
	<cfquery name="q_select_new_comments" datasource="mytunesbutleruserdata">
	SELECT
		COUNT(id) AS count_comments
	FROM
		comments
	WHERE
		date( dt_created ) = <cfqueryparam cfsqltype="cf_sql_date" value="#a_date#">
	;
	</cfquery>
	
	<cfset InsertPerformanceData( 'newcomments', a_date, q_select_new_comments.count_comments ) />	
	
	<cfquery name="q_select_shared_items" datasource="mytunesbutleruserdata">
	SELECT
		COUNT(id) AS count_shared
	FROM
		shareditems
	WHERE
		date( dt_created ) = <cfqueryparam cfsqltype="cf_sql_date" value="#a_date#">
	;
	</cfquery>
	
	<cfset InsertPerformanceData( 'shareditems', a_date, q_select_shared_items.count_shared ) />				
	
	<cfquery name="q_select_new_lastfm" datasource="mytunesbutleruserdata">
	SELECT
		COUNT(id) AS count_lastfm
	FROM
		3rdparty_ids
	WHERE
		servicename = 'lastfm'
		AND
		date( dt_created ) = <cfqueryparam cfsqltype="cf_sql_date" value="#a_date#">
	;
	</cfquery>
	
	<cfset InsertPerformanceData( 'newservice_lastfm', a_date, q_select_new_lastfm.count_lastfm ) />		
	
	<cfquery name="q_select_invitations" datasource="mytunesbutleruserdata">
	SELECT
		COUNT(id) AS count_invitations
	FROM
		invitations
	WHERE
		date( dt_created ) = <cfqueryparam cfsqltype="cf_sql_date" value="#a_date#">
	;
	</cfquery>
	
	<cfset InsertPerformanceData( 'invitations_sent', a_date, q_select_invitations.count_invitations ) />		
	
	<cfquery name="q_select_playeditems" datasource="mytunesbutlerlogging">
	SELECT
		COUNT(id) AS count_played_items
	FROM
		playeditems
	WHERE
		date( dt_created ) = <cfqueryparam cfsqltype="cf_sql_date" value="#a_date#">
	;
	</cfquery>
	
	<cfset InsertPerformanceData( 'playeditems', a_date, q_select_playeditems.count_played_items ) />
	
	<cfquery name="q_select_playeditems" datasource="mytunesbutlerlogging">
	SELECT
		COUNT(id) AS count_played_items
	FROM
		playeditems
	WHERE
		date( dt_created ) = <cfqueryparam cfsqltype="cf_sql_date" value="#a_date#">
		AND
		secondsplayed > 30
	;
	</cfquery>
	
	<cfset InsertPerformanceData( 'playeditems_over30sec', a_date, q_select_playeditems.count_played_items ) />	
	
	<cfquery name="q_select_playeditems" datasource="mytunesbutlerlogging">
	SELECT
		COUNT(id) AS count_played_items
	FROM
		playeditems
	WHERE
		date( dt_created ) = <cfqueryparam cfsqltype="cf_sql_date" value="#a_date#">
		AND
		preview = 1
	;
	</cfquery>
	
	<cfset InsertPerformanceData( 'playeditems_preview', a_date, q_select_playeditems.count_played_items ) />	
	
	<!--- <cfquery name="q_select_playeditems" datasource="mytunesbutlerlogging">
	SELECT
		COUNT(id) AS count_played_items
	FROM
		playeditems
	WHERE
		date( dt_created ) = <cfqueryparam cfsqltype="cf_sql_date" value="#a_date#">
		AND
		userkey = (		
		SELECT mediaitems.userkey FROM mytunesbutleruserdata.mediaitems AS mediaitems WHERE mediaitems.entrykey = playeditems.mediaitemkey
		)
	;
	</cfquery>
	
	<cfset InsertPerformanceData( 'playeditems_own', a_date, q_select_playeditems.count_played_items ) /> --->
	
	<cfquery name="q_select_playeditems" datasource="mytunesbutlerlogging">
	SELECT
		COUNT(playeditems.id) AS count_played_items
	FROM
		playeditems
	LEFT JOIN
		mytunesbutleruserdata.mediaitems AS mediaitems ON (mediaitems.entrykey = playeditems.mediaitemkey)
	WHERE
		date( playeditems.dt_created ) = <cfqueryparam cfsqltype="cf_sql_date" value="#a_date#">
		AND
		playeditems.secondsplayed > 30
		AND
		NOT mediaitems.userkey = playeditems.userkey
	;
	</cfquery>
	
	<cfset InsertPerformanceData( 'playeditems_foreign_over30sec', a_date, q_select_playeditems.count_played_items ) />		
	
	<cfquery name="q_select_playeditems" datasource="mytunesbutlerlogging">
	SELECT
		COUNT(id) AS count_played_items
	FROM
		playeditems
	WHERE
		date( dt_created ) = <cfqueryparam cfsqltype="cf_sql_date" value="#a_date#">
	;
	</cfquery>
	
	<cfset InsertPerformanceData( 'playeditems', a_date, q_select_playeditems.count_played_items ) />
	
	<cfquery name="q_select_playeditems_30sec" datasource="mytunesbutlerlogging">
	SELECT
		COUNT(id) AS count_played_items
	FROM
		playeditems
	WHERE
		date( dt_created ) = <cfqueryparam cfsqltype="cf_sql_date" value="#a_date#">
		AND
		secondsplayed > 30
	;
	</cfquery>
	
	<cfset InsertPerformanceData( 'playeditems_over30sec', a_date, q_select_playeditems_30sec.count_played_items ) />	
	
	<cfquery name="q_select_playeditems_fb" datasource="mytunesbutlerlogging">
	SELECT
		COUNT(id) AS count_played_items
	FROM
		playeditems
	WHERE
		date( dt_created ) = <cfqueryparam cfsqltype="cf_sql_date" value="#a_date#">
		AND
		applicationkey = 'CAA22BD2-CCAE-99A4-2221EC5A52249D66'
	;
	</cfquery>
	
	<cfset InsertPerformanceData( 'playeditems_fb', a_date, q_select_playeditems_fb.count_played_items ) />		
	
	<cfquery name="q_select_playeditems_iphone" datasource="mytunesbutlerlogging">
	SELECT
		COUNT(id) AS count_played_items
	FROM
		playeditems
	WHERE
		date( dt_created ) = <cfqueryparam cfsqltype="cf_sql_date" value="#a_date#">
		AND
		applicationkey = <cfqueryparam cfsqltype="cf_sql_varchar" value="#application.const.S_APPKEY_IPHONE#" />
	;
	</cfquery>
	
	<cfset InsertPerformanceData( 'playeditems_iphone', a_date, q_select_playeditems_iphone.count_played_items ) />		
	
	<cfquery name="q_select_playeditems_desktopradio" datasource="mytunesbutlerlogging">
	SELECT
		COUNT(id) AS count_played_items
	FROM
		playeditems
	WHERE
		date( dt_created ) = <cfqueryparam cfsqltype="cf_sql_date" value="#a_date#">
		AND
		applicationkey = <cfqueryparam cfsqltype="cf_sql_varchar" value="#application.const.S_APPKEY_DESKTOPRADIO#" />
	;
	</cfquery>
	
	<cfset InsertPerformanceData( 'playeditems_desktopradio', a_date, q_select_playeditems_desktopradio.count_played_items ) />		
	
	<cfquery name="local.q_select_playeditems_android" datasource="mytunesbutlerlogging">
	SELECT
		COUNT(id) AS count_played_items
	FROM
		playeditems
	WHERE
		date( dt_created ) = <cfqueryparam cfsqltype="cf_sql_date" value="#a_date#">
		AND
		applicationkey = <cfqueryparam cfsqltype="cf_sql_varchar" value="#application.const.S_APPKEY_ANDROID#" />
	;
	</cfquery>
	
	<cfset InsertPerformanceData( 'playeditems_android', a_date, local.q_select_playeditems_android.count_played_items ) />		
	
	<cfquery name="local.q_select_playeditems_sqn" datasource="mytunesbutlerlogging">
	SELECT
		COUNT(id) AS count_played_items
	FROM
		playeditems
	WHERE
		date( dt_created ) = <cfqueryparam cfsqltype="cf_sql_date" value="#a_date#">
		AND
		applicationkey = <cfqueryparam cfsqltype="cf_sql_varchar" value="#application.const.S_APPKEY_SQUEEZENETWORK#" />
	;
	</cfquery>
	
	<cfset InsertPerformanceData( 'playeditems_sqn', a_date, local.q_select_playeditems_sqn.count_played_items ) />		
	
	<cfquery name="q_select_exceptions" datasource="mytunesbutlerlogging">
	SELECT
		COUNT(id) AS count_exceptions
	FROM
		exceptionlog
	WHERE
		date( dt_created ) = <cfqueryparam cfsqltype="cf_sql_date" value="#a_date#">
	;
	</cfquery>
	
	<cfset InsertPerformanceData( 'exceptions', a_date, q_select_exceptions.count_exceptions ) />	
	
	
	<cfquery name="q_select_lastfm_submit" datasource="mytunesbutlerlogging">
	SELECT
		COUNT(id) AS count_lastfm
	FROM
		lastfm_submit_data
	WHERE
		date( dt_played ) = <cfqueryparam cfsqltype="cf_sql_date" value="#a_date#">
	;
	</cfquery>
	
	<cfset InsertPerformanceData( 'lastfm_submit', a_date, q_select_lastfm_submit.count_lastfm ) />		
		
	<cfquery name="q_select_apicalls" datasource="mytunesbutlerlogging">
	SELECT
		COUNT(id) AS count_calls
	FROM
		apicalls_logging
	WHERE
		date( dt_created ) = <cfqueryparam cfsqltype="cf_sql_date" value="#a_date#">
	;
	</cfquery>
	
	<cfset InsertPerformanceData( 'apicalls', a_date, q_select_apicalls.count_calls ) />			
		
	<cfquery name="q_select_apicalls" datasource="mytunesbutlerlogging">
	SELECT
		COUNT(id) AS count_calls
	FROM
		apicalls_logging
	WHERE
		date( dt_created ) = <cfqueryparam cfsqltype="cf_sql_date" value="#a_date#">
		AND
		applicationkey = 'ACD78BD2-CAAE-9AA4-3FB1EC5A52249D62'
	;
	</cfquery>
	
	<cfset InsertPerformanceData( 'apicalls_iphone', a_date, q_select_apicalls.count_calls ) />			
			
	<cfquery name="q_select_distinct_instances" datasource="mytunesbutlerlogging">
	SELECT
		COUNT(DISTINCT(hostname)) AS count_instances
	FROM
		serverstat
	WHERE
		date( dt_created ) = <cfqueryparam cfsqltype="cf_sql_date" value="#a_date#">
	;
	</cfquery>
	
	<cfset InsertPerformanceData( 'distinct_instances', a_date, Val(q_select_distinct_instances.count_instances) ) />	
	
	<cfquery name="q_select_avg_load" datasource="mytunesbutlerlogging">
	SELECT
		AVG(serverload) AS avg_load
	FROM
		serverstat
	WHERE
		date( dt_created ) = <cfqueryparam cfsqltype="cf_sql_date" value="#a_date#">
	;
	</cfquery>
	
	<cfset InsertPerformanceData( 'instances_avg_load', a_date, Val(q_select_avg_load.avg_load) ) />	

</cffunction>

<cffunction access="private" name="InsertPerformanceData" output="false" returntype="void">
	<cfargument name="indicator" type="string" required="true">
	<cfargument name="date" type="date" required="true">
	<cfargument name="value" type="numeric" required="true">
	
	<cfquery name="q_delete_old_value" datasource="mytunesbutlerlogging">
	DELETE FROM
		performancereporting
	WHERE
		(indicator = <cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.indicator#">)
		AND
		(date_report = <cfqueryparam cfsqltype="cf_sql_date" value="#arguments.date#">)
	;
	</cfquery>
	
	<cfquery name="q_insert_new_value" datasource="mytunesbutlerlogging">
	INSERT INTO
		performancereporting
		(
		indicator,
		date_report,
		val)
	VALUES
		(
		<cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.indicator#">,
		<cfqueryparam cfsqltype="cf_sql_date" value="#arguments.date#">,
		<cfqueryparam cfsqltype="cf_sql_integer" value="#Val( arguments.value )#">
		)
	;
	</cfquery>
	

</cffunction>
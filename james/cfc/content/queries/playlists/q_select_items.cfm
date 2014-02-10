<!--- 

select playlists

 --->

<!--- Do we have a single special, virtual playlist? In this case all the filters are useless ... --->
<cfif a_bol_filter_entrykeys AND application.udf.IsVirtualPlaylist( arguments.filter.entrykeys )>

	<cfset qSelectCollect = QueryNew( 'playlist_id', 'Integer') />
	<cfset QueryAddRow( qSelectCollect, 1 ) />
	<cfset QuerySetCell( qSelectCollect, 'playlist_id', 0, 1 ) />	

<cfelse>
	<cfquery name="qSelectCollect" datasource="mytunesbutleruserdata">
	(
	SELECT
		playlists.id AS playlist_id
	FROM
		playlists
	WHERE
	
		<!--- we have a typical playlist ... continue --->
		(playlists.librarykey IN (<cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.librarykeys#" list="true">))
		
		<!---  no tmp playlists --->
		<cfif NOT bIncludeTemporary>
			AND
			(playlists.istemporary  = 0) 
		</cfif>
		
		<!---  public only --->
		<cfif a_bol_filter_out_private>
			AND
			(playlists.public  = 1)
		</cfif>
		
		<!--- filter entrykeys --->
		<cfif a_bol_filter_entrykeys>
			AND
			(playlists.entrykey IN (<cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.filter.entrykeys#" list="true">))
		</cfif>
		)
		
		<!--- link further playlists? --->
		<cfif NOT a_bol_own_items_only>
			
			UNION ALL
			(
			SELECT
				playlists.id AS playlist_id
			FROM
				linked_playlists
			INNER JOIN
				playlists ON (playlists.id = linked_playlists.playlist_id)
			WHERE
				(createdbyuserkey = <cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.securitycontext.entrykey#">)
				<!--- AND NOT
				ISNULL( playlists.id ) --->
				
				
				<!--- filter entrykeys? --->
				<cfif a_bol_filter_entrykeys>
					AND
					(playlists.entrykey IN (<cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.filter.entrykeys#" list="true">))
				</cfif>
			)
		</cfif>	
	
	
	</cfquery>
</cfif>

<cfquery name="q_select_items" datasource="mytunesbutleruserdata">
SELECT
	playlists.userkey,
	playlists.id AS plist_ID,
	playlists.dt_created,	
	DATE_FORMAT( playlists.dt_lastmodified, '%Y%m%d%H%i%s') AS num_lastmodified,
	playlists.entrykey,
	playlists.name,
	playlists.description,
	playlists.tags,
	playlists.public,
	playlists.librarykey,
	playlists.dynamic,
	playlists.dynamic_criteria,
	playlists.istemporary,
	playlists.avgrating,
	playlists.imageset,
	playlists.img_revision,
	playlists.itemscount AS itemcount,
	playlists.totaltime,	
	playlists.licence_type_image,
	playlists.licence_image_link,
	playlists.source_service,
	playlists.external_identifier,
	/* text field holding the entrykeys */
	playlists.items,
	users.username,
	users.pic,
	users.privacy_playlists,
	/* calculated fields */
	/*0 AS itemcount,*/
	'' AS weight,
	0 AS systemplist,
	'' AS mb_trackidlist
	
	<!--- query for access details --->
	<cfif ListFindNoCase( arguments.options, 'notimesaccessed' ) IS 0>
		,IFNULL(timesaccessed.times, 0) AS times
		,timesaccessed.lasttime
		,DATEDIFF( CURRENT_TIMESTAMP, timesaccessed.lasttime) AS lasttimedays
	<cfelse>
		,0 AS times
		,Now() AS lasttime
		,0 AS lasttimedays
	</cfif>
	
	<!--- include rating? --->
	<cfif ListFindNoCase( arguments.options, 'norating' ) IS 0>
		,CONVERT( rating.rating, DECIMAL) AS rating
	<cfelse>
		,0 AS rating
	</cfif>
	
FROM
	playlists
LEFT JOIN
	users ON (users.id = playlists.userid)
	
/* last time accesses */
<cfif ListFindNoCase( arguments.options, 'notimesaccessed' ) IS 0>
	LEFT JOIN
		timesaccessed AS timesaccessed
			ON (timesaccessed.mediaitemkey = playlists.entrykey AND timesaccessed.userid = <cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.securitycontext.userid#">)
</cfif>

/* rating */
<cfif ListFindNoCase( arguments.options, 'norating' ) IS 0>
	LEFT JOIN
		ratings AS rating
		/* important: only select data of current user */
			ON (rating.mediaitemkey = playlists.entrykey AND rating.userid = <cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.securitycontext.userid#">)
</cfif>

WHERE
	(
		(playlists.id IN (<cfqueryparam cfsqltype="cf_sql_integer" value="#ValueList( qSelectCollect.playlist_id )#" list="true">))
		<!--- TODO: Optimze in case we've got only one user ... in this case use playlists.userid = n --->
	)
;
</cfquery>
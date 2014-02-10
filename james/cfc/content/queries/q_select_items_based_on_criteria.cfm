<!---

	get dynamic items

--->

<!--- TODO: Only load certain columns ... --->

<cfset a_bol_surprise_criteria_exists = application.udf.DynamicPlaylistCriteriaExists( a_struct_criteria, 'SURPRISE' ) />

<cfquery name="q_select_items_based_on_criteria" datasource="mytunesbutleruserdata">
SELECT
	mediaitems.id,
	mediaitems.entrykey,
	mediaitems.librarykey,
	mediaitems.artist,
	mediaitems.name,
	mediaitems.genre,
	timesaccessed.times,
	timesaccessed.lasttime AS dt_lastplayed,
	ratings.rating,
	/* calculate the surprise factor ... it's a number between 0 = NO surprise and 100 = very surprising '*/
	0 AS surprise_factor
FROM
	mediaitems
LEFT JOIN
	ratings ON (ratings.mediaitemkey = mediaitems.entrykey AND ratings.userid = mediaitems.userid)
LEFT JOIN
	timesaccessed AS timesaccessed ON (timesaccessed.userid = mediaitems.userid AND timesaccessed.mediaitemkey = mediaitems.entrykey)
WHERE
	(mediaitems.librarykey IN (<cfqueryparam cfsqltype="cf_sql_varchar" value="#a_str_librarykeys#" list="true">))
	AND
	(mediaitems.temporary = 0)

<!--- common, easy search --->
<cfif application.udf.DynamicPlaylistCriteriaExists( a_struct_criteria, 'COMMON_SEARCH' )>
	AND
		(
			(mediaitems.name LIKE <cfqueryparam cfsqltype="cf_sql_varchar" value="%#a_struct_criteria.common_search.value#%">)
			OR
			(mediaitems.album LIKE <cfqueryparam cfsqltype="cf_sql_varchar" value="%#a_struct_criteria.common_search.value#%">)
			OR
			(mediaitems.artist LIKE <cfqueryparam cfsqltype="cf_sql_varchar" value="%#a_struct_criteria.common_search.value#%">)
		)		
</cfif>

<!--- SEARCH BY SINGLE words --->
<cfif application.udf.DynamicPlaylistCriteriaExists( a_struct_criteria, 'ARTIST' )>
	AND
		(
			(mediaitems.artist LIKE <cfqueryparam cfsqltype="cf_sql_varchar" value="%#a_struct_criteria.artist.value#%">)
		)
</cfif>	

<cfif application.udf.DynamicPlaylistCriteriaExists( a_struct_criteria, 'NAME' )>
	AND
		(
			(mediaitems.name LIKE <cfqueryparam cfsqltype="cf_sql_varchar" value="%#a_struct_criteria.name.value#%">)
		)
</cfif>	

<cfif application.udf.DynamicPlaylistCriteriaExists( a_struct_criteria, 'ALBUM' )>
	AND
		(
			(mediaitems.album LIKE <cfqueryparam cfsqltype="cf_sql_varchar" value="%#a_struct_criteria.album.value#%">)
		)
</cfif>	

<cfif application.udf.DynamicPlaylistCriteriaExists( a_struct_criteria, 'TAG' )>
	AND
		(
			(mediaitems.tags LIKE <cfqueryparam cfsqltype="cf_sql_varchar" value="%#a_struct_criteria.tag.value#%">)
		)
</cfif>	

<!--- search MULTIPLE ITEMS --->

<!--- search for artists --->
<cfif application.udf.DynamicPlaylistCriteriaExists( a_struct_criteria, 'ARTISTS' )>
	AND
		(
			(mediaitems.artist IN (<cfqueryparam cfsqltype="cf_sql_varchar" value="#a_struct_criteria.artists.value#" list="true">))
		)
</cfif>	

<!--- track names --->
<cfif application.udf.DynamicPlaylistCriteriaExists( a_struct_criteria, 'NAMES' )>
	AND
		(
			(mediaitems.name IN (<cfqueryparam cfsqltype="cf_sql_varchar" value="#a_struct_criteria.names.value#" list="true">))
		)
</cfif>	

<!--- albums --->
<cfif application.udf.DynamicPlaylistCriteriaExists( a_struct_criteria, 'ALBUMS' )>
	AND
		(
			(mediaitems.album IN (<cfqueryparam cfsqltype="cf_sql_varchar" value="#a_struct_criteria.albums.value#" list="true">))
		)
</cfif>	

<!--- library keys --->
<cfif application.udf.DynamicPlaylistCriteriaExists( a_struct_criteria, 'LIBRARYKEYS' )>
	AND
		(
			(mediaitems.librarykey IN (<cfqueryparam cfsqltype="cf_sql_varchar" value="#a_struct_criteria.librarykeys.value#" list="true">))
		)
</cfif>	

<!--- genres --->
<cfif application.udf.DynamicPlaylistCriteriaExists( a_struct_criteria, 'GENRES' )>
	AND
		(
			(mediaitems.genre IN (<cfqueryparam cfsqltype="cf_sql_varchar" value="#a_struct_criteria.genres.value#" list="true">))
		)
</cfif>	

<!--- music brainz artist ids --->
<cfif application.udf.DynamicPlaylistCriteriaExists( a_struct_criteria, 'MBARTISTIDS' )>
	AND
		(
			(mediaitems.mb_artistid IN (<cfqueryparam cfsqltype="cf_sql_integer" value="#a_struct_criteria.mbartistids.value#" list="true">))
		)
</cfif>

<!--- MB album IDs --->
<cfif application.udf.DynamicPlaylistCriteriaExists( a_struct_criteria, 'MBALBUMIDS' )>
	AND
		(
			(mediaitems.mb_albumid IN (<cfqueryparam cfsqltype="cf_sql_integer" value="#a_struct_criteria.MBALBUMIDS.value#" list="true">))
		)
</cfif>


<!--- max age of track on system in days --->
<cfif application.udf.DynamicPlaylistCriteriaExists( a_struct_criteria, 'MAXAGEDAYS' )>
	AND
		(
			(DATEDIFF(Now(), mediaitems.dt_created) <= <cfqueryparam cfsqltype="cf_sql_integer" value="#a_struct_criteria.maxagedays.value#">)
		)
</cfif>

<!--- source property --->
<cfif application.udf.DynamicPlaylistCriteriaExists( a_struct_criteria, 'SOURCE' )>
	AND
		(
			(SOURCE = <cfqueryparam cfsqltype="cf_sql_varchar" value="#a_struct_criteria.source.value#" />)
		)
</cfif>

<!--- surprise level --->
<cfif a_bol_surprise_criteria_exists>

	<!--- check how much surprise the user wants --->
	<cfswitch expression="#a_struct_criteria.surprise.value#">
		<cfcase value="10">
		<!--- low:
		
			- high rating
			OR
			- often accessed within the last time
			 --->
		AND
			(
				(ratings.rating >= <cfqueryparam cfsqltype="cf_sql_integer" value="60">)
				OR
				(
					(ratings.rating IS NULL)
					AND
					(timesaccessed.times > <cfqueryparam cfsqltype="cf_sql_integer" value="8">)
					AND
					(timesaccessed.lasttime > <cfqueryparam cfsqltype="cf_sql_timestamp" value="#DateAdd( 'd', -21, Now() )#">)			
				)
				
			)
		</cfcase>
		<cfcase value="40">
		<!--- middle ... low rating or accesses within the last time --->
	
		AND
			(
				(ratings.rating >= <cfqueryparam cfsqltype="cf_sql_integer" value="40">)
				OR
				(
					(ratings.rating IS NULL)
					AND
					(timesaccessed.times > <cfqueryparam cfsqltype="cf_sql_integer" value="1">)
					AND
					(timesaccessed.lasttime > <cfqueryparam cfsqltype="cf_sql_timestamp" value="#DateAdd( 'd', -21, Now() )#">)			
				)
			)
		
		</cfcase>
		<cfcase value="70">
		<!--- high ... accesses fewer than 20 times ... needs to be improved in future times! --->
	
		AND
			(1 = 1)	
		AND
			(
				
				(
					(timesaccessed.times < <cfqueryparam cfsqltype="cf_sql_integer" value="15">)
					OR
					(timesaccessed.lasttime > <cfqueryparam cfsqltype="cf_sql_timestamp" value="#DateAdd( 'd', -21, Now() )#">)
				)
			OR
				<!--- or never touched before --->
				(timesaccessed.lasttime IS NULL)
			
			)
		</cfcase>
		
	</cfswitch>

</cfif>

ORDER BY

	<cfswitch expression="#arguments.order#">
		<cfcase value="RANDOM">
			RAND()
		</cfcase>
		<cfcase value="1">
			1
		</cfcase>
		<cfdefaultcase>
			mediaitems.artist
		</cfdefaultcase>
	</cfswitch>
	
LIMIT
	 #Val( a_int_max_rows )#
;
</cfquery>
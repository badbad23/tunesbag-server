<!--- 
	
	select music heard by followers
	
 --->

<cfif ListFindNoCase( sUserIds, arguments.securitycontext.userid ) GT 0>
	<cfset sUserIds = ListDeleteAt( sUserIds, ListFindNocase( sUserIds, arguments.securitycontext.userid )) />
</cfif>

<cfquery name="qSelectUserids" datasource="mytunesbutleruserdata">
SELECT
	timesaccessed.id
FROM
	timesaccessed
WHERE
	(timesaccessed.userid IN (<cfqueryparam cfsqltype="cf_sql_integer" value="0,#sUserIds#" list="true">))
	AND
	(timesaccessed.lasttime >= <cfqueryparam cfsqltype="cf_sql_timestamp" value="#DateAdd( 'd', -14, Now())#">)
;
</cfquery>

<cfquery name="q_select_dynamic_playlist_items" datasource="mytunesbutleruserdata">
SELECT
	mediaitem.id
FROM
	timesaccessed
LEFT JOIN
	mediaitems AS mediaitem ON (mediaitem.entrykey = timesaccessed.mediaitemkey)
WHERE
	(timesaccessed.id IN (<cfqueryparam cfsqltype="cf_sql_integer" value="0,#ValueList( qSelectUserids.id )#" list="true">))
ORDER BY
	timesaccessed.lasttime DESC
LIMIT
	<!--- return max n items --->
	#Val( arguments.maxrows )#
;
</cfquery>
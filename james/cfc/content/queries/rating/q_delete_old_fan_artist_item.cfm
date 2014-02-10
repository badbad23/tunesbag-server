<!--- 

	delete old fan item
	
 --->

<cfquery name="q_delete_old_fan_artist_item" datasource="mytunesbutleruserdata">
DELETE FROM
	ratings
WHERE
	userid = <cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.securitycontext.userid#">
	AND
	mediaitemtype = <cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.itemtype#">
	AND
	mbid = <cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.mbid#">
;
</cfquery>
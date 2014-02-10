<!--- delete old mediaitem ratings --->

<cfquery name="q_delete_old_mediaitem_ratings" datasource="mytunesbutleruserdata">
DELETE FROM
	ratings
WHERE
	userid = <cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.securitycontext.userid#">
	AND
	mediaitemtype = <cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.itemtype#">
	AND
	mediaitemkey = <cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.mediaitemkey#">
;
</cfquery>
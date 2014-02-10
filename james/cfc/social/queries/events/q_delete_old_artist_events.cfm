<cfquery name="q_delete_old_artist_events" datasource="mytunesbutleruserdata">
DELETE FROM
	events
WHERE
	artist = <cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.artist#">

<cfif Len( arguments.countryisocodes ) GT 0>
	AND
	country IN (<cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.countryisocodes#" list="true">)
</cfif>
;
</cfquery>
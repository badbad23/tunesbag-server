<cfquery name="q_insert_new_track" datasource="mytunesbutlercontent">
INSERT INTO
	trackcust
	(
	id,
	artist,
	name,
	gid,
	length
	)
VALUES
	(
	<cfqueryparam cfsqltype="cf_sql_integer" value="#a_id#">,
	<cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.artistid#">,
	<cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.name#">,
	<cfqueryparam cfsqltype="cf_sql_varchar" value="#a_gid#">,
	<cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.tracklen#">	
	)
;
</cfquery>
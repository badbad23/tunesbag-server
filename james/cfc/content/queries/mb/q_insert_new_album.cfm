<cfquery name="q_insert_new_album" datasource="mytunesbutlercontent">
INSERT INTO
	albumcust
	(
	id,
	gid,
	artist,
	name,
	page,
	attributes
	)
VALUES
	(
	<cfqueryparam cfsqltype="cf_sql_integer" value="#a_id#">,
	<cfqueryparam cfsqltype="cf_sql_varchar" value="#a_gid#">,
	<cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.artistid#">,
	<cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.name#">,
	0,
	/* take as default value for albums */
	1100
	)
;
</cfquery>
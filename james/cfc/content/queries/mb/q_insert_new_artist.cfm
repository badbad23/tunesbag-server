<cfquery name="q_insert_new_artist" datasource="mytunesbutlercontent">
INSERT INTO
	artistcust
	(
	id,
	gid,
	name,
	namesimple,
	sortname,
	page,
	quality
	)
VALUES
	(
	<cfqueryparam cfsqltype="cf_sql_integer" value="#a_id#">,
	<cfqueryparam cfsqltype="cf_sql_varchar" value="#a_gid#">,
	<cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.artist#">,
	<cfqueryparam cfsqltype="cf_sql_varchar" value="#ReReplaceNoCase( arguments.artist, '[^A-Z,^0-9]*', '', 'ALL')#">,
	<cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.artist#">,
	0,
	/* low quality by default, in case the artist is added for real */
	-1
	)
;
</cfquery>
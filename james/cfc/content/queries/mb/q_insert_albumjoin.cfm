<cfquery name="q_select_max_albumjoin" datasource="mytunesbutlercontent">
SELECT
	MAX(id) AS max_id
FROM
	albumjoincust
;
</cfquery>

<cfset a_id_albumjoin = Val( q_select_max_albumjoin.max_id ) + 1 />

<cfif a_id_albumjoin LT 100000000>
	<cfset a_id_albumjoin = 100000000 />
</cfif>

<cfquery name="q_insert_albumjoin" datasource="mytunesbutlercontent">
INSERT INTO
	albumjoincust
	(
	id,
	album,
	track,
	sequence	
	)
VALUES
	(
	<cfqueryparam cfsqltype="cf_sql_integer" value="#a_id_albumjoin#">,
	<cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.albumid#">,
	<cfqueryparam cfsqltype="cf_sql_integer" value="#a_id#">,
	<cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.sequence#">
	)
;
</cfquery>
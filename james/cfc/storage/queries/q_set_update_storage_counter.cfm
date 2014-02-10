<!---

	check if the counter exists, update if necessary or insert otherwise

--->

<cfquery name="q_select_counter_item_exists" datasource="mytunesbutleruserdata">
SELECT
	COUNT(id) AS count_id
FROM
	storagecounters
WHERE
	hashvalue = <cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.hashvalue#">
;
</cfquery>

<cfif q_select_counter_item_exists.count_id IS 0>

	<cfquery name="q_insert_hashvalue_count" datasource="mytunesbutleruserdata">
	INSERT INTO
		storagecounters
	(
		hashvalue,
		counter,
		dt_created,
		dt_lastupdate
	)
	VALUES
		(
		<cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.hashvalue#">,
		1,
		<cfqueryparam cfsqltype="cf_sql_timestamp" value="#Now()#">,
		<cfqueryparam cfsqltype="cf_sql_timestamp" value="#Now()#">		
	)
	;
	</cfquery>

<cfelse>

	<cfquery name="q_update_counter_item" datasource="mytunesbutleruserdata">
	UPDATE
		storagecounters
	SET
		counter = counter + 1,
		dt_lastupdate = <cfqueryparam cfsqltype="cf_sql_timestamp" value="#Now()#">
	WHERE
		hashvalue = <cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.hashvalue#">
	;
	</cfquery>

</cfif>
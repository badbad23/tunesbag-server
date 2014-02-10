

<cfquery name="q_select_last_log_items_of_this_user" datasource="mytunesbutlerlogging">
SELECT
	logbook.param,
	logbook.action,
	logbook.dt_created,
	logbook.createdbyusername,
	logbook.createdbyuserkey,
	logbook.affecteduserkey,
	logbook.objecttitle,
	logbook.linked_objectkey,
	logbook.private,
	logbook.entrykey,
	users.pic
FROM
	logbook
LEFT JOIN
	mytunesbutleruserdata.users AS users ON (users.entrykey = logbook.createdbyuserkey)
WHERE
	(logbook.dt_created > '2007/1/1')
	AND
	(
		
		<!--- events of friends (either done by friend or friend is affected) --->
		(logbook.createdbyuserkey = <cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.userkey#">)
		OR
		(logbook.affecteduserkey = <cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.userkey#">)
		
	)
	
	<!--- filter by userkeys? --->
	<cfif StructKeyExists( arguments.filter, 'actions' ) AND Len( arguments.filter.actions ) GT 0>
	
	AND
		(
			(logbook.action IN (<cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.filter.actions#" list="true">))
		)
	
	</cfif>
	
ORDER BY
	logbook.dt_created DESC
LIMIT
	50
;
</cfquery>
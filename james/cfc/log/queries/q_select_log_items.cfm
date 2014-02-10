<!---

	select news items of the given data

--->

<cfquery name="q_select_log_items" datasource="mytunesbutlerlogging">
SELECT
	logbook.param,
	logbook.action,
	logbook.dt_created,
	DATE_FORMAT( logbook.dt_created, '%Y%m%d%H%i%s' ) AS dt_created_num,
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
	mytunesbutleruserdata.users AS users ON (users.id = logbook.createdbyuserid)
WHERE
	(
		(
		
			<cfif sFriendUserids NEQ 0>
			<!--- events of friends (either done by friend or friend is affected) --->
			(logbook.createdbyuserid IN (<cfqueryparam cfsqltype="cf_sql_integer" value="#sFriendUserids#" list="true">))
			OR
			(logbook.affecteduserid IN (<cfqueryparam cfsqltype="cf_sql_integer" value="#sFriendUserids#" list="true">))
			
			<cfelse>
				(1 = 0)
			</cfif>
		)
		OR
		(
			<!--- affected yes but not created by user itself --->
			(logbook.affecteduserid = <cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.securitycontext.userid#">)
			
			/* options: #arguments.options# */
			/* userkey: #arguments.securitycontext.entrykey# */
			
			
			<!--- include or surpress own items (created by user itself) --->
			<cfif ListFindNocase( arguments.options, 'includeownitems' ) GT 0>
				OR
			<cfelse>
				AND NOT
			</cfif>
			
			(logbook.createdbyuserid = <cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.securitycontext.userid#">)
		
		)
	)
	
	<!--- filter by userkeys? --->
	<cfif StructKeyExists( arguments.filter, 'userkeys' ) AND Len( arguments.filter.userkeys ) GT 0>
	
	AND
		(
			(logbook.createdbyuserkey IN (<cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.filter.userkeys#" list="true">))
		)
	
	</cfif>
	
	<!--- filter by actions? --->
	<cfif StructKeyExists( arguments.filter, 'actions' ) AND Len( arguments.filter.actions ) GT 0>
	
	AND
		(
			(logbook.action IN (<cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.filter.actions#" list="true">))
		)
	
	</cfif>	
	
	<cfif Val( arguments.maxagedays ) GT 0>
		AND
			(
				logbook.dt_created >= <cfqueryparam cfsqltype="cf_sql_timestamp" value="#DateAdd( 'd', -arguments.maxagedays, Now() )#">
			)
	</cfif>
	
	<cfif Val( arguments.sincedate ) GT 0>
		AND
			(
				DATE_FORMAT( logbook.dt_created, '%Y%m%d%H%i%s' ) >= <cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.sincedate#">
			)
	</cfif>
	
ORDER BY
	logbook.dt_created DESC
LIMIT
	#Val( arguments.maxrows )#
;
</cfquery>
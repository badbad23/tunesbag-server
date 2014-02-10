<!--- 
	
	scan dropbox accounts

 --->

<cfsetting requesttimeout="1200" />

<cfquery name="qAccounts" datasource="mytunesbutleruserdata">
SELECT		state.user_ID,
			state.dt_created,
			state.dt_lastupdate,
			state.ID AS source_ID,
			accessdata.username,
			accessdata.pwd,
			accessdata.userkey,
			DATEDIFF( CURRENT_TIMESTAMP, state.dt_lastupdate) AS diffsync

FROM		3rdparty_ids AS accessdata

LEFT JOIN	users ON (users.entrykey = accessdata.userkey)
LEFT JOIN	mytunesbutlercontent.sourcessyncstate AS state ON
			(
				state.user_ID = users.ID
				AND
				state.servicename = <cfqueryparam cfsqltype="cf_sql_varchar" value="#application.const.S_SERVICE_DROPBOX#" />
			)

WHERE		accessdata.servicename = <cfqueryparam cfsqltype="cf_sql_varchar" value="#application.const.S_SERVICE_DROPBOX#" />
			AND
			accessdata.isworking = 1
			AND
			accessdata.enabled = 1
			AND
			/* waiting for sync or null */
			(state.status = <cfqueryparam cfsqltype="cf_sql_integer" value="#application.const.I_SYNC_SOURCE_STATUS_DEFAULT#" /> OR state.status IS NULL)
			AND NOT
			/* make sure user exists */
			users.ID IS NULL
			
			/* 
			* 	criteria:
			* 
			* 	never synced before
			* 
			* 	or more than 72 hrs ago
			* 
			*/
			
			AND
			(
				/* never been synched yet */
				state.dt_lastupdate IS NULL
				
				OR
				
				/* more than 2 days ago */
				DATEDIFF( CURRENT_TIMESTAMP, state.dt_lastupdate) > 2
				
			)
ORDER BY	diffsync
LIMIT		5
</cfquery>

<!--- <cfdump var="#qAccounts#"> --->

<cfoutput query="qAccounts">
	
	<h1>#qAccounts.user_ID# | #qAccounts.dt_lastupdate#</h1>

	<cfset stSecurityContext = application.beanFactory.getBean( 'SecurityComponent' ).GetUserContextByUserkey( qAccounts.userkey ) />

	<cfset stScan = application.beanFactory.getBean( 'Dropbox' ).performSync(
			stContext 				= stSecurityContext,
			bIgnoreExistingFiles 	= true
			) />
			<cfdump var="#stScan#">
	<p>#stScan.result# | #stScan.error# | #stScan.errormessage#</p>
	
	<cfset ORMFlush() />

	<!--- update old items left in the database --->
	<cfif stScan.result>
		
		<cfquery name="qAccounts" datasource="mytunesbutlercontent">
		UPDATE	sourcessyncstate
		SET		status 	= <cfqueryparam cfsqltype="cf_sql_integer" value="#application.const.I_SYNC_SOURCE_STATUS_DEFAULT#" />
		WHERE	id		= <cfqueryparam cfsqltype="cf_sql_integer" value="#qAccounts.source_ID#" />
		</cfquery>
		
	</cfif>
	
</cfoutput>
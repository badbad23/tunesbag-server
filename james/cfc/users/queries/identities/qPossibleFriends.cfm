<cfquery name="qPossibleFriends" datasource="mytunesbutleruserdata">
SELECT
	users_externalidentifiers.userkey,
	users.username,
	users.photoindex,
	users_externalidentifiers.provider,
	users.firstname,
	users.city,
	users.countryisocode
FROM
	users_externalidentifiers
LEFT JOIN
	users ON (users.entrykey = users_externalidentifiers.userkey)
WHERE

	<!--- data provided? --->
	<cfif StructKeyExists( stData, 'friends' ) AND IsArray( stData.friends )>
	
		users_externalidentifiers.identifier IN (<cfqueryparam cfsqltype="cf_sql_varchar" value="#ArrayToList( stData.friends )#" list="true">)
		
		<cfif ArrayLen( arguments.securitycontext.friends ) GT 0>		
			AND NOT
			users.entrykey IN (<cfqueryparam cfsqltype="cf_sql_varchar" value="#application.beanFactory.getBean( 'MediaitemsComponent' ).GetAllFriendUserkeys( arguments.securitycontext )#" list="true">)
		</cfif>
	
	<cfelse>
	
		<!--- no hits --->
		(0 = 1)
		
	</cfif>
	
	AND
	(LENGTH( users.username ) > 0)
;
</cfquery>
<!--- 

	check which servers are available

 --->


<!--- select servers which have been active during the last minute --->
<cfquery name="qSelectStat" datasource="mytunesbutlerlogging">
SELECT
	hostip,
	hostname,
	serverload,
	isstreaming,
	isuploading,
	countrycode,
	waiting_converting,
	waiting_s3upload,
	waiting_incoming
FROM
	serverstat
WHERE
	dt_created > <cfqueryparam cfsqltype="cf_sql_timestamp" value="#DateAdd( 'n', -2, Now() )#">
GROUP BY
	hostname
ORDER BY
	dt_created DESC
;
</cfquery>


<!--- <cfdump var="#qSelectStat#"> --->

<cfloop query="qSelectStat">
	
	<cfquery name="qUpdateEnabled" datasource="mytunesbutlerlogging" result="stUpdate">
	UPDATE
		serverpool
	SET
		enabled = 1,
		serverload = <cfqueryparam cfsqltype="cf_sql_float" value="#qSelectStat.serverload#">,
		isincoming = <cfqueryparam cfsqltype="cf_sql_integer" value="#qSelectStat.isuploading#">,
		isstreaming = <cfqueryparam cfsqltype="cf_sql_integer" value="#qSelectStat.isstreaming#">,
		dt_lastupdate = <cfqueryparam cfsqltype="cf_sql_timestamp" value="#Now()#">
	WHERE
		hostname = <cfqueryparam cfsqltype="cf_sql_varchar" value="#qSelectStat.hostname#">
	</cfquery>
	
	<cfif stUpdate.RECORDCOUNT IS 0>
		
		<!--- insert --->
		<cfquery name="qUpdateEnabled" datasource="mytunesbutlerlogging" result="stUpdate">
		INSERT INTO
			serverpool
			(
			enabled,
			hostip,
			hostname,
			serverload,
			isincoming,
			isstreaming,
			dt_lastupdate,
			dt_created,
			countryisocode
			)
		VALUES
			(
			1,
			<cfqueryparam cfsqltype="cf_sql_varchar" value="#qSelectStat.hostip#">,
			<cfqueryparam cfsqltype="cf_sql_varchar" value="#qSelectStat.hostname#">,
			<cfqueryparam cfsqltype="cf_sql_float" value="#qSelectStat.serverload#">, 
			<cfqueryparam cfsqltype="cf_sql_integer" value="#qSelectStat.isuploading#">,
			<cfqueryparam cfsqltype="cf_sql_integer" value="#qSelectStat.isstreaming#">,
			<cfqueryparam cfsqltype="cf_sql_timestamp" value="#Now()#">,
			<cfqueryparam cfsqltype="cf_sql_timestamp" value="#Now()#">,
			<cfqueryparam cfsqltype="cf_sql_varchar" value="#qSelectStat.countrycode#">
			)
		;
		</cfquery>
		
	</cfif>
	
</cfloop>

<cfquery name="qUpdateDisable" datasource="mytunesbutlerlogging">
UPDATE
	serverpool
SET
	enabled = 0
WHERE
	NOT hostname IN (<cfqueryparam cfsqltype="cf_sql_varchar" value="#ValueList( qSelectStat.hostname )#" list="true">)
;
</cfquery>


<cfquery name="qDeleteInvalidHost" datasource="mytunesbutlerlogging" result="stUpdate">
DELETE FROM
	serverpool
WHERE
	hostname = 'localhost'
;
</cfquery>

<!--- check if any upload/streaming servers are available --->
<cfquery name="qSelectServerIncoming" datasource="mytunesbutlerlogging">
SELECT
	COUNT(id) AS counter
FROM
	serverpool
WHERE
	enabled = 1
	AND
	isincoming = 1
;
</cfquery>

<cfquery name="qSelectServerStreaming" datasource="mytunesbutlerlogging">
SELECT
	COUNT(id) AS counter
FROM
	serverpool
WHERE
	enabled = 1
	AND
	isstreaming = 1
;
</cfquery>

<cfif qSelectServerIncoming.counter IS 0 OR qSelectServerStreaming.counter IS 0>
	<cfmail from="support@tunesBag.com" to="support@tunesBag.com" subject="ALERT: No Incoming/Streaming servers available">
		Please check the server pool.
	</cfmail>
</cfif>


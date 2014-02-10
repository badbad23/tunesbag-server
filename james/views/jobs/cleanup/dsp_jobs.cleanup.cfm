<!---

	cleanup job, clear cache for blogs for example

--->

<cfprocessingdirective pageencoding="utf-8" />
<cfsetting requesttimeout="200" />

<cfquery name="q_delete_old_cache_items" datasource="mytunesbutlerlogging">
DELETE FROM
	infocache
WHERE
	DATE_ADD(dt_created, INTERVAL expiresmin MINUTE) < Now()
;
</cfquery>

<!--- old autoadd items --->
<cfquery name="q_delete_old_autoadd_items" datasource="mytunesbutleruserdata">
DELETE FROM
	autoaddplist
WHERE
	dt_created < <cfqueryparam cfsqltype="cf_sql_timestamp" value="#DateAdd( 'd', -7, Now() )#">
;
</cfquery>

<!--- delete old done convertjobs --->
<!--- <cfquery name="q_delete_old_convertjobs" datasource="tb_incoming">
DELETE FROM
	convertjobs
WHERE
	dt_created < <cfqueryparam cfsqltype="cf_sql_timestamp" value="#DateAdd( 'd', -21, Now() )#">
	AND
	handled = 1
	AND
	done = 1
	AND
	errorno = 0
;
</cfquery> --->

<!--- old internal app logs --->
<cfquery name="qDeleteApiCallLog" datasource="mytunesbutlerlogging">
DELETE FROM
	apicalls_logging
WHERE
	dt_created < <cfqueryparam cfsqltype="cf_sql_timestamp" value="#DateAdd( 'd', -21, Now() )#">
	<!--- AND
	/* internal ... internal.streaming.getconvertdata etc */
	applicationkey = 'FF0D5A94-F8D9-60D4-4572A1A21EFEE8DD' --->
;
</cfquery>

<!--- old server stat --->
<cfquery name="qDeleteOldStatLog" datasource="mytunesbutlerlogging">
DELETE FROM
	serverstat
WHERE
	dt_created < <cfqueryparam cfsqltype="cf_sql_timestamp" value="#DateAdd( 'd', -3, Now() )#">
;
</cfquery>

<!--- delete old upload auth keys --->
<cfquery name="qDeleteUploadAuthKey" datasource="mytunesbutlerlogging">
DELETE FROM
	uploadauthkeys
WHERE
	dt_created < <cfqueryparam cfsqltype="cf_sql_timestamp" value="#DateAdd( 'd', -3, Now() )#">
;
</cfquery>

<!--- strands submit data --->
<cfquery name="qDeleteUploadAuthKey" datasource="mytunesbutlerlogging">
DELETE FROM
	uploadauthkeys
WHERE
	dt_created < <cfqueryparam cfsqltype="cf_sql_timestamp" value="#DateAdd( 'd', -3, Now() )#">
;
</cfquery>

<!--- win32 uploader --->
<cfquery name="qDeleteApiCallLog" datasource="mytunesbutlerlogging">
DELETE FROM
	strands_submit_data
WHERE
	dt_played < <cfqueryparam cfsqltype="cf_sql_timestamp" value="#DateAdd( 'd', -30, Now() )#">
;
</cfquery>

<!--- old events --->
<cfquery name="q_delete_old_events" datasource="mytunesbutlercontent">
DELETE FROM
	events
WHERE
	start < <cfqueryparam cfsqltype="cf_sql_timestamp" value="#DateAdd( 'd', -5, Now() )#">
;
</cfquery>

<!--- old mediaitem meta revisions --->
<cfquery name="qDeleteOldMetaRevisions" datasource="mytunesbutlerlogging">
DELETE FROM
	mediaitems_metadata_revisions
WHERE
	dt_created < <cfqueryparam cfsqltype="cf_sql_timestamp" value="#DateAdd( 'd', -14, Now() )#">
;
</cfquery>

<!--- delete old twitter postings --->
<cfquery name="qDeleteOldTwitterPostings" datasource="mytunesbutlercontent">
DELETE FROM
	twitterstream
WHERE
	dt_created < <cfqueryparam cfsqltype="cf_sql_timestamp" value="#DateAdd( 'd', -14, Now() )#">
;
</cfquery>

<!--- delete old temporary playlists --->
<cfquery name="qDeleteOldTemporaryPlaylists" datasource="mytunesbutleruserdata">
DELETE FROM
	playlists
WHERE
	istemporary = 1
	AND
	dt_created < <cfqueryparam cfsqltype="cf_sql_timestamp" value="#DateAdd( 'd', -5, Now() )#">
;
</cfquery>

<!--- archive old log items --->
<!---
<cfquery name="qSelectOldAPILog" datasource="mytunesbutlerlogging">
SELECT
	*
FROM
	apicalls_logging
WHERE
	dt_created < <cfqueryparam cfsqltype="cf_sql_timestamp" value="#DateAdd( 'd', -14, Now() )#">
ORDER BY
	id
LIMIT
	10000
;
</cfquery>

<cfset sData = SerializeJSON( qSelectOldAPILog ) />

<cffile action="write" output="#sData#" charset="utf-8" file="/tmp/test.txt" />--->

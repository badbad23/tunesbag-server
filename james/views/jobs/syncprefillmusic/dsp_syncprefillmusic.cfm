<cfinclude template="/common/scripts.cfm">

<!--- clear old data --->
<cfquery name="qDelete" datasource="mytunesbutlercontent">
DELETE FROM
	prefill_librarydata
;
</cfquery>

<!--- sync --->
<cfquery name="qSelectFreeUser" datasource="mytunesbutleruserdata">
SELECT
	entrykey
FROM
	users
WHERE
	username = 'free.music'
;
</cfquery>

<cfquery name="qSelectItems" datasource="mytunesbutleruserdata">
SELECT
	hashvalue,
	album,
	artist,
	genre,
	name,
	size,
	totaltime,
	tracknumber,
	year,
	samplerate,
	originalfilehashvalue,
	bitrate,
	analyzed,
	puid_analyzed,
	mb_matchlevel,
	mb_artistid,
	mb_albumid,
	mb_trackid,
	puid,
	puid_generated,
	licence_type,
	customartwork,
	entrykey
FROM
	mediaitems
WHERE
	userkey = <cfqueryparam cfsqltype="cf_sql_varchar" value="#qSelectFreeuser.entrykey#">
;
</cfquery>

<cfdump var="#qSelectItems#">

<!--- insert into prefill table --->
<cfoutput query="qSelectItems">

	<cfset stData = { album = qSelectItems.album, artist = qSelectItems.artist,
			 genre = qSelectItems.genre, size = qSelectItems.size, name = qSelectItems.name,
			 year = qSelectItems.year, tracknumber = qSelectItems.tracknumber, samplerate = qSelectItems.samplerate,
			 bitrate = qSelectItems.bitrate, analyzed = 1, puid_analyzed = 1, mb_matchlevel = qSelectItems.mb_matchlevel,
			 mb_artistid = qSelectItems.mb_artistid, qSelectItems.mb_albumid = qSelectItems.mb_albumid, mb_trackid = qSelectItems.mb_trackid,
			 puid = qSelectItems.puid, puid_generated = qSelectItems.puid_generated, licence_type = qSelectItems.licence_type,
			 tracklength = qSelectItems.totaltime, customartwork = qSelectItems.customartwork, source = 'prefill'
			 } />

	<cfquery name="qInsert" datasource="mytunesbutlercontent">
	INSERT INTO
		prefill_librarydata
		(
		originalmediaitemkey,
		hashvalue,
		originalhashvalue,
		metainformation,
		countrycode,
		dt_created,
		active		
		)
	VALUES
		(
		<cfqueryparam cfsqltype="cf_sql_varchar" value="#qSelectItems.entrykey#">,
		<cfqueryparam cfsqltype="cf_sql_varchar" value="#qSelectItems.hashvalue#">,
		<cfqueryparam cfsqltype="cf_sql_varchar" value="#qSelectItems.originalfilehashvalue#">,
		<cfqueryparam cfsqltype="cf_sql_longvarchar" value="#SerializeJSON( stData )#">,
		'',
		NOW(),
		1
		)
	;
	</cfquery>
	<cfdump var="#stData#">
</cfoutput>

done.
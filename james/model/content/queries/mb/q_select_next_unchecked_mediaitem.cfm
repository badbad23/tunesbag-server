<cfquery name="q_select_next_unchecked_mediaitem" datasource="mytunesbutleruserdata">
SELECT
	artist,
	album,
	entrykey,
	puid,
	name,
	mb_albumid,
	mb_artistid,
	mb_trackid
FROM
	mediaitems
WHERE
	userkey = <cfqueryparam cfsqltype="cf_sql_varchar" value="#application.udf.GetCurrentSecurityContext().entrykey#">
	AND
	LENGTH( puid ) > 0
	AND
	/* 0 = no hit yet, 1 = could not decide yet */
	puid_analyzed IN (0,-1)
ORDER BY
	dt_created
LIMIT
	1
;
</cfquery>
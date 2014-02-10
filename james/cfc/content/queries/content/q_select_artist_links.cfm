<cfquery name="q_select_artist_links" datasource="#application.udf.getMBds()#">
SELECT
	l_artist_url.id,
	l_artist_url.link1,
	l_artist_url.link_type,
	url.url,
	url.description
FROM
	l_artist_url
LEFT JOIN
	url ON (url.id = l_artist_url.link1)
WHERE
	l_artist_url.link0 = <cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.mbartistid#">
	AND
	l_artist_url.link_type IN (2,10,11,17)
	AND
	LENGTH( url.description ) > 0
;
</cfquery>
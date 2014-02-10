<!---

	Select fans of an artist

--->

<cfquery name="q_select_fans_of_artist" datasource="mytunesbutleruserdata">
SELECT
	ratings.userkey,
	users.username,
	users.pic,
	users.about_me
FROM
	ratings
LEFT JOIN
	mytunesbutleruserdata.users AS users ON (users.entrykey = ratings.userkey)
WHERE
	ratings.mbid = <cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.MBartistID#">
	AND
	/* type is artist */
	ratings.mediaitemtype = 2
GROUP BY
	userkey
;
</cfquery>
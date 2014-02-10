<!--- 

	select artists to which the user listened very often during the last 30 days

 --->

<cfquery name="q_select_implicit_fav_artists" datasource="mytunesbutlerlogging">
SELECT
	playeditems.mb_artistid,
	COUNT( playeditems.id ) AS counter
FROM
	playeditems
WHERE
	playeditems.dt_created > <cfqueryparam cfsqltype="cf_sql_timestamp" value="#DateAdd( 'd', -30, Now() )#">
	AND
	playeditems.userid = <cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.securitycontext.userid#">
	AND
	playeditems.secondsplayed > 30
	AND
	/* no "virtual artists" */
	playeditems.mb_artistid < 100000000
GROUP BY
	playeditems.mb_artistid
ORDER BY
	counter DESC
LIMIT
	20
;
</cfquery>
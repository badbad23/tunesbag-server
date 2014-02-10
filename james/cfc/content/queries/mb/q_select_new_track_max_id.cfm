<cfquery name="q_select_new_track_max_id" datasource="mytunesbutlercontent">
SELECT
	MAX(id) AS max_id
FROM
	trackcust
;
</cfquery>
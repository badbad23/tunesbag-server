<cfquery name="q_select_new_album_max" datasource="mytunesbutlercontent">
SELECT
	MAX(id) AS max_id
FROM
	albumcust
;
</cfquery>
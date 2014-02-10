<!---

	select distinct genres + number of items

--->

<cfquery name="q_select_genre_cloud_of_user" datasource="mytunesbutleruserdata">
SELECT
	mediaitems.genre, COUNT(genre) AS genre_count
FROM
	mediaitems
WHERE
	(mediaitems.userkey = <cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.userkey#">)
GROUP BY
	mediaitems.genre
HAVING COUNT(mediaitems.genre)>=1
ORDER BY
	mediaitems.genre,
	genre_count DESC,
	mediaitems.genre
;
</cfquery>
<!---

	select distinct genres visible to user

--->

<cfquery name="q_select_distinct_available_genres" datasource="mytunesbutleruserdata">
SELECT
	mediaitems.genre, COUNT(genre) AS genre_count
FROM
	mediaitems
WHERE
	librarykey IN (<cfqueryparam cfsqltype="cf_sql_varchar" value="#a_str_librarykeys#" list="true">)
	AND
	LENGTH( mediaitems.genre ) > 0
GROUP BY
	mediaitems.genre
HAVING COUNT(mediaitems.genre)>=1
ORDER BY
	mediaitems.genre,
	genre_count DESC,
	mediaitems.genre
;
</cfquery>
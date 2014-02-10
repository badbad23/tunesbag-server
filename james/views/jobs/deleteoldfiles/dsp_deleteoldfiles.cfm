<cfquery name="qSelectOverLimit" datasource="mytunesbutleruserdata">
SELECT
	*
FROM
	quota
WHERE
	currentsize > 1073741820
;
</cfquery>
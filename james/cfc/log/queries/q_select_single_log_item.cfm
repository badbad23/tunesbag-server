<!---

	select a single log item

--->

<cfquery name="q_select_single_log_item" datasource="mytunesbutlerlogging">
SELECT
	logbook.param,
	logbook.action,
	logbook.dt_created,
	logbook.createdbyusername,
	logbook.createdbyuserkey,
	logbook.affecteduserkey,
	logbook.objecttitle,
	logbook.linked_objectkey,
	logbook.private,
	logbook.entrykey,
	users.pic
FROM
	logbook
LEFT JOIN
	mytunesbutleruserdata.users AS users ON (users.entrykey = logbook.createdbyuserkey)
WHERE
	logbook.entrykey = <cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.entrykey#">
;
</cfquery>
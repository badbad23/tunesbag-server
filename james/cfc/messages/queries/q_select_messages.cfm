<!---

	select to / from messages

--->

<cfquery name="q_select_messages" datasource="mytunesbutleruserdata">
SELECT
	messages.entrykey,
	messages.subject,
	messages.body,
	messages.dt_created,
	DATE_FORMAT( messages.dt_created, '%Y%m%d%H%i%s') AS num_created,
	messages.userkey_to,
	messages.userkey_from,
	messages.status_read,
	messages.linked_objectkey,
	user_to.username AS username_to,
	user_to.pic AS user_to_pic,
	user_from.username AS username_from,
	user_from.pic AS user_from_pic
FROM
	messages
LEFT JOIN users AS user_to
	ON (user_to.entrykey = messages.userkey_to)
LEFT JOIN users AS user_from
	ON (user_from.entrykey = messages.userkey_from)	
WHERE
	(messages.userkey = <cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.securitycontext.entrykey#">)
ORDER BY
	messages.dt_created DESC
;
</cfquery>
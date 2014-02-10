<!---

	insert into s3 log

--->

<cfquery name="q_insert_s3_log" datasource="mytunesbutlerlogging">
INSERT INTO
	s3log
	(
	entrykey,
	dt_created,
	url,
	Authorization,
	requesttype,
	response
	)
VALUES
	(
	<cfqueryparam cfsqltype="cf_sql_varchar" value="#a_str_entrykey#">,
	<cfqueryparam cfsqltype="cf_sql_timestamp" value="#Now()#">,
	<cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.url#">,
	<cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.Authorization#">,
	<cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.reqtype#">,
	''
	)
;
</cfquery>
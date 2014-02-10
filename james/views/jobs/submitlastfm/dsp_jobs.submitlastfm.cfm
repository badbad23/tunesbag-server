<!---

	submit data to AudioScrobbler

--->

<cfinclude template="/common/scripts.cfm">

<cfquery name="q_select_items" datasource="mytunesbutlerlogging">
SELECT
	lastfm_submit_data.artist,
	lastfm_submit_data.dt_played,
	lastfm_submit_data.handled,
	lastfm_submit_data.id,
	lastfm_submit_data.name,
	lastfm_submit_data.tracklen,
	lastfm_submit_data.userkey,
	3rdparty_ids.username AS lastfm_username,
	3rdparty_ids.pwd AS lastfm_pwd
FROM
	lastfm_submit_data
LEFT JOIN
	mytunesbutleruserdata.3rdparty_ids AS 3rdparty_ids ON ((3rdparty_ids.userkey = lastfm_submit_data.userkey) AND (3rdparty_ids.servicename = 'lastfm') AND (3rdparty_ids.isworking = 1))
WHERE
	lastfm_submit_data.handled = 0
	AND
	LENGTH( 3rdparty_ids.username ) > 0
	AND
	LENGTH( 3rdparty_ids.pwd ) > 0
LIMIT
	100
	;
</cfquery>

<cfdump var="#q_select_items#">

<cfloop query="q_select_items">
	
	<cfset a_str_username = q_select_items.lastfm_username />
	<cfset a_str_pwd = q_select_items.lastfm_pwd />
	
	<cfset a_ts = application.udf.GetEpochTime() />
	<cfset a_str_token = LCase( Hash( Lcase( Hash( a_str_pwd ) ) & a_ts ) ) />
	
	<!--- <cfdump var="#a_str_token#">--->
	
	<cfset a_str_url = 'http://post.audioscrobbler.com/?hs=true&p=1.2&c=tba&v=0.1&u=#q_select_items.lastfm_username#&t=#a_ts#&a=#a_str_token#' />
	
	<cfhttp method="get" charset="utf-8" url="#a_str_url#" useragent="tunesBag Submitter 0.1 BETA"></cfhttp>
	
	<cfset a_str_content = cfhttp.FileContent />
	
	<!--- <cfdump var="#cfhttp#"> --->
	
	<cfif FindNoCase( 'OK', a_str_content ) IS 1>
	
		<cfset a_struct_response.response = ListGetAt( a_str_content, 1, Chr( 10) ) />
		<cfset a_struct_response.sessionkey = ListGetAt( a_str_content, 2, Chr( 10) ) />
		<cfset a_struct_response.submission = ListGetAt( a_str_content, 4, Chr( 10) ) />
	
		<cfdump var="#a_struct_response#">
			
		<cfhttp method="post" charset="utf-8" url="#a_struct_response.submission#" useragent="tunesBag Submitter 0.1 BETA">
			<cfhttpparam type="formfield" name="s" value="#a_struct_response.sessionkey#" encoded="true">
			<cfhttpparam type="formfield" name="a[0]" value="#q_select_items.artist#" encoded="true" />
			<cfhttpparam type="formfield" name="t[0]" value="#q_select_items.name#" encoded="true" />
			<cfhttpparam type="formfield" name="i[0]" value="#application.udf.GetEpochTime(  q_select_items.dt_played )#" encoded="true" />
			<cfhttpparam type="formfield" name="o[0]" value="P" />
			<cfhttpparam type="formfield" name="r[0]" value="L" />
			<cfhttpparam type="formfield" name="l[0]" value="#Val( q_select_items.tracklen )#" />
			<cfhttpparam type="formfield" name="b[0]" value="" />
			<cfhttpparam type="formfield" name="n[0]" value="" />
			<cfhttpparam type="formfield" name="m[0]" value="" />
		</cfhttp>
		
		<!--- <cfdump var="#cfhttp#"> --->
		success.<br /><br />
	
	<cfelse>
	
		error.<br /><br />
		<cfdump var="#cfhttp.FileContent#">
	
		<!--- access is not working --->		
		<cflog application="false" file="tb_audioscrobbler_submit" log="Application" type="warning" text="#a_str_username# #cfhttp.FileContent#">
		
		<!--- update to is not working --->
		<cfquery name="q_update_is_not_working" datasource="mytunesbutleruserdata">
		UPDATE
			3rdparty_ids
		SET
			isworking = 0
		WHERE
			(userkey = <cfqueryparam cfsqltype="cf_sql_varchar" value="#q_select_items.userkey#">)
			AND
			(servicename = 'lastfm')
		;
		</cfquery>
	
	</cfif>

	<cfquery name="q_update_handled" datasource="mytunesbutlerlogging">
	UPDATE
		lastfm_submit_data
	SET
		handled = 1
	WHERE
		id = <cfqueryparam cfsqltype="cf_sql_integer" value="#q_select_items.id#">
	;
	</cfquery>

</cfloop>
<!---

	request API 

--->

<cfinclude template="/common/scripts.cfm">

<cfset a_str_app_key = event.getArg( 'appkey' ) />
<cfset q_select_all_apps = event.getArg( 'q_select_all_applications' ) />
<cfset a_str_app_remote_key = event.getArg( 'a_str_app_remote_key' ) />

<cfquery name="q_select_app_name" dbtype="query">
SELECT
	*
FROM
	q_select_all_apps
WHERE
	entrykey = <cfqueryparam cfsqltype="cf_sql_varchar" value="#a_str_app_key#">
;
</cfquery>

<cfif q_select_app_name.recordcount IS 0>

	<cfsavecontent variable="request.content.final">
		<div class="status">
			The requested application does not exist (anymore)
		</div>	
	</cfsavecontent>
	
	<cfexit method="exittemplate">
</cfif>

<cfsavecontent variable="request.content.final">

<h1>Access to your data requested</h1>

<form action="/james/?">
<input type="hidden" name="event" value="user.api.requestremotekey" />
<input type="hidden" name="appkey" value="" />

<div class="confirmation">
The following application has requested access to your data: <b><cfoutput>#htmleditformat( q_select_app_name.appname )#</cfoutput></b>
<br /><br />
<cfoutput>#application.udf.si_img( 'key' )#</cfoutput> We protect your privacy:
You do not need to provide your password to the other application - just your username and this remote key.
<br /><br />
Please provide the following remote key to this application if you want to allow access:
</div>
<div class="status">

<h1><cfoutput>#a_str_app_remote_key#</cfoutput></h1>
</div>



</form>

</cfsavecontent>
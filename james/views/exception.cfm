<!---

	An exception happend!

--->

<cfinclude template="/common/scripts.cfm">

<cfset variables.exception = event.getArg("exception") />

<!--- <cfset exception_info = StructNew() />
<cfset exception_info.message = variables.exception.getMessage()/> --->
<!--- <cfset exception_info.details = variables.exception.getDetail() /> --->
<!--- <cfset exception_info.ExtendedInfo = variables.exception.getExtendedInfo() /> --->
<!--- <cfset exception_info.context = variables.exception.getTagContext() /> --->
<!--- <cfset exception_info = variables.exception.getCaughtException() />

<cfwddx action="cfml2wddx" input="#variables.exception_info#" output="a_str_wddx"> --->

<!--- <cfif application.udf.IsLoggedIn()>
	<cfset a_str_userkey = application.udf.GetCurrentSecurityContext().entrykey />
<cfelse>
	<cfset a_str_userkey = cgi.REMOTE_ADDR />
</cfif>

<cfset a_str_uuid = CreateUUID() />

<cfquery name="q_insert_log" datasource="mytunesbutlerlogging">
INSERT INTO
	exceptionlog
	(
	entrykey,
	dt_created,
	userkey,
	wddx,
	message)
VALUES
	(
	<cfqueryparam cfsqltype="cf_sql_varchar" value="#a_str_uuid#">,
	<cfqueryparam cfsqltype="cf_sql_timestamp" value="#CreateODBCDateTime( Now() )#">,
	<cfqueryparam cfsqltype="cf_sql_varchar" value="#a_str_userkey#">,
	<cfqueryparam cfsqltype="cf_sql_varchar" value="#a_str_wddx#">,
	<cfqueryparam cfsqltype="cf_sql_varchar" value="#Mid( variables.exception.getMessage(), 1, 250)#">
	)
;
</cfquery> --->

<html>
	<head>
		<style media="all" type="text/css">
			body,p,td,div {font-family:"Lucida Grande",Arial}
		</style>
		<title>An error occured!</title>
	</head>
<body style="padding:40px">
	<div style="padding:60px">
	<h2>An error occured</h2>
	
	<br /><br />
	We have logged the error and created an alert for our Dev team.
<!--- 	<br /><br />
	Please contact support@tunesBag.com with the reference ID <b><cfoutput>#a_str_uuid#</cfoutput></b> in case of any questions. --->
	</div>
</body>
</html>

<!--- 

<cfoutput>
<table>
	<tr>
		<td valign="top"><h4>Message</h4></td>
		<td valign="top"><p>#variables.exception.getMessage()#</p></td>
	</tr>
	<tr>
		<td valign="top"><h4>Detail</h4></td>
		<td valign="top"><p>#variables.exception.getDetail()#</p></td>
	</tr>
	<tr>
		<td valign="top"><h4>Extended Info</h4></td>
		<td valign="top"><p>#variables.exception.getExtendedInfo()#</p></td>
	</tr>
	<tr>
		<td valign="top"><h4>Tag Context</h4></td>
		<td valign="top">
			<cfset variables.tagCtxArr = variables.exception.getTagContext() />
			<cfloop index="i" from="1" to="#ArrayLen(variables.tagCtxArr)#">
				<cfset variables.tagCtx = variables.tagCtxArr[i] />
				<p>#variables.tagCtx['template']# (#variables.tagCtx['line']#)</p>
			</cfloop>
		</td>
	</tr>
	<tr>
		<td valign="top"><h4>Caught Exception</h4></td>
		<td valign="top"><cfdump var="#variables.exception.getCaughtException()#" expand="false" /></td>
	</tr>
</table>
</cfoutput> --->
<!--- request an app key --->

<cfinclude template="/common/scripts.cfm">

<cfif NOT application.udf.IsLoggedIn()>
	<cfsavecontent variable="request.content.final">
		<a href="/rd/login/">You have to log in to view this page</a>
	</cfsavecontent>
	<cfexit method="exittemplate">
</cfif>

<cfparam name="form.name" type="string" default="" />

<cfsavecontent variable="request.content.final">
<br />

<cfif cgi.REQUEST_METHOD IS 'POST' AND Len( form.name ) GT 0>
	
	<cfquery name="qInsert" datasource="mytunesbutleruserdata">
	INSERT INTO
		applications
		(
		entrykey,
		userkey,
		appname,
		dt_created,
		privileged
		)
	VALUES
		(
		<cfqueryparam cfsqltype="cf_sql_varchar" value="#createUUID()#" />,
		<cfqueryparam cfsqltype="cf_sql_varchar" value="#application.udf.GetCurrentSecurityContext().entrykey#" />,
		<cfqueryparam cfsqltype="cf_sql_varchar" value="#trim( form.name )#">,
		<cfqueryparam cfsqltype="cf_sql_timestamp" value="#Now()#">,
		0
		)
	;
	</cfquery>
	
</cfif>

<cfquery name="qSelectIsssuedAPIKeys" datasource="mytunesbutleruserdata">
SELECT
	*
FROM
	applications
WHERE
	userkey = <cfqueryparam cfsqltype="cf_sql_varchar" value="#application.udf.GetCurrentSecurityContext().entrykey#">
;
</cfquery>
<h2>Known applications (<cfoutput>#qSelectIsssuedAPIKeys.recordcount#</cfoutput>)</h2>

<table class="table_overview">
	<thead>
		<tr>
			<th>Application name</th>
			<th>Application key</th>
		</tr>
	</thead>
	<cfoutput query="qSelectIsssuedAPIKeys">
	<tr>
		<td>
			#htmleditformat( qSelectIsssuedAPIKeys.appname )#
		</td>
		<td>
			#htmleditformat( qSelectIsssuedAPIKeys.entrykey )#
		</td>
	</tr>
	</cfoutput>
</table>
<br /><br />
<h2>Add a new application</h2>
<form action="/james/?event=info.service.api.requestkey" method="post">
<table class="table_edit table_details">
	<tr>
		<td class="field_name">
			Name
		</td>
		<td>
			<input type="text" name="name" value="" />
		</td>
	</tr>
	<tr>
		<td class="field_name"></td>
		<td>
			<input type="submit" value="Add app" />
		</td>
	</tr>
</table>
</form>

<!--- <cfif cgi.REQUEST_METHOD IS 'POST'>

<div class="status">
Thank you for your submission - we will contact you soon with an API key.
</div>

<cfmail from="hansjoerg@tunesBag.com" to="hansjoerg@tunesBag.com" subject="api key request" type="html">
<cfdump var="#form#">
<cfdump var="#cgi#">
</cfmail>
</cfif> --->

<!--- <form action="/james/?event=info.service.api.requestkey" method="post">

All fields are mandatory
<br />
<table class="table_details table_edit">
	<tr>
		<td class="field_name">
			Name:
		</td>	
		<td>
			<input type="text" name="name" />
		</td>
	</tr>
	<tr>
		<td class="field_name">
			tunesBag - username:
		</td>	
		<td>
			<input type="text" name="username" />
		</td>
	</tr>
	<tr>
		<td class="field_name">
			Your homepage/blog:
		</td>	
		<td>
			<input type="text" name="homepage" />
		</td>
	</tr>		
	<tr>
		<td class="field_name">
			Which languages are you planning to use for the tunesBag API:
		</td>	
		<td>
			<input type="text" name="homepage" />
		</td>
	</tr>		
	<tr>
		<td class="field_name">
			Which kind of app do you want to develop?
		</td>	
		<td>
			<textarea name="appdescr" rows="5" cols="70"></textarea>
		</td>
	</tr>		
	<tr>
		<td></td>
		<td>
			<input type="submit" value="Request the API key" class="btn" />
		</td>
	</tr>
</table>

</form> --->

</cfsavecontent>
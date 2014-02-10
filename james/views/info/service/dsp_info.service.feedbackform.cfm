<!---

	send feedback

--->
<cfinclude template="/common/scripts.cfm">

<cfset a_str_subject = event.getArg( 'subject' ) />
<cfset a_str_message = event.getArg( 'message' ) />

<cflocation addtoken="false" url="http://feedback.tunesbag.com" />

<cfsavecontent variable="request.content.final">
<br /><br />
<h2>Your feedback is needed and welcome!</h2>

<cfif Len( a_str_message ) GT 0>
	<div class="confirmation">
	Your message has been sent!
	</div>
	
<cfmail from="support@tunesBag.com" to="support@tunesbag.com" subject="Feedback on tunesBag.com">
--- 
Subject: #a_str_subject#
---
Message: #a_str_message#
---
User: <cfif application.udf.IsLoggedIn()>
		#application.udf.GetCurrentSecurityContext().username# #application.udf.GetCurrentSecurityContext().entrykey#
		</cfif>
---
Browser: #cgi.HTTP_USER_AGENT#
---
IP: #cgi.REMOTE_ADDR#
</cfmail>
	
</cfif>

<form method="post" action="/james/?event=info.service.feedbackform">

<table class="table_details table_edit">
	<tr>
		<td class="field_name"></td>
		<td nowrap="true">
			<a href="http://groups.google.com/group/tunesbagcom" target="_blank">In case you think the question is interesting for all users,
			<br />
			please consider joining and posting in our Google group</a>
		</td>
	</tr>
	<tr>
		<td class="field_name">
			<cfoutput>#application.udf.GetLangValSec( 'cm_wd_subject' )#</cfoutput>
		</td>
		<td>
			<input type="text" name="subject" />
		</td>
	</tr>
	<!--- <tr>
		<td class="field_name">
			Category
		</td>
		<td>
			<input type="category">
		</td>
	</tr> --->
	<tr>
		<td class="field_name">
			<cfoutput>#application.udf.GetLangValSec( 'cm_wd_text' )#</cfoutput>
		</td>
		<td>
			<textarea name="message" rows="10" cols="40"></textarea>
		</td>
	</tr>
	<tr>
		<td class="field_name"></td>
		<td>
			<input type="submit" value="<cfoutput>#application.udf.GetLangValSec( 'cm_wd_btn_send' )#</cfoutput>" class="btn" />
		</td>
	</tr>
</table>

</form>

</cfsavecontent>
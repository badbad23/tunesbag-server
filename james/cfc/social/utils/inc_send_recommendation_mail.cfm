<!--- 

	send the mail

 --->
<cfset a_arr_data = [arguments.securitycontext.username, arguments.title] />

<cfset a_subject = application.udf.GetLangValSec( 'cm_ph_recommend_mail_subject', a_arr_data ) />


<cfsavecontent variable="sTextMail"><cfoutput>
#application.udf.GetLangValSec( 'cm_wd_hello' )#<cfif Len( arguments.firstname ) GT 0> #arguments.firstname#</cfif>,

#arguments.securitycontext.username# wants to share this with you:

** #arguments.title# **#chr(13)##chr(10)#
#Replace( arguments.link, ' ', '+', 'ALL')#

<cfif arguments.isuser>

Click here to login and listen to the track in full quality:
http://www.tunesBag.com/
<cfelse>
Click on the link above to listen to the recommended music.
</cfif>
	
<cfif Len( arguments.comment ) GT 0>#chr(13)##chr(10)##chr(13)##chr(10)#---
#arguments.securitycontext.username# said:

#arguments.comment#
---</cfif>

Stay tuned ;-)

Your tunesBag.com team

--
tunesBag is your personal online music hub - you can upload and access your
tunes from any browser in the world and send recommendations for playlists
or tracks to your friends. Simply check out http://www.tunesBag.com/
</cfoutput></cfsavecontent>

<cfsavecontent variable="sHTMLMail"><cfoutput>
<p>#application.udf.GetLangValSec( 'cm_wd_hello' )#<cfif Len( arguments.firstname ) GT 0> #arguments.firstname#</cfif>,</p>

<p>
	<a href="http://www.tunesBag.com/user/#arguments.securitycontext.username#"><img src="http://www.tunesBag.com/#application.udf.getUserImageLink( arguments.securitycontext.username, 75 )#" style="height: 36px; width: 30px;border:0px;padding: 4px;vertical-align:middle" /> #arguments.securitycontext.username#</a> wants to share this with you:</p>

<p>
	<a href="#Replace( arguments.link, ' ', '+', 'ALL')#"><strong>#arguments.title#</strong></a>
</p>
<cfif arguments.isuser>
<p>
	<a href="http://www.tunesBag.com/rd/start">Click here to login and listen to the track in full quality</a>
</p>
<cfelse>
<p>
	Click on the link above to listen to the recommended music.
</p>
</cfif>
	
<cfif Len( arguments.comment ) GT 0>
<p>
	#arguments.securitycontext.username# said:
	<br />
	#arguments.comment#
</p>
</cfif>

<p>Stay tuned ;-)
<br />
Your tunesBag.com team
</p>
<p>
tunesBag is your personal online music hub - you can upload and access your
tunes from any browser in the world and send recommendations for playlists
or tracks to your friends. Simply check out <a href="http://www.tunesBag.com/">tunesBag.com</a>
</p>
</cfoutput>
</cfsavecontent>

<cfset oMsg.sendGenericEmail( bIsRegisteredUser = isUser,
		sSubject = 'tunesBag.com: #a_subject#',
		sSender = 'tunesBag.com <noreply@tunesBag.com>', sTo = a_str_recipient,
		sHTMLContent = sHTMLMail, sTextContent = sTextMail, stUserData = stUserData ) />
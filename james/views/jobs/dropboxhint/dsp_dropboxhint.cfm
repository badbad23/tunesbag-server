<!--- 

select first-timers after a certain period of time

 --->

<cfquery name="qInfoMail" datasource="mytunesbutlercontent">
SELECT	state.user_ID,
		u.username,
		u.firstname,
		u.email,
		u.entrykey AS userkey
FROM	sourcessyncstate AS state
LEFT JOIN	mytunesbutleruserdata.users AS u ON (u.id = state.user_ID)
WHERE	state.servicename	= <cfqueryparam cfsqltype="cf_sql_varchar" value="#application.const.S_SERVICE_DROPBOX#" />
		AND
		state.status				= <cfqueryparam cfsqltype="cf_sql_integer" value="#application.const.I_SYNC_SOURCE_STATUS_DEFAULT#" />
		AND
		/* more than 15 minutes ago */
		state.dt_lastupdate < <cfqueryparam cfsqltype="cf_sql_timestamp" value="#DateAdd( 'n', -15, Now() )#" />
		AND NOT
		u.id IS NULL
ORDER BY
		state.dt_lastupdate DESC
</cfquery>

<cfdump var="#qInfoMail#">

<cfset oMsg = application.beanFactory.getBean( 'MessagesComponent' ) />

<cfloop query="qInfoMail">
	
	<cfset sPref = application.beanFactory.getBean( 'UserComponent' ).GetPreference(
			userkey			= qInfoMail.userkey,
			name			= application.const.S_PREF_DROPBOX_INTRO_SENT,
			defaultvalue	= 0
			) />
			
	<cfif sPref IS 0>
		
		<cfset stSecurityContext = application.beanFactory.getBean( 'SecurityComponent' ).GetUserContextByUserkey( qInfoMail.userkey ) />

		
		<cfset stMediaItems = application.beanFactory.getBean( 'MediaItemsComponent').GetUserContentDataMediaItems(
			librarykeys 	= '',
			securitycontext	= stSecurityContext,
			maxrows			= 15,
			search_criteria	= 'SOURCE?VALUE=dp'
			) />

		<cfset qItems = stMediaItems.q_SELECT_ITEMS />
		
		<cfdump var="#qItems#">
		
		<!--- any tracks found? --->
		<cfif qItems.recordcount GT 0>
		
<cfsavecontent variable="sHTML">
<cfoutput><p>Hi there -</p>
<p><b>Your Dropbox content is ready to play!</b><br />
<br />
We've sucessfully synced your Dropbox data and it's now available in your <a href="http://www.tunesBag.com/start">tunesBag library</a>!
<br /><br />
<b>What we suggest you to do now:</b>
<br />
<ul>
<li>You can now start accessing your tracks using your <a href="http://www.tunesBag.com/">browser</a>, <a href="http://www.tunesbag.com/rd/iphone/appstore">iPhone</a>, <a href="http://www.tunesbag.com/squeezenetwork/">Squeeezebox</a> and other clients.</li>

<li>Please <a href="https://www.dropbox.com/apps/9861/tunesbag-com-mediaplayer">rate our service at Dropbox</a>.</li>
<li>Connect with us and become a <a href="http://facebook.com/tunesBag">Fan on Facebook</a> and recommend it to your friends!</li>
</ul>
<b>Have nice day!</b>
</p>
<p>We've found #qItems.recordcount#+ tracks including the following ones:
<br />
<table>
<cfloop query="qItems">
<tr>
	<td style="padding:3px">
		<a href="http://www.tunesBag.com/start/"><img src="http://www.tunesBag.com/#application.udf.getArtistImageByID( qItems.mb_artistid, 48 )#" width="48" height="46" alt="#htmleditformat( qItems.artist )#" border="0" /></a>
	</td>
	<td style="padding:3px">
		<a href="http://www.tunesBag.com/start/">#htmleditformat( qItems.name )#</a>
		<br />
		<span style="color:gray">#htmleditformat( qItems.artist )#</span>
	</td>
</tr>
</cfloop>
</table>
</p></cfoutput>
</cfsavecontent>		

<cfsavecontent variable="sText">
Hi there -

Your Dropbox content is ready to play!

We've sucessfully synced your Dropbox data and it's now available in your tunesBag library at http://www.tunesBag.com/start!

What we suggest you to do now:

- You can now start accessing your tracks using your browser (www.tunesBag.com), iPhone (http://www.tunesbag.com/rd/iphone/appstore), Squeeezebox (http://www.tunesbag.com/squeezenetwork/) and other clients.

- Please rate our service at Dropbox: https://www.dropbox.com/apps/9861/tunesbag-com-mediaplayer

- Connect with us and become a Fan on Facebook http://facebook.com/tunesBag!

Have nice day!

We've found #qItems.recordcount#+ tracks including the following ones:
<cfloop query="qItems">
#htmleditformat( qItems.name )# - #htmleditformat( qItems.artist )#
</cfloop>
</cfsavecontent>

			<cfoutput>#sHTML#</cfoutput>
			
			<cfset stUserdata = { entrykey = qInfoMail.userkey, firstname = qInfoMail.firstname, email = qInfoMail.email, username = qInfoMail.username } />

			<cfset oMsg.sendGenericEmail( bIsRegisteredUser = true,
						sSubject = 'Dropbox content ready to play on tunesBag!',
						sSender = 'tunesBag.com <support@tunesBag.com>',
						sTo = qInfoMail.firstname & ' <' & qInfoMail.email & '>',
						sHTMLContent = sHTML, sTextContent = sText, stUserData = stUserData ) />
						
			<!--- store key, don't resend this message --->
			<cfset sPref = application.beanFactory.getBean( 'UserComponent' ).StorePreference(
				userkey	= qInfoMail.userkey,
				name	= application.const.S_PREF_DROPBOX_INTRO_SENT,
				value	= 1
				) />

		
		</cfif>
		

	
	</cfif>

</cfloop>
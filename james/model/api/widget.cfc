<!---

	widgets

--->

<cfcomponent name="widgets" displayname="widgets"output="false" extends="MachII.framework.Listener" hint="Handle widgets">
	
<cfinclude template="/common/scripts.cfm">

<cffunction name="configure" access="public" output="false" returntype="void" hint="Configures this listener as part of the Mach-II  framework"> 
	<!--- do nothing --->
</cffunction> 

<cffunction name="CheckWidgetParametersLastPlayedImage" access="public" output="false" returntype="void" hint="Check Widget parameters">
	<cfargument name="event" type="MachII.framework.Event" required="true" />
	
	<cfset var a_str_request = event.getArg( 'request' ) />
	<cfset var a_str_userkey = '' />
	<cfset var a_str_username = ListLast( a_str_request, '/' ) />
	<cfset var a_str_img_file = GetDirectoryFromPath( GetBaseTemplatePath() ) & 'template_lastplayedwidget.png' />
	<cfset var q_select_last_track = 0 />
	<cfset event.setArg( 'username', a_str_username) />
	
	<cfset a_str_userkey = getProperty( 'beanFactory' ).getBean( 'UserComponent' ).getEntrykeyByUsername( a_str_username ) />
	
	<cfif Len( a_str_userkey ) IS 0>
		<cfreturn />
	</cfif>
	
	<cfquery name="q_select_last_track" datasource="mytunesbutlerlogging">
	SELECT
		playeditems.mediaitemkey,
		mediaitems.artist,
		mediaitems.album,
		mediaitems.name
	FROM
		playeditems
	INNER JOIN mytunesbutleruserdata.mediaitems AS mediaitems
		ON (mediaitems.entrykey = playeditems.mediaitemkey)
	WHERE
		playeditems.userkey = <cfqueryparam cfsqltype="cf_sql_varchar" value="#a_str_userkey#">
	ORDER BY
		playeditems.dt_created DESC
	LIMIT
		1
	;
	</cfquery>
	
	<cfset event.setArg( 'q_select_last_track', q_select_last_track ) />
	<cfset event.setArg( 'templateimg', a_str_img_file ) />
	<cfset event.setarg( 'userkey', a_str_userkey )>
	
</cffunction>

<cffunction name="CheckWidgetParameters" access="public" output="false" returntype="void" hint="Check Widget parameters">
	<cfargument name="event" type="MachII.framework.Event" required="true" />
	
	<cfset var a_str_username = event.getArg( 'username' ) />
	
	<cfif Len( a_str_username ) IS 0>
		<cfreturn />
	</cfif>
	
</cffunction>

<cffunction access="public" name="CheckAdd2BagURL" output="false" returntype="void" hint="Check given add2bag URL">
	<cfargument name="event" type="MachII.framework.Event" required="true" />
	
	<cfset var a_str_url = trim(event.getArg( 's' )) />
	<cfset var cfhttp = 0 />
	<cfset var a_bol_ok = false />
	
	<cfif Len( a_str_url ) IS 0 OR FindNoCase( 'http://', a_str_url ) IS 0>
		<cfreturn />
	</cfif>

	<!--- check the file --->	
	<cfset a_bol_ok = getProperty( 'beanFactory' ).getBean( 'UploadComponent' ).CheckPointToURLData( location = a_str_url ).result />
	
	<cfset event.setArg( 'a_bol_ok', a_bol_ok ) />
	
	<!--- everything OK? add and proceed --->
	<cfif a_bol_ok AND application.udf.IsLoggedIn()>
		<cflocation addtoken="false" url="/james/?event=media.upload.webpage&DoCheckUpload=true&frmurl1=#UrlEncodedFormat( a_str_url )#&source=add2bag">
	</cfif>

</cffunction>

<cffunction access="public" name="CheckiTunesBarData" output="false" returntype="void" hint="get iTunes Bar parameters">
	<cfargument name="event" type="MachII.framework.Event" required="true" />
	
	<cfset var a_str_artist = event.getArg( 'artist' ) />
	<cfset var a_str_name = event.getArg( 'name' ) />
	<cfset var a_cmp_mediaitems = getProperty( 'beanFactory' ).getBean( 'MediaItemsComponent' ) />
	
	<!--- get social infos --->
	<cfset var a_struct_social_infos = getProperty( 'beanFactory' ).getBean( 'ContentComponent' ).getSocialInformationOfTrack( artist = a_str_artist,
									name = a_str_name,
									securitycontext = application.udf.GetCurrentSecurityContext() ) />
									
	<!--- TODO migrate to mbid --->
	<cfset var a_common_artist_info = a_cmp_mediaitems.GetCommonArtistInformation( mbid = 0 ) />
									
	<!--- track exists in library? --->
	<cfset var a_search_track_result = 0 />
	
	<cfset var a_str_search_criteria = 'ARTIST?VALUE=' & a_str_artist & '|' & 'NAME?VALUE=' & a_str_name & '' />									
									
	<cfset event.setArg( 'a_common_artist_info', a_common_artist_info ) />	
	<cfset event.setArg( 'a_struct_social_infos', a_struct_social_infos ) />
	
	<!--- search through the own library --->
	<cfset a_search_track_result = a_cmp_mediaitems.GetUserContentDataMediaItems( securitycontext = application.udf.GetCurrentSecurityContext(),
					search_criteria = a_str_search_criteria,
					librarykeys =  a_cmp_mediaitems.GetAllPossibleLibrarykeysForLibraryAccess( application.udf.GetCurrentSecurityContext() ) ) />
								
	<cfset event.setArg( 'a_search_track_result', a_search_track_result) />	
	
</cffunction>

</cfcomponent>
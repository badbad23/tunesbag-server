<cfinclude template="/common/scripts.cfm" />

<!--- do we have a "real" plist or a dynamic one? --->
<cfswitch expression="#event.getArg( 'type', 'default' )#">
	<cfcase value="custom">
		
		<!--- custom plist using search criteria etc --->
		
		<cfset sCriteria = event.getArg( 'criteria' ) />
		
		<!--- how to order? --->
		<cfset sOrder = event.getArg( 'order' ) />
		
		<cfset stData = getProperty( 'beanFactory' ).getBean( 'MediaItemsComponent' ).GetUserContentDataMediaItems( securitycontext = a_struct_securitycontext,
										librarykeys = getProperty( 'beanFactory' ).getBean( 'MediaItemsComponent' ).GetAllPossibleLibrarykeysForLibraryAccess( a_struct_securitycontext ),
										search_criteria = sCriteria,
										orderby = sOrder ) />
										
		<cfset qItems = stData.q_select_items />
										
		<cfset stPlist = {} />
		<cfset stPlist.q_select_items = QueryNew( 'name', 'Varchar' ) />
		<cfset QueryAddRow( stPlist.q_select_items, 1 ) />
		<cfset QuerySetCell( stPlist.q_select_items, 'name', '&##9889; ' & event.getArg( 'plistname', 'Custom Playlist') ) />
		
		
	</cfcase>
	<cfdefaultcase>
		
		<!--- a real playlist ... load items using plist commands --->
		<cfset sPlistkey = event.getArg( 'entrykey' ) />
		
		<cfset stPlist = getProperty( 'beanFactory' ).getBean( 'MediaItemsComponent' ).GetUserContentData(securitycontext = a_struct_securitycontext,
					filter = { entrykeys = sPlistkey },
					librarykeys = getProperty( 'beanFactory' ).getBean( 'MediaItemsComponent' ).GetAllPossibleLibrarykeysForLibraryAccess( a_struct_securitycontext ),
					type = 'playlists') />
		
		<!--- apply filter --->
		<cfset stFilter = { ids = stPlist.q_select_items.items, info_playlistkey = sPlistkey } />
		
		<!--- how to order? --->
		<cfset sOrder = event.getArg( 'order' ) />
		
		<cfset stItems = getProperty( 'beanFactory' ).getBean( 'MediaItemsComponent' ).GetUserContentData( securitycontext = a_struct_securitycontext,
				librarykeys = getProperty( 'beanFactory' ).getBean( 'MediaItemsComponent' ).GetAllPossibleLibrarykeysForLibraryAccess( a_struct_securitycontext ),
				type = 'mediaitems',
				filter = stFilter,
				orderby = sOrder ) />
				
		<cfset qItems = stItems.q_select_items />
		
	</cfdefaultcase>
</cfswitch>

<!--- get bitrate to use --->
<cfset iBitrate = getProperty( 'beanFactory' ).GetBean( 'UserComponent' ).GetPreference( userkey = a_struct_securitycontext.entrykey,
									name = application.const.S_PREF_SQBN_STREAMING_BITRATE,
									defaultvalue = 128 ) />

<cfif Val( iBitrate ) IS 0>
	<cfset iBitrate = 128 />
</cfif>

<!--- common output routine --->
<cfsavecontent variable="request.content.final">
<cfoutput>
<opml version="1.0" xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:fn="http://www.w3.org/2005/xpath-functions">
  <head>
    <title>#xmlformat( stPlist.q_select_items.name )#</title>
	
	<dateCreated>#application.udf.getHTTPDate( Now() )#</dateCreated>
	<dateModified>#application.udf.getHTTPDate( Now() )#</dateModified>
	
	<ownerName>tunesBag.com Limited</ownerName>
	<ownerEmail>office@tunesBag.com</ownerEmail>
	
  </head>
  <body>
	
	<cfloop query="qItems" endrow="200">
	
	<cfset sDisplay =  qItems.name & ' - ' & qItems.artist />
	<cfset sDisplay = ReplaceNoCase( sDisplay, '"', '', 'ALL' ) />
	
	<outline index="#qItems.currentrow#" duration="#qItems.totaltime#" text="#xmlformat( sDisplay )#" type="audio"
		URL="http://#cgi.SERVER_NAME#:#cgi.SERVER_PORT#/api/rest/items/get/deliver/?#getAPIUserRemotekeyPath(event)#&amp;entrykey=#UrlEncodedFormat( qItems.entrykey )#&amp;name=#UrlEncodedFormat( qItems.name )#&amp;targetbitrate=#iBitrate#&amp;options=forwardtoplayurl&amp;rand=#CreateUUID()#&amp;context=#application.const.I_PLAY_CONTEXT_USER_PLIST#&amp;f=#CreateUUID()#.mp3" />
	</cfloop>
	
	<cfif event.getArg( 'type', 'default' ) IS 'default'>
		<!--- add randomize link ... but only to real plists --->
		<outline text="&amp;##9858; &amp;##9860; #application.udf.GetLangValSec( 'cm_wd_randomize' )#"
				type="playlist"
				URL="http://#cgi.SERVER_NAME#:#cgi.SERVER_PORT#/api/rest/opml/playlist/?#getAPIUserRemotekeyPath(event)#&amp;entrykey=#stPlist.q_select_items.entrykey#&amp;order=RANDOMIZE&amp;dummy=#CreateUUID()#.opml" />
	</cfif>
	
  </body>
</opml>
</cfoutput>
</cfsavecontent>
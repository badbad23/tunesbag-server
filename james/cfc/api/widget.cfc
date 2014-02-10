<!--- widget --->

<cfcomponent displayName="Widget" hint="do Widget stuff" output="false">
	
	<cfinclude template="/common/scripts.cfm">
	
	<cffunction access="public" name="init" returntype="james.cfc.api.widget" output="false">
		<cfreturn this />
	</cffunction>
	
	<!--- 
	
		log an embedding request
	
	 --->
	<cffunction access="public" name="logWidgetEmbedding" output="false" returntype="struct"
			hint="a widget has been embedded into a website">
		<cfargument name="sSource" type="string" required="true" />
		<cfargument name="sWidgetKey" type="string" required="true"
			hint="entrykey of widget" />
		<cfargument name="sPlistkey" type="string" required="true" />
		<cfargument name="sUserAgent" type="string" required="true" />
		<cfargument name="sIP" type="string" required="true" />
		<cfargument name="sLocation" type="string" required="true"
			hint="http location if possible" />
		
		<cfset var stReturn = application.udf.GenerateReturnStruct() />
		<cfset var oTransfer = application.beanFactory.getBean( 'LogTransfer' ).getTransfer() />
		<cfset var oItem = oTransfer.new( 'logging.embed_notify' ) />
		<cfset var sEntrykey = CreateUUID() />
		
		<cfset oItem.setdt_created( Now() ) />
		<cfset oItem.setEntrykey( sEntrykey ) />
		<cfset oItem.setplistkey( arguments.sPlistkey ) />
		<cfset oItem.setip( Left( arguments.sIP, 50) ) />
		<cfset oItem.setUserAgent( Left( arguments.sUserAgent, 100) ) />
		<cfset oItem.setlocation( Left( arguments.sLocation, 500) ) />
		<cfset oItem.setsource( Left( arguments.sSource, 20) ) />
		<cfset oItem.setWidgetkey( arguments.sWidgetKey ) />

		<!--- store --->
		<cfset oTransfer.save( oItem ) />
		
		<!--- return the string as session key --->
		<cfset stReturn.sEntrykey = sEntrykey />
		
		<cfreturn application.udf.SetReturnStructSuccessCode(stReturn) />
	
	</cffunction>
	
	<!--- widget request to play a track --->
	<cffunction access="public" name="checkEmbedDeliverTrack" output="false" returntype="struct">
		<cfargument name="sWidgetKey" type="string" required="true"
			hint="entrykey of widget" />
		<cfargument name="sSessionkey" type="string" required="true"
			hint="session key" />
		<cfargument name="sTrackKey" type="string" required="true"
			hint="entrykey of track" />
		<cfargument name="sIP" type="string" required="true"
			hint="source IP" />
			
		<cfset var stReturn = application.udf.GenerateReturnStruct() />
		<cfset var oTransfer = application.beanFactory.getBean( 'LogTransfer' ).getTransfer() />
		<cfset var oItem = oTransfer.readByProperty( 'logging.embed_notify', 'entrykey', arguments.sSessionkey ) />
		<cfset var stSecurityContext = application.udf.generatePseudoSecurityContext( lang_id = 'en', ip = arguments.sIP ) />
		
		<!--- not a valid request --->
		<cfif NOT oItem.getIsPersisted()>
			<cfreturn application.udf.SetReturnStructErrorCode(stReturn, 9000, application.udf.GetLangValSec( 'er_ph_9000' ) ) />
		</cfif>
		
		<!--- TODO: Check security --->
		
		<!--- get deliver link --->
		<cfset var stDeliverInformation = application.beanFactory.getBean( 'MediaItemsComponent' ).GetMediaItem(applicationkey = arguments.sWidgetKey,
						securitycontext = stSecurityContext,
						entrykey = arguments.sTrackKey,
						sessionkey = arguments.sSessionkey,
						type = 0,
						operation = 'PLAY',
						targetbitrate = 128,
						targetformat = 'mp3',
						deliver_mode = true,
						preview = false) />
		
		<cfif NOT stDeliverInformation.result>
			<cfreturn stDeliverInformation />
		</cfif>
		
		<cfset stReturn.location = stDeliverInformation.deliver_info.location />
		
		<cfreturn application.udf.SetReturnStructSuccessCode(stReturn) />
	
	</cffunction>
	
	
	<!--- 
	
		check the security and return the items if it is ok
	
	 --->
	<cffunction access="public" name="checkEmbedSecurity" output="false" returntype="struct">
		<cfargument name="sPlistkey" type="string" required="true" />
		<cfargument name="sIP" type="string" required="true"
			hint="source IP" />
		
		<cfset var stReturn = application.udf.GenerateReturnStruct() />
		<cfset var sOwnerUserkey = '' />
		<!--- create a pseudo security context  --->
		<cfset var stSecurityContext = application.udf.generatePseudoSecurityContext( lang_id = 'en', ip = arguments.sIP ) />
		
		<!--- check if the right is given --->
		<cfif NOT stSecurityContext.rights.playlist.INTERACTIVERADIO>
			<!--- <cfset stReturn.stSecurityContext = stSecurityContext /> --->
			<cfreturn application.udf.SetReturnStructErrorCode(stReturn, 9000, application.udf.GetLangValSec( 'er_ph_9000' ) ) />
		</cfif>
		
		<cfset stReturn.stSecurityContext = stSecurityContext />
		
		<!--- check if the plist exists and security is ok --->
		<cfset var stCheckAccess = application.beanFactory.getBean( 'SecurityComponent' ).CheckAccess(
					entrykey = arguments.sPlistkey,
					securitycontext = stSecurityContext,
					ip = arguments.sIP,
					type = 'playlist',
					action = 'play',
					context = 0 ) />
					
		<!--- <cfset stCheckAccess.error = 10 />
		<cfset stCheckAccess.errormessage = 'Not in your country' />
		<cfset stCheckAccess.result = false /> --->
		<cfset stReturn.stCheckAccess = stCheckAccess />
		
		<!--- Failed, return --->
		<cfif NOT stCheckAccess.result>
			<cfreturn stCheckAccess />
		</cfif>
		
		<!--- load the playlist items now --->
		<cfset sOwnerUserkey = stCheckAccess.q_select_plist_data.userkey />
		
		<!--- load items --->		
		<cfset var stOwnerSecurityContext = application.beanFactory.getBean( 'SecurityComponent' ).GetUserContextByUserkey( userkey = sOwnerUserkey ) />
		
		<cfset var stPlaylist = application.beanFactory.getBean( 'PlaylistsComponent' ).getSimplePlaylistInfo( playlistkey = arguments.sPlistkey ) />
		
		<!--- alright? --->
		<cfif NOT stPlaylist.result>
			<cfreturn stPlaylist />
		</cfif>
		
		<!--- return two queries --->
		<cfset stReturn.qPlist = stPlaylist.Q_SELECT_SIMPLE_PLIST_INFO />
		<cfset stReturn.qPlistItems = stPlaylist.Q_SELECT_ITEMS />
		
		<cfreturn application.udf.SetReturnStructSuccessCode(stReturn) />
	
	</cffunction>
	
</cfcomponent>
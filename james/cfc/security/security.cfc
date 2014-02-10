<!--- //

	Module:		Security Business Logic
	Action:		
	Description:	
	
// --->

<cfcomponent output="false" hint="Security CFC">
	
	<cfinclude template="/common/scripts.cfm">

<cffunction name="init" access="public" output="false" returntype="james.cfc.security.security"> 
	<!--- do nothing --->
	<cfreturn this />
</cffunction> 

<cffunction access="public" name="checkSendLoginInformation" output="false" returntype="struct"
		hint="send username/password to user">
	<cfargument name="username" type="string" required="true"
		hint="the username of which we need the password">

	<cfset var stReturn = application.udf.GenerateReturnStruct() />
	<cfset var oTransfer = application.beanFactory.getBean( 'UsersTransfer' ).getTransfer() />
	<cfset var oUser = oTransfer.readByProperty( 'users.user', 'username', arguments.username ) />
	<cfset var stUserdata = {} />
	<cfset var sHTMLMail = ''/>
	<cfset var sTextMail = '' />
	<cfset var oMsg = application.beanFactory.getBean( 'MessagesComponent' ) />
	<cfset stUserdata = { entrykey = oUser.getEntrykey(), firstname = oUser.getFirstname(), email = oUser.getEmail(), username = oUser.getUsername() } />
	
	<cfif NOT oUser.getisPersisted()>
		<cfreturn application.udf.SetReturnStructErrorCode(stReturn, 999 ) />
	</cfif>
	
	<cfset stReturn.a_user = oUser />
	
<cfsavecontent variable="sTextMail"><cfoutput>
Someone (hopefully you) has requested to resend your password. If you did not request this information, please ignore this message.

Your username is #oUser.getusername()#
Your password is #oUser.getpwd()#

Click here to login: http://www.tunesBag.com/rd/start/

-- Your tunesBag team
</cfoutput></cfsavecontent>

<cfsavecontent variable="sHTMLMail"><cfoutput>
<p>Someone (hopefully you) has requested to resend your password. If you did not request this information, please ignore this message.</p>
<br />
<p>Your username is #oUser.getusername()#</p>
<p>Your password is #oUser.getpwd()#</p>
<br /><br />
Click here to login: <a href="http://www.tunesBag.com/rd/start/">http://www.tunesBag.com/</a>

-- Your tunesBag team
</cfoutput>
</cfsavecontent>

	<cfreturn oMsg.sendGenericEmail( bIsRegisteredUser = true, sSubject = 'Your tunesBag - password', sSender = 'tunesBag.com Password Reminder <office@tunesBag.com>', sTo = stUserdata.firstname & ' <' & stUserdata.email & '>', sHTMLContent = sHTMLMail, sTextContent = sTextMail, stUserData = stUserData ) />

	<cfreturn application.udf.SetReturnStructSuccessCode(stReturn) />

</cffunction>

<cffunction access="public" name="CheckLoginDataWebService" output="false" returntype="struct"
		hint="check the login (used for WS as well as internally)">
	<cfargument name="username" type="string" required="true">
	<cfargument name="password_md5" type="string" required="true"
		hint="password in md5 notation (hash value)">
		
	<cfset var stReturn = application.udf.GenerateReturnStruct() />
	<cfset var q_select_username_password_md5 = 0 />
		
	<cfinclude template="queries/q_select_username_password_md5.cfm">
	
	<!--- check pwd --->
	<cfif (q_select_username_password_md5.recordcount IS 1) AND ( CompareNoCase( Trim(q_select_username_password_md5.pwd_md5), Trim(arguments.password_md5)) IS 0)>
		<cfset stReturn.userkey = q_select_username_password_md5.entrykey />
		<cfreturn application.udf.SetReturnStructSuccessCode(stReturn) />
	<cfelse>
		<cfreturn application.udf.SetReturnStructErrorCode(stReturn, 12000 ) />
	</cfif>
	
</cffunction>

<cffunction access="public" name="CheckLoginData" output="false" returntype="struct"
		hint="check the login (used for WS as well as internally)">
	<cfargument name="username" type="string" required="true">
	<cfargument name="password" type="string" required="false" default=""
		hint="the password in plaintext">
	<cfargument name="password_md5" type="string" required="false" default=""
		hint="the password in MD5 hash format">
		
	<cfset var stReturn = application.udf.GenerateReturnStruct() />
	<cfset var oTransfer = application.beanFactory.getBean( 'UsersTransfer' ).getTransfer() />
	<cfset var a_item = oTransfer.readByProperty( 'users.user', 'username', arguments.username ) />
	<cfset var a_str_password = arguments.password_md5 />
	
	<!--- user exists? --->
	<cfif NOT a_item.getIsPersisted()>
		<cfreturn application.udf.SetReturnStructErrorCode(stReturn, 12000 ) />
	</cfif>
	
	<!--- make pwd check ... user given pwd or hash plaintext pwd --->
	<cfif Len( arguments.password ) GT 0>
		<cfset a_str_password = Hash( arguments.password ) />
	</cfif>
	
	<!---  AND a_item.getStatus() IS application.const.I_USER_STATUS_CONFIRMED --->
	
	<!--- hash values must be the same --->
	<cfif Hash( a_item.getpwd() ) IS a_str_password>
		<cfset stReturn.userkey = a_item.getEntrykey() />
		<cfreturn application.udf.SetReturnStructSuccessCode( stReturn ) />
	<cfelse>
		<cfreturn application.udf.SetReturnStructErrorCode(stReturn, 12000 ) />
	</cfif>

</cffunction>
	
<cffunction access="public" name="CheckAccess" description="Check the access to a certain item" output="false" returntype="struct">
	<cfargument name="entrykey" type="string" required="true">
	<cfargument name="securitycontext" type="struct" required="true">
	<cfargument name="ip" type="string" required="true">
	<cfargument name="type" type="string" required="true"
		hint="type of object, e.g. mediaitem, playlist, library">
	<cfargument name="action" type="string" required="false" default="read"
		hint="read, play, edit or delete">
	<cfargument name="context" type="numeric" required="false" default="0"
		hint="context in which this item has been requested">
	
	<cfset var q_select_mediaitem_data = 0 />
	<cfset var q_select_is_shared_mediaitem = 0 />
	<cfset var stReturn = application.udf.GenerateReturnStruct() />
	<cfset var q_select_plist_data = 0 />
	<cfset var a_bol_access_allowed = false />
	<cfset var sIndex = '' />
	
	<!--- return the possible actions --->
	<cfset stReturn.sPossibleActions = '' />
	
	<!--- playlist ... check if it the owner or the plist is public --->
	<cfswitch expression="#arguments.type#">
		<cfcase value="library">
		
		
		</cfcase>
		<cfcase value="mediaitem">
		
			<cfinclude template="queries/q_select_mediaitem_data.cfm">
			
			<cfswitch expression="#arguments.action#">
			
				<cfcase value="READ,PLAY">
					
					<!--- read / play --->
					
					
					<cfset stReturn.q_select_mediaitem_data = q_select_mediaitem_data />
					
					<!--- various possibilites 
					
						a) user herself
						a 2) is in a recommendation context PLUS user has enabled public access
						b) friends + access
						c) part of a public playlist and privacy is OK
					
					--->
					<cfset a_bol_access_allowed = (
							
							(q_select_mediaitem_data.userkey IS arguments.securitycontext.entrykey)
							OR
								(arguments.context IS 4)
								AND
								(q_select_mediaitem_data.PRIVACY_PLAYLISTS IS 0)
							OR
								(
								(q_select_mediaitem_data.are_friends GT 0)
								AND
								(q_select_mediaitem_data.accesslibrary GT 0)	
								)							
							OR
								(
								(q_select_mediaitem_data.published_in_playlists GT 0)
								AND
								(q_select_mediaitem_data.playlist_public GT 0)
								AND
								(q_select_mediaitem_data.PRIVACY_PLAYLISTS IS 0)
									
								)
							) />
					
					<!--- ok? --->
					<cfif a_bol_access_allowed>
						<cfreturn application.udf.SetReturnStructSuccessCode( stReturn ) />
					</cfif>
					
					<cfinclude template="queries/q_select_is_shared_mediaitem.cfm">
					
					<!--- is this a recommendation? --->
					<cfif q_select_is_shared_mediaitem.count_id GT 0>
						<cfreturn application.udf.SetReturnStructSuccessCode( stReturn ) />
					</cfif>
				
				</cfcase>
				<cfcase value="EDIT,DELETE">
				
					<!--- only the owner ... --->
					<cfif arguments.securitycontext.entrykey IS q_select_mediaitem_data.userkey>
						<cfreturn application.udf.SetReturnStructSuccessCode( stReturn ) />
					</cfif>
				
				</cfcase>
			
			</cfswitch>
		
		</cfcase>
		<cfcase value="playlist">
		
			<cfinclude template="queries/q_select_plist_data.cfm">
			
			<cfset stReturn.q_select_plist_data = q_select_plist_data />
			
			<cfswitch expression="#arguments.action#">
				<cfcase value="play,read">
					
					<!--- user wants to play a plist ... --->
					
					<!--- access only allowed for friends? --->
					<cfif q_select_plist_data.privacy_playlists IS 1 AND NOT q_select_plist_data.are_friends>
						<cfreturn application.udf.SetReturnStructErrorCode(stReturn, 1001 ) />
					</cfif>					
					
					<!--- for the play permission, check the country as well --->
					<cfswitch expression="#arguments.action#">
					
						<cfcase value="read">							
							<!--- we're in need of the browse right --->
							
							<cfif NOT arguments.securitycontext.rights.playlist.view>
								<cfreturn application.udf.SetReturnStructErrorCode(stReturn, 1001 ) />
							</cfif>
						
						</cfcase>
						<cfcase value="play">
							
							<!--- we're in need of the play permission ... at least radio must be true --->
							<cfif NOT arguments.securitycontext.rights.playlist.radio IS 1>
								<cfreturn application.udf.SetReturnStructErrorCode(stReturn, 1001, 'radio is not allowed' ) />
							</cfif>							
						
						</cfcase>
					</cfswitch>
					
					<!--- return the possible rights --->
					<cfloop list="#StructKeyList( arguments.securitycontext.rights.playlist )#" index="sIndex">
						
						<cfif arguments.securitycontext.rights.playlist[ sIndex ] IS 1>
							<!--- add to list of allowed actions --->
							<cfset ListAppend( stReturn.sPossibleActions, sIndex ) />
						</cfif>
						
					</cfloop>
					
					<!--- public? if not, no access for anyone --->
					<cfif q_select_plist_data.public IS 1>
						<cfreturn application.udf.SetReturnStructSuccessCode( stReturn ) />	
					</cfif>
										
				
				</cfcase>			
			</cfswitch>
			
		</cfcase>
	
	</cfswitch>	
	
	<cfreturn application.udf.SetReturnStructErrorCode(stReturn, 1001 ) />
</cffunction>

<cffunction access="public" name="GenerateSecurityContext" hint="define the structure" output="false" returntype="struct">
	<cfargument name="userkey" type="string" required="true">
	<cfargument name="userid" type="numeric" required="true" />
	<cfargument name="username" type="string" required="true">
	<cfargument name="style" type="string" required="false" default="">
	<cfargument name="lang_id" type="string" required="true">
	<cfargument name="utcdiff" type="string" required="false" default="0">
	<cfargument name="countryisocode" type="string" required="false" default="at"
		hint="country iso code">
	<cfargument name="accounttype" type="numeric" default="0" hint="account type ... 0 = default, 10 = S, 20 = M, 50 = L" />
	<cfargument name="provider" type="string" required="false" default=""
		hint="the provider of this login (e.g. facebook, myspace or empty for default)" />
	<cfargument name="externalidentifierkey" type="string" required="false" default=""
		hint="external identifier" />
	<cfargument name="defaultlibrarykey" type="string" required="true"
		hint="the default library key of this user" />
	<cfargument name="friends" type="array" required="true"
		hint="friends information (access, username etc)" />
	
	<!--- generate the context from the given data without any further checks --->
	<cfset var stReturn = { utcdiff = arguments.utcdiff,
								entrykey = arguments.userkey,
								userid = arguments.userid,
								username = arguments.username,
								lang_id = arguments.lang_id,
								style = arguments.style,
								countryisocode = arguments.countryisocode,
								accounttype = arguments.accounttype,
								provider = arguments.provider,
								externalidentifierkey = arguments.externalidentifierkey,
								defaultlibrarykey = arguments.defaultlibrarykey,
								friends = arguments.friends,
								exists = true } />
								
	<cfset var stPlans = application.beanFactory.getBean( 'ShopComponent' ).getPlans() />
	<cfset var sPlan  = '' />
	
	<!--- add licence context --->
	<cfset stReturn.rights = application.beanFactory.getBean( 'LicenceComponent' ).GetFeatureSetForUser( stReturn ) />
	
	<!--- add plan information --->
	<cfloop list="#StructKeyList( stPlans )#" index="sPlan">
		
		<cfif NOT CompareNoCase( stPlans[ sPlan ].accounttype, arguments.accounttype)>
			<cfset stReturn.stPlan = stPlans[ sPlan ] />
		</cfif>
		
	</cfloop>
	
	<cfreturn stReturn />
	
</cffunction>

<cffunction access="public" name="GetUserContextByUsername" hint="Calculate the user / security context" output="false" returntype="struct">
	<cfargument name="username" type="string" required="true"
		hint="username of user">
	<cfargument name="provider" type="string" required="false" default=""
		hint="provider of this login" />
	<cfargument name="externalidentifierkey" type="string" required="false" default=""
		hint="external identifier" />
		
	<cfset var oTransfer = application.beanFactory.getBean( 'UsersTransfer' ).getTransfer() />
	<cfset var a_item = oTransfer.readByProperty( 'users.user', 'username', arguments.username ) />
	<cfset var a_struct = GenerateSecurityContext( username = a_item.getUsername(),
								userkey = a_item.getEntrykey(),
								userid = a_item.getID(),
								style = '',
								lang_id = a_item.getLang_id(),
								utcdiff = 0,
								countryisocode = application.beanFactory.getBean( 'LicenceComponent' ).IPLookupCountry( ip = cgi.REMOTE_ADDR ),
								provider = arguments.provider,
								externalidentifierkey = arguments.externalidentifierkey,
								accounttype = a_item.getaccounttype(),
								friends = application.beanFactory.getbean( 'SocialComponent' ).GetSimpleFriendsInformation( a_item.getEntrykey() ),
								defaultlibrarykey = application.beanFactory.getBean( 'MediaitemsComponent' ).GetDefautLibraryEntrykey( a_item.getEntrykey() )  ) />
								
	<cfset a_struct.exists = a_item.getIsPersisted() />
	
	<cfreturn a_struct />
	
</cffunction>

<cffunction access="public" name="GetUserContextByUserkey" hint="Calculate the user / security context" output="false" returntype="struct">
	<cfargument name="userkey" type="string" required="true"
		hint="entrykey of user" />
	<cfargument name="provider" type="string" required="false" default=""
		hint="provider of this login or empty for default login without external provider" />
	<cfargument name="externalidentifierkey" type="string" required="false" default=""
		hint="external identifier" />
		
	<cfset var local = {} />
	
	<cfquery name="local.qSelectUser" datasource="mytunesbutleruserdata">
	SELECT
		username,
		entrykey,
		lang_id,
		id,
		accounttype
	FROM
		users
	WHERE
		entrykey = <cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.userkey#" />
	;
	</cfquery>
				
	<cfset var a_struct = GenerateSecurityContext( username = local.qSelectUser.username,
								userkey = local.qSelectUser.entrykey,
								userid = local.qSelectUser.id,
								style = '',
								lang_id = local.qSelectUser.lang_id,
								utcdiff = 0,
								provider = arguments.provider,
								externalidentifierkey = arguments.externalidentifierkey,
								countryisocode = application.beanFactory.getBean( 'LicenceComponent' ).IPLookupCountry( ip = cgi.REMOTE_ADDR ),
								accounttype = local.qSelectUser.accounttype,
								friends = application.beanFactory.getbean( 'SocialComponent' ).GetSimpleFriendsInformation( local.qSelectUser.Entrykey ),
								defaultlibrarykey = application.beanFactory.getBean( 'MediaitemsComponent' ).GetDefautLibraryEntrykey( local.qSelectUser.Entrykey )  ) />
								
	<cfset a_struct.exists = (local.qSelectUser.recordcount IS 1) />
	
	<cfreturn a_struct />
	
</cffunction>

<cffunction access="public" name="LogLogin" output="false" returntype="void" hint="log login to db">
	<cfargument name="securitycontext" type="struct" required="true">
	<cfargument name="user_agent" type="string" required="true">
	<cfargument name="ip" type="string" required="true">
	<cfargument name="provider" type="string" required="false" default=""
		hint="provider name (e.g. facebook, myspace) or empty" />
	
	<cfset var oTransfer = application.beanFactory.getBean( 'LogTransfer' ).getTransfer() />
	<cfset var oItem = oTransfer.new( 'logging.userlogin' ) />
	
	<cfset oItem.setuserkey( arguments.securitycontext.entrykey ) />
	<cfset oItem.setip( arguments.ip ) />
	<cfset oItem.setuseragent( Left( arguments.user_agent, 250) ) />
	<cfset oItem.setdt_created( Now() ) />
	<cfset oItem.setProvider( Left( arguments.provider, 20) ) />
	
	<cfset oTransfer.create( oItem ) />

</cffunction>


</cfcomponent>
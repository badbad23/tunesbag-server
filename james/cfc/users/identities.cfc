<!--- 
	
	user other identities with tunesBag

 --->

<cfcomponent displayname="identities" output="false">
	
	<cfinclude template="/common/scripts.cfm">
	<cfset variables.a_str_rpx_api_key = '' />

	<cffunction access="public" name="init" output="false" returntype="james.cfc.users.identities">
		
		<cfset SetRPXApiKey( application.udf.GetSettingsProperty( 'RPXApikey', '98b046f582d3fa6826229a8aab0796dc6abbbf4e' )) />
		<cfreturn this />
	</cffunction>
	
	<cffunction access="private" name="SetRPXApiKey" output="false" returntype="void">
		<cfargument name="apikey" type="string" required="true">
		<cfset variables.a_str_rpx_api_key = arguments.apikey />
	</cffunction>
	
	<cffunction access="public" name="GetRPXApiKey" output="false" returntype="string"
			hint="return the api key">
		<cfreturn variables.a_str_rpx_api_key />
	</cffunction>
	
	<cffunction access="public" name="GetRPXLoginData" output="false" returntype="struct"
			hint="return rpx provided login data">
		<cfargument name="entrykey" type="string" required="true"
			hint="entrykey in the db" />
		
		<cfset var stReturn = application.udf.GenerateReturnStruct() />
		<cfset var oTransfer = application.beanFactory.getBean( 'LogTransfer' ).getTransfer() />
		<cftry>
		<cfset var oItem = oTransfer.get( 'cache.rpxdatacache', arguments.entrykey ) />
			<cfcatch type="any">
				<cfreturn application.udf.SetReturnStructErrorCode(stReturn, 999) />
			</cfcatch>
		</cftry>
			
		<cfif NOT oItem.getIsPersisted()>
			<cfreturn application.udf.SetReturnStructErrorCode(stReturn, 999) />
		<cfelse>
		
			<cfset stReturn.oItem = oItem />
			
			<cfreturn application.udf.SetReturnStructSuccessCode( stReturn ) />
		</cfif>
		
	</cffunction>
	
	<cffunction access="public" name="StoreRPXLoginData" output="false" returntype="struct"
			hint="user has no account yet, so store the provided data for further usage">
		<cfargument name="token" type="string" required="true" />
		<cfargument name="provider" type="string" required="true" />
		<cfargument name="identifier" type="string" required="true" />
		<cfargument name="complete_userdata" type="struct" required="true" />
		<cfargument name="unified_userdata" type="struct" required="true" />
				
		<cfset var stReturn = application.udf.GenerateReturnStruct() />
		<cfset var oTransfer = application.beanFactory.getBean( 'LogTransfer' ).getTransfer() />
		<cfset var oItem = oTransfer.new( 'cache.rpxdatacache' ) />
		<cfset var sEntrykey = CreateUUID() />
		
		<cfset oItem.setEntrykey( sEntrykey ) />
		<cfset oItem.setdt_created( Now() ) />
		<cfset oItem.setrpxtoken( arguments.token ) />
		<cfset oItem.setSource( 'rpx' ) />
		<cfset oItem.setProvider( arguments.provider ) />
		<cfset oItem.setIdentifier( arguments.identifier ) />
		<cfset oItem.setcomplete_data( SerializeJSON( arguments.complete_userdata )) />
		<cfset oItem.setunified_userdata( SerializeJSON( arguments.unified_userdata )) />
		
		<cfset oTransfer.create( oItem ) />
		
		<cfset stReturn.Entrykey = sEntrykey />
		<cfreturn application.udf.SetReturnStructSuccessCode( stReturn ) />

	</cffunction>
	
	<cffunction access="public" name="CheckRPXLoginData" output="false" returntype="struct"
			hint="check the data provided by rpx">
		<cfargument name="token" type="string" required="true"
			hint="token provided by callback url">

		<cfset var stReturn = application.udf.GenerateReturnStruct() />
		<cfset var cfhttp = 0 />
		<cfset var a_str_content = '' />
		<cfset var a_struct_identity = {} />
		<cfset var stLookup = {} />
		<cfset var a_struct_userdata = {} />
		<cfset var sEntrykey = createUUID() />
		<cfset var local = {} />
		
		<cfif Len( arguments.token ) IS 0>
			<cfreturn application.udf.SetReturnStructErrorCode(stReturn, 999) />
		</cfif>
		
		<cftry>
			
			<!--- <cfset local.sys = createObject("java", "java.lang.System") />
			<cfset local.sys.setProperty("https.protocols", 'SSLv3') />
			<cfset local.sys.setProperty("force.http.jre.executor", true) />			 --->
			
			<cfset local.sOutputDocument = GetTempDirectory() & CreateUUID() & '.html' />
			
			<cfset local.sArguments = "--no-check-certificate --post-data 'apiKey=#UrlEncodedFormat( GetRPXApiKey() )#&token=#UrlEncodedFormat( arguments.token )#&extended=true' --output-document=#local.sOutputDocument# https://rpxnow.com/api/v2/auth_info" />
			
			<cfif FindNoCase( 'Mac', server.os.name ) GT 0>
				<cfset local.sArguments = ReplaceNoCase( local.sArguments, "--no-check-certificate", "" ) />
			</cfif>
			
			<cfexecute name="#application.udf.GetSettingsProperty( 'wget', 'wget' )#" arguments="#local.sArguments#" timeout="15"></cfexecute>
			
			<cffile action="read" charset="utf-8" file="#local.sOutputDocument#" variable="a_str_content">
			
			<!--- <cfhttp url="https://rpxnow.com/api/v2/auth_info" method="post" result="cfhttp" timeout="10">
				<cfhttpparam type="formfield" name="apiKey" value="#GetRPXApiKey()#" />
				<cfhttpparam type="formfield" name="token" value="#arguments.token#" />	
				<cfhttpparam type="formfield" name="extended" value="true" />
			</cfhttp>
			
			<cfset a_str_content = cfhttp.FileContent /> --->
			
			<cfset a_struct_identity = DeSerializeJSON( a_str_content ) />
			
			<cfset stReturn.data = a_struct_identity />
			
			<cfcatch type="any">
				<cfreturn application.udf.SetReturnStructErrorCode(stReturn, 999, cfcatch.Message & ' ' & local.sArguments ) />
			</cfcatch>
		</cftry>
		
		<!--- check status --->
		<cfif NOT CompareNoCase( a_struct_identity.stat, 'ok') IS 0>
			<!--- return error message --->
			<cfreturn application.udf.SetReturnStructErrorCode(stReturn, 999, a_struct_identity.err.msg) />
		</cfif>
		
		<!--- perform lookup --->
		<cfset stLookup = PerformExternalIdentifierLookup( identifier = a_struct_identity.profile.identifier,
											provider = a_struct_identity.profile.providername ) />
		
		<cfset stReturn.stLookup = stLookup />
		
		<!--- number of user bindings found in system --->
		<cfset stReturn.UserBindingsFound = stLookup.qIdentifierUserRel.recordcount />
		
		<!--- unify main data --->
		<cfset stReturn.unifiedUserdata = UnifyProvidedInformation( data = a_struct_identity ,provider = a_struct_identity.profile.providername ) />
		
		<!--- add some meta data --->
		<cfset stReturn.unifiedUserdata.source = 'rpx' />
		<cfset stReturn.unifiedUserdata.identifier = a_struct_identity.profile.identifier />
		<cfset stReturn.unifiedUserdata.provider = a_struct_identity.profile.providername />
		<cfset stReturn.unifiedUserdata.complete_data = a_struct_identity />		
		
		<cfreturn application.udf.SetReturnStructSuccessCode(stReturn) />
		
	</cffunction>
	
	<cffunction access="public" name="UnifyProvidedInformation" output="false" returntype="struct">
		<cfargument name="data" type="struct" required="true"
			hint="data provided by external provider">
		<cfargument name="provider" type="string" required="true">
		
		<cfset var a_struct = { username = '', email = '', firstname = '', photo = '' } />
		
		<!--- email
			ignore the new type of facebook email address
		 --->
		<cfif StructKeyExists( arguments.data.profile, 'email' ) AND FindNoCase( '@proxymail.facebook.com', arguments.data.profile.email) IS 0>
			<cfset a_struct.email = arguments.data.profile.email />
		</cfif>
		
		<cfif StructKeyExists( arguments.data.profile, 'verifiedEmail' ) AND FindNoCase( '@proxymail.facebook.com', arguments.data.profile.verifiedEmail) IS 0>
			<cfset a_struct.email = arguments.data.profile.verifiedEmail />
		</cfif>		
		
		<!--- firstname prio B --->
		<cfif StructKeyExists( arguments.data.profile, 'displayName') AND
			  Len( arguments.data.profile.displayName ) GT 0>
			<cfset a_Struct.firstname = ListFirst( arguments.data.profile.displayName, ' ') />
		</cfif>		
		
		<!--- try to get firstname from fullname ... CHECK FACEBOOK! --->
		<cfif StructKeyExists( arguments.data, 'sreg' ) AND StructKeyExists( arguments.data.sreg, 'fullname' )>
			<cfset a_struct.firstname = ListFirst( arguments.data.sreg.fullname, ' ') />
		</cfif>		
		
		<cfif StructKeyExists( arguments.data.profile, 'name') AND
			  IsStruct( arguments.data.profile.name ) AND
			  StructKeyExists( arguments.data.profile.name, 'givenname') AND
			  Len( arguments.data.profile.name.givenName ) GT 0>
			<cfset a_Struct.firstname = arguments.data.profile.name.givenName />
		</cfif>

		<!--- username prio b --->
		<cfif StructKeyExists( arguments.data, 'sreg' ) AND StructKeyExists( arguments.data.sreg, 'nickname' )>
			<cfset a_struct.username = arguments.data.sreg.nickname />
		</cfif>		
		
		<!--- prio a --->
		<cfif StructKeyExists( arguments.data.profile, 'preferredUsername' )>
			<cfset a_struct.username = arguments.data.profile.preferredUsername />
		</cfif>
		
		<!--- photo: facebook --->
		<cfif StructKeyExists( arguments.data.profile, 'photo' ) AND
				(Len( arguments.data.profile.photo ) GT 0 )>
			<cfset a_struct.photo = arguments.data.profile.photo />
		</cfif>
		
		<!--- windows live ... username = email, so take part in front of the @ --->		
		<cfif FindNoCase( '@', a_struct.username ) GT 0>
			<cfset a_struct.username = ListFirst( a_struct.username, '@' ) />
		</cfif>
		
		<!--- city --->
		
		<cfif StructKeyExists( arguments.data.profile, 'address' ) AND IsStruct( arguments.data.profile.address ) AND
				StructKeyExists( arguments.data.profile.address, 'city' )>
			<cfset a_struct.city = arguments.data.profile.address.city />
		</cfif>
		
		<cfif StructKeyExists( arguments.data.profile, 'address' ) AND IsStruct( arguments.data.profile.address ) AND
				StructKeyExists( arguments.data.profile.address, 'locality' )>
			<cfset a_struct.city = arguments.data.profile.address.locality />
		</cfif>
				
		
		<!--- TODO: Return further facebook data including photo, music preferences etc , zipcode--->
		
		<!--- AUTO FIND FRIENDS OF FB / MYSPACE HERE TOO! connect everything ... --->
		
		<cfreturn a_struct />
	
	</cffunction>
	
	<cffunction access="public" name="PerformExternalIdentifierLookup" output="false" returntype="struct"
			hint="Check provided identifier against stored relations">
		<cfargument name="identifier" type="string" required="true"
			hint="the identifier">
		<cfargument name="provider" type="string" required="true"
			hint="the provider">
		
		<cfset var stReturn = application.udf.GenerateReturnStruct() />
		<cfset var q_select_identities_by_identifier = 0 />
		
		<cfinclude template="queries/identities/q_select_identities_by_identifier.cfm">
		
		<cfset stReturn.qIdentifierUserRel = q_select_identities_by_identifier />

		<cfreturn application.udf.SetReturnStructSuccessCode(stReturn) />

	</cffunction>
	
	<cffunction access="public" name="GetExternalIdentityLinksOfUser" output="false" returntype="query">
		<cfargument name="securitycontext" type="struct" required="true" />
		
		<cfset var oTransfer = application.beanFactory.getBean( 'UsersTransfer' ).getTransfer() />
		<cfreturn oTransfer.ListByProperty( 'external_services.users_externalidentifiers', 'userkey', arguments.securitycontext.entrykey ) />
		
	</cffunction>
	
	<cffunction access="public" name="StoreExternalIdentityLink" output="false" returntype="struct"
			hint="store external binding">
		<cfargument name="securitycontext" type="struct" required="true" />
		<cfargument name="identifier" type="string" required="true"
			hint="the identifier" />
		<cfargument name="provider" type="string" required="true"
			hint="provider ID" />
		<cfargument name="source" type="string" required="true"
			hint="source of this binding" />
		<cfargument name="complete_data" type="struct" default="#StructNew()#"
			hint="full provided data for further handling" />
			
		<cfset var stReturn = application.udf.GenerateReturnStruct() />
		<cfset var stLookup = { userkey = arguments.securitycontext.entrykey, provider = arguments.provider, identifier = arguments.identifier } />
		<cfset var oTransfer = application.beanFactory.getBean( 'UsersTransfer' ).getTransfer() />
		<cfset var oItem = oTransfer.ReadByPropertyMap( 'external_services.users_externalidentifiers', stLookup ) />
		<cfset var sEntrykey = CreateUUID() />
		
		<cfset stReturn.bUpdate = (oItem.getIsPersisted() ) />
		<cfset stReturn.lookup = stLookup />
		<cfset stReturn.oItem = oItem />
		
		<!--- new item? --->
		<cfif NOT oitem.getIsPersisted()>
			<cfset oItem.setEntrykey( sEntrykey ) />
			<cfset oItem.setdt_created( Now() ) />
		<cfelse>
			<cfset sEntrykey = oItem.getEntrykey() />			
		</cfif>
		
		<cfset oItem.setuserkey( arguments.securitycontext.entrykey ) />
		<cfset oItem.setprovider( arguments.provider ) />
		<cfset oItem.setdt_lastlogin ( now() ) />
		<cfset oItem.setidentifier( arguments.identifier ) />
		<cfset oItem.setprovideddata( SerializeJSON( arguments.complete_data )) />

		<cfset oItem.setsource( arguments.source ) />
		
		<cfset oTransfer.save( oItem ) />
		
		<!--- return the key of this binding --->
		<cfset stReturn.entrykey = sEntrykey />
	
		<cfreturn application.udf.SetReturnStructSuccessCode( stReturn ) />
		
	</cffunction>
	
	<cffunction access="public" name="StoreUserPhotoOfOtherService" output="false" returntype="void"
			hint="take the picture of the other service and use this one">
		<cfargument name="securitycontext" type="struct" required="true"
			hint="userkey etc" />
		<cfargument name="sLocation" type="string" required="true"
			hint="http location" />
			
		<cfset var cfhttp = 0 />
		<cfset var ii = 0 />
		<cfset var sFilename = application.udf.GetTBTempDirectory() & CreateUUID() & '.' & ListLast( sLocation, '.' ) />
		
		<cfif (Len( sLocation ) IS 0) OR (FindNoCase( 'http', sLocation ) NEQ 1) OR (ListFindNoCase('jpg,gif,jpeg,png', ListLast( arguments.sLocation, '.')) IS 0)>
			<cfreturn />
		</cfif>
		
		<cftry>
		<cflock timeout="10" name="#Hash( arguments.sLocation )#" throwontimeout="true">
		
			<cfhttp charset="utf-8" method="get" url="#arguments.sLocation#" result="cfhttp"></cfhttp>
			
			<cffile action="write" output="#cfhttp.FileContent#" file="#sFilename#" />		

			<cfset application.beanFactory.getBean( 'UserComponent' ).StoreUserProfilePhoto( securitycontext = arguments.securitycontext, bigimagefile = sFilename ) />
		
		</cflock>
		<cfcatch type="any">
			<cfmail from="office@tunesBag.com" to="office@tunesBag.com" subject="pic add exception" timeout="30" type="html">
			<cfdump var="#arguments#">
			<cfdump var="#cfcatch#">
			</cfmail>
		</cfcatch>
		</cftry>
		
	</cffunction>
	
	<cffunction access="public" name="checkExternalIdentifierData" output="false" returntype="struct" hint="return friends etc">
		<cfargument name="securitycontext" type="struct" required="true"
			hint="userkey etc" />
			
		<cfset var stReturn = application.udf.GenerateReturnStruct() />
		<cfset var oTransfer = application.beanFactory.getBean( 'UsersTransfer' ).getTransfer() />
		<cfset var oItem = oTransfer.get( 'external_services.users_externalidentifiers', arguments.securitycontext.externalIdentifierKey ) />
		<cfset var stData = 0 />
		<cfset var qPossibleFriends = 0 />
				
		<cfif NOT oItem.getIsPersisted()>
			<cfreturn application.udf.SetReturnStructErrorCode(stReturn, 999) />
		</cfif>
		
		<cfset stData = DeSerializeJSON( oItem.getprovideddata() ) />
		
		<cfinclude template="queries/identities/qPossibleFriends.cfm">
		
		<cfset stReturn.qPossibleFriends = qPossibleFriends />
		
		<cfreturn application.udf.SetReturnStructSuccessCode( stReturn ) />
	
	</cffunction>
	
</cfcomponent>
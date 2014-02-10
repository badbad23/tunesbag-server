<!---

	very simple messages

--->

<cfprocessingdirective pageencoding="utf-8" />

<cfcomponent output="false">
	
	<cfinclude template="/common/scripts.cfm">

	<cffunction access="public" name="init" returntype="james.cfc.messages.messages" output="false">
		<cfreturn this />
	</cffunction>
	
	<cffunction access="public" name="sendGenericEmail" output="false" returntype="struct"
			hint="send a generic email routine">
		<cfargument name="sSender" type="string" required="true" />
		<cfargument name="sTo" type="string" required="true" />
		<cfargument name="sSubject" type="string" required="true" />
		<cfargument name="sHTMLContent" type="string" required="true" />
		<cfargument name="sTextContent" type="string" required="true" />
		<cfargument name="bTextOnly" type="boolean" default="false"
			hint="send text mail only?" />
		<cfargument name="stUserData" type="struct" default="#{ firstname = '', surname = '', username = '', email = '', entrykey = ''}#">
		<cfargument name="bNewsletter" type="boolean" default="false"
			hint="a newsletter? offer unsubscribe link?">
		<cfargument name="bIsRegisteredUser" type="boolean" default="false"
			hint="anonymous mail?" />
		<cfargument name="sCampaign" type="string" default="default" required="false"
			hint="campaign for tracking" />
		<cfargument name="sAttachments" type="string" default="" required="false"
			hint="files to attach" />
		
		<cfset var stReturn = application.udf.GenerateReturnStruct() />
		
		<cfset stReturn.stArgs = Arguments />
		
		<cfsavecontent variable="arguments.sHTMLContent">
		<cfinclude template="utils/inc_create_mail_html.cfm">
		</cfsavecontent>
		
		<cfset arguments.sHTMLContent = Trim( arguments.sHTMLContent ) />
		
		<cfsavecontent variable="arguments.sTextContent">
		<cfinclude template="utils/inc_create_mail_text.cfm">
		</cfsavecontent>		
		
		<cfset arguments.sTextContent = Trim( arguments.sTextContent ) />
		
<cftry>

<cfmail charset="utf-8" subject="#arguments.sSubject#" from="#arguments.sSender#" to="#arguments.sTo#" mailerid="tunesBag MailEngine 0.1">

<!--- attachments --->
<cfif Len( arguments.sAttachments ) GT 0>
	<cfloop list="#arguments.sAttachments#" index="local.sFile" delimiters=",">
		
		<cfif FileExists( local.sFile )>
			<cfmailparam file="#local.sFile#" />
		</cfif>
		
	</cfloop>
</cfif>

<cfmailpart type="text/plain" charset="utf-8">#arguments.sTextContent#</cfmailpart>
<cfif NOT arguments.bTextOnly>
<cfmailpart type="text/html" charset="utf-8">#arguments.sHTMLContent#</cfmailpart>
</cfif>
</cfmail>
<cfcatch type="any">
	
		<cfset stReturn.stCatch = cfcatch />
		<cfreturn application.udf.SetReturnStructErrorCode(stReturn, 999) />
</cfcatch>
</cftry>
		<cfset stReturn.bDone = true />
		<cfreturn application.udf.SetReturnStructSuccessCode(stReturn) />

	</cffunction>
	
	<cffunction access="public" name="GetMessagesOfUser" output="false" returntype="struct"
			hint="return all msgs of a user">
		<cfargument name="securitycontext" type="struct" required="true">
		<cfargument name="filter" type="struct" required="false" default="#StructNew()#">
		
		<cfset var stReturn = application.udf.GenerateReturnStruct() />
		<cfset var q_select_messages = 0 />

		<cfinclude template="queries/q_select_messages.cfm">
		
		<cfset stReturn.q_select_messages = q_select_messages />

		<cfreturn application.udf.SetReturnStructSuccessCode(stReturn) />

	</cffunction>
	
	<cffunction access="public" name="DeleteMessage" output="false" returntype="struct"
			hint="delete a message">
		<cfargument name="securitycontext" type="struct" required="true">
		<cfargument name="entrykey" type="string" required="true">
		
		<cfset var stReturn = application.udf.GenerateReturnStruct() />
		<cfset var a_struct_map = { userkey = arguments.securitycontext.entrykey, entrykey = arguments.entrykey } />
		<cfset var oTransfer = application.beanFactory.getBean( 'ContentTransfer' ).getTransfer() />
		<cfset var a_item = oTransfer.readbyPropertyMap( 'messages.message', a_struct_map ) />
		
		<cfset oTransfer.delete( a_item ) />
		
		<cfreturn application.udf.SetReturnStructSuccessCode(stReturn) />	

	</cffunction>
	
	<cffunction access="public" name="GetUnreadMessagesCount" output="false" returntype="numeric">
		<cfargument name="securitycontext" type="struct" required="true">
		
		<cfset var q_select_unread_count = 0 />
		
		<cfinclude template="queries/q_select_unread_count.cfm">
		
		<cfreturn Val( q_select_unread_count.count_id ) />
	
	</cffunction>
	
	<cffunction access="public" name="StoreMessage" output="false" returntype="struct"
			hint="store a sent message">
		<cfargument name="securitycontext" type="struct" required="true">
		<cfargument name="userkey_to" type="string" required="true">
		<cfargument name="subject" type="string" required="true">
		<cfargument name="body" type="string" required="true">
		<cfargument name="notify_recipient" type="boolean" required="true"
			hint="notify recipient?">
		
		<cfset var stReturn = application.udf.GenerateReturnStruct() />
		<cfset var oTransfer = application.beanFactory.getBean( 'ContentTransfer' ).getTransfer() />
		<cfset var a_item = oTransfer.new( 'messages.message' ) />
		<cfset var a_userdata_to = application.beanFactory.getBean( 'UserComponent' ).GetUserData( userkey = arguments.userkey_to ) />		
		
		<!--- TO the other user --->
		<cfset a_item.setUserkey( arguments.securitycontext.entrykey ) />
		<cfset a_item.setEntrykey( CreateUUID() ) />
		<cfset a_item.setSubject( arguments.subject ) />
		<cfset a_item.setstatus_read( 1 ) />
		<cfset a_item.setBody( arguments.body ) />
		<cfset a_item.setdt_created( Now() ) />
		<cfset a_item.setuserkey_to( arguments.userkey_to ) />
		<cfset a_item.setuserkey_from( arguments.securitycontext.entrykey ) />
		
		<cfset oTransfer.create( a_item ) />
		
		<!--- NOW For the other user --->
		<cfset a_item = oTransfer.new( 'messages.message' ) />
		
		<!--- TO the other user --->
		<cfset a_item.setUserkey( arguments.userkey_to ) />
		<cfset a_item.setEntrykey( CreateUUID() ) />
		<cfset a_item.setSubject( arguments.subject ) />
		<cfset a_item.setBody( arguments.body ) />
		<cfset a_item.setdt_created( Now() ) />
		<cfset a_item.setuserkey_to( arguments.userkey_to ) />
		<cfset a_item.setuserkey_from( arguments.securitycontext.entrykey ) />
		
		<cfset oTransfer.create( a_item ) />	
		
		<cfif arguments.notify_recipient>
			<!--- notify by email --->
<cftry>
<cfmail from="tunesBag Messaging <no-reply@tunesBag.com>" to="#a_userdata_to.a_struct_item.getEmail()#" subject="[tunesBag] #arguments.securitycontext.username# has sent you a message"><cfmailparam name="Sender" value="mail@tunesBag.com">
#a_userdata_to.a_struct_item.getFirstName()# -

#arguments.securitycontext.username# has sent you a new message:

Subject: #arguments.subject#
Text: #arguments.body#

Please click here to reply to the message: http://www.tunesBag.com/

Profile of the sender: http://www.tunesBag.com/user/#arguments.securitycontext.username#

-- Your tunesBag.com team
</cfmail>
<cfcatch type="any"></cfcatch></cftry>

		</cfif>
		
		<cfreturn application.udf.SetReturnStructSuccessCode(stReturn) />

	</cffunction>

</cfcomponent>
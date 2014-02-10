<!--- //

	Module:		Comments
	Action:		
	Description:	
// --->

<cfcomponent name="comments" displayname="Commentscomponent"output="false" extends="MachII.framework.Listener" hint="Handle comments">
	
<cfinclude template="/common/scripts.cfm">

<cffunction name="configure" access="public" output="false" returntype="void" hint="Configures this listener as part of the Mach-II  framework"> 
	<!--- do nothing --->
</cffunction> 

<cffunction name="LoadComments" access="public" output="false" returntype="void" hint="Load comments for a certain artist/album/track">
	<cfargument name="event" type="MachII.framework.Event" required="true" />
	
	<cfset var a_str_artist = arguments.event.getArg( 'artist' ) />
	<cfset var a_str_mediakey = arguments.event.getArg( 'entrykey' ) />
	<cfset var a_str_album = arguments.event.getArg( 'album' ) />
	<cfset var a_str_name = arguments.event.getArg( 'name' ) />
	<cfset var a_cmp_comments = getProperty( 'beanFactory' ).getBean( 'CommentsComponent' ) />
	
	<cfset var a_struct_comments = a_cmp_comments.GetComments( mediaitemkey = a_str_mediakey,
											artist = a_str_artist,
											album = a_str_album,
											name = a_str_name ) />
	
	<cfif a_struct_comments.result>
		<cfset arguments.event.setArg( 'q_select_comments', a_struct_comments.q_select_items ) />
	</cfif>
	
	
</cffunction>

</cfcomponent>
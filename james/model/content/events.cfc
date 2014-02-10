
<cfcomponent name="comments" displayname="Commentscomponent"output="false" extends="MachII.framework.Listener" hint="Handle events">
	
<cfinclude template="/common/scripts.cfm">

<cffunction name="configure" access="public" output="false" returntype="void" hint="Configures this listener as part of the Mach-II  framework"> 
	<!--- do nothing --->
</cffunction> 

<cffunction name="LoadArtistEvents" access="public" output="false" returntype="void" hint="Load events for a certain artist">
	<cfargument name="event" type="MachII.framework.Event" required="true" />
	
	<cfset var a_str_artist = arguments.event.getArg( 'artist' ) />
	<cfset var a_cmp_events = getProperty( 'beanFactory' ).getBean( 'EventsComponent' ) />
	<cfset var a_struct_events = a_cmp_events.CheckArtistEvents( artist = a_str_artist ) />
	
	<cfif a_struct_events.result>
		<cfset arguments.event.setArg( 'q_select_artist_events', a_struct_events.q_select_artist_events ) />
	</cfif>
	
	
</cffunction>

</cfcomponent>
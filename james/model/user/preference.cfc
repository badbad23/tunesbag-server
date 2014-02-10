<!--- //

	Module:		Preference component
	Description: 
	
// --->

<cfcomponent name="preference" displayname="Preference component"output="false" extends="MachII.framework.Listener" hint="Preference handler for tunesBag application">

<cfinclude template="/common/scripts.cfm">

<cffunction name="configure" access="public" output="false" returntype="void" hint="Configures this listener as part of the Mach-II  framework"> 
	<!--- do nothing --->
</cffunction>

<cffunction access="public" name="LoadCustomDesignElementData" output="false" returntype="void" hint="Load custom design data">
	<cfargument name="event" type="MachII.framework.Event" required="true" />
	
	<cfscript>
	arguments.event.setArg("pref_design_bg_color", LoadInternalPreference('customize.design_bg_color', ''));
	arguments.event.setArg("pref_design_text_color", LoadInternalPreference('customize.design_text_color', ''));
	arguments.event.setArg("pref_design_link_color", LoadInternalPreference('customize.design_link_color', ''));
	arguments.event.setArg("pref_design_content_bg_color", LoadInternalPreference('customize.design_content_bg_color', ''));
	arguments.event.setArg("pref_design_content_bg_sidebar", LoadInternalPreference('customize.design_content_bg_sidebar', ''));
	</cfscript>
</cffunction>

<cffunction access="public" name="getCustomWebStreamingBitrate" output="false" returntype="void" hint="set custom web streaming bitrate">
	<cfargument name="event" type="MachII.framework.Event" required="true" />
	
	<!--- set data, use default = 128 --->
	<cfset arguments.event.setArg("targetbitrate", LoadInternalPreference('web.streaming.quality', '128')) />
</cffunction>

<cffunction access="public" name="LoadAllStoredUserPreferences" output="false" returntype="void" hint="Load all available personal preferences">
	<cfargument name="event" type="MachII.framework.Event" required="true" />
	
	<cfset var a_transfer = getProperty( 'beanFactory' ).getBean( 'UsersTransfer' ).getTransfer() />
	<cfset var q_select_preferences = a_transfer.listByProperty( 'userpreferences.preference', 'userkey', application.udf.GetCurrentSecurityContext().entrykey ) />
	
	<cfscript>
	arguments.event.setArg( 'q_select_preferences', q_select_preferences );
	arguments.event.setArg("pref_skin", LoadInternalPreference('skin', ''));
	// arguments.event.setArg("pref_defaultplayer", LoadInternalPreference('defaultplayer', 'music'));
	arguments.event.setArg("pref_defaultorder", LoadInternalPreference('display.list.defaultorder', 'name'));
	arguments.event.setArg("web_streaming_quality", LoadInternalPreference('web.streaming.quality', '128'));
	arguments.event.setArg("sqbn_streaming_quality", LoadInternalPreference( application.const.S_PREF_SQBN_STREAMING_BITRATE, '128'));	
	
	arguments.event.setArg("bDisplayGuidedTour", LoadInternalPreference('display.guidedtour', '1'));
	// design: colors
	// arguments.event.setArg("pref_design_bg_color", LoadInternalPreference('customize.design_bg_color', ''));
	// arguments.event.setArg("pref_design_text_color", LoadInternalPreference('customize.design_text_color', ''));
	// arguments.event.setArg("pref_design_link_color", LoadInternalPreference('customize.design_link_color', ''));
	// arguments.event.setArg("pref_design_content_bg_color", LoadInternalPreference('customize.design_content_bg_color', ''));
	// arguments.event.setArg("pref_design_content_bg_sidebar", LoadInternalPreference('customize.design_content_bg_sidebar', ''));
	</cfscript>
	
</cffunction>

<cffunction access="private" name="LoadInternalPreference" output="false" returntype="string" hint="load a preference internally">
	<cfargument name="name" type="string" required="true">
	<cfargument name="defaultvalue" type="string" required="true">
	
	<cfreturn getProperty( 'beanFactory' ).GetBean( 'UserComponent' ).GetPreference( userkey = application.udf.GetCurrentSecurityContext().entrykey,
									name = arguments.name,
									defaultvalue = arguments.defaultvalue ) />
	
</cffunction>

<cffunction access="public" name="CheckStoreUserPreferences" output="false" returntype="void" hint="Check if we should store some user preferences">
	<cfargument name="event" type="MachII.framework.Event" required="true" />
	
	<cfset var a_bol_preference_exists = event.IsArgDefined( 'skin' ) />
	<cfset var a_do_reset = event.getArg( 'design_reset_all', false ) />
	<cfset var a_cmp_user = getProperty( 'beanFactory' ).getBean( 'UserComponent' ) />
	<cfset var a_update_data_reset_bg = { bgimage = 'RESET' } />
	
	<!--- reset all custom data --->
	<cfif a_do_reset>
		<cfset event.setArg( 'design_bg_color', '' ) />
		<cfset event.setArg( 'design_text_color', '' ) />
		<cfset event.setArg( 'design_link_color', '' ) />
		<cfset event.setArg( 'design_content_bg_color', '' ) />
		<cfset event.setArg( 'design_content_bg_sidebar', '' ) />
		
		<!--- reset default background --->
		<cfset a_cmp_user.UpdateUserData( securitycontext = application.udf.GetCurrentSecurityContext(), newvalues = a_update_data_reset_bg ) />
		
	</cfif>
	
	<!--- skin / design stuff exists --->
	<cfif a_bol_preference_exists>
		
		<!--- default web streaming bitrate --->
		<cfset getProperty( 'beanFactory' ).GetBean( 'UserComponent' ).StorePreference( userkey = application.udf.GetCurrentSecurityContext().entrykey,
					name = 'web.streaming.quality',
					value = arguments.event.getArg( 'streaming_bitrate', 128 )) />
					
		<!--- streaming bitrate squeezebox --->
		<cfset getProperty( 'beanFactory' ).GetBean( 'UserComponent' ).StorePreference( userkey = application.udf.GetCurrentSecurityContext().entrykey,
					name = application.const.S_PREF_SQBN_STREAMING_BITRATE,
					value = arguments.event.getArg( 'streaming_bitrate_sqbn', 128 )) />
		
		
		<!--- skin --->
		<cfset getProperty( 'beanFactory' ).GetBean( 'UserComponent' ).StorePreference( userkey = application.udf.GetCurrentSecurityContext().entrykey,
					name = 'skin',
					value = arguments.event.getArg( 'skin' )) />
					
		<!--- bg color --->
		<cfset getProperty( 'beanFactory' ).GetBean( 'UserComponent' ).StorePreference( userkey = application.udf.GetCurrentSecurityContext().entrykey,
					name = 'customize.design_bg_color',
					value = arguments.event.getArg( 'design_bg_color' )) />
		
		<!--- text color --->		
		<cfset getProperty( 'beanFactory' ).GetBean( 'UserComponent' ).StorePreference( userkey = application.udf.GetCurrentSecurityContext().entrykey,
					name = 'customize.design_text_color',
					value = arguments.event.getArg( 'design_text_color' )) />
					
		<!--- link color --->		
		<cfset getProperty( 'beanFactory' ).GetBean( 'UserComponent' ).StorePreference( userkey = application.udf.GetCurrentSecurityContext().entrykey,
					name = 'customize.design_link_color',
					value = arguments.event.getArg( 'design_link_color' )) />
		
		<!--- content bg color --->
		<cfset getProperty( 'beanFactory' ).GetBean( 'UserComponent' ).StorePreference( userkey = application.udf.GetCurrentSecurityContext().entrykey,
					name = 'customize.design_content_bg_color',
					value = arguments.event.getArg( 'design_content_bg_color' )) />
					
		<!--- sidebar --->		
		<cfset getProperty( 'beanFactory' ).GetBean( 'UserComponent' ).StorePreference( userkey = application.udf.GetCurrentSecurityContext().entrykey,
					name = 'customize.design_content_bg_sidebar',
					value = arguments.event.getArg( 'design_content_bg_sidebar' )) />
					
		<!--- rotate artist images? --->
		<cfset getProperty( 'beanFactory' ).GetBean( 'UserComponent' ).StorePreference( userkey = application.udf.GetCurrentSecurityContext().entrykey,
					name = 'ui.artistbgrot',
					value = arguments.event.getArg( 'rotateArtistBGImage', 0 )) />
		
	</cfif>

</cffunction>

</cfcomponent>
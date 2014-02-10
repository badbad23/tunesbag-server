<!--- //

	Module:		LastFM interaction
	Description: 
	Modified:	$Date$

	$Id$
	
// --->

<cfcomponent name="YT" displayname="Logging component"output="false" extends="MachII.framework.Listener" hint="Interact with youtube service">
	
<cfinclude template="/common/scripts.cfm">

<cffunction name="configure" access="public" output="false" returntype="void" hint="Configures this listener as part of the Mach-II  framework"> 
	<!--- do nothing --->
</cffunction> 

<cffunction name="FindVideoOfMediaItem" access="public" output="false" returntype="void" hint="Store log information in database"> 
<cfargument name="event" type="MachII.framework.Event" required="true" /> 

	<!--- <cfset var a_str_dao_path = '/tb_transfer_config/logging/' />
	<cfset var a_transfer = CreateObject("component", "transfer.TransferFactory").init(
									a_str_dao_path & 'datasource.xml',
									a_str_dao_path & "transfer.xml",
									getAppManager().getPropertyManager().getProperty('tempdir_mapping')).getTransfer() />
	<cfset var CFHTTP = 0 />
	<cfset var a_str_artist = event.getArg('artist', 'Air') />
	<cfset var a_str_http_content = '' />
	
	<cfhttp url="http://ws.audioscrobbler.com/1.0/artist/#urlencodedformat(a_str_artist)#/similar.xml"></cfhttp>
	
	<cfset a_str_http_content = cfhttp.FileContent />
		
	<!--- found? --->
	<cfif (FindNoCase('404', cfhttp.StatusCode) IS 1)>
		
		<cfscript>
		arguments.event.setArg('ArtistFound', false);
		</cfscript>
		
	<cfelse>
										
		<cfscript>
			arguments.event.setArg('ArtistFound', true);
			arguments.event.setArg('XMLInfoObj', XmlParse(a_str_http_content));
		</cfscript>
	
	</cfif> --->
	
</cffunction>

</cfcomponent>


<!--- //
	$Log$
	// --->
<!--- //

	Module:		Logger compnent
	Description: 
	
// --->

<cfcomponent name="provisioning" displayname="Logging component"output="false" extends="MachII.framework.Listener" hint="Prov cmp for tunesBag application">

<cffunction name="configure" access="public" output="false" returntype="void" hint="Configures this listener as part of the Mach-II  framework"> 
	<!--- do nothing --->
</cffunction> 

<cffunction name="CreateUploadStorage" access="public" output="false" returntype="void" hint="Store log information in database"> 
<cfargument name="event" type="MachII.framework.Event" required="true" /> 

	<cfreturn />
	
</cffunction>

</cfcomponent>
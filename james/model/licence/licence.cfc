<!--- //

	Module:		Security Component for mach-ii
	Action:		
	Description:	
	
// --->

<!--- general security checker ... --->
<cfcomponent name="security" displayname="licence component" output="false" extends="MachII.framework.Listener" hint="licenceing stuff for tunesBag application">
	
<cfinclude template="/common/scripts.cfm">

<cffunction name="configure" access="public" output="false" returntype="void" hint="Configures this listener as part of the Mach-II  framework"> 
<!--- do nothing --->
</cffunction> 

<cffunction access="public" name="generateLicencePermission" output="false" returntype="void" hint="tell client what is allowed">
	<cfargument name="event" type="MachII.framework.Event" required="true" />
	
	<cfset var oLicence = getProperty( 'beanFactory' ).getBean( 'LicenceComponent' ) />
	
	<cfset var stLicencePermissions = oLicence.applyLicencePermissionsToRequest( securitycontext = application.udf.GetCurrentSecurityContext(),
					 sRequest = 'LIBRARY',
					 bOwnDataOnly = true  ) />

	<cfset event.setArg( 'stLicencePermissions', stLicencePermissions ) />

</cffunction>

</cfcomponent>
<!--- init cfcs --->

<cfif StructKeyExists( application, 'bo' ) AND NOT StructKeyExists( url, 'reinit')>
	<cfexit method="exittemplate" />
</cfif>

<cflock type="exclusive" name="lock_init_cfc" timeout="60">

<cfset application.bo = {} />

<!--- start with the environment! --->
<cfset application.bo.oEnv = createObject( 'component', 'james.cfc.content.environments' ).init( sXMLEnvironmentsFile = 'config/environments.xml' ) />

</cflock>
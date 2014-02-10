<cfcomponent persistent="true" datasource="mytunesbutlercontent">
	
	<cfproperty name="id" fieldtype="id" ormtype="integer"
			generator="native"
			setter="false" />
		<cfproperty name="user_id" ormtype="integer"  />
		<cfproperty name="service_id" ormtype="integer"  />
		<cfproperty name="dt_created" ormtype="datetime" />
		<cfproperty name="dt_lastupdate" ormtype="datetime" />		
		<cfproperty name="servicename" ormtype="string" />
		<cfproperty name="source_id"  ormtype="integer" />
		<cfproperty name="status" ormtype="integer" />
		<cfproperty name="syncinfo" ormtype="string" />		
		<cfproperty name="times" ormType="integer" />
		
		<cffunction name="init" access="public" returntype="any" output="false">
			<cfreturn this />			
		</cffunction>

</cfcomponent> 
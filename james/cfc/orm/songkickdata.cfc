<cfcomponent persistent="true" datasource="mytunesbutlercontent">
	
	<cfproperty name="id" fieldtype="id" ormtype="integer"
			generator="native"
			setter="false" />
		<cfproperty name="mb_artistid" ormtype="integer"  />
		<cfproperty name="songkick_id" ormtype="integer"  />
		<cfproperty name="dstart" ormtype="timestamp" sqltype="timestamp" />
		<cfproperty name="lon" ormtype="float"  />
		<cfproperty name="lat" ormtype="float"  />		
		<cfproperty name="uri" ormtype="string" />
		<cfproperty name="location_city"  ormtype="string" />
		<cfproperty name="displayname" ormtype="string" />
		
		<cffunction name="init" access="public" returntype="any" output="false">
			
			<!--- <cfset this.setFirstname( 'Maxl' ) /> --->
			
			<cfreturn this />
			
		</cffunction>

</cfcomponent> 
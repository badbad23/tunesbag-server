<cfcomponent persistent="true" datasource="mytunesbutlercontent">
	
		<!--- primary --->
		<cfproperty name="artistid" fieldtype="id" ormtype="integer" />
		
		<!--- images --->
		<cfproperty name="img_revision" ormtype="integer"  />
		<cfproperty name="strip_available" ormtype="integer"  />		
		
		<!--- dates ... --->
		<cfproperty name="dt_created" ormtype="timestamp" sqltype="timestamp" />
		<cfproperty name="dt_lastupdate_lastfm" ormtype="timestamp" sqltype="timestamp" />
		<cfproperty name="dt_lastupdate_songkick" ormtype="timestamp" sqltype="timestamp" />
		
		<!--- some hints --->
		<cfproperty name="upcomingevents" ormtype="integer"  />
		<cfproperty name="fans" ormtype="integer"  />		
		
		<!--- images again --->
		<cfproperty name="artistimg"  ormtype="string" />
		
		<!--- bio in english --->
		<cfproperty name="bio_en" ormtype="string" />
		
		<!--- lastfm specific --->
		<cfproperty name="lastfm_listeners" ormtype="integer" />
		<cfproperty name="lastfm_playcount" ormtype="integer" />
		
		<!--- TODO: migrate to different table --->
		<cfproperty name="lastfm_tags" ormType="string" />
		
		<cffunction name="init" access="public" returntype="any" output="false">
			
			<cfreturn this />
			
		</cffunction>

</cfcomponent> 
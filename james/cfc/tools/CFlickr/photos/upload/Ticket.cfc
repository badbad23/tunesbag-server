<!---
Copyright 2006-2007 Chris Blackwell Email: chris@m0nk3y.net

This file is part of CFlickr.

CFlickr is free software; you can redistribute it and/or modify
it under the terms of the GNU General Public License as published by
the Free Software Foundation; either version 2 of the License, or
(at your option) any later version.

CFlickr is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
GNU General Public License for more details.

You should have received a copy of the GNU General Public License
along with CFlickr; if not, write to the Free Software
Foundation, Inc., 51 Franklin St, Fifth Floor, Boston, MA  02110-1301  USA
--->

<cfcomponent extends="CFlickr.AbstractObject">

	<cfscript>
	variables.id = 0;
	variables.complete = false;
	variables.error = false;
	variables.valid = true;
	variables.photoid = "";
	</cfscript>
	
	<cffunction name="getId" access="public" output="false" returntype="string">
		<cfreturn variables.id />
	</cffunction>
	<cffunction name="setId" access="public" output="false" returntype="void">
		<cfargument name="id" type="string" required="yes">
		<cfset variables.id = arguments.id >
	</cffunction>
	
	<cffunction name="getComplete" access="public" output="false" returntype="boolean">
		<cfreturn variables.complete />
	</cffunction>
	<cffunction name="setComplete" access="public" output="false" returntype="void">
		<cfargument name="complete" type="boolean" required="yes">
		<cfset variables.complete = arguments.complete >
	</cffunction>		
	
	<cffunction name="getError" access="public" output="false" returntype="boolean">
		<cfreturn variables.error />
	</cffunction>
	<cffunction name="setError" access="public" output="false" returntype="void">
		<cfargument name="error" type="boolean" required="yes">
		<cfset variables.error = arguments.error >
	</cffunction>		
	
	<cffunction name="getValid" access="public" output="false" returntype="boolean">
		<cfreturn variables.valid />
	</cffunction>
	<cffunction name="setValid" access="public" output="false" returntype="void">
		<cfargument name="valid" type="boolean" required="yes">
		<cfset variables.valid = arguments.valid >
	</cffunction>		
	
	<cffunction name="getPhotoId" access="public" output="false" returntype="string">
		<cfreturn variables.photoid />
	</cffunction>
	<cffunction name="setPhotoId" access="public" output="false" returntype="void">
		<cfargument name="photoid" type="string" required="yes">
		<cfset variables.photoid = arguments.photoid >
	</cffunction>		

	<cffunction name="parseXmlElement" access="public" output="true" returntype="CFlickr.photos.upload.Ticket">
		<cfargument name="xmlnode" type="any" required="yes" hint="An XML photo node from the Flickr rest service">
		<cfscript>
		if(structkeyexists(xmlnode.xmlattributes, 'id')) setId(xmlnode.xmlattributes.id);
		if(structkeyexists(xmlnode.xmlattributes, 'complete')) {
			if(xmlnode.xmlattributes.complete EQ 1) setComplete(true);
			if(xmlnode.xmlattributes.complete EQ 2) setError(true);
		}
		if(structkeyexists(xmlnode.xmlattributes, 'photoid')) setPhotoId(xmlnode.xmlattributes.photoid);
		if(structkeyexists(xmlnode.xmlattributes, 'invalid')) setValid(false);
		return this;
		</cfscript>

	</cffunction>
	
</cfcomponent>
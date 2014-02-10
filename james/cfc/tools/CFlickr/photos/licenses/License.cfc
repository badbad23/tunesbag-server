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
	variables.name = "";
	variables.licenseurl = "";
	</cfscript>
	
	<cffunction name="getId" access="public" output="false" returntype="string">
		<cfreturn variables.id />
	</cffunction>
	<cffunction name="setId" access="public" output="false" returntype="void">
		<cfargument name="id" type="string" required="yes">
		<cfset variables.id = arguments.id >
	</cffunction>

	<cffunction name="getName" access="public" output="false" returntype="string">
		<cfreturn variables.name />
	</cffunction>
	<cffunction name="setName" access="public" output="false" returntype="void">
		<cfargument name="name" type="string" required="yes">
		<cfset variables.name = arguments.name >
	</cffunction>
	
	<cffunction name="getUrl" access="public" output="false" returntype="string">
		<cfreturn variables.licenseurl/>
	</cffunction>
	<cffunction name="setUrl" access="public" output="false" returntype="void">
		<cfargument name="licenseurl" type="string" required="yes">
		<cfset variables.licenseurl = arguments.licenseurl>
	</cffunction>	
	
 	<cffunction name="parseXmlElement" access="public" output="false" returntype="CFlickr.photos.licenses.License">
		<cfargument name="xmlnode" type="any" required="yes">
		<cfscript>
		if(structkeyexists(xmlnode.xmlattributes, 'id')) setId(xmlnode.xmlattributes.id);
		if(structkeyexists(xmlnode.xmlattributes, 'name')) setName(xmlnode.xmlattributes.name);
		if(structkeyexists(xmlnode.xmlattributes, 'url')) setUrl(xmlnode.xmlattributes.url);
		return this;
		</cfscript>
	</cffunction>
</cfcomponent>
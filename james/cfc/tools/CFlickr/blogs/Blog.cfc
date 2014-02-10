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
	variables.id = "";	
	variables.name = "";
	variables.needpassword = false;
	variables.url = "";
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

	<cffunction name="getNeedPassword" access="public" output="false" returntype="boolean">
		<cfreturn variables.needpassword />
	</cffunction>
	<cffunction name="setNeedPassword" access="public" output="false" returntype="void">
		<cfargument name="needpassword" type="boolean" required="yes">
		<cfset variables.needpassword = arguments.needpassword >
	</cffunction>

	<cffunction name="getUrl" access="public" output="false" returntype="string">
		<cfreturn variables.url />
	</cffunction>
	<cffunction name="setUrl" access="public" output="false" returntype="void">
		<cfargument name="url" type="string" required="yes">
		<cfset variables.url = arguments.url >
	</cffunction>
	
	<cffunction name="parseXmlElement" access="public" output="false" returntype="CFlickr.blogs.Blog">
		<cfargument name="xmlnode" type="any" required="yes">
		<cfscript>
		if(structkeyexists(xmlnode.xmlattributes, 'id')) setId(xmlnode.xmlattributes.id);
		if(structkeyexists(xmlnode.xmlattributes, 'name')) setName(xmlnode.xmlattributes.name);
		if(structkeyexists(xmlnode.xmlattributes, 'needspassword')) setNeedPassword(xmlnode.xmlattributes.needspassword);
		if(structkeyexists(xmlnode.xmlattributes, 'url')) setUrl(xmlnode.xmlattributes.url);
		return this;
		</cfscript>
	</cffunction>



</cfcomponent>
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
	variables.path = "";
	variables.pathids = "";
	variables.count = 0;
	variables.subcats = arraynew(1);
	variables.groups = arraynew(1);
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
	
	<cffunction name="getPath" access="public" output="false" returntype="string">
		<cfreturn variables.path />
	</cffunction>
	<cffunction name="setPath" access="public" output="false" returntype="void">
		<cfargument name="path" type="string" required="yes">
		<cfset variables.path = arguments.path >
	</cffunction>
	
	<cffunction name="getPathIds" access="public" output="false" returntype="string">
		<cfreturn variables.pathids />
	</cffunction>
	<cffunction name="setPathIds" access="public" output="false" returntype="void">
		<cfargument name="pathids" type="string" required="yes">
		<cfset variables.pathids = arguments.pathids >
	</cffunction>
	
	<cffunction name="getCount" access="public" output="false" returntype="numeric">
		<cfreturn variables.count />
	</cffunction>
	<cffunction name="setCount" access="public" output="false" returntype="void">
		<cfargument name="count" type="numeric" required="yes">
		<cfset variables.count = arguments.count >
	</cffunction>
	
	<cffunction name="getSubCats" access="public" output="false" returntype="array">
		<cfreturn variables.subcats />
	</cffunction>
	<cffunction name="setSubCats" access="public" output="false" returntype="void">
		<cfargument name="subcats" type="array" required="yes">
		<cfset variables.subcats = arguments.subcats >
	</cffunction>
	<cffunction name="addSubCat" access="public" output="false" returntype="void">
		<cfargument name="subcat" type="CFlickr.groups.Category" required="yes">
		<cfset arrayappend(variables.subcats, arguments.subcat)>
	</cffunction>
	<cffunction name="removeSubCat" access="public" output="false" returntype="CFlickr.groups.Category">
		<cfargument name="position" type="numeric" required="yes">
		<cfset var tmp = "">
		<cfif arraylen(variables.subcats) GTE arguments.position>
			<cfset tmp = variables.subcats[arguments.position]>
			<cfset arraydeleteat(variables.subcats, arguments.position)>
		</cfif>
		<cfreturn tmp>		
	</cffunction>
	
	<cffunction name="getGroups" access="public" output="false" returntype="array">
		<cfreturn variables.groups />
	</cffunction>
	<cffunction name="setGroups" access="public" output="false" returntype="void">
		<cfargument name="groups" type="array" required="yes">
		<cfset variables.groups = arguments.groups >
	</cffunction>
	<cffunction name="addGroup" access="public" output="false" returntype="void">
		<cfargument name="group" type="CFlickr.groups.Group" required="yes">
		<cfset arrayappend(variables.groups, arguments.group)>
	</cffunction>
	<cffunction name="removeGroup" access="public" output="false" returntype="CFlickr.groups.Group">
		<cfargument name="position" type="numeric" required="yes">
		<cfset var tmp = "">
		<cfif arraylen(variables.groups) GTE arguments.position>
			<cfset tmp = variables.groups[arguments.position]>
			<cfset arraydeleteat(variables.groups, arguments.position)>
		</cfif>
		<cfreturn tmp>		
	</cffunction>
	
	<cffunction name="parseXmlElement" access="public" output="false" returntype="CFlickr.groups.Category">
		<cfargument name="xmlnode" type="any" required="yes">
		
		<cfscript>
		var tmp = "";
		var i = 0;
		o = "";
		
		if(structkeyexists(xmlnode.xmlattributes, 'id')) setId(xmlnode.xmlattributes.id);
		if(structkeyexists(xmlnode.xmlattributes, 'name')) setName(xmlnode.xmlattributes.name);
		if(structkeyexists(xmlnode.xmlattributes, 'path')) setPath(xmlnode.xmlattributes.path);
		if(structkeyexists(xmlnode.xmlattributes, 'pathids')) setPathIds(xmlnode.xmlattributes.pathids);
		if(structkeyexists(xmlnode.xmlattributes, 'count')) setCount(xmlnode.xmlattributes.count);
		
		// subcats
		tmp = xmlsearch(xmlnode, 'subcat');
		for(i=1; i LTE arraylen(tmp); i=i+1) {
			o = createobject("component", "Category");
			addSubCat(o.parseXmlElement(tmp[i]));
		}

		// groups
		tmp = xmlsearch(xmlnode, 'group');
		for(i=1; i LTE arraylen(tmp); i=i+1) {
			o = createobject("component", "Group");
			addGroup(o.parseXmlElement(tmp[i]));
		}
		
		return this;
		</cfscript>
		
	</cffunction>
	
</cfcomponent>
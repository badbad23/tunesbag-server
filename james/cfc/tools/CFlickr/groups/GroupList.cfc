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

<cfcomponent extends="CFlickr.AbstractList">

	<cffunction name="getGroups" access="public" output="false" returntype="array">
		<cfreturn getItems()>
	</cffunction>
	<cffunction name="setGroups" access="public" output="false" returntype="void">
		<cfargument name="groups" type="array" required="yes">
		<cfset setItems(arguments.groups)>
	</cffunction>
	<cffunction name="addGroup" access="public" output="false" returntype="void">
		<cfargument name="group" type="CFlickr.groups.Group" required="yes">
		<cfset addItem(arguments.group)>
	</cffunction>
	<cffunction name="removeGroup" access="public" output="false" returntype="CFlickr.groups.Group">
		<cfargument name="position" type="numeric" required="yes">
		<cfreturn removeItem(arguments.position)>
	</cffunction>

	<cffunction name="parseXmlElement" access="public" output="false" returntype="CFlickr.groups.GroupList">
		<cfargument name="xmlnode" type="any" required="yes">
		<cfset var tmp = "">
		<cfset var photo = "">
		<cfset var i = 0>
		<cfscript>
		if(structkeyexists(xmlnode.xmlattributes, 'page')) setPage(xmlnode.xmlattributes.page);
		if(structkeyexists(xmlnode.xmlattributes, 'pages')) setPages(xmlnode.xmlattributes.pages);
		if(structkeyexists(xmlnode.xmlattributes, 'perpage')) setPerPage(xmlnode.xmlattributes.perpage);
		if(structkeyexists(xmlnode.xmlattributes, 'total')) setTotal(xmlnode.xmlattributes.total);

		tmp = xmlsearch(xmlnode, "group");
		for(i=1; i LTE arraylen(tmp); i=i+1) {
			group = createobject("component", "CFlickr.groups.Group");
			addGroup(group.parseXmlElement(tmp[i]));
		}
		return this;
		</cfscript>
	
	</cffunction>

</cfcomponent>
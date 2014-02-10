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
	variables.description = "";
	variables.members = 0;
	variables.privacy = 0;
	variables.eighteenplus = false;
	variables.admin = false;
	variables.photocount = 0;
	variables.iconserver = 0;
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
	
	<cffunction name="getDescription" access="public" output="false" returntype="string">
		<cfreturn variables.description />
	</cffunction>
	<cffunction name="setDescription" access="public" output="false" returntype="void">
		<cfargument name="description" type="string" required="yes">
		<cfset variables.description = arguments.description >
	</cffunction>
	
	<cffunction name="getMembers" access="public" output="false" returntype="numeric">
		<cfreturn variables.members />
	</cffunction>
	<cffunction name="setMembers" access="public" output="false" returntype="void">
		<cfargument name="members" type="numeric" required="yes">
		<cfset variables.members = arguments.members >
	</cffunction>
	
	<cffunction name="getPrivacy" access="public" output="false" returntype="numeric">
		<cfreturn variables.privacy />
	</cffunction>
	<cffunction name="setPrivacy" access="public" output="false" returntype="void">
		<cfargument name="privacy" type="numeric" required="yes">
		<cfset variables.privacy = arguments.privacy >
	</cffunction>
	
	<cffunction name="getEighteenPlus" access="public" output="false" returntype="boolean">
		<cfreturn variables.eighteenplus />
	</cffunction>
	<cffunction name="setEighteenPlus" access="public" output="false" returntype="void">
		<cfargument name="eighteenplus" type="boolean" required="yes">
		<cfset variables.eighteenplus = arguments.eighteenplus >
	</cffunction>
	
	<cffunction name="getAdmin" access="public" output="false" returntype="boolean">
		<cfreturn variables.admin />
	</cffunction>
	<cffunction name="setAdmin" access="public" output="false" returntype="void">
		<cfargument name="admin" type="boolean" required="yes">
		<cfset variables.admin = arguments.admin >
	</cffunction>
		
	<cffunction name="getPhotoCount" access="public" output="false" returntype="numeric">
		<cfreturn variables.photocount />
	</cffunction>
	<cffunction name="setPhotoCount" access="public" output="false" returntype="void">
		<cfargument name="photocount" type="numeric" required="yes">
		<cfset variables.photocount = arguments.photocount >
	</cffunction>
		
	<cffunction name="getIconServer" access="public" output="false" returntype="numeric">
		<cfreturn variables.iconserver />
	</cffunction>
	<cffunction name="setIconServer" access="public" output="false" returntype="void">
		<cfargument name="iconserver" type="numeric" required="yes">
		<cfset variables.iconserver = arguments.iconserver >
	</cffunction>
	
	<cffunction name="getIconUrl" access="public" output="false" returntype="string">
		<cfreturn "http://static.flickr.com/#getIconServer()#/buddyicons/#getId()#.jpg">
	</cffunction>
	
	<cffunction name="parseXmlElement" access="public" output="false" returntype="CFlickr.groups.Group">
		<cfargument name="xmlnode" type="any" required="yes">
		
		<cfscript>
		var tmp = "";
		if(structkeyexists(xmlnode.xmlattributes, 'id')) setId(xmlnode.xmlattributes.id);
		else if(structkeyexists(xmlnode.xmlattributes, 'nsid')) setId(xmlnode.xmlattributes.nsid);
		
		if(structkeyexists(xmlnode.xmlattributes, 'name')) setName(xmlnode.xmlattributes.name);
		else if(structkeyexists(xmlnode.xmlattributes, 'title')) setName(xmlnode.xmlattributes.title);
		
		if(structkeyexists(xmlnode.xmlattributes, 'eighteenplus')) setEighteenPlus(xmlnode.xmlattributes.eighteenplus);
		if(structkeyexists(xmlnode.xmlattributes, 'admin')) setAdmin(xmlnode.xmlattributes.admin);
		if(structkeyexists(xmlnode.xmlattributes, 'privacy')) setPrivacy(xmlnode.xmlattributes.privacy);
		if(structkeyexists(xmlnode.xmlattributes, 'photos')) setPhotoCount(xmlnode.xmlattributes.photos);
		if(structkeyexists(xmlnode.xmlattributes, 'iconserver')) setIconServer(xmlnode.xmlattributes.iconserver);		
		
		// name
		tmp = xmlsearch(xmlnode, 'name');
		if(arraylen(tmp)) setName(tmp[1].xmltext);

		// gropupname
		tmp = xmlsearch(xmlnode, 'groupname');
		if(arraylen(tmp)) setName(tmp[1].xmltext);
		
		// description
		tmp = xmlsearch(xmlnode, 'description');
		if(arraylen(tmp)) setDescription(tmp[1].xmltext);
		
		// members
		tmp = xmlsearch(xmlnode, 'members');
		if(arraylen(tmp)) setMembers(tmp[1].xmltext);
		
		// privacy
		tmp = xmlsearch(xmlnode, 'privacy');
		if(arraylen(tmp)) setPrivacy(tmp[1].xmltext);
		
		return this;
		</cfscript>
	</cffunction>

</cfcomponent>
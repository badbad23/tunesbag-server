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

<cfcomponent extends="CFlickr.people.User">

	<cfscript>
	variables.friend = false;
	variables.family = false;
	variables.ignored = false;
	</cfscript>

	<cffunction name="getFriend" access="public" output="false" returntype="boolean">
		<cfreturn variables.friend />
	</cffunction>
	<cffunction name="setFriend" access="public" output="false" returntype="void">
		<cfargument name="friend" type="boolean" required="yes">
		<cfset variables.friend = arguments.friend >
	</cffunction>

	<cffunction name="getFamily" access="public" output="false" returntype="boolean">
		<cfreturn variables.family />
	</cffunction>
	<cffunction name="setFamily" access="public" output="false" returntype="void">
		<cfargument name="family" type="boolean" required="yes">
		<cfset variables.family = arguments.family >
	</cffunction>

	<cffunction name="getIgnored" access="public" output="false" returntype="boolean">
		<cfreturn variables.ignored />
	</cffunction>
	<cffunction name="setIgnored" access="public" output="false" returntype="void">
		<cfargument name="ignored" type="boolean" required="yes">
		<cfset variables.ignored = arguments.ignored >
	</cffunction>
	
	<cffunction name="parseXmlElement" access="public" output="false" returntype="CFlickr.contacts.Contact">
		<cfargument name="xmlnode" type="any" required="yes">
		<cfset var tmp = "">
		<cfset super.parseXmlElement(xmlnode)>
		<cfscript>
		if(structkeyexists(xmlnode.xmlattributes, 'nsid')) setId(xmlnode.xmlattributes.nsid);
		if(structkeyexists(xmlnode.xmlattributes, 'username')) setUsername(xmlnode.xmlattributes.username);
		if(structkeyexists(xmlnode.xmlattributes, 'realname')) setRealName(xmlnode.xmlattributes.realname);
		if(structkeyexists(xmlnode.xmlattributes, 'iconserver')) setIconServer(xmlnode.xmlattributes.iconserver);
		if(structkeyexists(xmlnode.xmlattributes, 'friend')) setFriend(xmlnode.xmlattributes.friend);
		if(structkeyexists(xmlnode.xmlattributes, 'family')) setFamily(xmlnode.xmlattributes.family);
		if(structkeyexists(xmlnode.xmlattributes, 'ignored')) setIgnored(xmlnode.xmlattributes.ignored);
		return this;
		</cfscript>
	</cffunction>

</cfcomponent>
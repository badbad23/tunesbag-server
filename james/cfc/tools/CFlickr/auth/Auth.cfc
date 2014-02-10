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
	variables.token = "";
	variables.perms = "";
	variables.user = createobject("component", "CFlickr.people.User");
	</cfscript>
	
	<!--- can't be callen `getToken()` as this conflicts with built in function --->
	<cffunction name="getAuthToken" access="public" output="false" returntype="string" 
		hint="This method is called 'getToken' in the Flickr API, but that method name conflicts with Coldfusions built in method">
		<cfreturn variables.token />
	</cffunction>
	<cffunction name="setAuthToken" access="public" output="false" returntype="void">
		<cfargument name="token" type="string" required="yes">
		<cfset variables.token = arguments.token>
	</cffunction>
	
	<cffunction name="getPermission" access="public" output="false" returntype="string">
		<cfreturn variables.perms />
	</cffunction>
	<cffunction name="setPermission" access="public" output="false" returntype="void">
		<cfargument name="perms" type="string" required="yes">
		<cfset variables.perms = arguments.perms>
	</cffunction>
	
	<cffunction name="getUser" access="public" output="false" returntype="CFlickr.people.User">
		<cfreturn variables.user />
	</cffunction>
	<cffunction name="setUser" access="public" output="false" returntype="void">
		<cfargument name="user" type="CFlickr.people.User" required="yes">
		<cfset variables.user = arguments.user>
	</cffunction>
	
	<cffunction name="parseXmlElement" access="public" output="false" returntype="CFlickr.auth.Auth">
		<cfargument name="xmlnode" type="any" required="yes">
		<cfscript>
		var tmp = "";
		// token
		tmp = xmlsearch(xmlnode, "token");
		if(arraylen(tmp)) setAuthToken(tmp[1].xmltext);
		
		// perms
		tmp = xmlsearch(xmlnode, "perms");
		if(arraylen(tmp)) setPermission(tmp[1].xmltext);
		
		// user
		tmp = xmlsearch(xmlnode, "user");
		if(arraylen(tmp)) tmp = tmp[1];
		if(structkeyexists(tmp.xmlattributes, 'fullname;')) getUser().setRealName(tmp.xmlattributes.fullname);
		if(structkeyexists(tmp.xmlattributes, 'nsid')) getUser().setId(tmp.xmlattributes.nsid);
		if(structkeyexists(tmp.xmlattributes, 'username')) getUser().setUsername(tmp.xmlattributes.username);
		</cfscript>
		<cfreturn this/>
	</cffunction>



</cfcomponent>
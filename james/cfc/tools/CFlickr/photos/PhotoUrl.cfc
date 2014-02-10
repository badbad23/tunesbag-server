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
	variables.photourl = "";
	variables.type = "";	
	</cfscript>
	
	<cffunction name="getUrl" access="public" output="false" returntype="string">
		<cfreturn variables.photourl/>
	</cffunction>
	<cffunction name="setUrl" access="public" output="false" returntype="void">
		<cfargument name="photourl" type="string" required="yes">
		<cfset variables.photourl = arguments.photourl>
	</cffunction>
	
	<cffunction name="getType" access="public" output="false" returntype="string">
		<cfreturn variables.type/>
	</cffunction>
	<cffunction name="setType" access="public" output="false" returntype="void">
		<cfargument name="type" type="string" required="yes">
		<cfset variables.type = arguments.type>
	</cffunction>
	
 	<cffunction name="parseXmlElement" access="public" output="false" returntype="CFlickr.photos.PhotoUrl">
		<cfargument name="xmlnode" type="any" required="yes" hint="must be an xml element of type 'url'">
		<cfscript>
		if(structkeyexists(xmlnode.xmlattributes, 'type')) setType(xmlnode.xmlattributes.type);
		setUrl(xmlnode.xmltext);
		</cfscript>
		<cfreturn this />
	</cffunction>

</cfcomponent>
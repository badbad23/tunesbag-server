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
	variables.label = "";
	variables.width = 0;
	variables.height = 0;
	variables.source = "";
	variables.url = "";
	</cfscript>
	
	<cffunction name="getLabel" access="public" output="false" returntype="string">
		<cfreturn variables.label />
	</cffunction>
	<cffunction name="setLabel" access="public" output="false" returntype="void">
		<cfargument name="label" type="string" required="yes">
		<cfset variables.label = arguments.label>
	</cffunction>

	<cffunction name="getWidth" access="public" output="false" returntype="numeric">
		<cfreturn variables.width />
	</cffunction>
	<cffunction name="setWidth" access="public" output="false" returntype="void">
		<cfargument name="width" type="numeric" required="yes">
		<cfset variables.width = arguments.width>
	</cffunction>

	<cffunction name="getHeight" access="public" output="false" returntype="numeric">
		<cfreturn variables.height />
	</cffunction>
	<cffunction name="setHeight" access="public" output="false" returntype="void">
		<cfargument name="height" type="numeric" required="yes">
		<cfset variables.height = arguments.height>
	</cffunction>

	<cffunction name="getSource" access="public" output="false" returntype="string">
		<cfreturn variables.source />
	</cffunction>
	<cffunction name="setSource" access="public" output="false" returntype="void">
		<cfargument name="source" type="string" required="yes">
		<cfset variables.source = arguments.source>
	</cffunction>

	<cffunction name="getUrl" access="public" output="false" returntype="string">
		<cfreturn variables.url />
	</cffunction>
	<cffunction name="setUrl" access="public" output="false" returntype="void">
		<cfargument name="url" type="string" required="yes">
		<cfset variables.url = arguments.url>
	</cffunction>
	
	<cffunction name="parseXmlElement" access="public" output="false" returntype="CFlickr.photos.Size">
		<cfargument name="xmlnode" type="any" required="yes">
		<cfscript>
		if(structkeyexists(xmlnode.xmlattributes, 'label')) setLabel(xmlnode.xmlattributes.label);
		if(structkeyexists(xmlnode.xmlattributes, 'width')) setWidth(xmlnode.xmlattributes.width);
		if(structkeyexists(xmlnode.xmlattributes, 'height')) setHeight(xmlnode.xmlattributes.height);
		if(structkeyexists(xmlnode.xmlattributes, 'source')) setSource(xmlnode.xmlattributes.source);
		if(structkeyexists(xmlnode.xmlattributes, 'url')) setUrl(xmlnode.xmlattributes.url);
		return this;
		</cfscript>
	</cffunction>

</cfcomponent>
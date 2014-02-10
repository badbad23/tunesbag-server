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
	variables.tagspace = "";
	variables.tagspaceid = 0;
	variables.tag = 0;
	variables.label = "";
	variables.raw = "";
	variables.clean = "";
	</cfscript>
	
	<cffunction name="getTagSpace" access="public" output="false" returntype="string">
		<cfreturn variables.tagspace />
	</cffunction>
	<cffunction name="setTagSpace" access="public" output="false" returntype="void">
		<cfargument name="tagspace" type="string" required="yes">
		<cfset variables.tagspace = arguments.tagspace>
	</cffunction>

	<cffunction name="getTagSpaceId" access="public" output="false" returntype="numeric">
		<cfreturn variables.tagspaceid />
	</cffunction>
	<cffunction name="setTagSpaceId" access="public" output="false" returntype="void">
		<cfargument name="tagspaceid" type="numeric" required="yes">
		<cfset variables.tagspaceid = arguments.tagspaceid>
	</cffunction>

	<cffunction name="getTag" access="public" output="false" returntype="numeric">
		<cfreturn variables.tag />
	</cffunction>
	<cffunction name="setTag" access="public" output="false" returntype="void">
		<cfargument name="tag" type="numeric" required="yes">
		<cfset variables.tag = arguments.tag>
	</cffunction>

	<cffunction name="getLabel" access="public" output="false" returntype="string">
		<cfreturn variables.label />
	</cffunction>
	<cffunction name="setLabel" access="public" output="false" returntype="void">
		<cfargument name="label" type="string" required="yes">
		<cfset variables.label = arguments.label>
	</cffunction>

	<cffunction name="getRaw" access="public" output="false" returntype="string">
		<cfreturn variables.raw />
	</cffunction>
	<cffunction name="setRaw" access="public" output="false" returntype="void">
		<cfargument name="raw" type="string" required="yes">
		<cfset variables.raw = arguments.raw>
	</cffunction>

	<cffunction name="getClean" access="public" output="false" returntype="string" hint="This method returns a pretty-formatted version of the tag where availabale">
		<cfreturn variables.clean />
	</cffunction>
	<cffunction name="setClean" access="public" output="false" returntype="void">
		<cfargument name="clean" type="string" required="yes">
		<cfset variables.clean = arguments.clean>
	</cffunction>
	
	<cffunction name="parseXmlElement" access="public" output="false" returntype="CFlickr.photos.Exif">
		<cfargument name="xmlnode" type="any" required="yes">
		<cfscript>
		var tmp = "";
		
		if(structkeyexists(xmlnode.xmlattributes, 'tagspace')) setTagSpace(xmlnode.xmlattributes.tagspace);
		if(structkeyexists(xmlnode.xmlattributes, 'tagspaceid')) setTagSpaceId(xmlnode.xmlattributes.tagspaceid);
		if(structkeyexists(xmlnode.xmlattributes, 'tag')) setTag(xmlnode.xmlattributes.tag);
		if(structkeyexists(xmlnode.xmlattributes, 'label')) setLabel(xmlnode.xmlattributes.label);
		
		tmp = xmlsearch(xmlnode, 'raw');
		if(arraylen(tmp)) setRaw(tmp[1].xmltext);
		
		tmp = xmlsearch(xmlnode, 'clean');
		if(arraylen(tmp)) setClean(tmp[1].xmltext);
		
		return this;
		</cfscript>
	</cffunction>


</cfcomponent>
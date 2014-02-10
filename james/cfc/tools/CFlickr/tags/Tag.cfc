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
	variables.author = "";
	variables.authorName = "";
	variables.raw = "";
	variables.value = "";
	variables.count = 0;
	variables.score = 0;
	variables.rawlist = "";
	</cfscript>
	
	<cffunction name="getId" access="public" output="false" returntype="string">
		<cfreturn variables.id />	
	</cffunction>
	<cffunction name="setId" access="public" output="false" returntype="void">
		<cfargument name="id" type="string" required="yes">
		<cfset variables.id = arguments.id >
	</cffunction>
		
	<cffunction name="getAuthorId" access="public" output="false" returntype="string">
		<cfreturn variables.author />	
	</cffunction>
	<cffunction name="setAuthorId" access="public" output="false" returntype="void">
		<cfargument name="author" type="string" required="yes">
		<cfset variables.author = arguments.author >
	</cffunction>
	
	<cffunction name="getAuthorName" access="public" output="false" returntype="string">
		<cfreturn variables.authorName />	
	</cffunction>
	<cffunction name="setAuthorName" access="public" output="false" returntype="void">
		<cfargument name="authorName" type="string" required="yes">
		<cfset variables.authorName = arguments.authorName >
	</cffunction>
	
	<cffunction name="getRaw" access="public" output="false" returntype="string">
		<cfreturn variables.raw />	
	</cffunction>
	<cffunction name="setRaw" access="public" output="false" returntype="void">
		<cfargument name="raw" type="string" required="yes">
		<cfset variables.raw = arguments.raw >
	</cffunction>
	
	<cffunction name="getRawList" access="public" output="false" returntype="string">
		<cfreturn variables.rawlist>
	</cffunction>
	<cffunction name="setRawList" access="public" output="false" returntype="void">
		<cfargument name="rawlist" type="string" required="yes">
		<cfset variables.rawlist = arguments.rawlist>
	</cffunction>
	
	<cffunction name="getValue" access="public" output="false" returntype="string">
		<cfreturn variables.value />	
	</cffunction>
	<cffunction name="setValue" access="public" output="false" returntype="void">
		<cfargument name="value" type="string" required="yes">
		<cfset variables.value = arguments.value >
	</cffunction>
	
	<cffunction name="getCount" access="public" output="false" returntype="numeric">
		<cfreturn variables.count />	
	</cffunction>
	<cffunction name="setCount" access="public" output="false" returntype="void">
		<cfargument name="count" type="numeric" required="yes">
		<cfset variables.count = arguments.count >
	</cffunction>

	<cffunction name="getScore" access="public" output="false" returntype="numeric">
		<cfreturn variables.score />	
	</cffunction>
	<cffunction name="setScore" access="public" output="false" returntype="void">
		<cfargument name="score" type="numeric" required="yes">
		<cfset variables.score = arguments.score >
	</cffunction>
		
 	<cffunction name="parseXmlElement" access="public" output="false" returntype="CFlickr.tags.Tag">
		<cfargument name="xmlnode" type="any" required="yes">
		<cfscript>
		var tmp = "";
		var myrawlist = "";
		var i = 0;

		if(structkeyexists(xmlnode.xmlattributes, 'id')) setID(xmlnode.xmlattributes.id);
		if(structkeyexists(xmlnode.xmlattributes, 'author')) setAuthorId(xmlnode.xmlattributes.author);
		if(structkeyexists(xmlnode.xmlattributes, 'authorname')) setAuthorName(xmlnode.xmlattributes.authorname);
		if(structkeyexists(xmlnode.xmlattributes, 'raw')) setRaw(xmlnode.xmlattributes.raw);
		if(structkeyexists(xmlnode.xmlattributes, 'count')) setCount(xmlnode.xmlattributes.count);
		if(structkeyexists(xmlnode.xmlattributes, 'score')) setScore(xmlnode.xmlattributes.score);

		if(structkeyexists(xmlnode.xmlattributes, 'clean')) setValue(xmlnode.xmlattributes.clean);
		else setValue(xmlnode.xmltext);
		
		tmp = xmlsearch(xmlnode, "raw");
		for(i=1; i LTE arraylen(tmp); i=i+1) {
			myrawlist = listappend(myrawlist, tmp[i].XmlText);
		}
		setRawList(myrawlist);
		
		</cfscript>
		
		<cfreturn this />
	</cffunction>


</cfcomponent>
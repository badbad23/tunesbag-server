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
	variables.authorid = "";
	variables.datecreate = createdate(1970,1,1);
	variables.permalink = "";
	variables.text = "";
	</cfscript>
	
	<cffunction name="getId" access="public" output="false" returntype="string">
		<cfreturn variables.id />
	</cffunction>
	<cffunction name="setId" access="public" output="false" returntype="void">
		<cfargument name="id" type="string" required="yes">
		<cfset variables.id = arguments.id >
	</cffunction>
	
	<cffunction name="getAuthor" access="public" output="false" returntype="string">
		<cfreturn variables.author />
	</cffunction>
	<cffunction name="setAuthor" access="public" output="false" returntype="void">
		<cfargument name="author" type="string" required="yes">
		<cfset variables.author = arguments.author >
	</cffunction>
	
	<cffunction name="getAuthorId" access="public" output="false" returntype="string">
		<cfreturn variables.authorid />
	</cffunction>
	<cffunction name="setAuthorId" access="public" output="false" returntype="void">
		<cfargument name="authorid" type="string" required="yes">
		<cfset variables.authorid = arguments.authorid >
	</cffunction>
	
	<cffunction name="getDateCreated" access="public" output="false" returntype="string">
		<cfreturn variables.datecreate />
	</cffunction>
	<cffunction name="setDateCreated" access="public" output="false" returntype="void">
		<cfargument name="datecreate" type="date" required="yes">
		<cfif isnumeric(arguments.datecreate)>
			<cfset arguments.datecreate = DateAdd("s", arguments.datecreate, createdate(1970,1,1))>
		</cfif>		
		<cfset variables.datecreate = arguments.datecreate >
	</cffunction>
	
	<cffunction name="getPermalink" access="public" output="false" returntype="string">
		<cfreturn variables.permalink />
	</cffunction>
	<cffunction name="setPermalink" access="public" output="false" returntype="void">
		<cfargument name="permalink" type="string" required="yes">
		<cfset variables.permalink = arguments.permalink >
	</cffunction>
	
	<cffunction name="getText" access="public" output="false" returntype="string">
		<cfreturn variables.text />
	</cffunction>
	<cffunction name="setText" access="public" output="false" returntype="void">
		<cfargument name="text" type="string" required="yes">
		<cfset variables.text = arguments.text >
	</cffunction>
	
	<cffunction name="parseXmlElement" access="public" output="false" returntype="CFlickr.comments.Comment">
		<cfargument name="xmlnode" type="any" required="yes">
		<cfscript>
		if(structkeyexists(xmlnode.xmlattributes, 'id')) setId(xmlnode.xmlattributes.id);
		if(structkeyexists(xmlnode.xmlattributes, 'author')) setAuthor(xmlnode.xmlattributes.author);
		if(structkeyexists(xmlnode.xmlattributes, 'datecreate')) setDateCreated(xmlnode.xmlattributes.datecreate);
		if(structkeyexists(xmlnode.xmlattributes, 'permalink')) setPermalink(xmlnode.xmlattributes.permalink);
		setText(xmlnode.xmltext);
		return this;
		</cfscript>
	</cffunction>

</cfcomponent>
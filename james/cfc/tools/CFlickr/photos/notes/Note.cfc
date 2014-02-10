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
	variables.authorid = "";
	variables.authorname = "";
	variables.h = 0;
	variables.w = 0;
	variables.x = 0;
	variables.y = 0;
	variables.datecreate = createdate(1970,1,1);
	variables.text = "";
	</cfscript>
	
	<cffunction name="getId" access="public" output="false" returntype="string">
		<cfreturn variables.id />
	</cffunction>
	<cffunction name="setId" access="public" output="false" returntype="void">
		<cfargument name="id" type="string" required="yes">
		<cfset variables.id = arguments.id >
	</cffunction>

	<cffunction name="getAuthorId" access="public" output="false" returntype="string">
		<cfreturn variables.authorid />
	</cffunction>
	<cffunction name="setAuthorId" access="public" output="false" returntype="void">
		<cfargument name="authorid" type="string" required="yes">
		<cfset variables.authorid = arguments.authorid >
	</cffunction>

	<cffunction name="getAuthorName" access="public" output="false" returntype="string">
		<cfreturn variables.authorname />
	</cffunction>
	<cffunction name="setAuthorName" access="public" output="false" returntype="void">
		<cfargument name="authorname" type="string" required="yes">
		<cfset variables.authorname = arguments.authorname >
	</cffunction>

	<cffunction name="getHeight" access="public" output="false" returntype="numeric">
		<cfreturn variables.h />
	</cffunction>
	<cffunction name="setHeight" access="public" output="false" returntype="void">
		<cfargument name="Height" type="numeric" required="yes">
		<cfset variables.h = arguments.height >
	</cffunction>

	<cffunction name="getWidth" access="public" output="false" returntype="numeric">
		<cfreturn variables.w />
	</cffunction>
	<cffunction name="setWidth" access="public" output="false" returntype="void">
		<cfargument name="Width" type="numeric" required="yes">
		<cfset variables.w = arguments.width >
	</cffunction>

	<cffunction name="getXPos" access="public" output="false" returntype="numeric">
		<cfreturn variables.x />
	</cffunction>
	<cffunction name="setXPos" access="public" output="false" returntype="void">
		<cfargument name="XPos" type="numeric" required="yes">
		<cfset variables.x = arguments.xpos >
	</cffunction>

	<cffunction name="getYPos" access="public" output="false" returntype="numeric">
		<cfreturn variables.y />
	</cffunction>
	<cffunction name="setYPos" access="public" output="false" returntype="void">
		<cfargument name="YPos" type="numeric" required="yes">
		<cfset variables.y = arguments.ypos >
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
	
	<cffunction name="getText" access="public" output="false" returntype="string">
		<cfreturn variables.Text />
	</cffunction>
	<cffunction name="setText" access="public" output="false" returntype="void">
		<cfargument name="Text" type="string" required="yes">
		<cfset variables.Text = arguments.Text >
	</cffunction>
	
 	<cffunction name="parseXmlElement" access="public" output="false" returntype="CFlickr.photos.notes.Note">
		<cfargument name="xmlnode" type="any" required="yes" hint="must be an xml element of type 'note'">
		<cfscript>
		if(structkeyexists(xmlnode.xmlattributes, 'author')) setAuthorId(xmlnode.xmlattributes.author);
		if(structkeyexists(xmlnode.xmlattributes, 'authorname')) setAuthorName(xmlnode.xmlattributes.authorname);
		if(structkeyexists(xmlnode.xmlattributes, 'id')) setId(xmlnode.xmlattributes.id);
		if(structkeyexists(xmlnode.xmlattributes, 'h')) setHeight(xmlnode.xmlattributes.h);
		if(structkeyexists(xmlnode.xmlattributes, 'w')) setWidth(xmlnode.xmlattributes.w);
		if(structkeyexists(xmlnode.xmlattributes, 'x')) setXPos(xmlnode.xmlattributes.x);
		if(structkeyexists(xmlnode.xmlattributes, 'y')) setYPos(xmlnode.xmlattributes.y);		
		setText(xmlnode.xmltext);
		</cfscript>
		<cfreturn this />
	</cffunction>
	

</cfcomponent>
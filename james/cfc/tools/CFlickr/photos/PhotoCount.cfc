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
	variables.count = 0;
	variables.fromdate = createdate(1970,1,1);
	variables.todate = createdate(1970,1,1);
	</cfscript>
	
	<cffunction name="getCount" access="public" output="false" returntype="numeric">
		<cfreturn variables.count />
	</cffunction>
	<cffunction name="setCount" access="public" output="false" returntype="void">
		<cfargument name="count" type="numeric" required="yes">
		<cfset variables.count = arguments.count>
	</cffunction>
	
	<cffunction name="getFromDate" access="public" output="false" returntype="date">
		<cfreturn variables.fromdate />
	</cffunction>
	<cffunction name="setFromDate" access="public" output="false" returntype="void">
		<cfargument name="fromdate" type="date" required="yes">
		<cfif isnumeric(arguments.fromdate)>
			<cfset arguments.fromdate = DateAdd("s", arguments.fromdate, createdate(1970,1,1))>
		</cfif>		
		<cfset variables.fromdate = arguments.fromdate>
	</cffunction>
	
	<cffunction name="getToDate" access="public" output="false" returntype="date">
		<cfreturn variables.todate />
	</cffunction>
	<cffunction name="setToDate" access="public" output="false" returntype="void">
		<cfargument name="todate" type="date" required="yes">
		<cfif isnumeric(arguments.todate)>
			<cfset arguments.todate = DateAdd("s", arguments.todate, createdate(1970,1,1))>
		</cfif>		
		<cfset variables.todate = arguments.todate>
	</cffunction>
	
	<cffunction name="parseXmlElement" access="public" output="false" returntype="CFlickr.photos.PhotoCount">
		<cfargument name="xmlnode" type="any" required="yes">
		
		<cfscript>
		if(structkeyexists(xmlnode.xmlattributes, 'count')) setCount(xmlnode.xmlattributes.count);
		if(structkeyexists(xmlnode.xmlattributes, 'fromdate')) setFromDate(xmlnode.xmlattributes.fromdate);
		if(structkeyexists(xmlnode.xmlattributes, 'todate')) setToDate(xmlnode.xmlattributes.todate);
		
		return this;
		</cfscript>
		
	</cffunction>
	

</cfcomponent>
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

	<cffunction name="setFaveDate" access="public" output="false" returntype="void">
		<cfargument name="favedate" type="date" required="yes">
		<cfset variables.favedate = arguments.favedate >
	</cffunction>
	<cffunction name="getFaveDate" access="public" output="false" returntype="date">
		<cfreturn variables.favedate>
	</cffunction>

	<cfscript>
	variables.favedate = 0;	
	</cfscript>
	
	<cffunction name="parseXmlElement" access="public" output="true" returntype="CFlickr.favorites.Favoriter">
		<cfargument name="xmlnode" type="any" required="yes" hint="An XML 'user' or 'person' element">
		<cfscript>
		super.parseXmlElement(arguments.xmlnode);
		if(structkeyexists(xmlnode.XmlAttributes, 'favedate')) setFaveDate(xmlnode.XmlAttributes.favedate);
		return this;
		</cfscript>
	
	</cffunction>
	
</cfcomponent>
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
	variables.latitude = "";
	variables.longitude = "";
	variables.accuracy = "";
	</cfscript>

	<cffunction name="getLatitude" access="public" output="false" returntype="numeric">
		<cfreturn variables.latitude />
	</cffunction>
	<cffunction name="setLatitude" access="public" output="false" returntype="void">
		<cfargument name="latitude" type="numeric" required="yes">
		<cfset variables.latitude = arguments.latitude>
	</cffunction>

	<cffunction name="getLongitude" access="public" output="false" returntype="numeric">
		<cfreturn variables.longitude />
	</cffunction>
	<cffunction name="setLongitude" access="public" output="false" returntype="void">
		<cfargument name="longitude" type="numeric" required="yes">
		<cfset variables.longitude = arguments.longitude>
	</cffunction>

	<cffunction name="getAccuracy" access="public" output="false" returntype="numeric">
		<cfreturn variables.accuracy />
	</cffunction>
	<cffunction name="setAccuracy" access="public" output="false" returntype="void">
		<cfargument name="accuracy" type="numeric" required="yes">
		<cfset variables.accuracy = arguments.accuracy>
	</cffunction>
		
 	<cffunction name="parseXmlElement" access="public" output="false" returntype="CFlickr.photos.geo.Location">
		<cfargument name="xmlnode" type="any" required="yes">
		<cfscript>
		if(structkeyexists(xmlnode.xmlattributes, 'latitude')) setLatitude(xmlnode.xmlattributes.latitude);
		if(structkeyexists(xmlnode.xmlattributes, 'longitude')) setLongitude(xmlnode.xmlattributes.longitude);
		if(structkeyexists(xmlnode.xmlattributes, 'accuracy')) setAccuracy(xmlnode.xmlattributes.accuracy);
		return this;
		</cfscript>
	</cffunction>

</cfcomponent>
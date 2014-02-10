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
	variables.ispublic = false;
	variables.iscontact = false;
	variables.isfriend = false;
	variables.isfamily = false;
	variables.permcomment = 0;
	variables.permaddmeta = 0;
	</cfscript>
	
	<cffunction name="getIsPublic" access="public" output="false" returntype="boolean">
		<cfreturn variables.ispublic />
	</cffunction>
	<cffunction name="setIsPublic" access="public" output="false" returntype="void">
		<cfargument name="ispublic" type="boolean" required="yes">
		<cfset variables.ispublic = arguments.ispublic >
	</cffunction>
	
	<cffunction name="getIsContact" access="public" output="false" returntype="boolean">
		<cfreturn variables.iscontact />
	</cffunction>
	<cffunction name="setIsContact" access="public" output="false" returntype="void">
		<cfargument name="iscontact" type="boolean" required="yes">
		<cfset variables.iscontact = arguments.iscontact >
	</cffunction>
	
	<cffunction name="getIsFriend" access="public" output="false" returntype="boolean">
		<cfreturn variables.isfriend />
	</cffunction>
	<cffunction name="setIsFriend" access="public" output="false" returntype="void">
		<cfargument name="isfriend" type="boolean" required="yes">
		<cfset variables.isfriend = arguments.isfriend >
	</cffunction>
	
	<cffunction name="getIsFamily" access="public" output="false" returntype="boolean">
		<cfreturn variables.isfamily />
	</cffunction>
	<cffunction name="setIsFamily" access="public" output="false" returntype="void">
		<cfargument name="isfamily" type="boolean" required="yes">
		<cfset variables.isfamily = arguments.isfamily >
	</cffunction>
	
	<cffunction name="getPermComment" access="public" output="false" returntype="numeric">
		<cfreturn variables.permcomment />
	</cffunction>
	<cffunction name="setPermComment" access="public" output="false" returntype="void">
		<cfargument name="permcomment" type="numeric" required="yes">
		<cfset variables.permcomment = arguments.permcomment >
	</cffunction>
	
	<cffunction name="getPermAddMeta" access="public" output="false" returntype="boolean">
		<cfreturn variables.permaddmeta />
	</cffunction>
	<cffunction name="setPermAddMeta" access="public" output="false" returntype="void">
		<cfargument name="permaddmeta" type="boolean" required="yes">
		<cfset variables.permaddmeta = arguments.permaddmeta >
	</cffunction>

		
 	<cffunction name="parseXmlElement" access="public" output="false" returntype="CFlickr.photos.Permission">
		<cfargument name="xmlnode" type="any" required="yes">
		<cfscript>
		if(structkeyexists(xmlnode.xmlattributes, 'ispublic')) setIsPublic(xmlnode.xmlattributes.ispublic);
		if(structkeyexists(xmlnode.xmlattributes, 'iscontact')) setIsContact(xmlnode.xmlattributes.iscontact);
		if(structkeyexists(xmlnode.xmlattributes, 'isfriend')) setIsFriend(xmlnode.xmlattributes.isfriend);
		if(structkeyexists(xmlnode.xmlattributes, 'isfamily')) setIsFamily(xmlnode.xmlattributes.isfamily);
		if(structkeyexists(xmlnode.xmlattributes, 'permcomment')) setPermComment(xmlnode.xmlattributes.permcomment);
		if(structkeyexists(xmlnode.xmlattributes, 'permaddmeta')) setPermAddMeta(xmlnode.xmlattributes.permaddmeta);
		return this;
		</cfscript>
	</cffunction>

</cfcomponent>
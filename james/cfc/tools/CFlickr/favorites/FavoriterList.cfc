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

<cfcomponent extends="CFlickr.AbstractList">

	<cfscript>
	variables.photo = createobject("component", "CFlickr.photos.Photo");
	</cfscript>

	<cffunction name="setPhoto" access="public" output="false" returntype="void">
		<cfargument name="photo" type="CFlickr.photos.Photo" required="yes">
		<cfset variables.photo = arguments.photo>
	</cffunction>
	<cffunction name="getPhoto" access="public" output="false" returntype="CFlickr.photos.Photo">
		<cfreturn variables.photo>
	</cffunction>

	<cffunction name="getFavoriters" access="public" output="false" returntype="array">
		<cfreturn getItems()>
	</cffunction>
	<cffunction name="setFavoriters" access="public" output="false" returntype="void">
		<cfargument name="favoriter" type="array" required="yes">
		<cfset setItems(arguments.favoriter)>
	</cffunction>
	<cffunction name="addFavoriter" access="public" output="false" returntype="void">
		<cfargument name="favoriter" type="CFlickr.favorites.Favoriter" required="yes">
		<cfset addItem(arguments.favoriter)>
	</cffunction>
	<cffunction name="removeFavoriter" access="public" output="false" returntype="Any">
		<cfargument name="position" type="numeric" required="yes">
		<cfreturn removeItem(arguments.position)>
	</cffunction>
	
	<cffunction name="parseXmlElement" access="public" output="false" returntype="CFlickr.AbstractList">
		<cfargument name="xmlnode" type="any" required="yes">
		<cfscript>
		var p = createobject("component", "CFlickr.photos.Photo");
		var f = "";
		var i = 0;
		var tmp = 0;
		
		super.parseXmlElement(arguments.xmlnode);
		variables.photo.parseXmlElement(xmlnode);
		
		tmp = xmlsearch(xmlnode, 'person');
		for(i=1; i LTE arraylen(tmp); i=i+1) {
			f = createobject("component", "CFlickr.favorites.Favoriter");
			f.parseXmlElement(tmp[i]);
			addItem(f);
		}
		
		return this;
		</cfscript>
	</cffunction>	



</cfcomponent>
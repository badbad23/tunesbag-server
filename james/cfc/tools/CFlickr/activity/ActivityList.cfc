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

	<cffunction name="getActivity" access="public" output="false" returntype="array">
		<cfreturn getItems()>
	</cffunction>
	<cffunction name="setActivity" access="public" output="false" returntype="void">
		<cfargument name="activity" type="array" required="yes">
		<cfset setItems(arguments.activity)>
	</cffunction>
	<cffunction name="addActivity" access="public" output="false" returntype="void">
		<cfargument name="activity" type="Any" required="yes">
		<cfset addItem(arguments.activity)>
	</cffunction>
	<cffunction name="removeActivity" access="public" output="false" returntype="Any">
		<cfargument name="position" type="numeric" required="yes">
		<cfreturn removeItem(arguments.position)>
	</cffunction>

	<cffunction name="parseXmlElement" access="public" output="false" returntype="CFlickr.activity.ActivityList">
		<cfargument name="xmlnode" type="any" required="yes">
		
		<cfscript>
		var items = xmlsearch(xmlnode, "item");
		var i = 0;
		var item = "";

		super.parseXmlElement(arguments.xmlnode);
		
		for(i=1; i LTE arraylen(items); i=i+1) {
			// we can't do anything unless we know what type this item is..
			if(structkeyexists(items[i].XmlAttributes, 'type')) {			
				if(items[i].XmlAttributes.type IS "photo") {
					item = createobject("component", "CFlickr.photos.Photo");
				}
				else if(items[i].XmlAttributes.type IS "photoset") {
					item = createobject("component", "CFlickr.photosets.Photoset");
				}
				addItem(item.parseXmlElement(items[i]));
			}
		}
		
		</cfscript>		
		
		<cfreturn this />
	</cffunction>
	
	
	
</cfcomponent>
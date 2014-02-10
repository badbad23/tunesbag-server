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

	<cffunction name="getContact" access="public" output="false" returntype="array">
		<cfreturn getItems()>
	</cffunction>
	<cffunction name="setContact" access="public" output="false" returntype="void">
		<cfargument name="contact" type="array" required="yes">
		<cfset setItems(arguments.contact)>
	</cffunction>
	<cffunction name="addContact" access="public" output="false" returntype="void">
		<cfargument name="contact" type="Any" required="yes">
		<cfset addItem(arguments.contact)>
	</cffunction>
	<cffunction name="removeContact" access="public" output="false" returntype="Any">
		<cfargument name="position" type="numeric" required="yes">
		<cfreturn removeItem(arguments.position)>
	</cffunction>

	<cffunction name="parseXmlElement" access="public" output="false" returntype="CFlickr.contacts.ContactList">
		<cfargument name="xmlnode" type="any" required="yes">
		
		<cfscript>
		var contacts = xmlsearch(xmlnode, "contact");
		var i = 0;
		var item = "";

		super.parseXmlElement(arguments.xmlnode);
		
		for(i=1; i LTE arraylen(contacts); i=i+1) {
			item = createobject("component", "CFlickr.contacts.Contact");
			addItem(item.parseXmlElement(contacts[i]));
		}
		</cfscript>		
		
		<cfreturn this />
	</cffunction>
	
	
	
</cfcomponent>
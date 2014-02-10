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
	variables.page = 0;
	variables.Pages = 0;
	variables.perPage = 0;
	variables.total = 0;
	variables.items = arraynew(1);
	</cfscript>

	<cffunction name="getPage" access="public" output="false" returntype="numeric" hint="The page number of this list">
		<cfreturn variables.page/>
	</cffunction>
	<cffunction name="setPage" access="public" output="false" returntype="void">
		<cfargument name="page" type="numeric" required="yes">
		<cfset variables.page = arguments.page >
	</cffunction>

	<cffunction name="getPages" access="public" output="false" returntype="numeric" hint="The total number of pages available">
		<cfreturn variables.Pages/>
	</cffunction>
	<cffunction name="setPages" access="public" output="false" returntype="void">
		<cfargument name="Pages" type="numeric" required="yes">
		<cfset variables.Pages = arguments.Pages >
	</cffunction>

	<cffunction name="getPerPage" access="public" output="false" returntype="numeric" hint="The number of items per page">
		<cfreturn variables.perPage/>
	</cffunction>
	<cffunction name="setPerPage" access="public" output="false" returntype="void">
		<cfargument name="perPage" type="numeric" required="yes">
		<cfset variables.perPage = arguments.perPage >
	</cffunction>

	<cffunction name="getTotal" access="public" output="false" returntype="numeric" hint="The number of items in this list">
		<cfreturn variables.total/>
	</cffunction>
	<cffunction name="setTotal" access="public" output="false" returntype="void">
		<cfargument name="total" type="numeric" required="yes">
		<cfset variables.total = arguments.total >
	</cffunction>

	<cffunction name="getItems" access="private" output="false" returntype="array">
		<cfreturn variables.items/>
	</cffunction>
	<cffunction name="setItems" access="private" output="false" returntype="void">
		<cfargument name="items" type="array" required="yes">
		<cfset variables.items = arguments.items >
	</cffunction>
	<cffunction name="addItem" access="private" output="false" returntype="void" >
		<cfargument name="item" type="any" required="yes">
		<cfset arrayappend(variables.items, arguments.item)>
	</cffunction>
	<cffunction name="removeItem" access="private" output="false" returntype="any"> 
		<cfargument name="position" type="numeric" required="yes">
		<cfset var tmp = "">
		<cfif arraylen(variables.items) GTE arguments.position>
			<cfset tmp = variables.items[arguments.position]>
			<cfset arraydeleteat(variables.items, arguments.position)>
		</cfif>
		<cfreturn tmp>
	</cffunction>
	
	<!--- Overriding methods should call super.parseXmlElement(xmlnode) --->
	<cffunction name="parseXmlElement" access="public" output="false" returntype="CFlickr.AbstractList">
		<cfargument name="xmlnode" type="any" required="yes">
		<cfscript>
		if(structkeyexists(xmlnode.xmlattributes, 'page')) setPage(xmlnode.xmlattributes.page);
		if(structkeyexists(xmlnode.xmlattributes, 'pages')) setPages(xmlnode.xmlattributes.pages);
		if(structkeyexists(xmlnode.xmlattributes, 'perpage')) setPerPage(xmlnode.xmlattributes.perpage);
		if(structkeyexists(xmlnode.xmlattributes, 'total')) setTotal(xmlnode.xmlattributes.total);
		</cfscript>
		<cfreturn this />
	</cffunction>

</cfcomponent>




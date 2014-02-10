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

<cfcomponent extends="CFlickr.AbstractInterface">

	<cffunction name="browse" access="public" output="false" returntype="CFlickr.groups.Category"
		hint="	Browse the group category tree, finding groups and sub-categories.<br>
				NB: This method can be very slow, especially if browsing large nodes in the category tree.<br>
				I'd recomend caching this data locally.<br>  
				TODO: improve speed">
		<cfargument name="cat_id" type="string" required="no" hint="The category id to fetch a list of groups and sub-categories for. If not specified, it defaults to zero, the root of the category tree.">
		<cfset var resp = flickr.get("flickr.groups.browse", arguments)>
		<cfset var cat = createObject("component", "Category")>
		<cfif resp.isError()>
			<cfthrow errorcode="#resp.getErrorCode()#" message="#resp.getErrorMessage()#">
		</cfif>			
		<cfreturn cat.parseXmlElement(resp.getPayload())>
	</cffunction>
	
	<cffunction name="getInfo" access="public" output="false" returntype="CFlickr.groups.Group" hint="Get information about a group.">
		<cfargument name="group_id" type="string" required="yes" hint="The NSID of the group to fetch information for. ">
		<cfset var resp = flickr.get("flickr.groups.getInfo", arguments)>
		<cfset var group = createObject("component", "Group")>
		<cfif resp.isError()>
			<cfthrow errorcode="#resp.getErrorCode()#" message="#resp.getErrorMessage()#">
		</cfif>			
		<cfreturn group.parseXmlElement(resp.getPayload())>
	</cffunction>

	<cffunction name="search" access="public" output="false" returntype="CFlickr.groups.GroupList" hint="Search for groups. 18+ groups will only be returned for authenticated calls where the authenticated user is over 18.">
		<cfargument name="text" type="string" required="yes" hint="The text to search for. ">
		<cfargument name="per_page" type="numeric" required="no" hint="Number of groups to return per page. If this argument is ommited, it defaults to 100. The maximum allowed value is 500. ">
		<cfargument name="page" type="numeric" required="no" hint="The page of results to return. If this argument is ommited, it defaults to 1. ">
		<cfset var resp = flickr.get("flickr.groups.search", arguments)>
		<cfset var grouplist = createObject("component", "GroupList")>
		<cfif resp.isError()>
			<cfthrow errorcode="#resp.getErrorCode()#" message="#resp.getErrorMessage()#">
		</cfif>	
		<cfreturn grouplist.parseXmlElement(resp.getPayload())>
	</cffunction>


</cfcomponent>
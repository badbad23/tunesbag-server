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

	<cffunction name="getGroup" access="public" output="false" returntype="string" hint="Returns the url to a group's page.">
		<cfargument name="group_id" type="string" required="yes" hint="The NSID of the group to fetch the url for. ">
		<cfset var resp = flickr.get("flickr.urls.getGroup", arguments)>
		<cfif resp.isError()>
			<cfthrow errorcode="#resp.getErrorCode()#" message="#resp.getErrorMessage()#">
		</cfif>
		<cfreturn resp.getPayload().xmlattributes.url>
	</cffunction>

	<cffunction name="getUserPhotos" access="public" output="false" returntype="string" hint="Returns the url to a user's photos.">
		<cfargument name="user_id" type="string" required="no" hint="The NSID of the user to fetch the url for. If omitted, the calling user is assumed.">
		<cfset var resp = flickr.get("flickr.urls.getUserPhotos", arguments)>
		<cfif resp.isError()>
			<cfthrow errorcode="#resp.getErrorCode()#" message="#resp.getErrorMessage()#">
		</cfif>
		<cfreturn resp.getPayload().xmlattributes.url>
	</cffunction>

	<cffunction name="getUserProfile" access="public" output="false" returntype="string" hint="Returns the url to a user's profile.">
		<cfargument name="user_id" type="string" required="no" hint="The NSID of the user to fetch the url for. If omitted, the calling user is assumed. ">
		<cfset var resp = flickr.get("flickr.urls.getUserProfile", arguments)>
		<cfif resp.isError()>
			<cfthrow errorcode="#resp.getErrorCode()#" message="#resp.getErrorMessage()#">
		</cfif>
		<cfreturn resp.getPayload().xmlattributes.url>
	</cffunction>

	<cffunction name="lookupGroup" access="public" output="false" returntype="CFlickr.groups.Group" hint="Returns a group NSID, given the url to a group's page or photo pool.">
		<cfargument name="url" type="string" required="yes" hint="The url to the group's page or photo pool. ">
		<cfset var resp = flickr.get("flickr.urls.lookupGroup", arguments)>
		<cfset var group = createobject("component", "CFlickr.groups.Group")>
		<cfif resp.isError()>
			<cfthrow errorcode="#resp.getErrorCode()#" message="#resp.getErrorMessage()#">
		</cfif>
		<cfreturn group.parseXmlElement(resp.getPayload()) />
	</cffunction>
	
	<cffunction name="lookupUser" access="public" output="false" returntype="string" hint="Returns a user NSID, given the url to a user's photos or profile.">
		<cfargument name="url" type="string" required="yes" hint="Thr url to the user's profile or photos page. ">
		<cfset var resp = flickr.get("flickr.urls.lookupUser", arguments)>
		<cfset var user = createobject("component", "CFlickr.people.User")>
		<cfif resp.isError()>
			<cfthrow errorcode="#resp.getErrorCode()#" message="#resp.getErrorMessage()#">
		</cfif>
		<cfreturn user.parseXmlElement(resp.getPayload()) />
	</cffunction>


</cfcomponent>
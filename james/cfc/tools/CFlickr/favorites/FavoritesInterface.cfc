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

	<cffunction name="add" access="public" output="false" returntype="boolean" hint="Adds a photo to a user's favorites list.">
		<cfargument name="photo_id" type="string" required="yes" hint="The id of the photo to add to the user's favorites.">
		<cfset var resp = flickr.get("flickr.favorites.add", arguments)>
		<cfif resp.isError()>
			<cfthrow errorcode="#resp.getErrorCode()#" message="#resp.getErrorMessage()#">
		</cfif>		
		<cfreturn NOT resp.isError()>
	</cffunction>

	<cffunction name="getList" access="public" output="false" returntype="CFlickr.photos.PhotoList" hint="Returns a list of the user's favorite photos. Only photos which the calling user has permission to see are returned.">
		<cfargument name="user_id" type="string" required="no" hint="The NSID of the user to fetch the favorites list for. If this argument is omitted, the favorites list for the calling user is returned.">
		<cfargument name="extras" type="string" required="no" hint="A comma-delimited list of extra information to fetch for each returned record. Currently supported fields are: license, date_upload, date_taken, owner_name, icon_server, original_format, last_update, geo.">
		<cfargument name="per_page" type="numeric" required="no" hint="Number of photos to return per page. If this argument is omitted, it defaults to 100. The maximum allowed value is 500. ">
		<cfargument name="page" type="numeric" required="no" hint="The page of results to return. If this argument is omitted, it defaults to 1. ">
		<cfset var resp = flickr.get("flickr.favorites.getList", arguments)>
		<cfset var photolist = createobject("component", "CFlickr.photos.PhotoList")>
		<cfif resp.isError()>
			<cfthrow errorcode="#resp.getErrorCode()#" message="#resp.getErrorMessage()#">
		</cfif>
		<cfreturn photolist.parseXmlElement(resp.getPayload())>
	</cffunction>	

	<cffunction name="getPublicList" access="public" output="false" returntype="CFlickr.photos.PhotoList" hint="Returns a list of favorite public photos for the given user.">
		<cfargument name="user_id" type="string" required="yes" hint="The NSID of the user to fetch the favorites list for. If this argument is omitted, the favorites list for the calling user is returned.">
		<cfargument name="extras" type="string" required="no" hint="A comma-delimited list of extra information to fetch for each returned record. Currently supported fields are: license, date_upload, date_taken, owner_name, icon_server, original_format, last_update, geo.">
		<cfargument name="per_page" type="numeric" required="no" hint="Number of photos to return per page. If this argument is omitted, it defaults to 100. The maximum allowed value is 500. ">
		<cfargument name="page" type="numeric" required="no" hint="The page of results to return. If this argument is omitted, it defaults to 1. ">
		<cfset var resp = flickr.get("flickr.favorites.getPublicList", arguments)>
		<cfset var photolist = createobject("component", "CFlickr.photos.PhotoList")>
		<cfif resp.isError()>
			<cfthrow errorcode="#resp.getErrorCode()#" message="#resp.getErrorMessage()#">
		</cfif>
		<cfreturn photolist.parseXmlElement(resp.getPayload())>
	</cffunction>

	<cffunction name="remove" access="public" output="false" returntype="boolean" hint="Removes a photo from a user's favorites list.">
		<cfargument name="photo_id" type="string" required="yes" hint="The id of the photo to remove from the user's favorites. ">
		<cfset var resp = flickr.get("flickr.favorites.remove", arguments)>
		<cfif resp.isError()>
			<cfthrow errorcode="#resp.getErrorCode()#" message="#resp.getErrorMessage()#">
		</cfif>		
		<cfreturn NOT resp.isError()>
	</cffunction>
	
</cfcomponent>
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

	<cffunction name="add" access="public" output="false" returntype="boolean" hint="Add a photo to a group's pool.">
		<cfargument name="photo_id" type="string" required="yes" hint="The id of the photo to add to the group pool. The photo must belong to the calling user. ">
		<cfargument name="group_id" type="string" required="yes" hint="The NSID of the group who's pool the photo is to be added to. ">
		<cfset var resp = flickr.get("flickr.groups.pools.add", arguments)>
		<cfif resp.isError()>
			<cfthrow errorcode="#resp.getErrorCode()#" message="#resp.getErrorMessage()#">
		</cfif>		
		<cfreturn NOT resp.isError()>
	</cffunction>	

	<cffunction name="getContext" access="public" output="false" returntype="CFlickr.photos.PhotoContext" hint="Returns next and previous photos for a photo in a group pool.">
		<cfargument name="photo_id" type="string" required="yes" hint="The id of the photo to fetch the context for. ">
		<cfargument name="group_id" type="string" required="yes" hint="The nsid of the group who's pool to fetch the photo's context for. ">
		<cfset var resp = flickr.get("flickr.groups.pools.getContext", arguments)>
		<cfset var context = createobject("component", "CFlickr.photos.PhotoContext")>
		<cfset var payload = "">
		<cfset var tmp = "">
		<cfset var photo = "">
		<cfif resp.isError()>
			<cfthrow errorcode="#resp.getErrorCode()#" message="#resp.getErrorMessage()#">
		</cfif>		
		
		<cfscript>
		payload = resp.getDoc();
		
		tmp = xmlsearch(payload, '/rsp/count');
		if(arraylen(tmp)) context.setCount(tmp[1].xmltext);
		
		tmp = xmlsearch(payload, '/rsp/prevphoto');
		if(arraylen(tmp)) {
			photo = createobject("component", "CFlickr.photos.Photo");
			context.setPrev(photo.parseXmlElement(tmp[1]));
		}
		
		tmp = xmlsearch(payload, '/rsp/nextphoto');
		if(arraylen(tmp)) {
			photo = createobject("component", "CFlickr.photos.Photo");
			context.setNext(photo.parseXmlElement(tmp[1]));
		}
		
		return context;		
		</cfscript>
	</cffunction>
	
	<cffunction name="getGroups" access="public" output="false" returntype="CFlickr.groups.GroupList" hint="Returns a list of groups to which you can add photos.">
		<cfargument name="page" type="numeric" required="no" hint="The page of results to return. If this argument is omitted, it defaults to 1.">
		<cfargument name="per_page" type="numeric" required="no" hint="Number of groups to return per page. If this argument is omitted, it defaults to 400. The maximum allowed value is 400.">
		<cfset var resp = flickr.get("flickr.groups.pools.getGroups", arguments)>
		<cfset grouplist = createobject("component", "CFlickr.groups.GroupList")>
		<cfif resp.isError()>
			<cfthrow errorcode="#resp.getErrorCode()#" message="#resp.getErrorMessage()#">
		</cfif>				
		<cfreturn grouplist.parseXmlElement(resp.getPayload())>
	</cffunction>	
		
	<cffunction name="getPhotos" access="public" output="false" returntype="CFlickr.photos.PhotoList" hint="Returns a list of pool photos for a given group, based on the permissions of the group and the user logged in (if any).">
		<cfargument name="group_id" type="string" required="yes" hint="The id of the group who's pool you which to get the photo list for">
		<cfargument name="tags" type="string" required="no" hint="A tag to filter the pool with. At the moment only one tag at a time is supported">
		<cfargument name="user_id" type="string" required="no" hint="The nsid of a user. Specifiying this parameter will retrieve for you only those photos that the user has contributed to the group pool">
		<cfargument name="extras" type="string" required="no" hint="List, any of: license, date_upload, date_taken, owner_name, icon_server, original_format, last_update">
		<cfargument name="per_page" type="numeric" required="no" hint="Number of photos to return per page. If this argument is omitted, it defaults to 100. The maximum allowed value is 500">
		<cfargument name="page" type="numeric" required="no" hint="The page of results to return. If this argument is omitted, it defaults to 1">

		<cfset var resp = flickr.get("flickr.groups.pools.getPhotos", arguments)>
		<cfset var photolist = createobject("component", "CFlickr.photos.PhotoList")>
		<cfif resp.isError()>
			<cfthrow errorcode="#resp.getErrorCode()#" message="#resp.getErrorMessage()#">
		</cfif>		
		<cfreturn photolist.parseXmlElement(resp.getPayload())>
	</cffunction>

	<cffunction name="remove" access="public" output="false" returntype="boolean" hint="Remove a photo from a group pool.">
		<cfargument name="photo_id" type="string" required="yes" hint="The id of the photo to remove from the group pool. The photo must either be owned by the calling user of the calling user must be an administrator of the group. ">
		<cfargument name="group_id" type="string" required="yes" hint="The NSID of the group who's pool the photo is to removed from. ">
		<cfset var resp = flickr.get("flickr.groups.pools.remove", arguments)>
		<cfif resp.isError()>
			<cfthrow errorcode="#resp.getErrorCode()#" message="#resp.getErrorMessage()#">
		</cfif>		
		<cfreturn NOT resp.isError()>
	</cffunction>	

</cfcomponent>



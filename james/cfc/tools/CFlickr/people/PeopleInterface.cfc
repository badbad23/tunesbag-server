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

	<cffunction name="findByEmail" access="public" output="false" returntype="CFlickr.people.User" hint="Return a user's NSID, given their email address">
 		<cfargument name="find_email" type="string" required="yes" hint="The email address of the user to find (may be primary or secondary). ">
		<cfset var resp = flickr.get("flickr.people.findByEmail", arguments)>
		<cfset var user = createObject("component", "CFlickr.people.User")>
		<cfif resp.isError()>
			<cfthrow errorcode="#resp.getErrorCode()#" message="#resp.getErrorMessage()#">
		</cfif>			
		<cfreturn user.parseXmlElement(resp.getPayload())>
	</cffunction>
	
	<cffunction name="findByUsername" access="public" output="false" returntype="CFlickr.people.User" hint="Return a user's NSID, given their username.">
 		<cfargument name="username" type="string" required="yes" hint="The username of the user to lookup.">
		<cfset var resp = flickr.get("flickr.people.findByUsername", arguments)>
		<cfset var user = createObject("component", "CFlickr.people.User")>
		<cfif resp.isError()>
			<cfthrow errorcode="#resp.getErrorCode()#" message="#resp.getErrorMessage()#">
		</cfif>			
		<cfreturn user.parseXmlElement(resp.getPayload())>
	</cffunction>
	
	<cffunction name="getInfo" access="public" output="true" returntype="CFlickr.people.User" hint="Get information about a user.">
		<cfargument name="user_id" type="string" required="no" hint="The NSID of the user to fetch information about. ">
		<cfset var resp = flickr.get("flickr.people.getInfo", arguments)>
		<cfset var user = createObject("component", "CFlickr.people.User")>
		<cfif resp.isError()>
			<cfthrow errorcode="#resp.getErrorCode()#" message="#resp.getErrorMessage()#">
		</cfif>			
		<cfreturn user.parseXmlElement(resp.getPayload())>
	</cffunction>
	
	<cffunction name="getPublicGroups" access="public" output="false" returntype="array" hint="Returns the list of public groups a user is a member of.">
		<cfargument name="user_id" type="string" required="yes" hint="The NSID of the user to fetch groups for. ">
		<cfset var resp = flickr.get("flickr.people.getPublicGroups", arguments)>
		<cfset var ret = arraynew(1)>
		<cfset var group = "">
		<cfset var tmp = "">
		<cfset var i = 0>
		
		<cfif resp.isError()>
			<cfthrow errorcode="#resp.getErrorCode()#" message="#resp.getErrorMessage()#">
		</cfif>			
		
		<cfscript>
		tmp = xmlsearch(resp.getPayLoad(), 'group');
		for(i=1; i LTE arraylen(tmp); i=i+1) {
			group = createobject("component", "CFlickr.groups.Group");
			arrayappend(ret, group.parseXmlElement(tmp[i]));
		}
		
		return ret;
		</cfscript>
	</cffunction>
	
	<cffunction name="getPublicPhotos" access="public" output="false" returntype="CFlickr.photos.PhotoList" hint="Get a list of public photos for the given user.">
		<cfargument name="user_id" type="string" required="yes" hint="The NSID of the user who's photos to return. ">
		<cfargument name="extras" type="string" required="no" hint="A comma-delimited list of extra information to fetch for each returned record. Currently supported fields are: license, date_upload, date_taken, owner_name, icon_server, original_format, last_update, geo. ">
		<cfargument name="per_page" type="numeric" required="no" hint="Number of photos to return per page. If this argument is omitted, it defaults to 100. The maximum allowed value is 500. ">
		<cfargument name="page" type="numeric" required="no" hint="The page of results to return. If this argument is omitted, it defaults to 1. ">
		<cfset var resp = flickr.get("flickr.people.getPublicPhotos", arguments)>
		<cfset var photolist = createobject("component", "CFlickr.photos.PhotoList")>
		<cfif resp.isError()>
			<cfthrow errorcode="#resp.getErrorCode()#" message="#resp.getErrorMessage()#">
		</cfif>
		<cfreturn photolist.parseXmlElement(resp.getPayload())>
	</cffunction>
	
	<cffunction name="getUploadStatus" access="public" output="false" returntype="CFlickr.people.User" hint="Returns information for the calling used related to photo uploads.">
		<cfset var resp = flickr.get("flickr.people.getUploadStatus")>
		<cfset var user = createObject("component", "CFlickr.people.User")>
		<cfif resp.isError()>
			<cfthrow errorcode="#resp.getErrorCode()#" message="#resp.getErrorMessage()#">
		</cfif>
		<cfreturn user.parseXmlElement(resp.getPayload())>
	</cffunction>
	

</cfcomponent>
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
	
	<cffunction name="addPhoto" access="public" output="false" returntype="boolean" hint="Add a photo to the end of an existing photoset.">
		<cfargument name="photoset_id" type="string" required="yes" hint="The id of the photoset to add a photo to. ">
		<cfargument name="photo_id" type="string" required="yes" hint="The id of the photo to add to the set. ">
		<cfset var resp = flickr.get("flickr.photosets.addPhoto", arguments)>
		<cfif resp.isError()>
			<cfthrow errorcode="#resp.getErrorCode()#" message="#resp.getErrorMessage()#">
		</cfif>
		<cfreturn NOT resp.isError()>
	</cffunction>
	
	<cffunction name="create" access="public" output="false" returntype="CFlickr.photosets.Photoset" hint="Create a new photoset for the calling user.">
		<cfargument name="title" type="string" required="yes" hint="A title for the photoset. ">
		<cfargument name="description" type="string" required="no" hint="A description of the photoset. May contain limited html. ">
		<cfargument name="primary_photo_id" type="string" required="yes" hint="The id of the photo to represent this set. The photo must belong to the calling user. ">
		<cfset var resp = flickr.get("flickr.photosets.create", arguments)>
		<cfset var photoset = createobject("component", "Photoset")>
		<cfif resp.isError()>
			<cfthrow errorcode="#resp.getErrorCode()#" message="#resp.getErrorMessage()#">
		</cfif>
		<cfreturn photoset.parseXmlElement(resp.getPayload())>
	</cffunction>
	
	<cffunction name="delete" access="public" output="false" returntype="void" hint="Delete a photoset.">
		<cfargument name="photoset_id" type="string" required="yes" hint="The id of the photoset to delete. It must be owned by the calling user. ">
		<cfset var resp = flickr.get("flickr.photosets.delete", arguments)>
		<cfif resp.isError()>
			<cfthrow errorcode="#resp.getErrorCode()#" message="#resp.getErrorMessage()#">
		</cfif>
	</cffunction>
	
	<cffunction name="editMeta" access="public" output="false" returntype="void" hint="Modify the meta-data for a photoset.">
		<cfargument name="photoset_id" type="string" required="yes" hint="The id of the photoset to modify. ">
		<cfargument name="title" type="string" required="yes" hint="The new title for the photoset. ">
		<cfargument name="description" type="string" required="no" hint="A description of the photoset. May contain limited html. ">
		<cfset var resp = flickr.get("flickr.photosets.editMeta", arguments)>
		<cfif resp.isError()>
			<cfthrow errorcode="#resp.getErrorCode()#" message="#resp.getErrorMessage()#">
		</cfif>
	</cffunction>
	
	<cffunction name="editPhotos" access="public" output="false" returntype="void" hint="Modify the photos in a photoset. Use this method to add, remove and re-order photos.">
		<cfargument name="photoset_id" type="string" required="yes" hint="The id of the photoset to modify. ">
		<cfargument name="primary_photo_id" type="string" required="yes" hint="The id of the photo to use as the 'primary' photo for the set. This id must also be passed along in photo_ids list argument. ">
		<cfargument name="photo_ids" type="string" required="yes" hint="A comma-delimited list of photo ids to include in the set. They will appear in the set in the order sent. This list must contain the primary photo id. All photos must belong to the owner of the set. This list of photos replaces the existing list. Call flickr.photosets.addPhoto to append a photo to a set. ">
		<cfset var resp = flickr.get("flickr.photosets.editPhotos", arguments)>
		<cfif resp.isError()>
			<cfthrow errorcode="#resp.getErrorCode()#" message="#resp.getErrorMessage()#">
		</cfif>
	</cffunction>
	
	<cffunction name="getContext" access="public" output="false" returntype="CFlickr.photos.PhotoContext" hint="Returns next and previous photos for a photo in a set.">
		<cfargument name="photo_id" type="string" required="yes" hint="The id of the photo to fetch the context for. ">
		<cfargument name="photoset_id" type="string" required="yes" hint="The id of the photoset for which to fetch the photo's context. ">
		<cfset var resp = flickr.get("flickr.photosets.getContext", arguments)>
		<cfset var context = createobject("component", "CFlickr.photos.PhotoContext")>
		<cfset var payload = "">
		<cfset var tmp = "">
		<cfset var photo = "">
		<cfif resp.isError()>
			<cfthrow errorcode="#resp.getErrorCode()#" message="#resp.getErrorMessage()#">
		</cfif>
		<cfscript>
		payload = resp.getDoc();
		
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
	
	<cffunction name="getInfo" access="public" output="false" returntype="CFlickr.photosets.Photoset" hint="Gets information about a photoset.">
		<cfargument name="photoset_id" type="string" required="yes" hint="The ID of the photoset to fetch information for. ">
		<cfset var resp = flickr.get("flickr.photosets.getInfo", arguments)>
		<cfset var set = createobject("component", "CFlickr.photosets.Photoset")>
		<cfif resp.isError()>
			<cfthrow errorcode="#resp.getErrorCode()#" message="#resp.getErrorMessage()#">
		</cfif>
		<cfreturn set.parseXmlElement(resp.getPayload())>
	</cffunction>

	<cffunction name="getList" access="public" output="false" returntype="array" hint="Returns the photosets belonging to the specified user.">
		<cfargument name="user_id" type="string" required="no" hint="The NSID of the user to get a photoset list for. If none is specified, the calling user is assumed. ">
		<cfset var resp = flickr.get("flickr.photosets.getList", arguments)>
		<cfset var payload = "">
		<cfset var ret = arraynew(1)>
		<cfset var tmp = "">
		<cfset var i = 0>
		<cfset var t = "">
		<cfif resp.isError()>
			<cfthrow errorcode="#resp.getErrorCode()#" message="#resp.getErrorMessage()#">
		</cfif>		
		<cfscript>
		payload = resp.getPayload();
		tmp = xmlsearch(payload, "photoset");
		for(i=1; i LTE arraylen(tmp); i=i+1) {
			t = createobject("component", "CFlickr.photosets.Photoset");
			arrayappend(ret, t.parseXmlElement(tmp[i]));
		}
		return ret;
		</cfscript>
	</cffunction>
	
	<cffunction name="getPhotos" access="public" output="false" returntype="CFlickr.photosets.Photoset" hint="Get the list of photos in a set.">
		<cfargument name="photoset_id" type="string" required="yes" hint="The id of the photoset to return the photos for.">
		<cfargument name="extras" type="string" required="no" hint="A comma-delimited list of extra information to fetch for each returned record. Currently supported fields are: license, date_upload, date_taken, owner_name, icon_server, original_format, last_update, geo. ">
		<cfargument name="privacy_filter" type="numeric" required="no" hint="Return photos only matching a certain privacy level. This only applies when making an authenticated call to view a photoset you own. Valid values are: <br>
			1 public photos <br>
			2 private photos visible to friends <br>
			3 private photos visible to family <br>
			4 private photos visible to friends & family <br>
			5 completely private photos ">
		<cfargument name="per_page" type="numeric" required="no" hint="Number of photos to return per page. If this argument is omitted, it defaults to 500. The maximum allowed value is 500.">
		<cfargument name="page" type="numeric" required="no" hint="The page of results to return. If this argument is omitted, it defaults to 1.">
		<cfset var resp = flickr.get("flickr.photosets.getPhotos", arguments)>
		<cfset var set = createobject("component", "CFlickr.photosets.Photoset")>
		<cfif resp.isError()>
			<cfthrow errorcode="#resp.getErrorCode()#" message="#resp.getErrorMessage()#">
		</cfif>
		<cfreturn set.parseXmlElement(resp.getPayload())>	 
	</cffunction>
	
	<cffunction name="orderSets" access="public" output="false" returntype="boolean" hint="Set the order of photosets for the calling user.">
		<cfargument name="photoset_ids" type="string" required="yes" hint="A comma delimited list of photoset IDs, ordered with the set to show first, first in the list. Any set IDs not given in the list will be set to appear at the end of the list, ordered by their IDs">
		<cfset var resp = flickr.get("flickr.photosets.orderSets", arguments)>
		<cfif resp.isError()>
			<cfthrow errorcode="#resp.getErrorCode()#" message="#resp.getErrorMessage()#">
		</cfif>
		<cfreturn NOT resp.isError()>	
	</cffunction>

	<cffunction name="removePhoto" access="public" output="false" returntype="boolean" hint="Remove a photo from a photoset.">
		<cfargument name="photoset_id" type="string" required="yes" hint="The id of the photoset to remove a photo from. ">
		<cfargument name="photo_id" type="string" required="yes" hint="The id of the photo to remove from the set. ">
		<cfset var resp = flickr.get("flickr.photosets.removePhoto", arguments)>
		<cfif resp.isError()>
			<cfthrow errorcode="#resp.getErrorCode()#" message="#resp.getErrorMessage()#">
		</cfif>
		<cfreturn NOT resp.isError()>	
	</cffunction>		
	
</cfcomponent>
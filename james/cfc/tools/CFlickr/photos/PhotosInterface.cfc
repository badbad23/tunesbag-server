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
	
	<cffunction name="addTags" access="public" output="false" returntype="boolean" hint="Add tags to a photo.">
		<cfargument name="photo_id" type="string" required="yes" hint="The id of the photo to add tags to. ">
		<cfargument name="tags" type="string" required="yes" hint="The tags to add to the photo. ">
		<cfset var resp = flickr.get("flickr.photos.addTags", arguments)>		
		<cfif resp.isError()>
			<cfthrow errorcode="#resp.getErrorCode()#" message="#resp.getErrorMessage()#">
		</cfif>
		<cfreturn NOT resp.isError()>
	</cffunction>
	
	<cffunction name="delete" access="public" output="false" returntype="boolean" hint="Delete a photo from flickr.">
		<cfargument name="photo_id" type="string" required="yes" hint="The id of the photo to delete. ">
		<cfset var resp = flickr.get("flickr.photos.delete", arguments)>		
		<cfif resp.isError()>
			<cfthrow errorcode="#resp.getErrorCode()#" message="#resp.getErrorMessage()#">
		</cfif>
		<cfreturn NOT resp.isError()>		
	</cffunction>
	
	<cffunction name="getAllContexts" access="public" output="false" returntype="array" hint="Returns all visible sets and pools the photo belongs to.">
		<cfargument name="photo_id" type="string" required="yes" hint="The photo to return information for. ">
		<cfset var resp = flickr.get("flickr.photos.getAllContexts", arguments)>		
		<cfset var ret = arraynew(1)>
		<cfset var i = 0>
		<cfset var payload = "">
		<cfset var o = "">
		
		<cfif resp.isError()>
			<cfthrow errorcode="#resp.getErrorCode()#" message="#resp.getErrorMessage()#">
		</cfif>

		<cfscript>
		payload = resp.getPayloadArray();
		for(i=1; i LTE arraylen(payload); i=i+1) {
			o = structnew();
				o.id = payload[i].xmlattributes.id; 
				o.title = payload[i].xmlattributes.title;
				o.type = payload[i].xmlname;
				arrayappend(ret, o);
		}
		return ret;
		</cfscript>		
	</cffunction>
	
	<cffunction name="getContactsPhotos" access="public" output="false" returntype="array" hint="Fetch a list of recent photos from the calling users' contacts.">
		<cfargument name="count" type="numeric" required="no" hint="Number of photos to return. Defaults to 10, maximum 50. This is only used if single_photo is not passed. ">
		<cfargument name="just_friends" type="boolean" required="no" hint="Only show photos from friends and family (excluding regular contacts). ">
		<cfargument name="single_photo" type="boolean" required="no" hint="Only fetch one photo (the latest) per contact, instead of all photos in chronological order.">
		<cfargument name="include_self" type="boolean" required="no" hint="Include photos from the calling user. ">
		<cfargument name="extras" type="string" required="no" hint="A comma-delimited list of extra information to fetch for each returned record. Currently supported fields are: license, date_upload, date_taken, owner_name, icon_server, original_format, last_update, geo. ">
		<cfset var resp = "">
		<cfset var ret = arraynew(1)>
		<cfset var photo = "">
		<cfset var tmp = "">
		<cfset var i = 0>
		
		<cfscript>
		if(arguments.just_friends) arguments.just_friends = 1;
		else arguments.just_friends = 0;
		if(arguments.single_photo) arguments.single_photo = 1;
		else arguments.single_photo = 0;
		if(arguments.include_self) arguments.include_self = 1;
		else arguments.include_self = 0;
		</cfscript>
		
		<cfset resp = flickr.get("flickr.photos.getContactsPhotos", arguments)>
		
		<cfif resp.isError()>
			<cfthrow errorcode="#resp.getErrorCode()#" message="#resp.getErrorMessage()#">
		</cfif>

		<cfscript>
		tmp = xmlsearch(resp.getPayload(), 'photo');
		for(i=1; i LTE arraylen(tmp); i=i+1) {
			photo = createobject("component", "CFlickr.photos.Photo");
			arrayappend(ret, photo.parseXmlElement(tmp[i]));
		}
		return ret;
		</cfscript>
	</cffunction>

	<cffunction name="getContactsPublicPhotos" access="public" output="false" returntype="array">
		<cfargument name="user_id" type="string" required="yes" hint="The NSID of the user to fetch photos for. ">
		<cfargument name="count" type="numeric" required="no" hint="Number of photos to return. Defaults to 10, maximum 50. This is only used if single_photo is not passed. ">
		<cfargument name="just_friends" type="boolean" required="no" hint="Only show photos from friends and family (excluding regular contacts). ">
		<cfargument name="single_photo" type="boolean" required="no" hint="Only fetch one photo (the latest) per contact, instead of all photos in chronological order.">
		<cfargument name="include_self" type="boolean" required="no" hint="Include photos from the calling user. ">
		<cfargument name="extras" type="string" required="no" hint="List, any of: license, date_upload, date_taken, owner_name, icon_server, original_format, last_update, geo">
		<cfset var resp = "">
		<cfset var ret = arraynew(1)>
		<cfset var photo = "">
		<cfset var tmp = "">
		<cfset var i = 0>

		<cfscript>
		if(arguments.just_friends) arguments.just_friends = 1;
		else arguments.just_friends = 0;
		if(arguments.single_photo) arguments.single_photo = 1;
		else arguments.single_photo = 0;
		if(arguments.include_self) arguments.include_self = 1;
		else arguments.include_self = 0;
		</cfscript>

		<cfset resp = flickr.get("flickr.photos.getContactsPublicPhotos", arguments)>
		
		<cfif resp.isError()>
			<cfthrow errorcode="#resp.getErrorCode()#" message="#resp.getErrorMessage()#">
		</cfif>

		<cfscript>
		tmp = xmlsearch(resp.getPayload(), 'photo');
		for(i=1; i LTE arraylen(tmp); i=i+1) {
			photo = createobject("component", "CFlickr.photos.Photo");
			arrayappend(ret, photo.parseXmlElement(tmp[i]));
		}
		return ret;
		</cfscript>
	</cffunction>
	
	<cffunction name="getContext" access="public" output="false" returntype="CFlickr.photos.PhotoContext" hint="Returns next and previous photos for a photo in a photostream.">
		<cfargument name="photo_id" type="string" required="yes" hint="The id of the photo to fetch the context for.">
		<cfset var resp = flickr.get("flickr.photos.getContext", arguments)>
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
	
	<cffunction name="getCounts" access="public" output="false" returntype="array" hint="Gets a list of photo counts for the given date ranges for the calling user.">
		<cfargument name="dates" type="array" required="no" hint="Array of dates, denoting the periods to return counts for. They should be specified smallest first.">
		<cfargument name="taken_dates" type="array" required="no" hint="Array of dates, denoting the periods to return counts for. They should be specified smallest first.">
		<cfset var resp = "">
		<cfset var ret = arraynew(1)>
		<cfset var photocount = "">
		<cfset var tmp = "">
		<cfset var i = 0>
		
		<cfif structkeyexists(arguments, 'dates')>
			<cfloop from="1" to="#arraylen(arguments.dates)#" index="i">
				<cfset arguments.dates[i] = _unix_dateformat(arguments.dates[i])>
			</cfloop>
			<cfset arguments.dates = listsort(arraytolist(arguments.dates), 'numeric', 'asc')>
		</cfif>
		<cfif structkeyexists(arguments, 'taken_dates')>
			<cfloop from="1" to="#arraylen(arguments.taken_dates)#" index="i">
				<cfset arguments.taken_dates[i] = _iso_dateformat(arguments.taken_dates[i])>
			</cfloop>
			<cfset arguments.taken_dates = listsort(arraytolist(arguments.taken_dates), 'textnocase', 'asc')>
		</cfif>

		<cfset resp = flickr.get("flickr.photos.getCounts", arguments)>

		<cfif resp.isError()>
			<cfthrow errorcode="#resp.getErrorCode()#" message="#resp.getErrorMessage()#">
		</cfif>
		
		<cfscript>
		tmp = xmlsearch(resp.getPayload(), 'photocount');
		for(i=1; i LTE arraylen(tmp); i=i+1) {
			photocount = createobject("component", "CFlickr.photos.PhotoCount");
			arrayappend(ret, photocount.parseXmlElement(tmp[i]));
		}
		return ret;	
		</cfscript>		
	</cffunction>
	
	<cffunction name="getExif" access="public" output="false" returntype="CFlickr.photos.Photo" hint="Retrieves a list of EXIF/TIFF/GPS tags for a given photo. The calling user must have permission to view the photo.">
		<cfargument name="photo_id" type="string" required="yes" hint="The is of the photo to fetch information for. ">
		<cfargument name="secret" type="string" required="no" hint="The secret for the photo. If the correct secret is passed then permissions checking is skipped. This enables the 'sharing' of individual photos by passing around the id and secret.">
		<cfset var resp = flickr.get("flickr.photos.getExif", arguments)>
		<cfset var photo = createobject("component", "CFlickr.photos.Photo")>
		<cfif resp.isError()>
			<cfthrow errorcode="#resp.getErrorCode()#" message="#resp.getErrorMessage()#">
		</cfif>
		<cfreturn photo.parseXmlElement(resp.getPayload())>
	</cffunction>

	<cffunction name="getFavorites" access="public" output="false" returntype="CFlickr.favorites.FavoriterList" hint="Returns the list of people who have favorited a given photo.">
		<cfargument name="photo_id" type="string" required="yes" hint="The ID of the photo to fetch the favoriters list for.">
		<cfargument name="page" type="numeric" required="no" hint="The page of results to return. If this argument is omitted, it defaults to 1. ">
		<cfargument name="per_page" type="numeric" required="no" hint="Number of users to return per page. If this argument is omitted, it defaults to 10. The maximum allowed value is 50.">
		<cfset var resp = flickr.get("flickr.photos.getInfo", arguments)>		
		<cfset var favoriterList = createobject("component", "CFlickr.favorites.FavoriterList")>
		<cfif resp.isError()>
			<cfthrow errorcode="#resp.getErrorCode()#" message="#resp.getErrorMessage()#">
		</cfif>
		<cfreturn favoriterList.parseXmlElement(resp.getpayload())>	
	</cffunction>
	

	<cffunction name="getInfo" access="public" output="true" returntype="CFlickr.photos.Photo" hint="Get information about a photo. The calling user must have permission to view the photo.">
		<cfargument name="photo_id" type="string" required="yes" hint="The is of the photo to fetch information for. ">
		<cfargument name="secret" type="string" required="no" hint="The secret for the photo. If the correct secret is passed then permissions checking is skipped. This enables the 'sharing' of individual photos by passing around the id and secret.">
		<cfset var resp = flickr.get("flickr.photos.getInfo", arguments)>		
		<cfset var photo = createobject("component", "Photo")>
		<cfif resp.isError()>
			<cfthrow errorcode="#resp.getErrorCode()#" message="#resp.getErrorMessage()#">
		</cfif>
		<cfreturn photo.parseXmlElement(resp.getpayload())>
	</cffunction>
	
	<cffunction name="getNotInSet" access="public" output="false" returntype="CFlickr.photos.PhotoList" hint="Returns a list of your photos that are not part of any sets.">
		<cfargument name="min_upload_date" type="date" required="no" hint="Minimum upload date. Photos with an upload date greater than or equal to this value will be returned. "> <!--- convert to unix timestamp --->
		<cfargument name="max_upload_date" type="date" required="no" hint="Maximum upload date. Photos with an upload date less than or equal to this value will be returned."> <!--- convert to unix timestamp --->
		<cfargument name="min_taken_date" type="date" required="no" hint="Minimum taken date. Photos with an taken date greater than or equal to this value will be returned."> <!--- convert to mysql datetime --->
		<cfargument name="max_taken_date" type="date" required="no" hint="Maximum taken date. Photos with an taken date less than or equal to this value will be returned."> <!--- convert to mysql datetime --->
		<cfargument name="privacy_filter" type="integer" required="no" hint="Return photos only matching a certain privacy level. Valid values are: <br>
			1 public photos <br>
			2 private photos visible to friends <br>
			3 private photos visible to family <br>
			4 private photos visible to friends & family <br>
			5 completely private photos ">
		<cfargument name="extras" type="string" required="no" hint="A comma-delimited list of extra information to fetch for each returned record. Currently supported fields are: license, date_upload, date_taken, owner_name, icon_server, original_format, last_update, geo.">
		<cfargument name="per_page" type="numeric" required="no" hint="Number of photos to return per page. If this argument is omitted, it defaults to 100. The maximum allowed value is 500. ">
		<cfargument name="page" type="numeric" required="no" hint="The page of results to return. If this argument is omitted, it defaults to 1. ">

		<cfset var photolist = createobject("component", "CFlickr.photos.PhotoList")>
		<cfset var resp = "">

		<cfscript>
		if( isdefined('arguments.min_upload_date') ) arguments.min_upload_date = _unix_dateformat(arguments.min_upload_date);
		if( isdefined('arguments.max_upload_date') ) arguments.max_upload_date = _unix_dateformat(arguments.max_upload_date);
		if( isdefined('arguments.min_taken_date') ) arguments.min_taken_date = _iso_dateformat(arguments.min_taken_date);
		if( isdefined('arguments.max_taken_date') ) arguments.max_taken_date = _iso_dateformat(arguments.max_taken_date);
		</cfscript>

		<cfset resp = flickr.get("flickr.photos.getNotInSet", arguments)>		
		<cfif resp.isError()>
			<cfthrow errorcode="#resp.getErrorCode()#" message="#resp.getErrorMessage()#">
		</cfif>
		<cfreturn photolist.parseXmlElement(resp.getPayload())>
	</cffunction>
	
	<cffunction name="getPerms" access="public" output="false" returntype="CFlickr.photos.Permission" hint="Get permissions for a photo.">
		<cfargument name="photo_id" type="string" required="yes" hint="The id of the photo to get permissions for.">
		<cfset var resp = flickr.get("flickr.photos.getPerms", arguments)>
		<cfset var perms = createobject("component", "CFlickr.photos.Permission")>
		<cfif resp.isError()>
			<cfthrow errorcode="#resp.getErrorCode()#" message="#resp.getErrorMessage()#">
		</cfif>
		<cfreturn perms.parseXmlElement(resp.getPayload())>
	</cffunction>
	
	<cffunction name="getRecent" access="public" output="false" returntype="CFlickr.photos.PhotoList" hint="Returns a list of the latest public photos uploaded to flickr.">
		<cfargument name="extras" type="string" required="no" hint="A comma-delimited list of extra information to fetch for each returned record. Currently supported fields are: license, date_upload, date_taken, owner_name, icon_server, original_format, last_update, geo. ">
		<cfargument name="per_page" type="numeric" required="no" hint="Number of photos to return per page. If this argument is omitted, it defaults to 100. The maximum allowed value is 500. ">
		<cfargument name="page" type="numeric" required="no" hint="The page of results to return. If this argument is omitted, it defaults to 1. ">
		<cfset var photolist = createobject("component", "CFlickr.photos.PhotoList")>
		<cfset var resp = flickr.get("flickr.photos.getRecent", arguments)>
		<cfif resp.isError()>
			<cfthrow errorcode="#resp.getErrorCode()#" message="#resp.getErrorMessage()#">
		</cfif>
		<cfreturn photolist.parseXmlElement(resp.getPayload())>
	</cffunction>	
	
	<cffunction name="getSizes" access="public" output="false" returntype="array" hint="Returns the available sizes for a photo. The calling user must have permission to view the photo.">
		<cfargument name="photo_id" type="string" required="yes" hint="The id of the photo to fetch size information for. ">
		<cfset var ret = arraynew(1)>
		<cfset var resp = flickr.get("flickr.photos.getSizes", arguments)>
		<cfset var tmp = "">
		<cfset var i = 0>
		<cfset var size = "">
		<cfif resp.isError()>
			<cfthrow errorcode="#resp.getErrorCode()#" message="#resp.getErrorMessage()#">
		</cfif>
		<cfscript>
		tmp = xmlsearch(resp.getPayload(), 'size');
		for(i=1; i LTE arraylen(tmp); i=i+1) {
			size = createobject("component", "CFlickr.photos.Size");
			arrayappend(ret, size.parseXmlElement(tmp[i]));
		}
		return ret;
		</cfscript>
	</cffunction>
	
	<cffunction name="getUntagged" access="public" output="false" returntype="CFlickr.photos.PhotoList" hint="Returns a list of your photos with no tags.">
		<cfargument name="min_upload_date" type="date" required="no" hint="Minimum upload date. Photos with an upload date greater than or equal to this value will be returned. "> <!--- convert to unix timestamp --->
		<cfargument name="max_upload_date" type="date" required="no" hint="Maximum upload date. Photos with an upload date less than or equal to this value will be returned."> <!--- convert to unix timestamp --->
		<cfargument name="min_taken_date" type="date" required="no" hint="Minimum taken date. Photos with an taken date greater than or equal to this value will be returned."> <!--- convert to mysql datetime --->
		<cfargument name="max_taken_date" type="date" required="no" hint="Maximum taken date. Photos with an taken date less than or equal to this value will be returned."> <!--- convert to mysql datetime --->
		<cfargument name="privacy_filter" type="integer" required="no" hint="Return photos only matching a certain privacy level. Valid values are: <br>
			1 public photos <br>
			2 private photos visible to friends <br>
			3 private photos visible to family <br>
			4 private photos visible to friends & family <br>
			5 completely private photos ">
		<cfargument name="extras" type="string" required="no" hint="A comma-delimited list of extra information to fetch for each returned record. Currently supported fields are: license, date_upload, date_taken, owner_name, icon_server, original_format, last_update, geo.">
		<cfargument name="per_page" type="numeric" required="no" hint="Number of photos to return per page. If this argument is omitted, it defaults to 100. The maximum allowed value is 500. ">
		<cfargument name="page" type="numeric" required="no" hint="The page of results to return. If this argument is omitted, it defaults to 1. ">

		<cfset var photolist = createobject("component", "CFlickr.photos.PhotoList")>
		<cfset var resp = "">

		<cfscript>
		if( isdefined('arguments.min_upload_date') ) arguments.min_upload_date = _unix_dateformat(arguments.min_upload_date);
		if( isdefined('arguments.max_upload_date') ) arguments.max_upload_date = _unix_dateformat(arguments.max_upload_date);
		if( isdefined('arguments.min_taken_date') ) arguments.min_taken_date = _iso_dateformat(arguments.min_taken_date);
		if( isdefined('arguments.max_taken_date') ) arguments.max_taken_date = _iso_dateformat(arguments.max_taken_date);
		</cfscript>

		<cfset resp = flickr.get("flickr.photos.getUntagged", arguments)>		
		<cfif resp.isError()>
			<cfthrow errorcode="#resp.getErrorCode()#" message="#resp.getErrorMessage()#">
		</cfif>
		<cfreturn photolist.parseXmlElement(resp.getPayload())>
	</cffunction>


	<cffunction name="getWithGeoData" access="public" output="true" returntype="CFlickr.photos.PhotoList">
		<cfargument name="min_upload_date" type="date" required="no" hint="Minimum upload date. Photos with an upload date greater than or equal to this value will be returned. "> <!--- convert to unix timestamp --->
		<cfargument name="max_upload_date" type="date" required="no" hint="Maximum upload date. Photos with an upload date less than or equal to this value will be returned."> <!--- convert to unix timestamp --->
		<cfargument name="min_taken_date" type="date" required="no" hint="Minimum taken date. Photos with an taken date greater than or equal to this value will be returned."> <!--- convert to mysql datetime --->
		<cfargument name="max_taken_date" type="date" required="no" hint="Maximum taken date. Photos with an taken date less than or equal to this value will be returned."> <!--- convert to mysql datetime --->
		<cfargument name="privacy_filter" type="string" required="no" hint="Return photos only matching a certain privacy level. Valid values are: <br>
			1 public photos <br>
			2 private photos visible to friends <br>
			3 private photos visible to family <br>
			4 private photos visible to friends & family <br>
			5 completely private photos ">
		<cfargument name="sort" type="string" required="no" hint="The order in which to sort returned photos. Deafults to date-posted-desc. The possible values are: date-posted-asc, date-posted-desc, date-taken-asc, date-taken-desc, interestingness-desc, and interestingness-asc.">
		<cfargument name="extras" type="string" required="no" hint="List, any of: license, date_upload, date_taken, owner_name, icon_server, original_format, last_update, geo">
		<cfargument name="per_page" type="numeric" required="no" hint="Number of photos to return per page. If this argument is omitted, it defaults to 100. The maximum allowed value is 500.">
		<cfargument name="page" type="numeric" required="no" hint="The page of results to return. If this argument is omitted, it defaults to 1.">
		
		<cfset var photolist = createobject("component", "CFlickr.photos.PhotoList")>
		<cfset var resp = "">
		
		<cfscript>
		if( isdefined('arguments.min_upload_date') ) arguments.min_upload_date = _unix_dateformat(arguments.min_upload_date);
		if( isdefined('arguments.max_upload_date') ) arguments.max_upload_date = _unix_dateformat(arguments.max_upload_date);
		if( isdefined('arguments.min_taken_date') ) arguments.min_taken_date = _iso_dateformat(arguments.min_taken_date);
		if( isdefined('arguments.max_taken_date') ) arguments.max_taken_date = _iso_dateformat(arguments.max_taken_date);
		</cfscript>
		
		<cfset resp = flickr.get("flickr.photos.getWithGeoData", arguments)>		
		<cfif resp.isError()>
			<cfthrow errorcode="#resp.getErrorCode()#" message="#resp.getErrorMessage()#">
		</cfif>
		
		<cfreturn photolist.parseXmlElement(resp.getPayload())>
	</cffunction>

	<cffunction name="getWithoutGeoData" access="public" output="true" returntype="CFlickr.photos.PhotoList">
		<cfargument name="min_upload_date" type="date" required="no" hint="Minimum upload date. Photos with an upload date greater than or equal to this value will be returned. "> <!--- convert to unix timestamp --->
		<cfargument name="max_upload_date" type="date" required="no" hint="Maximum upload date. Photos with an upload date less than or equal to this value will be returned."> <!--- convert to unix timestamp --->
		<cfargument name="min_taken_date" type="date" required="no" hint="Minimum taken date. Photos with an taken date greater than or equal to this value will be returned."> <!--- convert to mysql datetime --->
		<cfargument name="max_taken_date" type="date" required="no" hint="Maximum taken date. Photos with an taken date less than or equal to this value will be returned."> <!--- convert to mysql datetime --->
		<cfargument name="privacy_filter" type="string" required="no" hint="Return photos only matching a certain privacy level. Valid values are: <br>
			1 public photos <br>
			2 private photos visible to friends <br>
			3 private photos visible to family <br>
			4 private photos visible to friends & family <br>
			5 completely private photos ">
		<cfargument name="sort" type="string" required="no" hint="The order in which to sort returned photos. Deafults to date-posted-desc. The possible values are: date-posted-asc, date-posted-desc, date-taken-asc, date-taken-desc, interestingness-desc, and interestingness-asc.">
		<cfargument name="extras" type="string" required="no" hint="List, any of: license, date_upload, date_taken, owner_name, icon_server, original_format, last_update, geo">
		<cfargument name="per_page" type="numeric" required="no" hint="Number of photos to return per page. If this argument is omitted, it defaults to 100. The maximum allowed value is 500.">
		<cfargument name="page" type="numeric" required="no" hint="The page of results to return. If this argument is omitted, it defaults to 1.">
		
		<cfset var photolist = createobject("component", "CFlickr.photos.PhotoList")>
		<cfset var resp = "">
		
		<cfscript>
		if( isdefined('arguments.min_upload_date') ) arguments.min_upload_date = _unix_dateformat(arguments.min_upload_date);
		if( isdefined('arguments.max_upload_date') ) arguments.max_upload_date = _unix_dateformat(arguments.max_upload_date);
		if( isdefined('arguments.min_taken_date') ) arguments.min_taken_date = _iso_dateformat(arguments.min_taken_date);
		if( isdefined('arguments.max_taken_date') ) arguments.max_taken_date = _iso_dateformat(arguments.max_taken_date);
		</cfscript>
		
		<cfset resp = flickr.get("flickr.photos.getWithoutGeoData", arguments)>		
		<cfif resp.isError()>
			<cfthrow errorcode="#resp.getErrorCode()#" message="#resp.getErrorMessage()#">
		</cfif>
		
		<cfreturn photolist.parseXmlElement(resp.getPayload())>
	</cffunction>
	
	<cffunction name="recentlyUpdated" access="public" output="false" returntype="CFlickr.photos.PhotoList" 
			hint="Return a list of your photos that have been recently created or which have been recently modified.<br>
			Recently modified may mean that the photo's metadata (title, description, tags) may have been changed or a comment has been added (or just modified somehow :-)">
		<cfargument name="min_date" type="date" required="yes" hint="the date from which modifications should be compared. "> <!--- convert to unix timestamp --->
		<cfargument name="extras" type="string" required="no" hint="List, any of: license, date_upload, date_taken, owner_name, icon_server, original_format, last_update, geo">
		<cfargument name="per_page" type="numeric" required="no" hint="Number of photos to return per page. If this argument is omitted, it defaults to 100. The maximum allowed value is 500.">
		<cfargument name="page" type="numeric" required="no" hint="The page of results to return. If this argument is omitted, it defaults to 1.">

		<cfset var photolist = createobject("component", "CFlickr.photos.PhotoList")>
		<cfset var resp = "">
			
		<cfscript>
		if( isdefined('arguments.min_date') ) arguments.min_date = _unix_dateformat(arguments.min_date);
		</cfscript>

		<cfset resp = flickr.get("flickr.photos.recentlyUpdated", arguments)>		
		<cfif resp.isError()>
			<cfthrow errorcode="#resp.getErrorCode()#" message="#resp.getErrorMessage()#">
		</cfif>
		
		<cfreturn photolist.parseXmlElement(resp.getPayload())>
	
	</cffunction>
	
	<cffunction name="removeTag" access="public" output="false" returntype="boolean" hint="Remove a tag from a photo.">
		<cfargument name="tag_id" type="string" required="yes" hint="The tag to remove from the photo. This parameter should contain a tag id, as returned by CFlickr.photos.PhotosInterface.getInfo() method.">
		<cfset var resp = flickr.get("flickr.photos.removeTag", arguments)>		
		<cfif resp.isError()>
			<cfthrow errorcode="#resp.getErrorCode()#" message="#resp.getErrorMessage()#">
		</cfif>
		<cfreturn NOT resp.isError()>
	</cffunction>
	
	<cffunction name="search" access="public" output="true" returntype="CFlickr.photos.PhotoList" hint="Return a list of photos matching some criteria. Only photos visible to the calling user will be returned. To return private or semi-private photos, the caller must be authenticated with 'read' permissions, and have permission to view the photos. Unauthenticated calls will only return public photos.">
		<cfargument name="user_id" type="string" required="no" hint="The NSID of the user who's photo to search. If this parameter isn't passed then everybody's public photos will be searched. A value of 'me' will search against the calling user's photos for authenticated calls. ">
		<cfargument name="tags" type="string" required="no" hint="A comma-delimited list of tags. Photos with one or more of the tags listed will be returned. ">
		<cfargument name="tag_mode" type="string" required="no" hint="Either 'any' for an OR combination of tags, or 'all' for an AND combination. Defaults to 'any' if not specified.">
		<cfargument name="text" type="string" required="no" hint="A free text search. Photos who's title, description or tags contain the text will be returned. ">
		<cfargument name="min_upload_date" type="date" required="no" hint="Minimum upload date. Photos with an upload date greater than or equal to this value will be returned. "> <!--- convert to unix timestamp --->
		<cfargument name="max_upload_date" type="date" required="no" hint="Maximum upload date. Photos with an upload date less than or equal to this value will be returned."> <!--- convert to unix timestamp --->
		<cfargument name="min_taken_date" type="date" required="no" hint="Minimum taken date. Photos with an taken date greater than or equal to this value will be returned."> <!--- convert to mysql datetime --->
		<cfargument name="max_taken_date" type="date" required="no" hint="Maximum taken date. Photos with an taken date less than or equal to this value will be returned."> <!--- convert to mysql datetime --->
		<cfargument name="license" type="string" required="no" hint="The license id for photos (for possible values see the CFlickr.photos.licenses.LicensesInterface.getInfo() method). Multiple licenses may be comma-separated.">
		<cfargument name="sort" type="string" required="no" hint="The order in which to sort returned photos. Deafults to date-posted-desc. The possible values are: date-posted-asc, date-posted-desc, date-taken-asc, date-taken-desc, interestingness-desc, interestingness-asc, and relevance. ">
		<cfargument name="privacy_filter" type="string" required="no" hint="Return photos only matching a certain privacy level. Valid values are: <br>
			1 public photos <br>
			2 private photos visible to friends <br>
			3 private photos visible to family <br>
			4 private photos visible to friends & family <br>
			5 completely private photos ">
		<cfargument name="bbox" type="string" required="no" hint="A comma-delimited list of 4 values defining the Bounding Box of the area that will be searched. The 4 values represent the bottom-left corner of the box and the top-right corner, minimum_longitude, minimum_latitude, maximum_longitude, maximum_latitude. Longitude has a range of -180 to 180 , latitude of -90 to 90. Defaults to -180, -90, 180, 90 if not specified. ">
		<cfargument name="accuracy" type="numeric" required="no" hint="Recorded accuracy level of the location information. World level is 1, Country is ~3, Region ~6, City ~11, Street ~16. Current range is 1-16. Defaults to maximum value if not specified. ">
		<cfargument name="safe_search" type="numeric" required="no" hint="Safe search setting:<br>
		    * 1 for safe.<br>
		    * 2 for moderate.<br>
		    * 3 for restricted.<br>
			(Please note: Un-authed calls can only see Safe content.)">
		<cfargument name="content_type"	 type="numeric" required="no" hint="Content Type setting:<br>
    * 1 for photos only.<br>
    * 2 for screenshots only.<br>
    * 3 for 'other' only.<br>
    * 4 for photos and screenshots.<br>
    * 5 for screenshots and 'other'.<br>
    * 6 for photos and 'other'.<br>
    * 7 for photos, screenshots, and 'other' (all).">
		<cfargument name="extras" type="string" required="no" hint="A comma-delimited list of extra information to fetch for each returned record. Currently supported fields are: license, date_upload, date_taken, owner_name, icon_server, original_format, last_update, geo. ">		
		<cfargument name="machine_tags" type="string" required="no" hint="Aside from passing in a fully formed machine tag, there is a special syntax for searching on specific properties :<br>
			* Find photos using the 'dc' namespace : &quot;machine_tags&quot; => &quot;dc:&quot;<br>
		    * Find photos with a title in the 'dc' namespace : &quot;machine_tags&quot; => &quot;dc:title=&quot;<br>
		    * Find photos titled &quot;mr. camera&quot; in the 'dc' namespace : &quot;machine_tags&quot; => &quot;dc:title=\&quot;mr. camera\&quot;<br>
		    * Find photos whose value is &quot;mr. camera&quot; : &quot;machine_tags&quot; => &quot;*:*=\&quot;mr. camera\&quot;&quot;<br>
		    * Find photos that have a title, in any namespace : &quot;machine_tags&quot; => &quot;*:title=&quot;<br>
		    * Find photos that have a title, in any namespace, whose value is &quot;mr. camera&quot; : &quot;machine_tags&quot; => &quot;*:title=\&quot;mr. camera\&quot;&quot;<br>
		    * Find photos, in the 'dc' namespace whose value is &quot;mr. camera&quot; : &quot;machine_tags&quot; => &quot;dc:*=\&quot;mr. camera\&quot;&quot;<br>
			Multiple machine tags may be queried by passing a comma-separated list. The number of machine tags you can pass in a single query depends on the tag mode (AND or OR) that you are querying with. &quot;AND&quot; queries are limited to (16) machine tags. &quot;OR&quot; queries are limited to (8).">
		<cfargument name="machine_tag_mode" type="string" required="no" hint="Either 'any' for an OR combination of tags, or 'all' for an AND combination. Defaults to 'any' if not specified.">
		<cfargument name="group_id" type="string" required="no" hint="The id of a group who's pool to search. If specified, only matching photos posted to the group's pool will be returned.">
		
		<cfargument name="per_page" type="numeric" required="no" hint="Number of photos to return per page. If this argument is omitted, it defaults to 100. The maximum allowed value is 500. ">
		<cfargument name="page" type="numeric" required="no" hint="The page of results to return. If this argument is omitted, it defaults to 1. ">
		
		<cfset var photolist = createobject("component", "CFlickr.photos.PhotoList")>
		<cfset var resp = "">
		
		<cfscript>
		if( isdefined('arguments.min_upload_date') ) arguments.min_upload_date = _unix_dateformat(arguments.min_upload_date);
		if( isdefined('arguments.max_upload_date') ) arguments.max_upload_date = _unix_dateformat(arguments.max_upload_date);
		if( isdefined('arguments.min_taken_date') ) arguments.min_taken_date = _iso_dateformat(arguments.min_taken_date);
		if( isdefined('arguments.max_taken_date') ) arguments.max_taken_date = _iso_dateformat(arguments.max_taken_date);
		</cfscript>
		
		<cfset resp = flickr.get("flickr.photos.search", arguments)>		
		<cfif resp.isError()>
			<cfthrow errorcode="#resp.getErrorCode()#" message="#resp.getErrorMessage()#">
		</cfif>
		
		<cfreturn photolist.parseXmlElement(resp.getPayload())>
	</cffunction>

	<cffunction name="setContentType" access="public" output="false" returntype="boolean" hint="Set the content type of a photo.">
		<cfargument name="photo_id" type="string" required="yes" hint="The id of the photo to set the content type for.">
		<cfargument name="content_type" type="numeric" required="yes" hint="The content type of the photo. Must be one of: 1 for Photo, 2 for Screenshot, and 3 for Other.">
		<cfset resp = flickr.get("flickr.photos.setDates", arguments)>
		<cfif resp.isError()>
			<cfthrow errorcode="#resp.getErrorCode()#" message="#resp.getErrorMessage()#">
		</cfif>
		<cfreturn NOT resp.isError()>	
	</cffunction>

	<cffunction name="setDates" access="public" output="false" returntype="boolean" hint="Set one or both of the dates for a photo.">
		<cfargument name="photo_id" type="string" required="yes" hint="The id of the photo to edit dates for. ">
		<cfargument name="date_posted" type="date" required="no" hint="The date the photo was uploaded to flickr. ">
		<cfargument name="date_taken" type="date" required="no" hint="The date the photo was taken. ">
		<cfargument name="date_taken_granularity" type="numeric" required="no" hint="The accuracy to which we know the date to be true. At present, only three granularities are used:<br>
			0 Y-m-d H:i:s <br>
			4 Y-m <br>
			6 Y ">
		<cfset var resp = "">

		<cfscript>
		if( isdefined('arguments.date_posted') ) arguments.date_posted = _unix_dateformat(arguments.date_posted);
		if( isdefined('arguments.date_taken') ) arguments.date_taken = _iso_dateformat(arguments.date_taken);
		</cfscript>
		
		<cfset resp = flickr.get("flickr.photos.setDates", arguments)>

		<cfif resp.isError()>
			<cfthrow errorcode="#resp.getErrorCode()#" message="#resp.getErrorMessage()#">
		</cfif>
		<cfreturn NOT resp.isError()>
	</cffunction>
	
	<cffunction name="setMeta" access="public" output="false" returntype="boolean" hint="Set the meta information for a photo.">
		<cfargument name="photo_id" type="string" required="yes" hint="The id of the photo to set information for. ">
		<cfargument name="title" type="string" required="yes" hint="The title for the photo. ">
		<cfargument name="description" type="string" required="yes" hint="The description for the photo. ">
		<cfset var resp = flickr.get("flickr.photos.setMeta", arguments)>
		<cfif resp.isError()>
			<cfthrow errorcode="#resp.getErrorCode()#" message="#resp.getErrorMessage()#">
		</cfif>
		<cfreturn NOT resp.isError()>
	</cffunction>
	
	<cffunction name="setPerms" access="public" output="false" returntype="boolean" hint="Set permissions for a photo.">
		<cfargument name="photo_id" type="string" required="yes" hint="The id of the photo to set permissions for. ">
		<cfargument name="is_public" type="boolean" required="yes" hint="true to set the photo to public, false to set it to private. ">
		<cfargument name="is_friend" type="boolean" required="yes" hint="true to make the photo visible to friends when private, false to not.">
		<cfargument name="is_family" type="boolean" required="yes" hint="true to make the photo visible to family when private, false to not. ">
		<cfargument name="perm_comment" type="numeric" required="yes" hint="who can add comments to the photo and it's notes. one of:<br>
			0: nobody<br>
			1: friends & family<br>
			2: contacts<br>
			3: everybody">
		<cfargument name="perm_addmeta" type="numeric" required="yes" hint="who can add notes and tags to the photo. one of:<br>
			0: nobody / just the owner<br>
			1: friends & family<br>
			2: contacts<br>
			3: everybody ">
		<cfset var resp = "">

		<cfscript>
		if(arguments.is_public) arguments.is_public = 1;
		else arguments.is_public = 0;
		if(arguments.is_friend) arguments.is_friend = 1;
		else arguments.is_friend = 0;
		if(arguments.is_family) arguments.is_family = 1;
		else arguments.is_family = 0;
		</cfscript>

		<cfset resp = flickr.get("flickr.photos.setPerms", arguments)>

		<cfif resp.isError()>
			<cfthrow errorcode="#resp.getErrorCode()#" message="#resp.getErrorMessage()#">
		</cfif>
		<cfreturn NOT resp.isError()>		
	</cffunction>
	
	<cffunction name="setSafetyLevel" access="public" output="false" returntype="boolean" hint="Set the safety level of a photo.">
		<cfargument name="photo_id" type="string" required="yes" hint="The id of the photo to set safety level for. ">
		<cfargument name="safety_level" type="numeric" required="no" hint="The safety level of the photo. Must be one of: 1 for Safe, 2 for Moderate, and 3 for Restricted.">
		<cfargument name="hidden" type="boolean" required="no" hint="Whether or not to additionally hide the photo from public searches. Must be either 1 for Yes or 0 for No.">
		<cfset var resp = flickr.get("flickr.photos.setSafetyLevel", arguments)>
		<cfif resp.isError()>
			<cfthrow errorcode="#resp.getErrorCode()#" message="#resp.getErrorMessage()#">
		</cfif>
		<cfreturn NOT resp.isError()>		
	</cffunction>
	
	<cffunction name="setTags" access="public" output="false" returntype="boolean" hint="Set the tags for a photo.">
		<cfargument name="photo_id" type="string" required="yes" hint="The id of the photo to set tags for. ">
		<cfargument name="tags" type="string" required="yes" hint="All tags for the photo (as a single space-delimited string). ">
		<cfset var resp = flickr.get("flickr.photos.setTags", arguments)>
		<cfif resp.isError()>
			<cfthrow errorcode="#resp.getErrorCode()#" message="#resp.getErrorMessage()#">
		</cfif>
		<cfreturn NOT resp.isError()>		
	</cffunction>
	
</cfcomponent>
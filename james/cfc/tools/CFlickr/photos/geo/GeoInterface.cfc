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

	<cffunction name="getLocation" access="public" output="false" returntype="CFlickr.photos.geo.Location" hint="Get the geo data (latitude and longitude and the accuracy level) for a photo.">
		<cfargument name="photo_id" type="string" required="yes" hint="The id of the photo you want to retrieve location data for. ">
		<cfset var resp = flickr.get("flickr.photos.geo.getLocation", arguments)>
		<cfset var location = createobject("component", "CFlickr.photos.geo.Location")>
		<cfset var tmp = xmlsearch(resp.getPayload(), "location")>
		<cfif resp.isError()>
			<cfthrow errorcode="#resp.getErrorCode()#" message="#resp.getErrorMessage()#">
		<cfelseif NOT arraylen(tmp)>
			<cfthrow errorcode="CFlickr.GeoInterface.NoLocation" message="No location was returned for photo #arguments.photo_id#">
		</cfif>
		<cfreturn location.parseXmlElement(tmp[1])>
	</cffunction>
	
	<cffunction name="getPerms" access="public" output="false" returntype="CFlickr.photos.Permission" hint="Get permissions for who may view geo data for a photo.">
		<cfargument name="photo_id" type="string" required="yes" hint="The id of the photo to get permissions for. ">
		<cfset var resp = flickr.get("flickr.photos.geo.getPerms", arguments)>
		<cfset var perm = createobject("component", "CFlickr.photos.Permission")>
		<cfif resp.isError()>
			<cfthrow errorcode="#resp.getErrorCode()#" message="#resp.getErrorMessage()#">
		</cfif>
		<cfreturn perm.parseXmlElement(resp.getPayload())/>
	</cffunction>

	<cffunction name="removeLocation" access="public" output="false" returntype="void" hint="Removes the geo data associated with a photo.">
		<cfargument name="photo_id" type="string" required="yes" hint="The id of the photo you want to remove location data from. ">
		<cfset var resp = flickr.get("flickr.photos.geo.removeLocation", arguments)>
		<cfif resp.isError()>
			<cfthrow errorcode="#resp.getErrorCode()#" message="#resp.getErrorMessage()#">
		</cfif>
	</cffunction>

	<cffunction name="setLocation" access="public" output="false" returntype="void" hint="Sets the geo data (latitude and longitude and, optionally, the accuracy level) for a photo. Before users may assign location data to a photo they must define who, by default, may view that information. Users can edit this preference at http://www.flickr.com/account/geo/privacy/. If a user has not set this preference, the API method will return an error.">
		<cfargument name="photo_id" type="string" required="yes" hint="The id of the photo to set location data for. ">
		<cfargument name="lat" type="numeric" required="yes" hint="The latitude whose valid range is -90 to 90. Anything more than 6 decimal places will be truncated.">
		<cfargument name="lon" type="numeric" required="yes" hint="The longitude whose valid range is -180 to 180. Anything more than 6 decimal places will be truncated.">
		<cfargument name="accuracy" type="numeric" required="no" hint="Recorded accuracy level of the location information. World level is 1, Country is ~3, Region ~6, City ~11, Street ~16. Current range is 1-16. Defaults to 16 if not specified.">
		<cfset var resp = flickr.get("flickr.photos.geo.setLocation", arguments)>
		<cfif resp.isError()>
			<cfthrow errorcode="#resp.getErrorCode()#" message="#resp.getErrorMessage()#">
		</cfif>
	</cffunction>
	
	<cffunction name="setPerms" access="public" output="false" returntype="void" hint="Set the permission for who may view the geo data associated with a photo.">
		<cfargument name="photo_id" type="string" required="yes" hint="The id of the photo to get permissions for. ">
		<cfargument name="is_public" type="boolean" required="yes" hint="true to set viewing permissions for the photo's location data to public, false to set it to private. ">
		<cfargument name="is_contact" type="boolean" required="yes" hint="true to set viewing permissions for the photo's location data to contacts, false to set it to private. ">
		<cfargument name="is_friend" type="boolean" required="yes" hint="true to set viewing permissions for the photo's location data to friends, false to set it to private. ">
		<cfargument name="is_family" type="boolean" required="yes" hint="true to set viewing permissions for the photo's location data to family, false to set it to private. ">
		<cfset var resp = "">		
		<cfscript>
		if(arguments.is_public) arguments.is_public = 1;
		else arguments.is_public = 0;
		if(arguments.is_contact) arguments.is_contact = 1;
		else arguments.is_contact = 0;
		if(arguments.is_friend) arguments.is_friend = 1;
		else arguments.is_friend = 0;
		if(arguments.is_family) arguments.is_family = 1;
		else arguments.is_family = 0;
		</cfscript>
		
		<cfset resp = flickr.get("flickr.photos.geo.setPerms", arguments)>
		<cfif resp.isError()>
			<cfthrow errorcode="#resp.getErrorCode()#" message="#resp.getErrorMessage()#">
		</cfif>	
	</cffunction>
	
</cfcomponent>
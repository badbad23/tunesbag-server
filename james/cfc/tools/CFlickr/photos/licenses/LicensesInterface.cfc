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

	<cffunction name="getInfo" access="public" output="false" returntype="array">
		<cfset var resp = flickr.get("flickr.photos.licenses.getInfo")>		
		<cfset var ret = arraynew(1)>
		<cfset var license = 0>
		<cfset var i = 0>
		<cfset var tmp = "">
		
		<cfif resp.isError()>
			<cfthrow errorcode="#resp.getErrorCode()#" message="#resp.getErrorMessage()#">
		</cfif>

		<cfscript>
		tmp = xmlsearch(resp.getPayload(), 'license');
		for(i=1; i LTE arraylen(tmp); i=i+1) {
			license = createobject("component", "CFlickr.photos.licenses.License");
			arrayappend(ret, license.parseXmlElement(tmp[i]));
		}
		return ret;
		</cfscript>
	</cffunction>
	
	<cffunction name="setLicense" access="public" output="false" returntype="boolean" hint="Sets the license for a photo.">
		<cfargument name="photo_id" type="string" required="yes" hint="The photo to update the license for. ">
		<cfargument name="license_id" type="numeric" required="yes" hint="The license to apply, or 0 (zero) to remove the current license. ">
		<cfset var resp = flickr.get("flickr.photos.licenses.setLicense", arguments)>
		<cfif resp.isError()>
			<cfthrow errorcode="#resp.getErrorCode()#" message="#resp.getErrorMessage()#">
		</cfif>
		<cfreturn NOT resp.isError()>	
	</cffunction>

</cfcomponent>
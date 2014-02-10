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

	<cffunction name="Rotate" access="public" output="false" returntype="boolean" hint="Rotate a photo.">
		<cfargument name="photo_id" type="string" required="yes" hint="The id of the photo to rotate. ">
		<cfargument name="degrees" type="numeric" required="yes" hint="The amount of degrees by which to rotate the photo (clockwise) from it's current orientation. Valid values are 90, 180 and 270. ">
		<cfset var resp = flickr.get("flickr.photos.transform.rotate", arguments)>
		<cfif resp.isError()>
			<cfthrow errorcode="#resp.getErrorCode()#" message="#resp.getErrorMessage()#">
		</cfif>
		<cfreturn NOT resp.isError()>		
	</cffunction>

</cfcomponent>
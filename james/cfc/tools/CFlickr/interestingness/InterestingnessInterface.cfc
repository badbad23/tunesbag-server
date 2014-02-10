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

	<cffunction name="getList" access="public" output="false" returntype="CFlickr.photos.PhotoList" hint="Returns the list of interesting photos for the most recent day or a user-specified date.">
		<cfargument name="date" type="date" required="no" hint="A specific date to return interesting photos for.">
		<cfargument name="extras" type="string" required="no" hint="A comma-delimited list of extra information to fetch for each returned record. Currently supported fields are: license, date_upload, date_taken, owner_name, icon_server, original_format, last_update, geo. ">
		<cfargument name="per_page" type="numeric" required="no" hint="Number of photos to return per page. If this argument is omitted, it defaults to 100. The maximum allowed value is 500. ">
		<cfargument name="page" type="numeric" required="no" hint="The page of results to return. If this argument is omitted, it defaults to 1. ">
		
		<cfset var resp = "">
		<cfset var photolist = createObject("component", "CFlickr.photos.PhotoList")>

		<cfscript>
		if(structkeyexists(arguments, "date")) arguments.date = dateformat(arguments.date, "YYYY-MM-DD");
		</cfscript>

		<cfset resp = flickr.get("flickr.interestingness.getList", arguments)>
		<cfif resp.isError()>
			<cfthrow errorcode="#resp.getErrorCode()#" message="#resp.getErrorMessage()#">
		</cfif>			
		<cfreturn photolist.parseXmlElement(resp.getPayload())>
		
	</cffunction>

</cfcomponent>
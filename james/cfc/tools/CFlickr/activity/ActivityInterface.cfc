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

	<cffunction name="userComments" access="public" output="false" returntype="any" hint="Returns a list of recent activity on photos commented on by the calling user. Do not poll this method more than once an hour.">
		<cfargument name="per_page" type="numeric" required="no" hint="Number of items to return per page. If this argument is omitted, it defaults to 10. The maximum allowed value is 50.">
		<cfargument name="page" type="numeric" required="no" hint="The page of results to return. If this argument is omitted, it defaults to 1.">

		<cfset var resp = flickr.get("flickr.activity.userComments", arguments)>
		<cfset var activitylist = createobject("component", "ActivityList")>
		<cfset var tmp = "">
		
		<cfif resp.isError()>
			<cfthrow errorcode="#resp.getErrorCode()#" message="#resp.getErrorMessage()#">
		</cfif>

		<cfreturn activitylist.parseXmlElement(resp.getPayload()) />
	</cffunction>


	<cffunction name="userPhotos" access="public" output="false" returntype="any" hint="Returns a list of recent activity on photos belonging to the calling user. Do not poll this method more than once an hour.">
		<cfargument name="timeframe" type="string" required="no" hint="The timeframe in which to return updates for. This can be specified in days ('2d') or hours ('4h'). The default behavoir is to return changes since the beginning of the previous user session.">
		<cfargument name="per_page" type="numeric" required="no" hint="Number of items to return per page. If this argument is omitted, it defaults to 10. The maximum allowed value is 50.">
		<cfargument name="page" type="numeric" required="no" hint="The page of results to return. If this argument is omitted, it defaults to 1.">

		<cfset var resp = flickr.get("flickr.activity.userPhotos", arguments)>
		<cfset var activitylist = createobject("component", "ActivityList")>
		<cfset var tmp = "">
		
		<cfif resp.isError()>
			<cfthrow errorcode="#resp.getErrorCode()#" message="#resp.getErrorMessage()#">
		</cfif>

		<cfreturn activitylist.parseXmlElement(resp.getPayload()) />
	</cffunction>


</cfcomponent>



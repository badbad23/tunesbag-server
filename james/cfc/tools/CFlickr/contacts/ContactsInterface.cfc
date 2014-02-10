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

	<cffunction name="getList" access="public" output="false" returntype="CFlickr.contacts.ContactList" hint="Get a list of contacts for the calling user.">
		<cfargument name="filter" type="string" required="no" hint="friend,family,both,neither">
		<cfargument name="page" type="numeric" required="no" hint="The page of results to return. If this argument is omitted, it defaults to 1.">
		<cfargument name="per_page" type="numeric" required="no" hint="Number of contacts to return per page. If this argument is omitted, it defaults to 1000. The maximum allowed value is 1000.">
		<cfset var resp = flickr.get("flickr.contacts.getList", arguments)>
		<cfset var contactList = createobject("component", "CFlickr.contacts.ContactList")>
		<cfif resp.isError()>
			<cfthrow errorcode="#resp.getErrorCode()#" message="#resp.getErrorMessage()#">
		</cfif>
		<cfreturn contactList.parseXmlElement(resp.getPayload()) />
	</cffunction>

	<cffunction name="getPublicList" access="public" output="false" returntype="CFlickr.contacts.ContactList" hint="Get the contact list for a user.">
		<cfargument name="user_id" type="string" required="yes">
		<cfargument name="page" type="numeric" required="no" hint="The page of results to return. If this argument is omitted, it defaults to 1.">
		<cfargument name="per_page" type="numeric" required="no" hint="Number of contacts to return per page. If this argument is omitted, it defaults to 1000. The maximum allowed value is 1000.">
		<cfset var resp = flickr.get("flickr.contacts.getPublicList", arguments)>
		<cfset var contactList = createobject("component", "CFlickr.contacts.ContactList")>
		<cfif resp.isError()>
			<cfthrow errorcode="#resp.getErrorCode()#" message="#resp.getErrorMessage()#">
		</cfif>
		<cfreturn contactList.parseXmlElement(resp.getPayload()) />
	</cffunction>


</cfcomponent>
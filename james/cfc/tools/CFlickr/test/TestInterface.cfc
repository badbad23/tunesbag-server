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

	<cffunction name="echo" access="public" output="false" returntype="struct" hint="A testing method which echo's all paramaters back in the response.">
		<!--- no arguments required, any passed in will be echoed back --->
		<cfset var resp = flickr.get("flickr.test.echo", arguments)>
		<cfset var payload = "">
		<cfset var ret = structnew()>
		<cfset var node = "">
		<cfif resp.isError()>
			<cfthrow errorcode="#resp.getErrorCode()#" message="#resp.getErrorMessage()#">
		</cfif>
		<cfset payload = resp.getPayloadArray()>
		<cfloop from="1" to="#arraylen(payload)#" index="i">
			<cfset node = payload[i]>
			<cfset ret[node.xmlname] = node.xmltext>
		</cfloop>
		<cfreturn ret>
	</cffunction>
	
	<cffunction name="login" access="public" output="true" returntype="any" hint="A testing method which checks if the caller is logged in then returns their username.">
		<cfset var resp = flickr.get("flickr.test.login", arguments)>
		<cfset var user = createobject("component", "CFlickr.people.User")>
		<cfif resp.isError()>
			<cfthrow errorcode="#resp.getErrorCode()#" message="#resp.getErrorMessage()#">
		</cfif>
		<cfreturn user.parseXmlElement(resp.getPayload())>
	</cffunction>

	<cffunction name="null" access="public" output="true" returntype="any" hint="Place holder for null method, does nothing as far as i can tell.. ?">
		<cfreturn false>
	</cffunction>
	
</cfcomponent>
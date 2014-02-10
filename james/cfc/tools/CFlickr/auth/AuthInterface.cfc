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

	<cffunction name="checkToken" access="public" output="false" returntype="CFlickr.auth.Auth">
		<cfargument name="auth_token" type="string" required="yes" hint="The authentication token to check.">
		<cfset var resp = flickr.get("flickr.auth.checkToken", arguments)>
		<cfset var auth = createobject("component", "CFlickr.auth.Auth")>
		<cfif resp.isError()>
			<cfthrow errorcode="#resp.getErrorCode()#" message="#resp.getErrorMessage()#">
		</cfif>
		<cfreturn auth.parseXmlElement(resp.getPayload())>
	</cffunction>	
	
	<cffunction name="getFrob" access="public" output="false" returntype="string">
		<cfset var resp = flickr.get("flickr.auth.getFrob", arguments)>
		<cfif resp.isError()>
			<cfthrow errorcode="#resp.getErrorCode()#" message="#resp.getErrorMessage()#">
		</cfif>
		<cfreturn resp.getPayload().xmlText>		
	</cffunction>
	
	<cffunction name="getFullToken" access="public" output="false" returntype="CFlickr.auth.Auth">
		<cfargument name="mini_token" type="string" required="yes" hint="The mini-token typed in by a user. It should be 9 digits long. It may optionally contain dashes.">
		<cfset var resp = flickr.get("flickr.auth.getFullToken", arguments)>
		<cfset var auth = createobject("component", "CFlickr.auth.Auth")>
		<cfif resp.isError()>
			<cfthrow errorcode="#resp.getErrorCode()#" message="#resp.getErrorMessage()#">
		</cfif>
		<cfreturn auth.parseXmlElement(resp.getPayload())>
	</cffunction>
	
	<!--- getToken() is a builtin function --->
	<cffunction name="getAuthToken" access="public" output="false" returntype="CFlickr.auth.Auth" hint="This method actially calls <strong>flickr.auth.getToken</strong>, getToken() is a built in CF method so it has been renamed">
		<cfargument name="frob" type="string" required="yes" hint="The frob to check.">
		<cfset var resp = flickr.get("flickr.auth.getToken", arguments)>
		<cfset var auth = createobject("component", "CFlickr.auth.Auth")>
		<cfif resp.isError()>
			<cfthrow errorcode="#resp.getErrorCode()#" message="#resp.getErrorMessage()#">
		</cfif>
		<cfreturn auth.parseXmlElement(resp.getPayload())>
	</cffunction>	
	
	<cffunction name="getAuthUrl" access="public" output="false" returntype="string">
		<cfargument name="perms" type="string" required="yes" hint="The permission you are requesting, read, write or delete.">
		<cfargument name="frob" type="string" required="no" hint="A frob.">
		<cfset var host = flickr.getUrl("auth") & "?">
		<cfset var sig = "">
		<cfset arguments.api_key = flickr.getApikey()>
		<cfset arguments.api_sig = flickr.getSignature(arguments)>
		<cfscript>
		for(key in arguments) {
			if(len(arguments[key])) host = host & lcase(key) & "=" & arguments[key] & "&";
		}
		</cfscript>
		
		<cfreturn host>
	</cffunction>

</cfcomponent>
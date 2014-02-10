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

<cffunction name="getContentType" access="public" output="false" returntype="any" hint="Returns the default content type preference for the user.">
	<cfset resp = flickr.get("flickr.prefs.getContentType", arguments)>

	<cfif resp.isError()>
		<cfthrow errorcode="#resp.getErrorCode()#" message="#resp.getErrorMessage()#">
	</cfif>	
	
	<cfreturn resp.getPayload().XmlAttributes.content_type />
</cffunction>

<cffunction name="getHidden" access="public" output="false" returntype="any" hint="Returns the default hidden preference for the user.">
	<cfset resp = flickr.get("flickr.prefs.getHidden", arguments)>

	<cfif resp.isError()>
		<cfthrow errorcode="#resp.getErrorCode()#" message="#resp.getErrorMessage()#">
	</cfif>	
	
	<cfreturn resp.getPayload().XmlAttributes.hidden />
</cffunction>

<cffunction name="getSafetyLevel" access="public" output="false" returntype="any" hint="Returns the default safety level preference for the user.">
	<cfset resp = flickr.get("flickr.prefs.getSafetyLevel", arguments)>

	<cfif resp.isError()>
		<cfthrow errorcode="#resp.getErrorCode()#" message="#resp.getErrorMessage()#">
	</cfif>	
	
	<cfreturn resp.getPayload().XmlAttributes.safety_level />
</cffunction>

	

</cfcomponent>
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

	<cffunction name="getMethodInfo" access="public" output="false" returntype="CFlickr.reflection.Method" hint="Returns information for a given flickr API method.">
		<cfargument name="method_name" type="string" required="yes" hint="The name of the method to fetch information for. ">
		<cfset var resp = flickr.get("flickr.reflection.getMethodInfo", arguments)>
		<cfset var method = createobject("component", "Method")>
		<cfset var payloadarray = "">
		<cfset var i = 0>
		<cfif resp.isError()>
			<cfthrow errorcode="#resp.getErrorCode()#" message="#resp.getErrorMessage()#">
		</cfif>
		
		<!--- 	Flickr's response to this method seems wrong, 
				method, args and errors are seperate nodes.  
				args and errs should probably be children of method  
				To get around this we need to parse each node of the response seperately
		--->
		<cfset payloadarray = resp.getPayloadArray()>
		<cfloop from="1" to="#arraylen(payloadarray)#" index="i">
			<cfset method.parseXmlElement(payloadarray[i])>
		</cfloop>
		
		<cfreturn method>
	</cffunction>

	<cffunction name="getMethods" access="public" output="true" returntype="array" hint="Returns a list of available flickr API methods.">
		<cfset var resp = flickr.get("flickr.reflection.getMethods", arguments)>
		<cfset var tmp = "">
		<cfset var ret = arraynew(1)>
		<cfif resp.isError()>
			<cfthrow errorcode="#resp.getErrorCode()#" message="#resp.getErrorMessage()#">
		</cfif>
		<cfscript>
		tmp = xmlsearch(resp.getPayload(), 'method');
		for(i=1; i LTE arraylen(tmp); i=i+1) {
			arrayappend(ret, tmp[i].xmltext);
		}
		return ret;
		</cfscript>
	</cffunction>


</cfcomponent>
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

<cfcomponent>
	
	<cfscript>
	variables.status = "";
	variables.payload = "";
	variables.errorcode = "";
	variables.errormsg = "";
	variables.doc = "";
	</cfscript>

	<cffunction name="parse" access="public" output="false" returntype="void">
		<cfargument name="xmldoc"type="any" required="yes">
		<cfset var x = xmlsearch(xmldoc, '/rsp')>
		<cfset var ec = "">
		<cfset variables.doc = xmldoc>
		<cfif NOT arraylen(x)>
			<cfthrow message="Error parsing Flickr xml response">
		</cfif>
		<cfset x = x[1]>
		<cfset variables.status = x.xmlattributes.stat>
		<cfif lcase(variables.status) EQ "ok">
			<cfset variables.payload = x.XmlChildren>
		<cfelse>
			<cfset ec = xmlsearch(x, 'err')>
			<cfset ec = ec[1]>
			<cfset variables.errorcode = ec.xmlattributes.code>
			<cfset variables.errormsg = ec.xmlattributes.msg>
		</cfif>
	</cffunction>
	
	<cffunction name="getStatus" access="public" output="false" returntype="string">
		<cfreturn status>
	</cffunction>
	
	<!--- Generally we're just after the single element in the payload --->
	<cffunction name="getPayload" access="public" output="false" returntype="any">
		<cfif arraylen(payload)>
			<cfreturn payload[1]>
		<cfelse>
			<cfthrow message="REST response payload has no elements">
		</cfif>
	</cffunction>
	
	<!--- Certain methods return multiple elements below /rsp, like TestInterface.echo() --->
	<cffunction name="getPayloadArray" access="public" output="false" returntype="array">
		<cfreturn payload>
	</cffunction>
	
	<cffunction name="getErrorCode" access="public" output="false" returntype="string">
		<cfreturn errorcode>
	</cffunction>

	<cffunction name="getErrorMessage" access="public" output="false" returntype="string">
		<cfreturn errormsg>
	</cffunction>
	
	<cffunction name="isError" access="public" output="false" returntype="boolean">
		<cfif lcase(variables.status) EQ "ok">
			<cfreturn false>
		<cfelse>
			<cfreturn true>
		</cfif>

	</cffunction>
	
	<!--- return the original xml doc --->
	<cffunction name="getDoc">
		<cfreturn doc>
	</cffunction>


</cfcomponent>
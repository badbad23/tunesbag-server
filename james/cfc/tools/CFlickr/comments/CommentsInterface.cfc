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

<cfcomponent extends="CFlickr.AbstractInterface" hint="This is now deprecated in favor of CFlickr.photos.comments.CommentsInterface and CFlickr.photosets.comments.CommentsInterface">

	<cffunction name="getListPhoto" access="public" output="false" returntype="array">
		<cfargument name="photo_id" type="string" required="yes">
		<cfset var resp = flickr.get("flickr.photos.comments.getList", arguments)>		
		<cfset var ret = arraynew(1)>
		<cfset var comment = 0>
		<cfset var i = 0>
		<cfset var tmp = "">
		
		<cfif resp.isError()>
			<cfthrow errorcode="#resp.getErrorCode()#" message="#resp.getErrorMessage()#">
		</cfif>

		<cfscript>
		tmp = xmlsearch(resp.getPayload(), 'comment');
		for(i=1; i LTE arraylen(tmp); i=i+1) {
			comment = createobject("component", "CFlickr.comments.Comment");
			arrayappend(ret, comment.parseXmlElement(tmp[i]));
		}
		return ret;
		</cfscript>
	</cffunction>

	<cffunction name="getListPhotoset" access="public" output="false" returntype="array">
		<cfargument name="photoset_id" type="string" required="yes">
		<cfset var resp = flickr.get("flickr.photosets.comments.getList", arguments)>		
		<cfset var ret = arraynew(1)>
		<cfset var comment = 0>
		<cfset var i = 0>
		<cfset var tmp = "">
		
		<cfif resp.isError()>
			<cfthrow errorcode="#resp.getErrorCode()#" message="#resp.getErrorMessage()#">
		</cfif>

		<cfscript>
		tmp = xmlsearch(resp.getPayload(), 'comment');
		for(i=1; i LTE arraylen(tmp); i=i+1) {
			comment = createobject("component", "CFlickr.comments.Comment");
			arrayappend(ret, comment.parseXmlElement(tmp[i]));
		}
		return ret;
		</cfscript>
	</cffunction>


</cfcomponent>
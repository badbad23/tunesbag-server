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

	<cffunction name="getHotList" access="public" output="false" returntype="array" hint="Returns a list of hot tags for the given period.">
		<cfargument name="period" type="string" required="no" hint="The period for which to fetch hot tags. Valid values are day and week (defaults to day).">
		<cfargument name="count" type="numeric" required="no" hint="The number of tags to return. Defaults to 20. Maximum allowed value is 200.">
		<cfset var resp = flickr.get("flickr.tags.getHotList", arguments)>
		<cfset var ret = arraynew(1)>
		<cfset var tag = "">
		<cfset var tmp = "">
		<cfset var i = 0>

		<cfif resp.isError()>
			<cfthrow errorcode="#resp.getErrorCode()#" message="#resp.getErrorMessage()#">
		</cfif>
		
		<cfscript>
		tmp = xmlsearch(resp.getPayload(), 'tag');
		for(i=1; i LTE arraylen(tmp); i=i+1) {
			tag = createobject("component", "CFlickr.tags.Tag");
			arrayappend(ret, tag.parseXmlElement(tmp[i]));
		}
		return ret;
		</cfscript>
		
	</cffunction>


	<cffunction name="getListPhoto" access="public" output="false" returntype="array" hint="Get the tag list for a given photo.">
		<cfargument name="photo_id" type="string" required="yes" hint="The id of the photo to return tags for. ">
		<cfset var resp = flickr.get("flickr.tags.getListPhoto", arguments)>
		<cfset var ret = arraynew(1)>
		<cfset var tag = "">
		<cfset var tmp = "">
		<cfset var i = 0>

		<cfif resp.isError()>
			<cfthrow errorcode="#resp.getErrorCode()#" message="#resp.getErrorMessage()#">
		</cfif>
		
		<cfscript>
		tmp = xmlsearch(resp.getPayload(), 'tags/tag');
		for(i=1; i LTE arraylen(tmp); i=i+1) {
			tag = createobject("component", "CFlickr.tags.Tag");
			arrayappend(ret, tag.parseXmlElement(tmp[i]));
		}
		return ret;
		</cfscript>
	</cffunction>

	<cffunction name="getListUser" access="public" output="false" returntype="array" hint="Get the tag list for a given user (or the currently logged in user).">
		<cfargument name="user_id" type="string" required="no" hint="The NSID of the user to fetch the tag list for. If this argument is not specified, the currently logged in user (if any) is assumed. ">
		<cfset var resp = flickr.get("flickr.tags.getListUser", arguments)>
		<cfset var ret = arraynew(1)>
		<cfset var tag = "">
		<cfset var tmp = "">
		<cfset var i = 0>

		<cfif resp.isError()>
			<cfthrow errorcode="#resp.getErrorCode()#" message="#resp.getErrorMessage()#">
		</cfif>
		
		<cfscript>
		tmp = xmlsearch(resp.getPayload(), 'tags/tag');
		for(i=1; i LTE arraylen(tmp); i=i+1) {
			tag = createobject("component", "CFlickr.tags.Tag");
			arrayappend(ret, tag.parseXmlElement(tmp[i]));
		}
		return ret;
		</cfscript>
	</cffunction>

	<cffunction name="getListUserRaw" access="public" output="false" returntype="array" hint="Get the raw versions of a given tag (or all tags) for the currently logged-in user.">
		<cfargument name="tag" type="string" required="no" hint="The tag you want to retrieve all raw versions for.">

		<cfset var resp = flickr.get("flickr.tags.getListUserRaw", arguments)>
		<cfset var ret = arraynew(1)>
		<cfset var _tag = "">
		<cfset var tmp = "">
		<cfset var i = 0>

		<cfif resp.isError()>
			<cfthrow errorcode="#resp.getErrorCode()#" message="#resp.getErrorMessage()#">
		</cfif>

		<cfscript>
		tmp = xmlsearch(resp.getPayload(), 'tags/tag');
		for(i=1; i LTE arraylen(tmp); i=i+1) {
			_tag = createobject("component", "CFlickr.tags.Tag");
			arrayappend(ret, _tag.parseXmlElement(tmp[i]));
		}
		return ret;
		</cfscript>
	</cffunction>

	<cffunction name="getListUserPopular" access="public" output="false" returntype="array" hint="Get the popular tags for a given user (or the currently logged in user).">
		<cfargument name="user_id" type="string" required="no" hint="The NSID of the user to fetch the tag list for. If this argument is not specified, the currently logged in user (if any) is assumed. ">
		<cfargument name="count" type="numeric" required="no" hint="Number of popular tags to return. defaults to 10 when this argument is not present. ">
		<cfset var resp = flickr.get("flickr.tags.getListUserPopular", arguments)>
		<cfset var ret = arraynew(1)>
		<cfset var tag = "">
		<cfset var tmp = "">
		<cfset var i = 0>

		<cfif resp.isError()>
			<cfthrow errorcode="#resp.getErrorCode()#" message="#resp.getErrorMessage()#">
		</cfif>
		
		<cfscript>
		tmp = xmlsearch(resp.getPayload(), 'tags/tag');
		for(i=1; i LTE arraylen(tmp); i=i+1) {
			tag = createobject("component", "CFlickr.tags.Tag");
			arrayappend(ret, tag.parseXmlElement(tmp[i]));
		}
		return ret;
		</cfscript>
	</cffunction>

	<cffunction name="getRelated" access="public" output="false" returntype="array" hint="Returns a list of tags 'related' to the given tag, based on clustered usage analysis.">
		<cfargument name="tag" type="string" required="yes" hint="The tag to fetch related tags for. ">
		<cfset var resp = flickr.get("flickr.tags.getRelated", arguments)>
		<cfset var ret = arraynew(1)>
		<cfset var t = "">
		<cfset var tmp = "">
		<cfset var i = 0>

		<cfif resp.isError()>
			<cfthrow errorcode="#resp.getErrorCode()#" message="#resp.getErrorMessage()#">
		</cfif>
		
		<cfscript>
		tmp = xmlsearch(resp.getPayload(), 'tag');
		for(i=1; i LTE arraylen(tmp); i=i+1) {
			t = createobject("component", "CFlickr.tags.Tag");
			arrayappend(ret, t.parseXmlElement(tmp[i]));
		}
		return ret;
		</cfscript>

	</cffunction>

</cfcomponent>


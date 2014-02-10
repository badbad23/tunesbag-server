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

	<cffunction name="getList" access="public" output="false" returntype="Array" hint="Get a list of configured blogs for the calling user.">
		<cfset var resp = flickr.get("flickr.blogs.getList", arguments)>
		<cfset var blog = "">
		<cfset var tmp = "">
		<cfset var i = 0>
		<cfset var ret = arraynew(1)>
		<cfif resp.isError()>
			<cfthrow errorcode="#resp.getErrorCode()#" message="#resp.getErrorMessage()#">
		</cfif>
		<cfscript>
		tmp = xmlsearch(resp.getPayload(), "blog");
		for(i=1; i LTE arraylen(tmp); i=i+1) {
			blog = createobject("component", "CFlickr.blogs.Blog");
			arrayappend(ret, blog.parseXmlElement(tmp[i]));
		}
		return ret;
		</cfscript>
	</cffunction>
	
	<cffunction name="postPhoto" access="public" output="false" returntype="boolean" hint="Post a photo to a blog configured on flickr.">
		<cfargument name="blog_id" type="string" required="yes" hint="The id of the blog to post to">
		<cfargument name="photo_id" type="string" required="yes" hint="The id of the photo to blog">
		<cfargument name="title" type="string" required="yes" hint="The blog post title">
		<cfargument name="description" type="string" required="yes" hint="The blog post body">
		<cfargument name="blog_password" type="string" required="no" hint="The password for the blog (used when the blog does not have a stored password)">
		<cfset var resp = flickr.get("flickr.blogs.postPhoto", arguments)>
		<cfif resp.isError()>
			<cfthrow errorcode="#resp.getErrorCode()#" message="#resp.getErrorMessage()#">
		</cfif>
		<cfreturn NOT resp.isError() />
	</cffunction>


</cfcomponent>
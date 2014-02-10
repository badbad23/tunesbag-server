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

	<cffunction name="uploadPhoto" access="public" output="false" returntype="string" hint="Upload a photo to Flickr">
		<cfargument name="photo" type="string" required="yes" hint="Absolute path to an image file to upload">
		<cfargument name="title" type="string" required="no" hint="The title of the photo. ">
		<cfargument name="description" type="string" required="no" hint="A description of the photo. May contain some limited HTML.">
		<cfargument name="tags" type="string" required="no" hint="A space-seperated list of tags to apply to the photo. ">
		<cfargument name="is_public" type="boolean" required="no" hint="Set to false for no, true for yes. Specifies who can view the photo. ">
		<cfargument name="is_friend" type="boolean" required="no" hint="Set to false for no, true for yes. Specifies who can view the photo. ">
		<cfargument name="is_family" type="boolean" required="no" hint="Set to false for no, true for yes. Specifies who can view the photo. ">
		<cfargument name="async" type="boolean" required="no" default="0" hint="If true will return an upload ticket, if false will return the photoid">
		<cfset var resp = "">
		<cfscript>
		if(arguments.is_public) arguments.is_public = 1;
		else arguments.is_public = 0;
		if(arguments.is_friend) arguments.is_friend = 1;
		else arguments.is_friend = 0;
		if(arguments.is_family) arguments.is_family = 1;
		else arguments.is_family = 0;
		</cfscript>
		<cfset resp = post(params=arguments, url=flickr.getUrl('upload'))>
		<cfif resp.isError()>
			<cfthrow errorcode="#resp.getErrorCode()#" message="#resp.getErrorMessage()#">
		</cfif>
		<!--- this will either be the photoid for a non-async uplaod or a ticketid for an async upload --->
		<cfreturn resp.getPayload().xmltext>
	</cffunction>

	<cffunction name="replacePhoto" access="public" output="true" returntype="string" hint="Replace a photo with a new image">
		<cfargument name="photo" type="string" required="yes" hint="Absolute path to an image file to upload">
		<cfargument name="photo_id" type="string" required="yes" hint="The ID of the photo to replace">
		<cfargument name="async" type="boolean" required="no" default="0" hint="If true will return a upload ticket, if false will return the photoid">
		<cfset var resp = post(params=arguments, url=flickr.getUrl('replace'))>
		<cfif resp.isError()>
			<cfthrow errorcode="#resp.getErrorCode()#" message="#resp.getErrorMessage()#">
		</cfif>
		<!--- this will either be the photoid for a non-async uplaod or a ticketid for an async upload --->
		<cfreturn resp.getPayload().xmltext>
	</cffunction>


	<!--- the upload interface has its own post method, because it needs to send a binary file,
	 	  to a different url, and is signed slightly differently--->
	<cffunction name="post" access="private" output="true" returntype="CFlickr.Response">
		<cfargument name="params" type="struct" required="no" default="#structnew()#">
		<cfargument name="url" type="string" required="no" default="#flickr.getUrl('upload')#">
		<cfset var sig = "">
		<cfset var photo = "">
		<cfset var response = createobject("component", "CFlickr.Response")>
		<cfset var secret = flickr.getSecret()>
		<cfset params.api_key = flickr.getApiKey()>
		<cfset params.auth_token = flickr.getAuthToken()>
		<!--- we need to take the photo out of the params collection because it doesnt get hashed
			we'll put it back in later so that its set in the setLastParams() --->
		<cfif structkeyexists(params, "photo")>
			<cfset photo = params.photo>
			<cfset structdelete(params, "photo")>
		</cfif>

		<!--- need to enforce lcase and alphabetical order --->
		<cfset paramlist = listsort(lcase(structkeylist(params)), "TEXT")>

		<cfif len(secret)> 
			<cfset sig = secret> 					<!--- create the string to hash --->
			<cfloop list="#paramlist#" index="i">
				<cfif len(params[i])>
					<cfset sig = sig & "#i##params[i]#"> 	<!--- add each param to the string --->
				<cfelse> 
					<cfset structdelete(params, i)> 		<!--- delete any empty params passed in --->
				</cfif>
			</cfloop>
			<cfset params.api_sig = lcase(hash(sig))>		<!--- create the md5 hash and add it to the params collection --->
		<cfelse>
			<cfloop collection="#params#" item="i">
				<cfif NOT len(params[i])>
					<cfset structdelete(params, i)>
				</cfif>
			</cfloop>
		</cfif>
		
		<cfhttp url="#arguments.url#" method="post">
			<cfloop collection="#params#" item="i">
				<cfhttpparam name="#lcase(i)#" type="formfield" value="#params[i]#">
			</cfloop>
			<cfif len(photo)>
				<cfhttpparam name="photo" type="file" file="#photo#">
				<cfset params.photo = photo>
			</cfif>
		</cfhttp>
		<cfset params.url = arguments.url>
		
		<cfset flickr.setLastResponse(response)>
		<cfset flickr.setLastParams(params)>
		<cfset response.parse(xmlparse(cfhttp.FileContent))>
		<cfreturn response>
	</cffunction>

	
	<cffunction name="checkTickets" access="public" output="false" returntype="array" hint="Checks the status of one or more asynchronous photo upload tickets.">
		<cfargument name="tickets" type="string" required="yes" hint="A comma-delimited list of ticket ids">
		<cfset var resp = flickr.get("flickr.photos.upload.checkTickets", arguments)>
		<cfset var ret = arraynew(1)>
		<cfset var i = 0>
		<cfset var ticket = "">
		<cfset var tmp = "">
		
		<cfif resp.isError()>
			<cfthrow errorcode="#resp.getErrorCode()#" message="#resp.getErrorMessage()#">
		</cfif>

		<cfscript>
		tmp = xmlsearch(resp.getPayload(), 'ticket');
		for(i=1; i LTE arraylen(tmp); i=i+1) {
			ticket = createobject("component", "CFlickr.photos.upload.Ticket");
			arrayappend(ret, ticket.parseXmlElement(tmp[i]));
		}
		return ret;
		</cfscript>		
	</cffunction>




</cfcomponent>
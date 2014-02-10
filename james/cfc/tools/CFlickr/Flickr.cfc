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
	variables.version = "0.7";
    variables.apikey = "";
    variables.secret = "";
	variables.token = "";
	variables.urls = structnew();
    variables.urls.rest = 'http://api.flickr.com/services/rest/';
    variables.urls.upload = 'http://api.flickr.com/services/upload/';	
    variables.urls.replace = 'http://api.flickr.com/services/replace/';	
	variables.urls.auth = 'http://www.flickr.com/services/auth/';
	variables.interfaces = structnew();
	variables.lastresponse = createobject("component", "Response");
	variables.lastRequestCached	= false;
	variables.lastparams = structnew();
	</cfscript>

	<cffunction name="init" access="public" output="false" returntype="CFlickr.Flickr">
		<cfargument name="apikey" type="string" required="yes">
		<cfargument name="secret" type="string" required="no" default="">
		<cfargument name="token" type="string" required="no" default="">
		<cfargument name="cache" type="CFlickr.cache.AbstractCache" required="no">
		<cfset setApiKey(arguments.apikey)>
		<cfset setSecret(arguments.secret)>
		<cfset setAuthToken(arguments.token)>
		<cfif structkeyexists(arguments, "cache")>
			<cfset variables.cache = arguments.cache>
		</cfif>
		<cfreturn this>
	</cffunction>

	<cffunction name="getUrl" access="public" output="false" returntype="string">
		<cfargument name="key" type="string" required="yes">
		<cfif structkeyexists(variables.urls, arguments.key)>
			<cfreturn variables.urls[arguments.key]>
		<cfelse>
			<cfthrow message="Url Type #arguments.key# not found">
		</cfif>
	</cffunction>
	
	<cffunction name="setUrl" access="public" output="false" returntype="void">
		<cfargument name="key" type="string" required="yes">
		<cfargument name="value" type="string" required="yes">
		<cfset variables.urls[arguments.key] = arguments.value>
	</cffunction>

	<cffunction name="getApiKey" access="public" output="false" returntype="string">
		<cfreturn variables.apikey />
	</cffunction>
	<cffunction name="setApiKey" access="public" output="false" returntype="void">
		<cfargument name="apikey" type="string" required="yes">
		<cfset variables.apikey = arguments.apikey>
	</cffunction>	
	
	<cffunction name="getSecret" access="public" output="false" returntype="string">
		<cfreturn variables.secret />
	</cffunction>
	<cffunction name="setSecret" access="public" output="false" returntype="void">
		<cfargument name="secret" type="string" required="yes">
		<cfset variables.secret = arguments.secret>
	</cffunction>	

	<cffunction name="getAuthToken" access="public" output="false" returntype="string">
		<cfreturn variables.token />
	</cffunction>
	<cffunction name="setAuthToken" access="public" output="false" returntype="void">
		<cfargument name="token" type="string" required="yes">
		<cfset variables.token = arguments.token>
	</cffunction>
	
	<!--- GET actually uses POST to avoid any problems with some Flickr methods requiring post and limits on get request lengths --->
	<cffunction name="get" access="public" output="false" returntype="CFlickr.Response">
		<cfargument name="method" type="string" required="yes">
		<cfargument name="params" type="struct" required="no" default="#structnew()#">
		<cfreturn post(argumentCollection=arguments)>
	</cffunction>

	<cffunction name="post" access="public" output="false" returntype="CFlickr.Response">
		<cfargument name="method" type="string" required="yes">
		<cfargument name="params" type="struct" required="no" default="#structnew()#">
		<cfset var sig = "">
		<cfset var raw_response = "">
		<cfset var response = createobject("component", "CFlickr.Response")>
		
		<cfset params.method = arguments.method>
		<cfset params.api_key = variables.apikey>
		<cfif len(variables.token)>
			<cfset params.auth_token = variables.token>
		</cfif>

		<!--- need to enforce lcase and alphabetical order --->
		<cfset paramlist = listsort(lcase(structkeylist(params)), "TEXT")>

		<cfif len(variables.secret)> 
			<cfset sig = variables.secret> 					<!--- create the string to hash --->
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
		
		<!--- if we are processing a cached response, dont do another request --->
		<cfif structkeyexists(variables, "cache") AND cache.existsInCache(params)>
			<cfset raw_response = cache.getFromCache(params)>
			<cfset variables.lastRequestCached = true>
		<cfelse>
			<cfhttp url="#getUrl('rest')#" method="post">
				<cfloop collection="#params#" item="i">
					<cfhttpparam name="#lcase(i)#" type="formfield" value="#params[i]#">
				</cfloop>
			</cfhttp>
			<cfset raw_response = cfhttp.FileContent>

			<cfif structkeyexists(variables, "cache")>
				<cfset cache.saveToCache(params, raw_response)>
			</cfif>
			<cfset variables.lastRequestCached = false>
		</cfif>
		
		<cfset setLastResponse(response)>
		<cfset setLastParams(params)>
		<cfset response.parse(xmlparse(raw_response))>
		<cfreturn response>
	</cffunction>
	
	<cffunction name="getLastResponse" access="public" output="false" returntype="CFlickr.Response">
		<cfreturn variables.lastresponse />
	</cffunction>
	<cffunction name="setLastResponse" access="public" output="false" returntype="void">
		<cfargument name="response" type="CFlickr.Response" required="yes">
		<cfset variables.lastresponse = arguments.response>
	</cffunction>

	<cffunction name="getLastRequestCached" access="public" output="false" returntype="boolean">
		<cfreturn variables.lastRequestCached />
	</cffunction>
	
	<cffunction name="getCache" access="public" output="false" returntype="CFlickr.cache.AbstractCache">
		<cfif NOT structkeyexists(variables, "cache")>
			<cfthrow errorcode="CFlickr.cache.NoCacheSet" message="CFlickr is not currently using a cache">
		</cfif>
		<cfreturn variables.cache>		
	</cffunction>
	<cffunction name="setCache" access="public" output="false" returntype="void">
		<cfargument name="cache" type="CFlickr.cache.AbstractCache" required="yes">
		<cfset variables.cache = arguments.cache>
	</cffunction>

	<cffunction name="getLastParams" access="public" output="false" returntype="struct">		
		<cfreturn variables.lastparams />
	</cffunction>
	<cffunction name="setLastParams" access="public" output="false" returntype="void">
		<cfargument name="params" type="struct" required="yes">
		<cfset variables.lastparams = arguments.params>
	</cffunction>

	<cffunction name="getSignature" access="public" output="false" returntype="string">
		<cfargument name="params" type="struct" required="yes">
		<cfset var s = getSecret()>
		<cfset var paramlist = listsort(lcase(structkeylist(params)), "TEXT")>
		<cfloop list="#paramlist#" index="i">
			<cfif len(params[i])>
				<cfset s = s & i & params[i]>
			</cfif>
		</cfloop>
		<cfreturn lcase(hash(s))>
	</cffunction>

	<!--- INTERFACES --->	
	<cffunction name="getAllInterfaces" access="public" output="false" returntype="struct">
		<cfset var i = "">
		<cfscript>
		for(i in this) {
			if(findnocase("get", i, 1) AND findnocase("interface", i) ) {
				variables.interfaces[replacenocase(i, "get", "")] = evaluate("#i#()");
			}
		}		
		</cfscript>
	</cffunction>
	
	<cffunction name="getInterface" access="private" returntype="any">
		<cfargument name="name" type="string" required="yes">
		<cfif NOT structkeyexists(variables.interfaces, arguments.name)>
			<cfset variables.interfaces[arguments.name] = createobject("component", arguments.name)>
			<cfset variables.interfaces[arguments.name].init(this)>
		</cfif>
		<cfreturn variables.interfaces[arguments.name]>
	</cffunction>
	
	<cffunction name="getActivityInterface" access="public" returntype="CFlickr.activity.ActivityInterface">
		<cfreturn getInterface("CFlickr.activity.ActivityInterface") />
	</cffunction>

	<cffunction name="getAuthInterface" access="public" returntype="CFlickr.auth.AuthInterface">
		<cfreturn getInterface("CFlickr.auth.AuthInterface") />
	</cffunction>
	
	<cffunction name="getBlogsInterface" access="public" returntype="CFlickr.blogs.BlogsInterface">
		<cfreturn getInterface("CFlickr.blogs.BlogsInterface") />
	</cffunction>
	
	<cffunction name="getContactsInterface" access="public" returntype="CFlickr.contacts.ContactsInterface">
		<cfreturn getInterface("CFlickr.contacts.ContactsInterface") />
	</cffunction>
	
	<cffunction name="getFavoritesInterface" access="public" returntype="CFlickr.favorites.FavoritesInterface">
		<cfreturn getInterface("CFlickr.favorites.FavoritesInterface") />
	</cffunction>

	<cffunction name="getGeoInterface" access="public" returntype="CFlickr.photos.geo.GeoInterface">
		<cfreturn getInterface("CFlickr.photos.geo.GeoInterface") />
	</cffunction>

	<cffunction name="getGroupsInterface" access="public" returntype="CFlickr.groups.GroupsInterface">
		<cfreturn getInterface("CFlickr.groups.GroupsInterface") />
	</cffunction>
	
	<cffunction name="getPoolsInterface" access="public" returntype="CFlickr.groups.pools.PoolsInterface">
		<cfreturn getInterface("CFlickr.groups.pools.PoolsInterface") />
	</cffunction>
	
	<cffunction name="getInterestingnessInterface" access="public" returntype="CFlickr.interestingness.InterestingnessInterface">
		<cfreturn getInterface("CFlickr.interestingness.InterestingnessInterface") />
	</cffunction>

	<cffunction name="getPeopleInterface" access="public" returntype="CFlickr.people.PeopleInterface">
		<cfreturn getInterface("CFlickr.people.PeopleInterface") />
	</cffunction>
	
	<cffunction name="getTestInterface" access="public" returntype="CFlickr.test.TestInterface">
		<cfreturn getInterface("CFlickr.test.TestInterface") />
	</cffunction>

	<cffunction name="getPhotosInterface" access="public" returntype="CFlickr.photos.PhotosInterface">
		<cfreturn getInterface("CFlickr.photos.PhotosInterface") />
	</cffunction>

	<cffunction name="getCommentsInterface" access="public" returntype="CFlickr.comments.CommentsInterface" hint="Deprecated: use getPhotoCommentsInterface() or getPhotosetsCommentsInterface instead">
		<cfreturn getInterface("CFlickr.comments.CommentsInterface") />
	</cffunction>

	<cffunction name="getPhotoCommentsInterface" access="public" returntype="CFlickr.photos.comments.CommentsInterface">
		<cfreturn getInterface("CFlickr.photos.comments.CommentsInterface") />
	</cffunction>

	<cffunction name="getPhotosetsCommentsInterface" access="public" returntype="CFlickr.photosets.comments.CommentsInterface">
		<cfreturn getInterface("CFlickr.photosets.comments.CommentsInterface") />
	</cffunction>

	<cffunction name="getLicensesInterface" access="public" returntype="CFlickr.photos.licenses.LicensesInterface">
		<cfreturn getInterface("CFlickr.photos.licenses.LicensesInterface") />
	</cffunction>

	<cffunction name="getNotesInterface" access="public" returntype="CFlickr.photos.notes.NotesInterface">
		<cfreturn getInterface("CFlickr.photos.notes.NotesInterface") />
	</cffunction>

	<cffunction name="getPhotosetsInterface" access="public" returntype="CFlickr.photosets.PhotosetsInterface">
		<cfreturn getInterface("CFlickr.photosets.PhotosetsInterface") />
	</cffunction>
	
	<cffunction name="getPrefsInterface" access="public" returntype="CFlickr.prefs.PrefsInterface">
		<cfreturn getInterface("CFlickr.prefs.PrefsInterface") />
	</cffunction>

	<cffunction name="getTagsInterface" access="public" returntype="CFlickr.tags.TagsInterface">
		<cfreturn getInterface("CFlickr.tags.TagsInterface") />
	</cffunction>

	<cffunction name="getTransformInterface" access="public" returntype="CFlickr.photos.transform.TransformInterface">
		<cfreturn getInterface("CFlickr.photos.transform.TransformInterface") />
	</cffunction>

	<cffunction name="getReflectionInterface" access="public" returntype="CFlickr.reflection.ReflectionInterface">
		<cfreturn getInterface("CFlickr.reflection.ReflectionInterface") />
	</cffunction>

	<cffunction name="getUrlsInterface" access="public" returntype="CFlickr.urls.UrlsInterface">
		<cfreturn getInterface("CFlickr.urls.UrlsInterface") />
	</cffunction>

	<cffunction name="getUploadInterface" access="public" returntype="CFlickr.photos.upload.UploadInterface">
		<cfreturn getInterface("CFlickr.photos.upload.UploadInterface") />
	</cffunction>

	<cffunction name="getVersion" access="public" returntype="any">
		<cfreturn variables.version />
	</cffunction>
		
</cfcomponent>
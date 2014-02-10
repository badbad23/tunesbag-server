<!---
   Copyright 2007 Andrew Duckett

   Licensed under the Apache License, Version 2.0 (the "License");
   you may not use this file except in compliance with the License.
   You may obtain a copy of the License at

      http://www.apache.org/licenses/LICENSE-2.0

   Unless required by applicable law or agreed to in writing, software
   distributed under the License is distributed on an "AS IS" BASIS,
   WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
   See the License for the specific language governing permissions and
   limitations under the License.

   Facebook Development Platform (pre-release) ColdFusion MX 7 client

   Created by Andrew Duckett
   Thanks to John Keipple for all of his input  

   For help with this library, contact andrew@nearpersonal.com   
--->
<cfcomponent output="no">

	<cffunction name="init" access="public" returntype="FacebookRestClient" output="false">
		<cfargument name="apiKey" type="string" required="yes" />
		<cfargument name="secret" type="string" required="yes" />
		<cfargument name="server" type="string" required="no" default="http://api.facebook.com/restserver.php" />
		<cfargument name="apiVersion" type="string" required="no" default="1.0" />
		<cfargument name="format" type="string" required="no" default="xml" />

		<cfset setApiKey( arguments.apiKey ) />
		<cfset setSecret( arguments.secret ) />
		<cfset setServer( arguments.server ) />
		<cfset setApiVersion( arguments.apiVersion ) />
		<cfset setFormat( arguments.format ) />

		<cfreturn this />
	</cffunction>
	
	<!--- accessors --->
	<cffunction name="setApiKey" access="public" output="false" returntype="void">
		<cfargument name="apiKey" type="string" required="yes" />
		<cfset variables._apiKey = arguments.apiKey />
	</cffunction>
	<cffunction name="getApiKey" access="public" output="false" returntype="string">
		<cfreturn variables._apiKey />
	</cffunction>
	
	<cffunction name="setSecret" access="public" output="false" returntype="void">
		<cfargument name="secret" type="string" required="yes" />
		<cfset variables._secret = arguments.secret />
	</cffunction>
	<cffunction name="getSecret" access="public" output="false" returntype="string">
		<cfreturn variables._secret />
	</cffunction>
	
	<cffunction name="setServer" access="public" output="false" returntype="void">
		<cfargument name="server" type="string" required="yes" />
		<cfset variables._server = arguments.server />
	</cffunction>
	<cffunction name="getServer" access="public" output="false" returntype="string">
		<cfreturn variables._server />
	</cffunction>

	<cffunction name="setApiVersion" access="public" output="false" returntype="void">
		<cfargument name="apiVersion" type="string" required="yes" />
		<cfset variables._apiVersion = arguments.apiVersion />
	</cffunction>
	<cffunction name="getApiVersion" access="public" output="false" returntype="string">
		<cfreturn variables._apiVersion />
	</cffunction>
	
	<cffunction name="setFormat" access="public" output="false" returntype="void">
		<cfargument name="format" type="string" required="yes" />
		<cfset variables._format = arguments.format />
	</cffunction>
	<cffunction name="getFormat" access="public" output="false" returntype="string">
		<cfreturn variables._format />
	</cffunction>
	
	<cffunction name="getUnixTimestamp" access="public" output="false" returntype="date">
		<cfif not StructKeyExists(variables, "_unixstart")>
			<cfset variables._unixstart = CreateDate(1970,1,1) />
		</cfif>
		<cfreturn variables._unixstart />
	</cffunction>
	
	<!--- authentication --->
	<cffunction name="auth_createToken" access="public" output="false" returntype="any">
		<cfthrow type="FacebookRestClient.MethodNotImplemented" 
				message="The method auth_createToken is not yet implemented." />
	</cffunction>
	
	<cffunction name="auth_getSession" access="public" output="false" returntype="any">
		<cfargument name="auth_token" type="string" required="yes" />
		<cfset var result = "" />
		<cfset var params = StructNew() />
		
		<cfset params["auth_token"] = arguments.auth_token />
		
		<cfset result = callMethod("facebook.auth.getSession", params) />
		<cfif getFormat() eq "xml">
			<cfset result = XmlToObject(result) />
		</cfif>
		
		<cfreturn result />
	</cffunction>

	<!--- fql --->
	<cffunction name="fql_query" access="public" output="false" returntype="any">
		<cfargument name="session_key" type="string" required="yes" />
		<cfargument name="query" type="string" required="yes" />
		<cfset var result = "" />
		<cfset var params = StructNew() />
		
		<cfset params["session_key"] = arguments.session_key />
		<cfset params["query"] = arguments.query />
		
		<cfset result = callMethod("facebook.fql.query", params) />
		<cfif getFormat() eq "xml">
			<cfset result = XmlToObject(result) />
		</cfif>
		
		<cfreturn result />
	</cffunction>

	<!--- events --->
	<cffunction name="events_get" access="public" output="false" returntype="any">
		<cfargument name="session_key" type="string" required="yes" />
		<cfargument name="uid" type="numeric" required="no" />
		<cfargument name="eids" type="string" required="no" />
		<cfargument name="start_time" type="any" required="no" />
		<cfargument name="end_time" type="any" required="no" />
		<cfargument name="rsvp_status" type="string" required="no" />
		<cfset var result = "" />
		<cfset var params = StructNew() />
		
		<cfset params["session_key"] = arguments.session_key />
		<cfif StructKeyExists(arguments, "uid")>
			<cfset params["uid"] = arguments.uid />
		</cfif>
		<cfif StructKeyExists(arguments, "eids")>
			<cfset params["eids"] = arguments.eids />
		</cfif>
		<cfif StructKeyExists(arguments, "start_time") and arguments.start_time neq 0>
			<cfset params["start_time"] = DateDiff("s", getUnixTimestamp(), arguments.start_time) />
		</cfif>
		<cfif StructKeyExists(arguments, "end_time") and arguments.end_time neq 0>
			<cfset params["end_time"] = DateDiff("s", getUnixTimestamp(), arguments.end_time) />
		</cfif>
		<cfif StructKeyExists(arguments, "rxvp_status")>
			<cfset params["rsvp_status"] = arguments.rsvp_status />
		</cfif>
		
		<cfset result = callMethod("facebook.events.get", params) />
		<cfif getFormat() eq "xml">
			<cfset result = XmlToArray(result) />
		</cfif>
		
		<cfreturn result />
	</cffunction>
	
	<cffunction name="events_getMembers" access="public" output="false" returntype="any">
		<cfargument name="session_key" type="string" required="yes" />
		<cfargument name="eid" type="numeric" required="yes" />
		<cfset var result = "" />
		<cfset var params = StructNew() />
		
		<cfset params["session_key"] = arguments.session_key />
		<cfset params["eid"] = arguments.eid />
		
		<cfset result = callMethod("facebook.events.getMembers", params) />
		<cfif getFormat() eq "xml">
			<cfset result = XmlToObject(result) />
		</cfif>
		
		<cfreturn result />
	</cffunction>

	<!--- friends --->
	<cffunction name="friends_areFriends" access="public" output="false" returntype="any">
		<cfargument name="session_key" type="string" required="yes" />
		<cfargument name="uids1" type="string" required="yes" />
		<cfargument name="uids2" type="string" required="yes" />
		<cfset var result = "" />
		<cfset var params = StructNew() />
		
		<cfset params["uids1"] = arguments.uids1 />
		<cfset params["uids2"] = arguments.uids2 />
		
		<cfset result = callMethod("facebook.friends.areFriends", params) />
		<cfif getFormat() eq "xml">
			<cfset result = XmlToArray(result) />
		</cfif>
		
		<cfreturn result />
	</cffunction>
	
	<cffunction name="friends_get" access="public" output="false" returntype="any">
		<cfargument name="session_key" type="string" required="yes" />
		<cfset var result = "" />
		<cfset var params = StructNew() />
		
		<cfset params["session_key"] = arguments.session_key />
		
		<cfset result = callMethod("facebook.friends.get", params) />
		<cfif getFormat() eq "xml">
			<cfset result = XmlToArray(result) />
		</cfif>
		
		<cfreturn result />
	</cffunction>
	
	<cffunction name="friends_getAppUsers" access="public" output="false" returntype="any">
		<cfargument name="session_key" type="string" required="yes" />
		<cfset var result = "" />
		<cfset var params = StructNew() />
		
		<cfset params["session_key"] = arguments.session_key />
		
		<cfset result = callMethod("facebook.friends.getAppUsers", params) />
		<cfif getFormat() eq "xml">
			<cfset result = XmlToArray(result) />
		</cfif>
		
		<cfreturn result />
	</cffunction>
	
	<!--- groups --->
	<cffunction name="groups_get" access="public" output="false" returntype="any">
		<cfargument name="session_key" type="string" required="yes" />
		<cfargument name="uid" type="numeric" required="no" />
		<cfargument name="gids" type="string" required="no" />
		<cfset var result = "" />
		<cfset var params = StructNew() />
		
		<cfset params["session_key"] = arguments.session_key />
		<cfif StructKeyExists(arguments, "uid")>
			<cfset params["uid"] = arguments.uid />
		</cfif>
		<cfif StructKeyExists(arguments, "gids")>
			<cfset params["gids"] = arguments.gids />
		</cfif>
		
		<cfset result = callMethod("facebook.groups.get", params) />
		<cfif getFormat() eq "xml">
			<cfset result = XmlToArray(result) />
		</cfif>
		
		<cfreturn result />
	</cffunction>
	
	<cffunction name="groups_getMembers" access="public" output="false" returntype="any">
		<cfargument name="session_key" type="string" required="yes" />
		<cfargument name="gid" type="string" required="yes" />
		<cfset var result = "" />
		<cfset var params = StructNew() />
		
		<cfset params["session_key"] = arguments.session_key />
		<cfset params["gid"] = arguments.gid />
		
		<cfset result = callMethod("facebook.groups.getMembers", params) />
		<cfif getFormat() eq "xml">
			<cfset result = XmlToObject(result) />
		</cfif>
		
		<cfreturn result />
	</cffunction>
	
	<!--- notifications --->
	<cffunction name="notifications_get" access="public" output="false" returntype="any">
		<cfargument name="session_key" type="string" required="yes" />
		<cfset var result = "" />
		<cfset var params = StructNew() />
		
		<cfset params["session_key"] = arguments.session_key />
		
		<cfset result = callMethod("facebook.notifications.get", params) />
		<cfif getFormat() eq "xml">
			<cfset result = XmlToObject(result) />
		</cfif>
		
		<cfreturn result />
	</cffunction>
	
	<cffunction name="notifications_send" access="public" output="false" returntype="any">
		<cfargument name="session_key" type="string" required="yes" />
		<cfargument name="to_ids" type="string" required="true" />
		<cfargument name="notification" type="string" required="true">
		<cfset var result = "" />
		<cfset var params = StructNew() />
		
		<cfset params["session_key"] = arguments.session_key />
		<cfset params["to_ids"] = arguments.to_ids />
		<cfset params["notification"] = arguments.notification />
		
		<cfset result = callMethod("facebook.notifications.send", params) />
		<cfif getFormat() eq "xml">
			<cfset result = XmlToObject(result) />
		</cfif>
		
		<cfreturn result />
	</cffunction>	
	
	<!--- publish actions --->
	<cffunction name="minifeed_publishToUser" access="public" output="false" returntype="any">
		<cfargument name="session_key" type="string" required="yes" />
		<cfargument name="title" type="string" required="true">
		<cfargument name="body" type="string" required="true">
		
		<cfset var result = "" />
		<cfset var params = StructNew() />
		<cfset var a_struct_template_data = {} />
		
		<cfset a_struct_template_data.artist = 'Massive Attack' />
		<cfset a_struct_template_data.images = ArrayNew(1) />
		<cfset a_struct_template_data.images[1] = { src = 'http://res.tunesbag.com/images/tunesbag-logo-140px.png', href = 'http://www.tunesBag.com/playlist-Massive+Attack' } />
		
		<cfset params["session_key"] = arguments.session_key />
		<cfset params["body"] = arguments.body />
		<cfset params["title"] = arguments.title />
		<cfset params['template_bundle_id'] = '53068971668' />
		<cfset params['template_data'] = SerializeJSON( a_struct_template_data ) />
		
		<cfset result = callMethod("facebook.Feed.publishUserAction", params) />
		<cfif getFormat() eq "xml">
			<cfset result = XmlToObject(result) />
		</cfif>
		
		<cfreturn result />
	</cffunction>
	
	<!--- photos --->
	<cffunction name="photos_addTag" access="public" output="false" returntype="any">
		<cfargument name="session_key" type="string" required="yes" />
		<cfargument name="pid" type="numeric" required="yes" />
		<cfargument name="tag_uid" type="numeric" required="yes" />
		<cfargument name="tag_text" type="string" required="yes" />
		<cfargument name="x" type="numeric" required="yes" />
		<cfargument name="y" type="numeric" required="yes" />
		<cfargument name="tags" type="string" required="no" />
		<cfset var result = "" />
		<cfset var params = StructNew() />
		
		<cfset params["session_key"] = arguments.session_key  />
		<cfset params["pid"] = arguments.pid  />
		<cfset params["tag_uid"] = arguments.tag_uid  />
		<cfset params["tag_text"] = arguments.tag_text  />
		<cfset params["x"] = arguments.x  />
		<cfset params["y"] = arguments.y  />
		
		<cfset result = callMethod("facebook.photos.addTag", params) />
		<cfif getFormat() eq "xml">
			<cfset result = XmlToObject(result) />
		</cfif>
		
		<cfreturn result />
	</cffunction>
	
	<cffunction name="photos_addTags" access="public" output="false" returntype="any">
		<cfargument name="session_key" type="string" required="yes" />
		<cfargument name="tags" type="string" required="yes" />
		<cfset var result = "" />
		<cfset var params = StructNew() />
		
		<cfset params["session_key"] = arguments.session_key  />
		<cfset params["tags"] = arguments.tags/>
		
		<cfset result = callMethod("facebook.photos.addTag", params) />
		<cfif getFormat() eq "xml">
			<cfset result = XmlToObject(result) />
		</cfif>
		
		<cfreturn result />
	</cffunction>
	
	<cffunction name="photos_createAlbum" access="public" output="false" returntype="any">
		<cfargument name="session_key" type="string" required="yes" />
		<cfargument name="name" type="string" required="yes" />
		<cfargument name="location" type="string" required="no" />
		<cfargument name="description" type="string" required="no" />
		<cfset var result = "" />
		<cfset var params = StructNew() />
		
		<cfset params["session_key"] = arguments.session_key  />
		<cfset params["name"] = arguments.name/>
		
		<cfif StructKeyExists(arguments, "location")>
			<cfset params["location"] = arguments.location />
		</cfif>
		<cfif StructKeyExists(arguments, "description")>
			<cfset params["description"] = arguments.description />
		</cfif>
		
		<cfset result = callMethod("facebook.photos.createAlbum", params) />
		<cfif getFormat() eq "xml">
			<cfset result = XmlToObject(result) />
		</cfif>
		
		<cfreturn result />
	</cffunction>

	<cffunction name="photos_get" access="public" output="false" returntype="any">
		<cfargument name="session_key" type="string" required="yes" />
		<cfargument name="subj_id" type="numeric" required="no" />
		<cfargument name="aid" type="numeric" required="no" />
		<cfargument name="pids" type="string" required="no" />
		<cfset var result = "" />
		<cfset var params = StructNew() />
		
		<cfset params["session_key"] = arguments.session_key  />
		<cfif StructKeyExists(arguments, "subj_id")>
			<cfset params["subj_id"] = arguments.subj_id />
		</cfif>
		<cfif StructKeyExists(arguments, "aid")>
			<cfset params["aid"] = arguments.aid />
		</cfif>
		<cfif StructKeyExists(arguments, "pids")>
			<cfset params["pids"] = arguments.pids />
		</cfif>
		
		<cfset result = callMethod("facebook.photos.get", params) />
		<cfif getFormat() eq "xml">
			<cfset result = XmlToArray(result) />
		</cfif>
		
		<cfreturn result />
	</cffunction>

	<cffunction name="photos_getAlbums" access="public" output="false" returntype="any">
		<cfargument name="session_key" type="string" required="yes" />
		<cfargument name="uid" type="numeric" required="no" />
		<cfargument name="pids" type="string" required="no" />
		<cfset var result = "" />
		<cfset var params = StructNew() />
		
		<cfset params["session_key"] = arguments.session_key  />
		<cfif StructKeyExists(arguments, "uid")>
			<cfset params["uid"] = arguments.uid />
		</cfif>
		<cfif StructKeyExists(arguments, "pids")>
			<cfset params["pids"] = arguments.pids />
		</cfif>
		
		<cfset result = callMethod("facebook.photos.getAlbums", params) />
		<cfif getFormat() eq "xml">
			<cfset result = XmlToArray(result) />
		</cfif>
		
		<cfreturn result />
	</cffunction>
	
	<cffunction name="photos_getTags" access="public" output="false" returntype="any">
		<cfargument name="session_key" type="string" required="yes" />
		<cfargument name="pids" type="string" required="yes" />
		<cfset var result = "" />
		<cfset var params = StructNew() />
		
		<cfset params["session_key"] = arguments.session_key  />
		<cfset params["pids"] = arguments.pids  />
		
		<cfset result = callMethod("facebook.photos.getTags", params) />
		<cfif getFormat() eq "xml">
			<cfset result = XmlToArray(result) />
		</cfif>
		
		<cfreturn result />
	</cffunction>

	<cffunction name="photos_upload" access="public" output="false" returntype="any">
		<cfargument name="session_key" type="string" required="yes" />
		<cfargument name="filepath" type="string" required="yes" />
		<cfargument name="aid" type="numeric" required="no" />
		<cfargument name="caption" type="string" required="no" />
		<cfset var result = "" />
		<cfset var params = StructNew() />
		
		<cfset params["session_key"] = arguments.session_key />
		
		<cfif StructKeyExists(arguments, "aid")>
			<cfset params["aid"] = arguments.aid />
		</cfif>
		<cfif StructKeyExists(arguments, "caption")>
			<cfset params["caption"] = arguments.caption />
		</cfif>
		
		<cfif not FileExists(arguments.filepath)>
			<cfset arguments.filepath = ExpandPath(arguments.filepath) />
			
			<cfif not FileExists(arguments.filepath)>
				<cfthrow type="FacebookRestClient.FileNotFound"
						 message="File #arguments.filepath# does not exists." />
			</cfif>
		</cfif>
		
		<cfset result = callMethod("facebook.photos.upload", params, arguments.filepath) />
		<cfif getFormat() eq "xml">
			<cfset result = XmlToObject(result) />
		</cfif>
		
		<cfreturn result />
	</cffunction>
	
	<!--- update --->
	<cffunction name="update_decodeIDs" access="public" output="false" returntype="any">
		<cfargument name="ids" type="string" required="yes" />
		<cfset var result = "" />
		<cfset var params = StructNew() />
		
		<cfset params["ids"] = arguments.ids />
		
		<cfset result = callMethod("facebook.update.decodeIDs", params) />
		<cfif getFormat() eq "xml">
			<cfset result = XmlToArray(result) />
		</cfif>
		
		<cfreturn result />
	</cffunction>
		
	<!--- users --->
	<cffunction name="users_getInfo" access="public" output="false" returntype="any">
		<cfargument name="session_key" type="string" required="yes" />
		<cfargument name="uids" type="string" required="yes" />
		<cfargument name="fields" type="string" required="no" />
		<cfset var result = "" />
		<cfset var params = StructNew() />
		
		<cfset params["session_key"] = arguments.session_key />
		<cfset params["uids"] = arguments.uids />
		
		<cfif StructKeyExists(arguments, "fields")>
			<cfset params["fields"] = arguments.fields />
		<cfelse>
			<!--- if no fields were passed in, get everything --->
			<cfset params["fields"] = "about_me,activities,affiliations,birthday,books,current_location,education_history,first_name,hometown_location,hs_info,interests,is_app_user,last_name,meeting_for,meeting_sex,movies,music,name,notes_count,pic,pic_big,pic_small,political,profile_update_time,quotes,relationship_status,religion,sex,significant_other_id,status,timezone,tv,wall_count,work_history" />
		</cfif>
		
		<cfset result = callMethod("facebook.users.getInfo", params) />
		<cfif getFormat() eq "xml">
			<cfset result = XmlToArray(result) />
		</cfif>
		
		<cfreturn result />
	</cffunction>
	
	<cffunction name="users_getLoggedInUser" access="public" output="false" returntype="any">
		<cfargument name="session_key" type="string" required="yes" />
		<cfset var result = "" />
		<cfset var params = StructNew() />
		
		<cfset params["session_key"] = arguments.session_key />
		
		<cfset result = callMethod("facebook.users.getLoggedInUser", params) />
		<cfif getFormat() eq "xml">
			<cfset result = XmlToObject(result) />
		</cfif>
		
		<cfreturn result />
	</cffunction>
	
	<!--- Private Methods --->
	<cffunction name="callMethod" access="public" output="false" returntype="any" 
		hint="I initialize and invoke the request method.  I act as an interface to the request method.">
		<cfargument name="method" type="string" required="yes" />
		<cfargument name="params" type="struct" required="no" default="#StructNew()#" />
		<cfargument name="filepath" type="string" required="no" />
		<cfset var result = StructNew() />

		<!--- add params to the param struct --->
		<cfset StructInsert(arguments.params, "method", arguments.method) />
		<cfset StructInsert(arguments.params, "api_key", getApiKey()) />
		<cfset StructInsert(arguments.params, "v", getApiVersion()) />
		<cfset StructInsert(arguments.params, "call_id", getTickCount()) />
		
		<!--- post the result, and clean up the XML --->
		<cfset result = postRequest(argumentCollection=arguments) />
		
		<cfif StructKeyExists(result, "error_code")>
			<cfthrow type="FacebookRestClient.#result.error_code#"
			         errorcode="#result.fb_error.code#" 
					 message="There was an error executing your request." 
					 detail="#result.error_msg#" />
		</cfif>

		<cfreturn result />
	</cffunction>

	<cffunction name="postRequest" access="private" output="false" hint="I make the actual facebook request.">
		<cfargument name="method" type="string" required="yes" />
		<cfargument name="params" type="struct" required="yes" />
		<cfargument name="filepath" type="string" required="no" />
		<cfset var key = "" />
		<cfset var cfhttp = 0 />

		<!--- 
		@TODO: Provide more clean-up (URLEncodedFormat doesn't seem to be working)
		<cfloop collection="#arguments.params#" item="key">
			<cfset arguments.params[key] = URLEncodedFormat(arguments.params[key]) />
		</cfloop> --->

		<!--- add the signature --->
		<cfset StructInsert(arguments.params, "sig", generateSignature(arguments.params)) />

		<cfhttp url="#getServer()#" method="post" charset="utf-8" redirect="no">
			<cfloop collection="#arguments.params#" item="key">
				<cfhttpparam name="#key#" value="#arguments.params[key]#" type="FORMFIELD" />
			</cfloop>
			<cfif StructKeyExists(arguments, "filepath") and FileExists(arguments.filepath)>
				<cfhttpparam type="file" name="file" file="#arguments.filepath#" />
			</cfif>
		</cfhttp>
		
		<cfreturn XmlParse(cfhttp.FileContent) />
	</cffunction>

	<cffunction name="generateSignature" access="private" output="true" returntype="string" 
		hint="I generate and return a key.">
		<cfargument name="params" required="yes" type="struct" />
		<cfset var buffer = CreateObject("java","java.lang.StringBuffer").init("") />
		<cfset var result = "" />
		<cfset var sortedKeys = getSortedKeyList(arguments.params) />
		<cfset var key = "" />

		<!--- add key=value to buffer --->
		<cfloop list="#sortedKeys#" index="key" delimiters=",">
			<cfset buffer.append(key & "=" & arguments.params[key]) />
		</cfloop>

		<!--- add the secret --->
		<cfset buffer.append( getSecret() ) />
		
		<!--- hash buffer --->
		<cfset result = hash(buffer.toString()) />
		
		<cfreturn LCase(result) />
	</cffunction>
	
	<cffunction name="getSortedKeyList" access="private" output="false" returntype="string" 
		hint="I return a list of sorted params.">
		<cfargument name="params" required="yes" type="struct" />
		<cfset var keys = StructKeyList(arguments.params,",") />
		<cfset var sortedKeys = ListSort(keys, "textnocase", "Asc", ",") />
		<cfreturn sortedKeys />
	</cffunction>

	<!---
	Inspired by Artur Kordowski's DataTypeConvert.cfc (XmlToStruct method) (nfo@newsight.de) 
	Modified to offer more accurate results from the facebook API --->
	<cffunction name="XmlToObject" access="public" output="true" returntype="any" 
		hint="Converts the given XML document to a ColdFusion object.">
		<cfargument name="xmlObj" required="yes" type="any" />
		<cfset var result    = StructNew() />
		<cfset var xmlData   = arguments.xmlObj />
		<cfset var childLen  = "" />
		<cfset var childList = "" />
		<cfset var data      = "" />
		<cfset var i         = 0 />

		<cfif StructKeyExists(xmlData, "xmlRoot")>
			<cfset result = XmlToObject(xmlData.xmlRoot) />
		<cfelse>
			<cfset childLen = ArrayLen(xmlData.xmlChildren) />
			<cfset childList = StructKeyList(xmlData, ",") />

			<cfif childLen gt 1 and ListValueCount( childList, xmlData.xmlChildren[1].xmlName, ",") eq childLen>
				<cfset result = XmlToArray(xmlData) />
			<cfelse>
				<!--- otherwise we are dealing with a structure --->
				<cfloop from="1" to="#childLen#" index="i">
					<cfset data = xmlData.xmlChildren[i] />

					<cfif ArrayLen(data.xmlChildren) gt 1>
						<cfset result[LCase(data.xmlName)] = XmlToObject(data) />
					<cfelse>
						<cfset result[LCase(data.xmlName)] = data.xmlText />
					</cfif>
				</cfloop>
			</cfif>
		</cfif>

		<cfreturn result />
	</cffunction>
	
	<!--- fbml --->
   <cffunction name="fbml_setFBML" access="public" output="false" returntype="any">
      <cfargument name="fbml" type="string" required="yes" />
      <cfargument name="sess_key" type="string" required="yes" />

      <cfset var result = "" />
      <cfset var params = StructNew() />

      <cfset params["markup"] = arguments.fbml/>
      <cfset params["session_key"] = arguments.sess_key/>      

      <cfset result = callMethod("facebook.profile.setFBML", params) />

      <cfreturn result />
   </cffunction>

   <cffunction name="fbml_getFBML" access="public" output="false" returntype="any">
      <cfargument name="sess_key" type="string" required="yes" />
      <cfargument name="uid" type="string" required="yes" />

      <cfset var result = "" />
      <cfset var params = StructNew() />
      
      <cfset params["uid"] = arguments.uid />
      <cfset params["session_key"] = arguments.sess_key />
      
      <cfset result = callMethod("facebook.profile.getFBML", params) />

      <cfreturn result />
   </cffunction>	
	
	<!--- This method will force the first group to be an array --->
	<cffunction name="XmlToArray" access="public" output="false" returntype="array" 
		hint="I take an xml object and always return an array.  Using this method will 
		ensure the results are parsed as an array.">
		<cfargument name="xmlObj" required="yes" type="any" />
		<cfset var result    = ArrayNew(1) />
		<cfset var xmlData   = arguments.xmlObj />
		<cfset var childLen  = 0 />
		<cfset var childList = 0 />
		<cfset var data      = "" />
		<cfset var i         = 0 />
		
		<cfif StructKeyExists(xmlData, "xmlRoot")>
			<cfset result = XmlToArray(xmlData.xmlRoot) />
		<cfelse>
			<cfset childLen = ArrayLen(xmlData.xmlChildren) />
			<cfset childList = StructKeyList(xmlData, ",") />
			
			<cfloop from="1" to="#childLen#" index="i">
				<cfset data = xmlData.xmlChildren[i] />
				
				<cfif ArrayLen(data.xmlChildren) gt 1>
					<cfset ArrayAppend( result, XmlToObject(data) ) />
				<cfelse>
					<cfset ArrayAppend( result, Trim(data.xmlText) ) />
				</cfif>
			</cfloop>
		</cfif>
		
		<cfreturn result />
	</cffunction>

</cfcomponent>
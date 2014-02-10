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

<cfcomponent extends="CFlickr.AbstractObject">

	<cfscript>
	variables.id = "";
	variables.username = "";
	variables.admin = false;;
	variables.pro = false;
	variables.iconServer = 0;
	variables.realName = "";
	variables.location = "";
	variables.photosFirstDate = createdatetime(1970, 01, 01, 0, 0, 0);
	variables.photosFirstDateTaken = createdatetime(1970, 01, 01, 0, 0, 0);
	variables.photosCount = 0;
	variables.bandwidthMax = 0;
	variables.bandwidthUsed = 0;
	variables.filesizeMax = 0;
	variables.mbox_sha1sum = "";
	</cfscript>	

	<cffunction name="getId" access="public" output="false" returntype="string">
		<cfreturn variables.id>
	</cffunction>
	<cffunction name="setId" access="public" output="false" returntype="void">
		<cfargument name="id" type="string" required="yes">
		<cfset variables.id = arguments.id>
	</cffunction>
	
	<cffunction name="getUsername" access="public" output="false" returntype="string">
		<cfreturn variables.username>
	</cffunction>
	<cffunction name="setUsername" access="public" output="false" returntype="void">
		<cfargument name="username" type="string" required="yes">
		<cfset variables.username = arguments.username>
	</cffunction>
	
	<cffunction name="getAdmin" access="public" output="false" returntype="boolean">
		<cfreturn variables.admin>
	</cffunction>
	<cffunction name="setAdmin" access="public" output="false" returntype="void">
		<cfargument name="admin" type="boolean" required="yes">
		<cfset variables.admin = arguments.admin>
	</cffunction>
	
	<cffunction name="getPro" access="public" output="false" returntype="boolean">
		<cfreturn variables.pro>
	</cffunction>
	<cffunction name="setPro" access="public" output="false" returntype="void">
		<cfargument name="pro" type="boolean" required="yes">
		<cfset variables.pro = arguments.pro>
	</cffunction>
	
	<cffunction name="getIconServer" access="public" output="false" returntype="numeric">
		<cfreturn variables.iconserver>
	</cffunction>
	<cffunction name="setIconServer" access="public" output="false" returntype="void">
		<cfargument name="iconserver" type="numeric" required="yes">
		<cfset variables.iconserver = arguments.iconserver>
	</cffunction>
	
	<cffunction name="getRealName" access="public" output="false" returntype="string">
		<cfreturn variables.realname>
	</cffunction>
	<cffunction name="setRealName" access="public" output="false" returntype="void">
		<cfargument name="realname" type="string" required="yes">
		<cfset variables.realname = arguments.realname>
	</cffunction>
	
	<cffunction name="getLocation" access="public" output="false" returntype="string">
		<cfreturn variables.location>
	</cffunction>
	<cffunction name="setLocation" access="public" output="false" returntype="void">
		<cfargument name="location" type="string" required="yes">
		<cfset variables.location = arguments.location>
	</cffunction>
	
	<cffunction name="getPhotosFirstDate" access="public" output="false" returntype="date">
		<cfreturn variables.photosFirstDate>
	</cffunction>
	<cffunction name="setPhotosFirstDate" access="public" output="false" returntype="void">
		<cfargument name="photosFirstDate" type="date" required="yes">
		<cfif isnumeric(arguments.photosFirstDate)>
			<cfset arguments.photosFirstDate = DateAdd("s", arguments.photosFirstDate, createdate(1970,1,1))>
		</cfif>
		<cfset variables.photosFirstDate = arguments.photosFirstDate>
	</cffunction>
	
	<cffunction name="getPhotosFirstDateTaken" access="public" output="false" returntype="date">
		<cfreturn variables.photosFirstDateTaken>
	</cffunction>
	<cffunction name="setPhotosFirstDateTaken" access="public" output="false" returntype="void">
		<cfargument name="photosFirstDateTaken" type="date" required="yes">
		<cfset variables.photosFirstDateTaken = arguments.photosFirstDateTaken>
	</cffunction>
	
	<cffunction name="getPhotosCount" access="public" output="false" returntype="numeric">
		<cfreturn variables.PhotosCount>
	</cffunction>
	<cffunction name="setPhotosCount" access="public" output="false" returntype="void">
		<cfargument name="PhotosCount" type="numeric" required="yes">
		<cfset variables.PhotosCount = arguments.PhotosCount>
	</cffunction>
	
	<cffunction name="getMboxSha1sum" access="public" output="false" returntype="string">
		<cfreturn variables.mbox_sha1sum>
	</cffunction>
	<cffunction name="setMboxSha1sum" access="public" output="false" returntype="void">
		<cfargument name="mbox_sha1sum" type="string" required="yes">
		<cfset variables.mbox_sha1sum = arguments.mbox_sha1sum>
	</cffunction>
	
	<cffunction name="getBandwidthMax" access="public" output="false" returntype="numeric">
		<cfreturn variables.bandwidthMax>
	</cffunction>
	<cffunction name="setBandwidthMax" access="public" output="false" returntype="void">
		<cfargument name="bandwidthMax" type="numeric" required="yes">
		<cfset variables.bandwidthMax = arguments.bandwidthMax>
	</cffunction>
	
	<cffunction name="getBandwidthUsed" access="public" output="false" returntype="numeric">
		<cfreturn variables.bandwidthUsed>
	</cffunction>
	<cffunction name="setBandwidthUsed" access="public" output="false" returntype="void">
		<cfargument name="bandwidthUsed" type="numeric" required="yes">
		<cfset variables.bandwidthUsed = arguments.bandwidthUsed>
	</cffunction>
	
	<cffunction name="getFileSizeMax" access="public" output="false" returntype="numeric">
		<cfreturn variables.filesizeMax>
	</cffunction>
	<cffunction name="setFileSizeMax" access="public" output="false" returntype="void">
		<cfargument name="filesizeMax" type="numeric" required="yes">
		<cfset variables.filesizeMax = arguments.filesizeMax>
	</cffunction>
		
	<cffunction name="getIconUrl" access="public" output="false" returntype="string">
		<cfreturn "http://static.flickr.com/#getIconServer()#/buddyicons/#getId()#.jpg">
	</cffunction>
	
	<cffunction name="parseXmlElement" access="public" output="true" returntype="CFlickr.people.User">
		<cfargument name="xmlnode" type="any" required="yes" hint="An XML 'user' or 'person' node from the Flickr rest service">
		<cfset var tmp = "">
		
		<cfscript>
		if(structkeyexists(xmlnode.XmlAttributes, 'id')) setId(xmlnode.XmlAttributes.id);
		else if(structkeyexists(xmlnode.XmlAttributes, 'nsid')) setId(xmlnode.XmlAttributes.nsid);

		if(structkeyexists(xmlnode.XmlAttributes, 'isadmin')) setAdmin(xmlnode.XmlAttributes.isadmin);
		if(structkeyexists(xmlnode.XmlAttributes, 'ispro')) setPro(xmlnode.XmlAttributes.ispro);
		if(structkeyexists(xmlnode.XmlAttributes, 'iconserver')) setIconServer(xmlnode.XmlAttributes.iconserver);

		// username		
		tmp = xmlsearch(xmlnode, 'username');
		if(arraylen(tmp)) setUserName(tmp[1].xmltext);
		
		// realname
		tmp = xmlsearch(xmlnode, 'realname');
		if(arraylen(tmp)) setRealName(tmp[1].xmltext);
		
		// mbox_sha1sum
		tmp = xmlsearch(xmlnode, 'mbox_sha1sum');
		if(arraylen(tmp)) setMboxSha1sum(tmp[1].xmltext);
		
		// location
		tmp = xmlsearch(xmlnode, 'location');
		if(arraylen(tmp)) setLocation(tmp[1].xmltext);
		
		// firstdate
		tmp = xmlsearch(xmlnode, 'photos/firstdate');
		if(arraylen(tmp) AND len(tmp[1].xmltext)) setPhotosFirstDate(tmp[1].xmltext);
		
		// firstdatetaken
		tmp = xmlsearch(xmlnode, 'photos/firstdatetaken');
		if(arraylen(tmp) AND len(tmp[1].xmltext) AND IsDate(tmp[1].xmltext)) setPhotosFirstDateTaken(tmp[1].xmltext);
		
		// photo count
		tmp = xmlsearch(xmlnode, 'photos/count');
		if(arraylen(tmp)) setPhotosCount(tmp[1].xmltext);
		
		// bandwidth
		tmp = xmlsearch(xmlnode, 'bandwidth');
		if(arraylen(tmp)) {
			if(structkeyexists(tmp[1].xmlattributes, 'max')) setBandwidthMax(tmp[1].xmlattributes.max);
			if(structkeyexists(tmp[1].xmlattributes, 'used')) setBandwidthUsed(tmp[1].xmlattributes.used);
		}

		// filesize
		tmp = xmlsearch(xmlnode, 'filesize');
		if(arraylen(tmp)) {
			if(structkeyexists(tmp[1].xmlattributes, 'max')) setFileSizeMax(tmp[1].xmlattributes.max);
		}

		return this;
		</cfscript>
	</cffunction>
	
</cfcomponent>
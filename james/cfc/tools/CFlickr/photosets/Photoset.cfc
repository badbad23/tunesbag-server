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

<cfcomponent extends="CFlickr.photos.PhotoList">

	<cfscript>
	variables.id = "";
	variables.secret = "";
	variables.owner = "";
	variables.primaryPhoto = createobject("component", "CFlickr.photos.Photo");
//	variables.photocount = 0;
	variables.title = "";
	variables.description = "";
	variables.url = "";
//	variables.photos = arraynew(1);
	</cfscript>

	<cffunction name="getId" access="public" output="false" returntype="string">
		<cfreturn variables.id />
	</cffunction>
	<cffunction name="setId" access="public" output="false" returntype="void">
		<cfargument name="id" type="string" required="yes">
		<cfset variables.id = arguments.id >
	</cffunction>

	<cffunction name="getOwnerId" access="public" output="false" returntype="string">
		<cfreturn variables.owner />
	</cffunction>
	<cffunction name="setOwnerId" access="public" output="false" returntype="void">
		<cfargument name="owner" type="string" required="yes">
		<cfset variables.owner = arguments.owner >
	</cffunction>

	<cffunction name="getPrimaryPhoto" access="public" output="false" returntype="CFlickr.photos.Photo">
		<cfreturn variables.primaryPhoto />
	</cffunction>
	<cffunction name="setPrimaryPhoto" access="public" output="false" returntype="void">
		<cfargument name="primaryPhoto" type="CFlickr.photos.Photo" required="yes">
		<cfset variables.primaryPhoto = arguments.primaryPhoto >
	</cffunction>

	<cffunction name="getPhotoCount" access="public" output="false" returntype="numeric">
		<cfreturn getTotal() />
	</cffunction>
	<cffunction name="setPhotoCount" access="public" output="false" returntype="void">
		<cfargument name="photocount" type="numeric" required="yes">
		<cfset setTotal(arguments.photocount) >
	</cffunction>

	<cffunction name="getTitle" access="public" output="false" returntype="string">
		<cfreturn variables.title />
	</cffunction>
	<cffunction name="setTitle" access="public" output="false" returntype="void">
		<cfargument name="title" type="string" required="yes">
		<cfset variables.title = arguments.title >
	</cffunction>

	<cffunction name="getDescription" access="public" output="false" returntype="string">
		<cfreturn variables.description />
	</cffunction>
	<cffunction name="setDescription" access="public" output="false" returntype="void">
		<cfargument name="description" type="string" required="yes">
		<cfset variables.description = arguments.description >
	</cffunction>
	
	<cffunction name="getUrl" access="public" output="false" returntype="string">
		<cfreturn variables.url />
	</cffunction>
	<cffunction name="setUrl" access="public" output="false" returntype="void">
		<cfargument name="url" type="string" required="yes">
		<cfset variables.url = arguments.url >
	</cffunction>

<!---	
	<!--- These methods only add/remove photos from the object, not on Flickr --->
	<cffunction name="getPhotos" access="public" output="false" returntype="array">
		<cfreturn getItems()/>
	</cffunction>
	<cffunction name="setPhotos" access="public" output="false" returntype="void">
		<cfargument name="photos" type="array" required="yes">
		<cfset setItems(arguments.photos)>
		<cfset variables.photocount = arraylen(variables.photos)>
	</cffunction>
	<cffunction name="addPhoto" access="public" output="false" returntype="void" >
		<cfargument name="photo" type="CFlickr.photos.Photo" required="yes">
		<cfset addItems(photo)>
		<cfset variables.photocount = arraylen(variables.photos)>
	</cffunction>
	<cffunction name="removePhoto" access="public" output="false" returntype="CFlickr.photos.Photo"> 
		<cfargument name="position" type="numeric" required="yes">
		<cfreturn removeItem(arguments.position)>
	</cffunction>	
--->

 	<cffunction name="parseXmlElement" access="public" output="false" returntype="CFlickr.photosets.Photoset">
		<cfargument name="xmlnode" type="any" required="yes" hint="must be an xml element of type 'photoset'">
		<cfscript>
		var tmp = "";
		var p = "";
		var i = 0;

		super.parseXmlElement(xmlnode);
		
		if(structkeyexists(xmlnode.xmlattributes, 'id')) setId(xmlnode.xmlattributes.id);
		if(structkeyexists(xmlnode.xmlattributes, 'photos')) setPhotoCount(xmlnode.xmlattributes.photos);
		if(structkeyexists(xmlnode.xmlattributes, 'title')) setTitle(xmlnode.xmlattributes.title);
		// primary photo
		if(structkeyexists(xmlnode.xmlattributes, 'primary')) getPrimaryPhoto().setId(xmlnode.xmlattributes.primary);
		if(structkeyexists(xmlnode.xmlattributes, 'server')) getPrimaryPhoto().setServer(xmlnode.xmlattributes.server);
		if(structkeyexists(xmlnode.xmlattributes, 'secret')) getPrimaryPhoto().setSecret(xmlnode.xmlattributes.secret);
		// title
		tmp = xmlsearch(xmlnode, 'title');
		if(arraylen(tmp)) setTitle(tmp[1].xmltext);
		// description
		tmp = xmlsearch(xmlnode, 'description');
		if(arraylen(tmp)) setDescription(tmp[1].xmltext);
/*
		// photo child elements are now parsed out by PhotoList
		tmp = xmlsearch(xmlnode, 'photo');
		for(i=1; i LTE arraylen(tmp); i=i+1) {
			p = createobject("component", "CFlickr.photos.Photo");
			p = p.parseXmlElement(tmp[i]);
			addPhoto(p);  // add the photo to the set
			if(structkeyexists(tmp[i].xmlattributes, 'isprimary') AND tmp[i].xmlattributes.isprimary) setPrimaryPhoto(p);  // if this is the primary photo, then set it
		}
*/
		return this;
		</cfscript>
	</cffunction>	


</cfcomponent>
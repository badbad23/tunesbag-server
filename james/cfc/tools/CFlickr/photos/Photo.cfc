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
	variables.owner = createobject("component", "CFlickr.people.User");
	variables.secret = "";
	variables.server = "";
	variables.farm = "1";
	variables.originalformat = "jpg";
	variables.originalsecret = "";	
	variables.favorite = false;
	variables.license = "";
	variables.primary = false;
	variables.title = "";
	variables.description = "";
	variables.isPublic = false;
	variables.isFriend = false;
	variables.isFamily = false;
	variables.datePosted = createdate(1970,1,1);
	variables.dateTaken = createdate(1970,1,1);
	variables.lastUpdate = createdate(1970,1,1);
	variables.takenGranularity = 0;
	variables.canaddmeta = 0;
	variables.cancomment = 0;
	variables.commentCount = 0;
	variables.notes = arraynew(1);
	variables.tags = arraynew(1);
	variables.urls = arraynew(1);
	variables.exif = arraynew(1);
	variables.events = arraynew(1);
	
	// valid photo sizes
	this.size_original = "_o";
	this.size_small_square = "_s";
	this.size_small = "_m";
	this.size_thumbnail = "_t";
	this.size_medium = "";
	this.size_large = "_b";
	</cfscript>
	
	<!--- size strings must be one of the this.size_xxxxx attributes --->
	<cffunction name="getPhotoUrl" access="public" output="false" returntype="string">
		<cfargument name="size" type="string" required="no" default="#this.size_medium#">
		<cfset var format = "jpg">
		<cfset var secret = getSecret()>
		<cfif arguments.size EQ this.size_original>
			<cfset format = getOriginalFormat()>
			<cfset secret = getOriginalSecret()>
		</cfif>
		<cfreturn "http://farm#getFarm()#.static.flickr.com/#getServer()#/#getId()#_#secret##arguments.size#.#format#">
	</cffunction>
	
	<cffunction name="getId" access="public" output="false" returntype="string">
		<cfreturn variables.id />
	</cffunction>
	<cffunction name="setId" access="public" output="false" returntype="void">
		<cfargument name="id" type="string" required="yes">
		<cfset variables.id = arguments.id >
	</cffunction>

	<cffunction name="getOwner" access="public" output="false" returntype="CFlickr.people.User">
		<cfreturn variables.owner />
	</cffunction>
	<cffunction name="setOwner" access="public" output="false" returntype="void">
		<cfargument name="owner" type="CFlickr.people.User" required="yes">
		<cfset variables.owner = arguments.owner >
	</cffunction>

	<cffunction name="getSecret" access="public" output="false" returntype="string">
		<cfreturn variables.secret />
	</cffunction>
	<cffunction name="setSecret" access="public" output="false" returntype="void">
		<cfargument name="secret" type="string" required="yes">
		<cfset variables.secret = arguments.secret >
	</cffunction>
	
	<cffunction name="getServer" access="public" output="false" returntype="string">
		<cfreturn variables.Server />
	</cffunction>
	<cffunction name="setServer" access="public" output="false" returntype="void">
		<cfargument name="Server" type="string" required="yes">
		<cfset variables.Server = arguments.Server >
	</cffunction>

	<cffunction name="getFarm" access="public" output="false" returntype="string">
		<cfreturn variables.farm />
	</cffunction>
	<cffunction name="setFarm" access="public" output="false" returntype="void">
		<cfargument name="farm" type="string" required="yes">
		<cfset variables.farm = arguments.farm >
	</cffunction>
	
	<cffunction name="getOriginalSecret" access="public" output="false" returntype="string">
		<cfreturn variables.OriginalSecret />
	</cffunction>
	<cffunction name="setOriginalSecret" access="public" output="false" returntype="void">
		<cfargument name="OriginalSecret" type="string" required="yes">
		<cfset variables.OriginalSecret = arguments.OriginalSecret >
	</cffunction>

	<cffunction name="getOriginalFormat" access="public" output="false" returntype="string">
		<cfreturn variables.OriginalFormat />
	</cffunction>
	<cffunction name="setOriginalFormat" access="public" output="false" returntype="void">
		<cfargument name="OriginalFormat" type="string" required="yes">
		<cfset variables.OriginalFormat = arguments.OriginalFormat >
	</cffunction>
	
	<cffunction name="getFavorite" access="public" output="false" returntype="boolean">
		<cfreturn variables.favorite />
	</cffunction>
	<cffunction name="setFavorite" access="public" output="false" returntype="void">
		<cfargument name="favorite" type="boolean" required="yes">
		<cfset variables.favorite = arguments.favorite >
	</cffunction>

	<cffunction name="getLicense" access="public" output="false" returntype="string">
		<cfreturn variables.license />
	</cffunction>
	<cffunction name="setLicense" access="public" output="false" returntype="void">
		<cfargument name="license" type="string" required="yes">
		<cfset variables.license = arguments.license >
	</cffunction>

	<cffunction name="getPrimary" access="public" output="false" returntype="boolean">
		<cfreturn variables.primary />
	</cffunction>
	<cffunction name="setPrimary" access="public" output="false" returntype="void">
		<cfargument name="primary" type="boolean" required="yes">
		<cfset variables.primary = arguments.primary >
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

	<cffunction name="getIsPublic" access="public" output="false" returntype="boolean">
		<cfreturn variables.isPublic />
	</cffunction>
	<cffunction name="setIsPublic" access="public" output="false" returntype="void">
		<cfargument name="isPublic" type="boolean" required="yes">
		<cfset variables.isPublic = arguments.isPublic >
	</cffunction>

	<cffunction name="getIsFriend" access="public" output="false" returntype="boolean">
		<cfreturn variables.isFriend />
	</cffunction>
	<cffunction name="setIsFriend" access="public" output="false" returntype="void">
		<cfargument name="isFriend" type="boolean" required="yes">
		<cfset variables.isFriend = arguments.isFriend >
	</cffunction>

	<cffunction name="getIsFamily" access="public" output="false" returntype="boolean">
		<cfreturn variables.isFamily />
	</cffunction>
	<cffunction name="setIsFamily" access="public" output="false" returntype="void">
		<cfargument name="isFamily" type="boolean" required="yes">
		<cfset variables.isFamily = arguments.isFamily >
	</cffunction>

	<cffunction name="getDatePosted" access="public" output="false" returntype="date">
		<cfreturn variables.datePosted />
	</cffunction>
	<cffunction name="setDatePosted" access="public" output="false" returntype="void">
		<cfargument name="datePosted" type="date" required="yes">
		<cfif isnumeric(arguments.datePosted)>
			<cfset arguments.datePosted = DateAdd("s", arguments.datePosted, createdate(1970,1,1))>
		</cfif>		
		<cfset variables.datePosted = arguments.datePosted >
	</cffunction>

	<cffunction name="getDateTaken" access="public" output="false" returntype="date">
		<cfreturn variables.dateTaken />
	</cffunction>
	<cffunction name="setDateTaken" access="public" output="false" returntype="void">
		<cfargument name="dateTaken" type="date" required="yes">
		<cfset variables.dateTaken = arguments.dateTaken >
	</cffunction>

	<cffunction name="getLastUpdate" access="public" output="false" returntype="date">
		<cfreturn variables.lastUpdate />
	</cffunction>
	<cffunction name="setLastUpdate" access="public" output="false" returntype="void">
		<cfargument name="lastUpdate" type="date" required="yes">
		<cfif isnumeric(lastUpdate)>
			<cfset lastUpdate = DateAdd("s", lastUpdate, createdate(1970,1,1))>
		</cfif>		
		<cfset variables.lastUpdate = arguments.lastUpdate >
	</cffunction>

	<cffunction name="getTakenGranularity" access="public" output="false" returntype="numeric">
		<cfreturn variables.takenGranularity />
	</cffunction>
	<cffunction name="setTakenGranularity" access="public" output="false" returntype="void">
		<cfargument name="takenGranularity" type="numeric" required="yes">
		<cfset variables.takenGranularity = arguments.takenGranularity >
	</cffunction>

	<cffunction name="getCanAddMeta" access="public" output="false" returntype="numeric">
		<cfreturn variables.canaddmeta />
	</cffunction>
	<cffunction name="setCanAddMeta" access="public" output="false" returntype="void">
		<cfargument name="canaddmeta" type="numeric" required="yes">
		<cfset variables.canaddmeta = arguments.canaddmeta >
	</cffunction>

	<cffunction name="getCanComment" access="public" output="false" returntype="numeric">
		<cfreturn variables.cancomment />
	</cffunction>
	<cffunction name="setCanComment" access="public" output="false" returntype="void">
		<cfargument name="cancomment" type="numeric" required="yes">
		<cfset variables.cancomment = arguments.cancomment >
	</cffunction>

	<cffunction name="getCommentCount" access="public" output="false" returntype="numeric">
		<cfreturn variables.commentCount />
	</cffunction>
	<cffunction name="setCommentCount" access="public" output="false" returntype="void">
		<cfargument name="commentCount" type="numeric" required="yes">
		<cfset variables.commentCount = arguments.commentCount >
	</cffunction>

	<cffunction name="getNotes" access="public" output="false" returntype="array">
		<cfreturn variables.notes />
	</cffunction>
	<cffunction name="setNotes" access="public" output="false" returntype="void">
		<cfargument name="notes" type="array" required="yes">
		<cfset variables.notes = arguments.notes >
	</cffunction>
	<cffunction name="_addNote" access="private" output="false" returntype="void">
		<cfargument name="note" type="CFlickr.photos.notes.Note" required="yes">
		<cfset arrayappend(variables.notes, arguments.note)>
	</cffunction>
	<cffunction name="_removeNote" access="private" output="false" returntype="CFlickr.photos.notes.Note">
		<cfargument name="position" type="numeric" required="yes">
		<cfset var tmp = "">
		<cfif arraylen(variables.notes) GTE arguments.poisiton>
			<cfset tmp = variables.notes[arguments.poisiton]>
			<cfset arraydeleteat(variables.notes, arguments.poisiton)>
		</cfif>
		<cfreturn tmp>
	</cffunction>

	<cffunction name="getTags" access="public" output="false" returntype="array">
		<cfreturn variables.tags />
	</cffunction>
	<cffunction name="setTags" access="public" output="false" returntype="void">
		<cfargument name="tags" type="array" required="yes">
		<cfset variables.tags = arguments.tags >
	</cffunction>
	<cffunction name="_addTag" access="private" output="false" returntype="void">
		<cfargument name="tag" type="CFlickr.tags.Tag" required="yes">
		<cfset arrayappend(variables.tags, arguments.tag)>
	</cffunction>
	<cffunction name="_removeTag" access="private" output="false" returntype="CFlickr.tags.Tag">
		<cfargument name="position" type="numeric" required="yes">
		<cfset var tmp = "">
		<cfif arraylen(variables.tags) GTE arguments.poisiton>
			<cfset tmp = variables.tags[arguments.poisiton]>
			<cfset arraydeleteat(variables.tags, arguments.poisiton)>
		</cfif>
		<cfreturn tmp>
	</cffunction>


	<cffunction name="getUrls" access="public" output="false" returntype="array">
		<cfargument name="type" type="string" required="no">
		<cfset var i = 0>
		<cfset var ret = 0>
		<cfif structkeyexists(arguments, "type")>
			<cfset ret = arraynew(1)>
			<cfloop from="1" to="#arraylen(variables.urls)#" index="i">
				<cfif lcase(variables.urls[i].getType()) EQ lcase(arguments.type)>
					<cfset arrayappend(ret, variables.urls[i])>
				</cfif>
			</cfloop>
			<cfreturn ret />
		<cfelse>
			<cfreturn variables.urls />
		</cfif>
	</cffunction>
	<cffunction name="setUrls" access="public" output="false" returntype="void">
		<cfargument name="urls" type="array" required="yes">
		<cfset variables.urls = arguments.urls >
	</cffunction>
	<cffunction name="_addUrl" access="private" output="false" returntype="void">
		<cfargument name="photourl" type="CFlickr.photos.PhotoUrl" required="yes">
		<cfset arrayappend(variables.urls, arguments.photourl)>
	</cffunction>
	<cffunction name="_removeUrl" access="private" output="false" returntype="CFlickr.photos.PhotoUrl">
		<cfargument name="position" type="numeric" required="yes">
		<cfset var tmp = "">
		<cfif arraylen(variables.urls) GTE arguments.poisiton>
			<cfset tmp = variables.urls[arguments.poisiton]>
			<cfset arraydeleteat(variables.urls, arguments.poisiton)>
		</cfif>
		<cfreturn tmp>
	</cffunction>
	
	<cffunction name="getExif" access="public" output="false" returntype="array">
		<cfreturn variables.exif />
	</cffunction>
	<cffunction name="setExif" access="public" output="false" returntype="void">
		<cfargument name="exif" type="array" required="yes">
		<cfset variables.exif = arguments.exif >
	</cffunction>
	<cffunction name="_addExif" access="private" output="false" returntype="void">
		<cfargument name="exif" type="CFlickr.photos.Exif" required="yes">
		<cfset arrayappend(variables.exif, arguments.exif)>
	</cffunction>
	<cffunction name="_removeExif" access="private" output="false" returntype="CFlickr.photos.Exif">
		<cfargument name="position" type="numeric" required="yes">
		<cfset var tmp = "">
		<cfif arraylen(variables.exif) GTE arguments.poisiton>
			<cfset tmp = variables.exif[arguments.poisiton]>
			<cfset arraydeleteat(variables.exif, arguments.poisiton)>
		</cfif>
		<cfreturn tmp>
	</cffunction>
	
	<cffunction name="getEvents" access="public" output="false" returntype="array">
		<cfreturn variables.events />
	</cffunction>
	<cffunction name="setEvents" access="public" output="false" returntype="void">
		<cfargument name="activity" type="array" required="yes">
		<cfset variables.events = arguments.events >
	</cffunction>
	<cffunction name="_addEvent" access="private" output="false" returntype="void">
		<cfargument name="event" type="Any" required="yes">
		<cfset arrayappend(variables.events, arguments.event)>
	</cffunction>
	<cffunction name="_removeEvent" access="private" output="false" returntype="Any">
		<cfargument name="position" type="numeric" required="yes">
		<cfset var tmp = "">
		<cfif arraylen(variables.events) GTE arguments.poisiton>
			<cfset tmp = variables.events[arguments.poisiton]>
			<cfset arraydeleteat(variables.events, arguments.poisiton)>
		</cfif>
		<cfreturn tmp>
	</cffunction>
			
	<cffunction name="parseXmlElement" access="public" output="true" returntype="CFlickr.photos.Photo">
		<cfargument name="xmlnode" type="any" required="yes" hint="An XML photo node from the Flickr rest service">

		<cfscript>
		var tmp = "";
		var i = 0;
		var t = "";
		
		// ATTRIBUTES
		// check to see if any of these are stored as attributes first
		if(structkeyexists(xmlnode.XmlAttributes, 'id')) setId(xmlnode.XmlAttributes.id);
		if(structkeyexists(xmlnode.XmlAttributes, 'isfamily') AND isvalid('boolean', xmlnode.XmlAttributes.isfamily)) setIsFamily(xmlnode.XmlAttributes.isfamily);
		if(structkeyexists(xmlnode.XmlAttributes, 'isfriend') AND isvalid('boolean', xmlnode.XmlAttributes.isfriend)) setIsFriend(xmlnode.XmlAttributes.isfriend);
		if(structkeyexists(xmlnode.XmlAttributes, 'ispublic') AND isvalid('boolean', xmlnode.XmlAttributes.ispublic)) setIsPublic(xmlnode.XmlAttributes.ispublic);
		if(structkeyexists(xmlnode.XmlAttributes, 'permaddmeta') AND isvalid('boolean', xmlnode.XmlAttributes.permaddmeta)) setCanAddMeta(xmlnode.XmlAttributes.permaddmeta);
		if(structkeyexists(xmlnode.XmlAttributes, 'permcomment') AND isvalid('boolean', xmlnode.XmlAttributes.permcomment)) setCanComment(xmlnode.XmlAttributes.permcomment);

		if(structkeyexists(xmlnode.XmlAttributes, 'secret')) setSecret(xmlnode.XmlAttributes.secret);
		if(structkeyexists(xmlnode.XmlAttributes, 'server')) setServer(xmlnode.XmlAttributes.server);
		if(structkeyexists(xmlnode.XmlAttributes, 'farm')) setFarm(xmlnode.XmlAttributes.farm);
		if(structkeyexists(xmlnode.XmlAttributes, 'title')) setTitle(xmlnode.XmlAttributes.title);
		if(structkeyexists(xmlnode.XmlAttributes, 'license')) setLicense(xmlnode.XmlAttributes.license);
		if(structkeyexists(xmlnode.XmlAttributes, 'dateupload')) setDatePosted(xmlnode.XmlAttributes.dateupload);
		if(structkeyexists(xmlnode.XmlAttributes, 'datetaken')) setDateTaken(xmlnode.XmlAttributes.datetaken);
		if(structkeyexists(xmlnode.XmlAttributes, 'lastupdate')) setLastUpdate(xmlnode.XmlAttributes.lastupdate);
		if(structkeyexists(xmlnode.XmlAttributes, 'datetakengranularity')) setTakenGranularity(xmlnode.XmlAttributes.datetakengranularity);

		if(structkeyexists(xmlnode.XmlAttributes, 'originalsecret')) setOriginalSecret(xmlnode.XmlAttributes.originalsecret);
		if(structkeyexists(xmlnode.XmlAttributes, 'originalformat')) setOriginalFormat(xmlnode.XmlAttributes.originalformat);

		// owner attributes
		if(structkeyexists(xmlnode.XmlAttributes, 'owner')) getowner().setId(xmlnode.XmlAttributes.owner);
		if(structkeyexists(xmlnode.XmlAttributes, 'ownername')) getowner().setUsername(xmlnode.XmlAttributes.ownername);
		if(structkeyexists(xmlnode.XmlAttributes, 'iconserver')) getowner().setIconServer(xmlnode.XmlAttributes.iconserver);
		if(structkeyexists(xmlnode.XmlAttributes, 'owner')) getowner().setId(xmlnode.XmlAttributes.owner);
		
		// hack to get server from prev/next context photos, this might get broken.
		if(structkeyexists(xmlnode.XmlAttributes, 'thumb')) {
			try {
				tmp = xmlnode.XmlAttributes.thumb;
				tmp = REFind("/[^##\?]*", tmp, Find("://", tmp)+3, true);
				tmp = mid(xmlnode.XmlAttributes.thumb, tmp.pos[1], tmp.len[1]);
				tmp = listfirst(tmp, '/');
				setServer(tmp);
			} catch(any e) {}
		}
		
		// CHILD ELEMENTS
		// owner
		tmp = xmlsearch(xmlnode, 'owner');
		if(arraylen(tmp)) {
			t = createobject("component", "CFlickr.people.User");
			setOwner(t.parseXmlElement(tmp[1]));
		}
		
		// title
		tmp = xmlsearch(xmlnode, 'title');
		if(arraylen(tmp)) setTitle(tmp[1].xmltext);
		
		// description 
		tmp = xmlsearch(xmlnode, 'description');
		if(arraylen(tmp)) setDescription(tmp[1].xmltext);
		
		// visibility
		tmp = xmlsearch(xmlnode, 'visibility');
		if(arraylen(tmp)) { tmp = tmp[1];
			if(structkeyexists(tmp.XmlAttributes, 'isfamily')) setIsFamily(tmp[1].XmlAttributes.isfamily);
			if(structkeyexists(tmp.XmlAttributes, 'isfriend')) setIsFriend(tmp[1].XmlAttributes.isfriend);
			if(structkeyexists(tmp.XmlAttributes, 'ispublic')) setIsPublic(tmp[1].XmlAttributes.ispublic);
		}
		
		// dates 
		tmp = xmlsearch(xmlnode, 'dates');
		if(arraylen(tmp)) { tmp = tmp[1];
			if(structkeyexists(tmp.XmlAttributes, 'lastupdate')) setLastUpdate(tmp.XmlAttributes.lastupdate);
			if(structkeyexists(tmp.XmlAttributes, 'posted')) setDatePosted(tmp.XmlAttributes.posted);
			if(structkeyexists(tmp.XmlAttributes, 'taken')) setDateTaken(tmp.XmlAttributes.taken);
			if(structkeyexists(tmp.XmlAttributes, 'takengranularity')) setTakenGranularity(tmp.XmlAttributes.takengranularity);
		}
		
		// permissions 
		tmp = xmlsearch(xmlnode, 'permissions');
		if(arraylen(tmp)) { tmp = tmp[1];
			if(structkeyexists(tmp.XmlAttributes, 'permaddmeta')) setCanAddMeta(tmp.XmlAttributes.permaddmeta);
			if(structkeyexists(tmp.XmlAttributes, 'permcomment')) setCanComment(tmp.XmlAttributes.permcomment);
		}

		// comment count		
		tmp = xmlsearch(xmlnode, 'comments');
		if(arraylen(tmp)) setCommentCount(tmp[1].xmltext);

		// notes				
		tmp = xmlsearch(xmlnode, 'notes/note');
		if(arraylen(tmp)) {
			for(i=1; i LTE arraylen(tmp); i=i+1) {
				t = createobject("component", "CFlickr.photos.notes.Note");
				_addNote(t.parseXmlElement(tmp[i]));
			}
		}
		
		// tags
		tmp = xmlsearch(xmlnode, 'tags/tag');
		if(arraylen(tmp)) {
			for(i=1; i LTE arraylen(tmp); i=i+1) {
				t = createobject("component", "CFlickr.tags.Tag");
				_addTag(t.parseXmlElement(tmp[i]));
			}
		}		
		
		// urls
		tmp = xmlsearch(xmlnode, 'urls/url');
		if(arraylen(tmp)) {
			for(i=1; i LTE arraylen(tmp); i=i+1) {
				t = createobject("component", "CFlickr.photos.PhotoUrl");
				_addUrl(t.parseXmlElement(tmp[i]));
			}
		}
		
		// exif		
		tmp = xmlsearch(xmlnode, 'exif');
		if(arraylen(tmp)) {
			for(i=1; i LTE arraylen(tmp); i=i+1) {
				t = createobject("component", "CFlickr.photos.Exif");
				_addExif(t.parseXmlElement(tmp[i]));
			}
		}
		
		// activity
		tmp = xmlsearch(xmlnode, 'activity/event');
		if(arraylen(tmp)) {
			for(i=1; i LTE arraylen(tmp); i=i+1) {
				if(structkeyexists(tmp[i].XmlAttributes, 'type')) {
					if(tmp[i].XmlAttributes.type IS 'comment') {
						t = createobject("component", "CFlickr.comments.Comment");
						if(structkeyexists(tmp[i].XmlAttributes, 'commentid')) t.setId(tmp[i].XmlAttributes.commentid);
						if(structkeyexists(tmp[i].XmlAttributes, 'dateadded')) t.setDateCreated(tmp[i].XmlAttributes.dateadded);
						if(structkeyexists(tmp[i].XmlAttributes, 'username')) t.setAuthor(tmp[i].XmlAttributes.username);
						if(structkeyexists(tmp[i].XmlAttributes, 'user')) t.setAuthorId(tmp[i].XmlAttributes.user);
						t.setText(tmp[i].XmlText);
						_addEvent(t);
					}
					else if(tmp[i].XmlAttributes.type IS 'note') {
						t = createobject("component", "CFlickr.notes.Note");
						if(structkeyexists(tmp[i].XmlAttributes, 'noteid')) t.setId(tmp[i].XmlAttributes.noteid);
						if(structkeyexists(tmp[i].XmlAttributes, 'user')) t.setAuthorId(tmp[i].XmlAttributes.user);
						if(structkeyexists(tmp[i].XmlAttributes, 'username')) t.setAuthorName(tmp[i].XmlAttributes.username);
						if(structkeyexists(tmp[i].XmlAttributes, 'dateadded')) t.setDateCreated(tmp[i].XmlAttributes.dateadded);
						_addEvent(t);
					}
				}
			}
		}
		
		return this;
		</cfscript>
		
	</cffunction>


</cfcomponent>
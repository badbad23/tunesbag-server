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

	<cffunction name="Add" access="public" output="false" returntype="numeric" hint="Add a note to a photo. Coordinates and sizes are in pixels, based on the 500px image size shown on individual photo pages.">
		<cfargument name="photo_id" type="string" required="yes" hint="The id of the photo to add a note to. ">
		<cfargument name="note_x" type="numeric" required="yes" hint="The left coordinate of the note. ">
		<cfargument name="note_y" type="numeric" required="yes" hint="The top coordinate of the note. ">
		<cfargument name="note_w" type="numeric" required="yes" hint="The width of the note. ">
		<cfargument name="note_h" type="numeric" required="yes" hint="The height of the note. ">
		<cfargument name="note_text" type="string" required="yes" hint="The description of the note. ">
		<cfset var resp = flickr.get("flickr.photos.notes.add", arguments)>
		<cfset var payload = resp.getPayload()>
		<cfif resp.isError()>
			<cfthrow errorcode="#resp.getErrorCode()#" message="#resp.getErrorMessage()#">
		</cfif>
		<cfreturn payload.xmlattributes.id>
	</cffunction>
	
	<cffunction name="Delete" access="public" output="false" returntype="boolean" hint="Delete a note from a photo.">
		<cfargument name="note_id" type="string" required="yes" hint="The id of the note to delete. ">
		<cfset var resp = flickr.get("flickr.photos.notes.delete", arguments)>
		<cfif resp.isError()>
			<cfthrow errorcode="#resp.getErrorCode()#" message="#resp.getErrorMessage()#">
		</cfif>
		<cfreturn NOT resp.isError()>
	</cffunction>

	<cffunction name="Edit" access="public" output="false" returntype="boolean" hint="Edit a note on a photo. Coordinates and sizes are in pixels, based on the 500px image size shown on individual photo pages. ">
		<cfargument name="note_id" type="string" required="yes" hint="The id of the note to edit. ">
		<cfargument name="note_x" type="numeric" required="yes" hint="The left coordinate of the note. ">
		<cfargument name="note_y" type="numeric" required="yes" hint="The top coordinate of the note. ">
		<cfargument name="note_w" type="numeric" required="yes" hint="The width of the note. ">
		<cfargument name="note_h" type="numeric" required="yes" hint="The height of the note. ">
		<cfargument name="note_text" type="string" required="yes" hint="The description of the note. ">
		<cfset var resp = flickr.get("flickr.photos.notes.edit", arguments)>
		<cfif resp.isError()>
			<cfthrow errorcode="#resp.getErrorCode()#" message="#resp.getErrorMessage()#">
		</cfif>
		<cfreturn NOT resp.isError()>
	</cffunction>

</cfcomponent>
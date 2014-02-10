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

	<cffunction name="getNext" access="public" output="false" returntype="any">
		<cfif NOT structkeyexists(variables, 'next')>
			<cfthrow message="Next item has not been set">
		</cfif>
		<cfreturn variables.next />
	</cffunction>
	<cffunction name="setNext" access="public" output="false" returntype="void">
		<cfargument name="next" type="any" required="yes">
		<cfset variables.next = arguments.next>
	</cffunction>
	
	<cffunction name="getPrev" access="public" output="false" returntype="any">
		<cfif NOT structkeyexists(variables, 'prev')>
			<cfthrow message="Previous item has not been set">
		</cfif>
		<cfreturn variables.prev />
	</cffunction>
	<cffunction name="setPrev" access="public" output="false" returntype="void">
		<cfargument name="prev" type="any" required="yes">
		<cfset variables.prev = arguments.prev>
	</cffunction>
	
</cfcomponent>
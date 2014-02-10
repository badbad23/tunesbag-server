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
	variables.name = "";
	variables.needslogin = false;
	variables.needssigning = false;
	variables.requiredperms = 0;
	variables.description = "";
	variables.response = "";
	variables.explanation = "";
	variables.arguments = arraynew(1);
	variables.errors = arraynew(1);
	</cfscript>
	
	<cffunction name="getName" access="public" output="false" returntype="string">
		<cfreturn variables.name />
	</cffunction>
	<cffunction name="setName" access="public" output="false" returntype="void">
		<cfargument name="name" type="string" required="yes">
		<cfset variables.name = arguments.name >
	</cffunction>	
	
	<cffunction name="getNeedsLogin" access="public" output="false" returntype="boolean">
		<cfreturn variables.needslogin />
	</cffunction>
	<cffunction name="setNeedsLogin" access="public" output="false" returntype="void">
		<cfargument name="needslogin" type="boolean" required="yes">
		<cfset variables.needslogin = arguments.needslogin >
	</cffunction>	
	
	<cffunction name="getNeedsSigning" access="public" output="false" returntype="boolean">
		<cfreturn variables.needssigning />
	</cffunction>
	<cffunction name="setNeedsSigning" access="public" output="false" returntype="void">
		<cfargument name="needssigning" type="boolean" required="yes">
		<cfset variables.needssigning = arguments.needssigning >
	</cffunction>	
	
	<cffunction name="getrequiredperms" access="public" output="false" returntype="numeric">
		<cfreturn variables.requiredperms />
	</cffunction>
	<cffunction name="setrequiredperms" access="public" output="false" returntype="void">
		<cfargument name="requiredperms" type="numeric" required="yes">
		<cfset variables.requiredperms = arguments.requiredperms >
	</cffunction>	
	
	<cffunction name="getDescription" access="public" output="false" returntype="string">
		<cfreturn variables.description />
	</cffunction>
	<cffunction name="setDescription" access="public" output="false" returntype="void">
		<cfargument name="description" type="string" required="yes">
		<cfset variables.description = arguments.description >
	</cffunction>	
	
	<cffunction name="getResponse" access="public" output="false" returntype="string">
		<cfreturn variables.response />
	</cffunction>
	<cffunction name="setResponse" access="public" output="false" returntype="void">
		<cfargument name="response" type="string" required="yes">
		<cfset variables.response = arguments.response >
	</cffunction>	
	
	<cffunction name="getExplanation" access="public" output="false" returntype="string">
		<cfreturn variables.explanation />
	</cffunction>
	<cffunction name="setExplanation" access="public" output="false" returntype="void">
		<cfargument name="explanation" type="string" required="yes">
		<cfset variables.explanation = arguments.explanation >
	</cffunction>	
	
	<cffunction name="getArguments" access="public" output="false" returntype="array">
		<cfreturn variables.arguments />
	</cffunction>
	<cffunction name="setArguments" access="public" output="false" returntype="void">
		<cfargument name="arguments" type="array" required="yes">
		<cfset variables.arguments = arguments.arguments >
	</cffunction>	
	<cffunction name="addArgument" access="public" output="false" returntype="void" >
		<cfargument name="argument" type="struct" required="yes">
		<cfset arrayappend(variables.arguments, argument)>
	</cffunction>
	<cffunction name="removeArgument" access="public" output="false" returntype="struct"> 
		<cfargument name="position" type="numeric" required="yes">
		<cfset var tmp = "">
		<cfif arraylen(variables.arguments) GTE arguments.position>
			<cfset tmp = variables.arguments[arguments.position]>
			<cfset arraydeleteat(variables.arguments, arguments.position)>
		</cfif>
		<cfreturn tmp>
	</cffunction>		
	
	<cffunction name="getErrors" access="public" output="false" returntype="array">
		<cfreturn variables.errors />
	</cffunction>
	<cffunction name="setErrors" access="public" output="false" returntype="void">
		<cfargument name="errors" type="array" required="yes">
		<cfset variables.errors = arguments.errors >
	</cffunction>
	<cffunction name="addError" access="public" output="false" returntype="void" >
		<cfargument name="error" type="struct" required="yes">
		<cfset arrayappend(variables.errors, error)>
	</cffunction>
	<cffunction name="removeError" access="public" output="false" returntype="struct"> 
		<cfargument name="position" type="numeric" required="yes">
		<cfset var tmp = "">
		<cfif arraylen(variables.errors) GTE arguments.position>
			<cfset tmp = variables.errors[arguments.position]>
			<cfset arraydeleteat(variables.errors, arguments.position)>
		</cfif>
		<cfreturn tmp>
	</cffunction>		
		
 	<cffunction name="parseXmlElement" access="public" output="false" returntype="CFlickr.reflection.Method">
		<cfargument name="xmlnode" type="any" required="yes">
		<cfscript>
		var tmp = 0;
		var i = 0;
		var s = 0;


		if(structkeyexists(xmlnode.xmlattributes, 'name')) setName(xmlnode.xmlattributes.name);
		if(structkeyexists(xmlnode.xmlattributes, 'needslogin')) setNeedsLogin(xmlnode.xmlattributes.needslogin);
		if(structkeyexists(xmlnode.xmlattributes, 'needssigning')) setNeedsSigning(xmlnode.xmlattributes.needssigning);
		if(structkeyexists(xmlnode.xmlattributes, 'requiredperms')) setRequiredPerms(xmlnode.xmlattributes.requiredperms);

		tmp = xmlsearch(xmlnode, 'description');
		if(arraylen(tmp)) setDescription(tmp[1].xmltext);
		
		tmp = xmlsearch(xmlnode, 'response');
		if(arraylen(tmp)) setResponse(tmp[1].xmltext);
		
		tmp = xmlsearch(xmlnode, 'explanation');
		if(arraylen(tmp)) setExplanation(tmp[1].xmltext);
		
		tmp = xmlsearch(xmlnode, 'argument');
		for(i=1; i LTE arraylen(tmp); i=i+1) {
			s = structnew();
			if(structkeyexists(tmp[i].xmlattributes, 'name')) s.name = tmp[i].xmlattributes.name;
			if(structkeyexists(tmp[i].xmlattributes, 'optional')) s.optional = tmp[i].xmlattributes.optional;
			s.description = tmp[i].xmltext;
			addArgument(s);
		}
		
		tmp = xmlsearch(xmlnode, 'error');
		for(i=1; i LTE arraylen(tmp); i=i+1) {
			s = structnew();
			if(structkeyexists(tmp[i].xmlattributes, 'code')) s.code = tmp[i].xmlattributes.code;
			if(structkeyexists(tmp[i].xmlattributes, 'message')) s.message= tmp[i].xmlattributes.message;
			s.description = tmp[i].xmltext;
			addError(s);
		}
		
		return this;
		</cfscript>
	</cffunction>

</cfcomponent>










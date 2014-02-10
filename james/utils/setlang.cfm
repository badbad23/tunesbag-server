<!--- set the language cookie --->
<cfparam name="url.lang_id" type="string" default="en" />

<cfcookie name="lang_id" value="#url.lang_id#" />

<cfif Len( cgi.HTTP_REFERER ) GT 0>
	<cfset sTarget = cgi.HTTP_REFERER />
<cfelse>
	<cfset sTarget = '/' />
</cfif>

<cflocation addtoken="false" url="#sTarget#">
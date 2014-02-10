<!---

	image caching
	
	Check if a filename has been provided and is valid, deliver image
	
	otherwise perform a redirect

--->

<cfset a_str_filename = event.getArg( 'filename', '' ) />
<cfset a_str_href = event.getArg( 'url', '' ) />

<cfif Len( a_str_href ) IS 0>
	<cflocation addtoken="false" url="http://cdn.tunesBag.com/images/space1x1.png" />
</cfif>

<cfif FileExists( a_str_filename ) AND ListLast( a_str_filename, '.' ) IS 'jpg'>
	<cfcontent deletefile="false" type="image/jpeg" file="#a_str_filename#">
<cfelse>
	<cflocation addtoken="false" url="#a_str_href#">
</cfif>
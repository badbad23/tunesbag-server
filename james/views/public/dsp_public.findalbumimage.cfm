<!--- deliver album cover art --->


<cfset a_str_image_location = event.getArg( 'image_location' ) />
<cfset iSize = event.getArg( 'Size' ) />

<cfif FileExists( a_str_image_location )>
	<cfcontent deletefile="false" file="#a_str_image_location#" type="image/jpeg">
<cfelse>
	<cflocation addtoken="false" url="http://cdn.tunesBag.com/images/unknown_album_#iSize#x#iSize#.png">
</cfif>
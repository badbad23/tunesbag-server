<!--- deliver artist image --->

<cfset a_str_image = event.getArg( 'image_location', '' ) />
<cfset sSize = event.getArg( 'Size', 120 ) />

<!--- 
<cfdump var="#event.getargs()#">
<cfabort >
 --->

<cfif FileExists( a_str_image )>
	<cfcontent deletefile="false" file="#a_str_image#" type="image/jpeg" />
<cfelse>
	<!--- forward to unknwon artist image --->
	<cflocation addtoken="false" url="http://cdn.tunesBag.com/images/unknown-artist-#sSize#x#sSize#.png" />
</cfif>
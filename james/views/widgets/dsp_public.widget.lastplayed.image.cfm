<!--- display email att img --->

<cfinclude template="/common/scripts.cfm">

<cfset a_str_userkey = event.getArg( 'userkey', '' ) />
<cfset a_str_template_img = event.getArg( 'templateimg' ) />
<cfset q_select_last_track = event.getArg( 'q_select_last_track' ) />

<!--- data found? --->
<cfif Len( a_str_userkey ) IS 0>2
	<cfexit method="exittemplate">
</cfif>

<cfif NOT FileExists( a_str_template_img )><cfoutput>#a_str_template_img#</cfoutput>
	<cfexit method="exittemplate">
</cfif>


<cfset a_str_tmp_file = application.udf.GetTBTempDirectory() & CreateUUID() & '.png' />

<cfset a_str_last_track = application.udf.ShortenString( q_select_last_track.name, 25) &  '- ' & application.udf.ShortenString( q_select_last_track.artist, 25) />

<cfif Len( q_select_last_track.album ) GT 0>
	<cfset a_str_last_track = a_str_last_track & ' (' & application.udf.ShortenString( q_select_last_track.album, 25 ) & ')' />
</cfif>

<cfset intFontSize = 12 />
<!--- Create ColdFusion image canvas. --->
<cfset objImage = ImageNew( "", 500, intFontSize + 8, "rgb" ) />


<cfimage action="read" source="#a_str_template_img#" name="objImage">

 <cfset objFontProperties = {
Font = "Lucida Sans Demibold",
 Size = intFontSize,
 Style = "plain"  } />


 <!--- Draw text. --->
 <cfset ImageDrawText(
	 objImage,
	 a_str_last_track,
	 135,
	 (intFontSize + 12),
	 objFontProperties
 	) />

<cfimage action="write" destination="#a_str_tmp_file#" source="#objImage#" overwrite="yes" format="jpeg" />

 <!--- Draw image. --->
<cfcontent deletefile="false" file="#a_str_tmp_file#" type="image/png">

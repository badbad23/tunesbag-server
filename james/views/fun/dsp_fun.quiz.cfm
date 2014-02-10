<!---

	quiz first trial

--->

<cfset a_str_quiz_key = event.getArg( 'quizkey', '' ) />
<cfset a_int_step = event.getArg( 'step', 1 ) />

<cfsavecontent variable="request.content.final">

<cfsavecontent variable="a_str_html_head">
<cfoutput>
<meta http-equiv="refresh" content="10;URL=/james/?event=fun.quiz&amp;quizkey=#a_str_quiz_key#&amp;step=#( a_int_step + 1 )#" />
</cfoutput>
</cfsavecontent>

<cfhtmlhead text="#a_str_html_head#">

<cfquery name="q_select_random_tracks" datasource="mytunesbutleruserdata">
SELECT
	artist,name,album,year,entrykey
FROM
	mediaitems
WHERE
	LENGTH( artist ) > 0
ORDER BY
	RAND()
LIMIT
	4
</cfquery>

<cfset a_int_rand = RandRange( 1, 4 ) />

<cfoutput query="q_select_random_tracks">
<a href="##"><h4>#q_select_random_tracks.artist#
	<br />#q_select_random_tracks.name#</h4></a>
</cfoutput>
<cfset a_str_entrykey = q_select_random_tracks['entrykey'][ a_int_rand ] />

<cfset a_str_file = '/james/index.cfm?event=play.deliverfile&entrykey=' & a_str_entrykey & '&nocache=true' />

<embed
src="http://www.jeroenwijering.com/embed/mediaplayer.swf"
width="470"
height="20"
allowscriptaccess="always"
allowfullscreen="true"
flashvars="height=20&width=470&file=<cfoutput>#UrlEncodedFormat( a_str_file )#</cfoutput>&source=&autostart=true&type=mp3"
/>

</cfsavecontent>
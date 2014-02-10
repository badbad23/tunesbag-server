
<cfsavecontent variable="request.content.final">

<cfset event.setArg( 'PageTitle', 'Tour' ) />

<h1>Screenshots</h1>
<br />
Click on the Screenshot to enlarge the image
<br /><br />
<table>
	<tr>
		<td width="50%" style="text-align:center;padding:4px">
			<a href="http://cdn.tunesBag.com/images/content/screenshots/dec09/library.jpg"><img class="b_all" alt="Library" src="http://cdn.tunesBag.com/images/content/screenshots/dec09/thumbnail-library.jpg" style="padding:12px" /></a>
			<br />
			Library
		</td>
		<td width="50%" style="text-align:center;padding:4px">
			<a href="http://cdn.tunesBag.com/images/content/screenshots/dec09/playlist-web.jpg"><img class="b_all" src="http://cdn.tunesBag.com/images/content/screenshots/dec09/thumbnail-playlist.jpg" style="padding:12px" /></a>
			<br />
			Playlist
		</td>
	</tr>
	<tr>
		<td width="50%" style="text-align:center;padding:4px">
			<a href="http://cdn.tunesBag.com/images/content/screenshots/dec09/login-signup.jpg"><img class="b_all"  src="http://cdn.tunesBag.com/images/content/screenshots/dec09/thumbnail-signup.jpg" style="padding:12px" /></a>
			<br />
			Signup
		</td>
		<td width="50%" style="text-align:center;padding:4px">
			<a href="http://cdn.tunesBag.com/images/content/screenshots/dec09/premium.jpg"><img class="b_all"src="http://cdn.tunesBag.com/images/content/screenshots/dec09/thumbnail-premium.jpg" style="padding:12px" /></a>
			<br />
			Premium Services
		</td>
	</tr>
</table>

</cfsavecontent>

<!--- <cfhttp method="get" charset="utf-8" url="http://localhost:8080/ehcache/rest/sampleCache2/xxx">
</cfhttp>

<cfset xData = XMLParse( cfhttp.filecontent ) />

<cfhtmlhead text="#xData.xmlRoot.htmlhead.xmltext#">

<cfsavecontent variable="request.content.final">
<cfoutput>#xData.xmlRoot.body.xmltext#</cfoutput>
</cfsavecontent> --->
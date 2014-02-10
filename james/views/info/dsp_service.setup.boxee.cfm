<!--- add boxee --->
<cfinclude template="/common/scripts.cfm">

<!--- remote key for boxee --->
<cfset a_str_app_remote_key = event.getArg( 'a_str_app_remote_key' ) />

<cfsavecontent variable="request.content.final">


<table>
	<tr>
		<td style="padding:20px" valign="top">
			<a title="boxee" href="http://boxee.tv" target="_blank"><img src="http://cdn.tunesBag.com/images/partner/services/boxee_logo.png" alt="boxee" style="border:0px" /></a>
			<br /><br /><br />
			
			<a title="xbmc" href="http://xbmc.org" target="_blank"><img src="http://cdn.tunesBag.com/images/partner/services/xbmc.png" alt="xbmc" style="border:0px;width:100px" /></a>
			<div style="color:gray;text-align:center">Coming soon</div>
			<br /><br /><br /><br />
			<div style="text-align:center;color:gray;font-size: 10px">
				tunesBag.com is not affiliated with boxee and xbmc. All brand names, trademarks and logos are the property of their respective owners.
			</div>
</td>
<td valign="top" style="padding:20px">
	<h2 style="color:gray">Control tunesBag using the remote control from your couch!</h2>
	<h1>tunesBag now streaming to boxee / xmbc</h1>
	
	<br />
	<p style="line-height: 160%">
	tunesBag is coming to more and more devices - now we're entering your TV set by supporting two leading media center products - <a href="http://boxee.tv/">boxee</a> (up &amp; running) &amp; <a href="http://xmbc.org">xbmc</a> (coming soon)!
	<br />
	By adding tunesBag as media source, you're able to browse through your tunes collection and play tracks right from your couch! 
	This new service is part of our effort to make tunesBag available on several platforms (including the <a href="http://blog.tunesbag.com/2008/12/iphone-owner-use-tunesbag-app-to-stream.html">iPhone</a>) so stay tuned for the release of other clients.
	</p>
	<br />
	
	<h3>How to add tunesBag to boxee</h3>

	<br />
	
	<div style="padding-left:20px" class="status">
	<h4>1) Copy the following link to the clipboard</h4>
	
	
	
	<cfoutput>
	<form name="boxee" id="boxee">
	
	
	<input width="20" style="width:600px;padding:2px;font-size:12px;" onclick="document.boxee.boxee_url.focus();document.boxee.boxee_url.select();" type="text" name="boxee_url" id="boxee_url" value="rss://tunesbag.com/api/rest/rss/welcome/?appkey=7706ECA1-F205-9A74-1C41F00931943688&username=#htmleditformat( application.udf.GetCurrentSecurityContext().username )#&remotekey=#htmleditformat( a_str_app_remote_key )#" />
	
	</form>
	</cfoutput>
	<br />
	2) <b>Launch boxee</b>
	<br /><br />
	3) Go to "<b>Settings</b>" / "<b>Media Sources and Applications</b>"
	<br /><br />
	4) Click on "<b>Manually add source</b>"
	<br /><br />
	5) Enter "<b>tunesBag</b>" as source name and <b>paste the link from the clipboard (apple + v)</b>. Select music as type and click on "<b>Add</b>" to finish!
	<br /><br />
	<b>Done! Switch to Music / Internet / tunesBag to listen to all the playlists!</b>
	
	<br />
	Please let us know any feedback using <a href="http://feedback.tunesBag.com/">feedback.tunesBag.com</a>.
	
	<br />
	</div>
	<br />
	<h3>Some screenshots - what you can expect!</h3>
	<div style="padding-left:20px">
	
	<img src="http://cdn.tunesBag.com/images/content/boxee/screen_boxee_1.jpg"  style="margin:10px;width:400px;height:250px" />
	<br />
	Playlist view
	<br />
	<img src="http://cdn.tunesBag.com/images/content/boxee/screen_boxee_visual.jpg"  style="margin:10px;width:400px;height:250px" />
	<br />
	Visualization
	<br />
	<img src="http://cdn.tunesBag.com/images/content/boxee/screen_boxee_artists.jpg"  style="margin:10px;width:400px;height:250px" />
	<br />
	Browse artists
	<br />
	<img src="http://cdn.tunesBag.com/images/content/boxee/screen_boxee_genres.jpg"  style="margin:10px;width:400px;height:250px" />
	<br />
	Browse genres
	
	</div>
</td>

	</tr>
</table>


</cfsavecontent>
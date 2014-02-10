<!--- add SQBN --->
<cfinclude template="/common/scripts.cfm">

<!--- remote key for SQBN --->
<cfset a_str_app_remote_key = event.getArg( 'a_str_app_remote_key' ) />

<cfif application.udf.IsLoggedIn()>
	<cfset sURL = 'http://tunesbag.com/api/rest/opml/welcome/?appkey=' & application.const.S_APPKEY_SQUEEZENETWORK & '&username=' & application.udf.GetCurrentSecurityContext().username & '&remotekey=' & a_str_app_remote_key & '&f=welcome.opml' />
</cfif>

<cfset event.setArg( 'PageTitle', 'Stream to your Logitech Squeezebox') />
<cfset event.setArg( 'PageDescription', 'Setup instructions for how to stream your entire music collection and playlists stored on tunesBag.com to your Logitech Squeezebox. Supporting Boom, Touch and Remote controls.' ) />

<cfsavecontent variable="request.content.final">


<table>
	<tr>
		<td style="padding:20px;text-align:center;width: 190px" valign="top">
			<b>Supported devices</b>
			<br />
			<span class="addinfotext">
			Click to show more information on amazon.com
			</span>
			<br /><br />
			<a href="http://www.amazon.com/gp/product/B002LARRDK?ie=UTF8&tag=tunesbagcom-20&linkCode=as2&camp=1789&creative=9325&creativeASIN=B002LARRDK" target="_blank"><img border="0" src="/res/images/content/sqbn/sqbn-prod1.jpg" alt="Logitech Squeezebox" title="Logitech Sqzeezebox Remote Streaming" /></a><img src="http://www.assoc-amazon.com/e/ir?t=tunesbagcom-20&l=as2&o=1&a=B002LARRDK" width="1" height="1" border="0" alt="" style="border:none !important; margin:0px !important;" />
			
			<br /><br /><br />
			<a href="http://www.amazon.com/gp/product/B001DJ64D4?ie=UTF8&tag=tunesbagcom-20&linkCode=as2&camp=1789&creative=9325&creativeASIN=B001DJ64D4" target="_blank"><img border="0" src="/res/images/content/sqbn/sqbn-prod2.jpg" alt="Logitech Squeezebox Boom" title="Logitech Squeezebox Boom Music Locker service" /></a><img src="http://www.assoc-amazon.com/e/ir?t=tunesbagcom-20&l=as2&o=1&a=B001DJ64D4" width="1" height="1" border="0" alt="" style="border:none !important; margin:0px !important;" />
			<br /><br /><br />
			<a href="http://www.amazon.com/gp/product/B001413GT6?ie=UTF8&tag=tunesbagcom-20&linkCode=as2&camp=1789&creative=9325&creativeASIN=B001413GT6" target="_blank"><img border="0" src="/res/images/content/sqbn/sqbn-prod3.jpg" alt="Logitech Squeezebox" style="width:120px" title="Squeezebox Remote" /></a><img src="http://www.assoc-amazon.com/e/ir?t=tunesbagcom-20&l=as2&o=1&a=B001413GT6" width="1" height="1" border="0" alt="" style="border:none !important; margin:0px !important;" />

			
			<br /><br />
			<div style="text-align:center;color:gray;font-size: 10px">
				tunesBag.com is not affiliated with Logitech(r). All brand names, trademarks and logos are the property of their respective owners.
			</div>
</td>
<td valign="top" style="padding:20px">
	<h2 style="color:gray">Logitech® Squeezebox™ Players</h2>
	<h1>tunesBag now streaming to your Squeezebox</h1>
	
	<br />
	<p style="line-height: 160%">
	You can now access your entire music collection and playlists stored on tunesBag.com using your Squeezebox! We've implemented various views, you can browse through your playlists, artists, albums and genres.
	</p>
	<br />
	
	<h3>How to add tunesBag to your Squeezebox</h3>

	<br />
	
	<div style="padding-left:20px;width:90%" class="status">
	
	<cfif application.udf.IsLoggedIn()>
	<h4>1) Copy the following link to the clipboard</h4>
	
	<cfoutput>
	<form name="sqbn" id="sqbn">
		
		<textarea rows="2" cols="40" style="width:540px" id="sqbn_url" onclick="document.sqbn.sqbn_url.focus();document.sqbn.sqbn_url.select();">#htmleditformat( sURL )#</textarea>
		
	</form>
	</cfoutput>
	
	<cfelse>
		
		<cfoutput>
		<h4>1 ) Sign in or create a new tunesBag account for free</h4>
		
		<form>
			<p style="padding:12px">
			<input type="button" class="btn" value="#application.udf.GetLangValSec( 'nav_login' )#" onclick="location.href='/rd/login/?returnurl=#htmleditformat( cgi.SCRIPT_NAME & '?' & cgi.QUERY_STRING )#'" />
			&nbsp;&nbsp;
			<input type="button" class="btn" value="#application.udf.GetLangValSec( 'nav_sign_up' )#" onclick="location.href='/rd/signup/?source=squeezenetwork'" />
			</p>
		</form>
		</cfoutput>
	
	</cfif>
	
	<br />
	2) <b>Login to <a href="http://www.mysqueezebox.com/settings/favorites">www.mysqueezebox.com/settings/favorites</a></b>
	<br /><br />
	3) Go to "<b>Favorites</b>"
	<br /><br />
	4) Enter "<b>tunesBag</b>" as source name and <b>paste the link from the clipboard (apple + v)</b>. Ignore any error messages. Click on "<b>Add</b>" to finish!
	<br /><br />
	<b>Done! Launch the "Favorites" menu on your Squeezebox, select "tunesBag" and enjoy the service!</b>
	
	<br /><br />
	Please let us know any feedback using <a href="http://feedback.tunesBag.com/">feedback.tunesBag.com</a>.
	
	<br />
	<br />
	<i>Hint: You can modify the streaming quality in the user preferences (128 - 320 kb /sec)</i>
	</div>
	<!--- <br />
	<h3>Some screenshots - what you can expect!</h3>
	<div style="padding-left:20px">
	
	<img src="http://deliver.tunesbagcdn.com/images/content/boxee/screen_boxee_1.jpg"  style="margin:10px;width:400px;height:250px" />
	<br />
	Playlist view
	<br />
	<img src="http://deliver.tunesbagcdn.com/images/content/boxee/screen_boxee_visual.jpg"  style="margin:10px;width:400px;height:250px" />
	<br />
	Visualization
	<br />
	<img src="http://deliver.tunesbagcdn.com/images/content/boxee/screen_boxee_artists.jpg"  style="margin:10px;width:400px;height:250px" />
	<br />
	Browse artists
	<br />
	<img src="http://deliver.tunesbagcdn.com/images/content/boxee/screen_boxee_genres.jpg"  style="margin:10px;width:400px;height:250px" />
	<br />
	Browse genres --->
	
	</div>
</td>

	</tr>
</table>


</cfsavecontent>
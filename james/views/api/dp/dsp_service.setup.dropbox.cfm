<!--- 

	dropbox integration

 --->

<cfsavecontent variable="request.content.final">

<div style="width:600px;margin-left:auto;margin-right:auto;margin-bottom:60px;line-height:160%">
<img src="/res/images/partner/services/dropbox-240x81.png" width="240" height="81" alt="" title="Dropbox logo" />
<br /><br />
<h1>Enable tunesBag as your Dropbox MP3 Media Player</h1>
<br />
<p>
	<b>Connect your Dropbox account to tunesBag and all your media files will automatically appear in your tunesBag library ready to play!</b>
	<br />
	<form action="/james/?" method="get" id="connectdp">
	<input type="hidden" name="event" value="service.dropbox.linkaccount" />
	<div class="confirmation">
	<input type="submit" value="Connect Dropbox and tunesBag" class="btn" />
	</div>
	<img onclick="$('#connectdp').submit();" src="/res/images/content/dp/dropbox-tunesbag-integration.jpg" width="580" height="354" style="border: silver solid 1px;padding: 4px;margin-top:20px;cursor:pointer" alt="" title="Dropbox Media Player (tunesBag) Supporting MP3, WMA, M4A and OGG" />
	</form>
	<br /><br />
	<b>Requirements</b>
	<br />
	A free <a href="/rd/signup/?source=dropbox">tunesBag</a> and a <a href="http://db.tt/1HY0MkJ">Dropbox</a> account.

	<br /><br />
	<b>FAQ</b>
	<br />
	<ul class="ul_nopoints" id="faq">
		<li>
			<a href="##" onclick="showanswer(1);return false">Is this feature part of my service plan?</a>
		</li>
		<li class="answer hidden" id="faqanswer1">
			This feature is currently in beta-mode and available for all users for free. This might change in the future.
		</li>
		<li>
			<a href="##" onclick="showanswer(2);return false">Will the Dropbox files count against my tunesBag quota?</a>
		</li>
		<li class="answer hidden" id="faqanswer2">
		No, as the files won't be copied to tunesBag. The files will still be hosted by Dropbox.
		</li>
		<li>
			<a href="##" onclick="showanswer(3);return false">What happens if I remove media files from my Dropbox account?</a>
		</li>
		<li class="answer hidden" id="faqanswer3">
			The file will dissappear from your tunesBag library automatically.
		</li>
		<li>
			<a href="##" onclick="showanswer(4);return false">Can I play tracks stored on Dropbox on my iPhone or Squeezebox?</a>
		</li>
		<li class="answer hidden" id="faqanswer4">
			Yes of course, the files are available to all supported clients.
		</li>
		<li>
			<a href="##" onclick="showanswer(5);return false">How long does it take that my files show up in tunesBag?</a>
		</li>
		<li class="answer hidden" id="faqanswer5">
			That depends on the size of your library stored on Dropbox, the first tracks in your library should appear after a minute or so.
		</li>
		<li>
			<a href="##" onclick="showanswer(6);return false">I found a bug / I have an improvement request.</a>
		</li>
		<li class="answer hidden" id="faqanswer6">
			Please write us at <a href="http://feedback.tunesBag.com/">feedback.tunesBag.com</a> and we're glad to help you!
		</li>
	</ul>
</p>
</div>

<script type="text/javascript">
	function showanswer(index) {
		$('#faq .answer').hide();
		
		$('#faqanswer' + index).slideDown();
			
	}
</script>
</cfsavecontent>

<!--- modify title --->
<cfset event.setArg( 'PageTitle', 'Dropbox media player app (mp3, wma, m4a and ogg) for browsers and iPhone') />
<cfset event.setArg( 'PageDescription', 'Setup instructions for how to stream your entire music collection and playlists stored on Dropbox to your browser, iphone or other devices' ) />

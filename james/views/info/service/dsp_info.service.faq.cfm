<!---

	FAQ

--->

<cfprocessingdirective pageencoding="utf-8">

<cfsavecontent variable="sHead">
	<style type="text/css" media="all">
		h3 {
			margin-top:12px !important;
			}
		.answer {
			line-height:150%;
			width:600px;padding-left:70px;
			}
	</style>
</cfsavecontent>

<cfhtmlhead text="#sHead#" />

<cfset event.setArg( 'PageTitle', 'FAQ' ) />

<cfsavecontent variable="request.content.final">
	
<h1>FAQ - Frequently asked questions</h1>

<br />
<h2 class="lightbg bb">Common</h2>
<h3>What does tunesBag offer?</h3>
<p class="answer">
      tunesBag is your music hub allowing you to access your personal library whenever and wherever you are. <!--- tunesBag allows you to share playlists and listen to new music. --->
</p>
<h3>Is the service available in my country?</h3>
<p class="answer">
      The basic service (access your music library) is available in every country. Licence services (e.g. streaming) are subject to territorial agreements.
</p>
<h3>How long does it take to upload my tunes?</h3>
<p class="answer">
      The duration of your uploading process depends on your personal connection. But don't bother: You can upload in the background without limiting your PC’s or service functionality.
	<br />
	We recommend you to start with your favourite playlists in order to get the best user experience.
</p>
<h3>Can other people access my library and playlists?</h3>
<p class="answer">This depend on the licencing situation in your country. <!--- At the current moment this is only possible in a few selected countries including Austria. ---></p>
<h3>Where is the data stored?</h3>
<p class="answer">The data is stored on tunesBag servers. Your PC / notebook does not have to be switched on in order to access your tunes and playlists.
</p>
<h3>Is my data safe?</h3>
<p class="answer">Yes. We do backup the data and try to ensure data security as much as possible.</p>
<h3>Can I access my tunes on my mobile?</h3>
<p class="answer">Please check out our <a href="http://tunesbagdev/rd/iphone/appstore">iPhone app</a>.</p>
<!--- 
<h3>Do I have to pay something if my friends are listening to my tunes?</h3>
<p class="answer">No, the service does not charge for this functionality.</p>
 --->

<!--- <h3>Can I embed playlists in my website, blog or Facebook?</h3>
<p class="answer">Yes, we offer widget solutions for that soon.</p> --->
<h3>Do you offer premium services?</h3>
<p class="answer">Yes, please have a detailed look <a href="/rd/upgrade/">here</a></p>
<br />
<h2 class="bb lightbg">Technical</h2>

<!--- <h3>Am I able to download tracks from friends?</h3>
<p class="answer">No, licences do not support this functionality. But if you have identified a track you love you can buy it on your preferred platform with a simple click.</p> --->

<!--- <h3>What can I "share" on tunesBag?</h3>
<p class="answer">
      share your love to music, playlists, thoughts, recommendations,…
</p> --->
 
<h3>Is tunesBag a blackbox? </h3>
<p class="answer">No, you can restore your tracks anytime to your local harddisk again. tunesBag is also open to <a href="http://code.google.com/p/tunesbag-api/" target="_blank">developers (API)</a>.</p>

 
<h3>Which browsers / operating system are supported?</h3>
<p class="answer">
      tunesBag is supporting all established browsers and operating systems. If you face troubles in using tunesBag please give us a hint (support (at) tunesBag.com) to allow us to fix it.
</p>
        

<h3>Do I need a special player to use tunesBag?</h3>
<p class="answer">
      No, all you need is an installed Flash Plugin.
</p>

<h3>Do I have to install software on my computer?</h3>
<p class="answer">
      No, there are additional applications e.g. upload client that can be used, the service itself is browser based.
</p>
 
<h3>Do I have to upload all my files even if other users have uploaded the same track?</h3>
<p class="answer">
      Yes as tunesBag will create a backup of your personal files.
</p>
     
<h3>Which audio formats does tunesBag support?</h3>
<p class="answer">
      We support all major formats including mp3, m4a, wma and ogg.
</p>
 
<h3>What about the quality of audio files?</h3>
<p class="answer">
      The quality depends on the source (your audio files).
</p>
 
<h3>Do you support DRM protected files?</h3>
<p class="answer">
      No, DRM protected files are not supported. Please consider upgrading to non-DRM versions.
</p>
<h3>How many tracks can I upload?</h3>
<p class="answer">
      The number of tracks is limited by the storage space needed, if you need more space we recommend a <a href="/rd/upgrade/">premium account</a>. 
</p>
<br />
<h2 class="bb lightbg">Premium</h2>
<h3>How can I sign up to the Premium Service?</h3>
<p class="answer">
	Just click on "Upgrade" in the main interface in order to show instructions on how to upgrade.
</p>
<h3>How can I pay?</h3>
<p class="answer">
	We currently support PayPal.
</p>

<br />
<h2 class="bb lightbg">Legal</h2>

<h3>Is the service legal?</h3>
<p class="answer">
      Yes, tunesBag can only be used to manage music you've already acquired. Sharing (Streaming) is subject to territorial licence agreements.
</p>
<br />
<h2 class="lightbg bb">Common</h2>

<h3>Where is the company located?</h3>
<p class="answer">
      The HQ of tunesBag is based in Vienna, Austria.
</p>
 
<h3>What about the team?</h3>
<p class="answer">
      We are a team of music lovers sharing the vision of creating the music service we would like to have legally.
</p>
 
<h3>How does tunesBag make money?</h3>
<p class="answer">
      tunesBag is generating revenues out of advertisement and premium services. 
</p>

<h3>What's the business strategy?</h3>
<p class="answer">
      Create a sustainable and legal business. 
</p>
<br /><br />
	
<!--- 
<h1>FAQ - Frequently asked questions</h1>
<a href="/rd/contact/">Contact us in case of further questions!</a>
<br /><br />
<h2 class="bb">What is tunesBag?</h2>
<br />
<div style="line-height:200%;width:600px;padding-left:70px;">
tunesBag is an online audio library where you can upload your own music. The product enables you to listen to your tracks and playlists from any computer connected to the internet.
</div>
<h2 class="bb">Legal</h2>
<br />
<h4>Is tunesBag a legal service?</h4>
<div style="line-height:200%;width:600px;padding-left:70px;">
<b>Yes</b>, tunesBag can only be used to manage music you already have. You can share your library with friends according to the law in Austria (Privatkopie).
<br /><br />
<b>Austrian law</b>
<br />
§ 42 UrhG. (1) Jedermann darf von einem Werk einzelne Vervielfältigungsstücke auf Papier oder einem ähnlichen Träger zum eigenen Gebrauch herstellen.
<br />
(4) Jede natürliche Person darf von einem Werk einzelne Vervielfältigungsstücke auf anderen als den in Abs. 1 genannten Trägern zum privaten Gebrauch und weder für unmittelbare noch mittelbare kommerzielle Zwecke herstellen.
<br />
(5) Eine Vervielfältigung zum eigenen oder privaten Gebrauch liegt vorbehaltlich der Abs. 6 und 7 nicht vor, wenn sie zu dem Zweck vorgenommen wird, das Werk mit Hilfe des Vervielfältigungsstückes der Öffentlichkeit zugänglich zu machen. Zum eigenen oder privaten Gebrauch hergestellte Vervielfältigungsstücke dürfen nicht dazu verwendet werden, das Werk damit der Öffentlichkeit zugänglich zu machen.
<br />
Source: <a href="http://www.ris.bka.gv.at" target="_blank">www.ris.bka.gv.at</a>
<br />
Further information: <a href="http://www.internet4jurists.at/urh-marken/immaterial.htm" target="_blank">i4j.at</a>
<br /><br />
</div>
<h4>How much does tunesBag cost?</h4>
<div style="line-height:200%;width:600px;padding-left:70px;">
<b>It's free!</b> At least at the moment all services are offered at zero, null, nada. This might change in the future for premium services.
</div><br /><br />
<h2 class="bb">Technical</h2>
<br />
<h4>How much can I upload?</h4>
<div style="line-height:200%;width:600px;padding-left:70px;">
During the beta version we apply a fair-use policy - you are allowed to upload as much as you would like to but ask you to contact us if you want to upload more than 5 - 7 GB.
</div>
<h4>Which files can I upload?</h4>
<div style="line-height:200%;width:600px;padding-left:70px;">
We support the most popular formats - MP3 and WMA. Other formats will be supported in future versions, but let's face it - we have a standard (MP3). DRM protected files (the infamous m4a / m4p etc files) are not supported.
</div>
<h4>Do I have to install any software in order to use tunesBag</h4>
<div style="line-height:200%;width:600px;padding-left:70px;">
No. A recent version of flash is all you need. Our uploader application need to be installed but this takes just about a minute.
</div>
<h4>Can I upload my complete iTunes library?</h4>
<div style="line-height:200%;width:600px;padding-left:70px;">
<b>Yes</b>, we offer a native uploader for Apple iTunes &amp; Winamp. You can upload either your whole library or just certain playlists.
</div>
<h4>Is there an API so that I can develop my own applications?</h4>
<div style="line-height:200%;width:600px;padding-left:70px;">
Yes, there will be an API for our services. <a href="http://groups.google.com/group/tunesbagcom" target="_blank">Please join our Google Group in order to be notified about the start.</a>
</div> --->

</cfsavecontent>
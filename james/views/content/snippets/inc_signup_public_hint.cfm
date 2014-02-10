<!--- 

	a special handler for visitors coming from google search requests
	
	cgi.REMOTE_ADDR IS '80.108.10.9' AND 

 --->

<!--- <div>
<iframe border="0" style="border:0px" frameborder="0"  src="http://www.moosify.com/widgets/explorer/?partner=tunesbag" width="720" height="90"></iframe>
<div style="clear:both"></div>
</div> --->


<!--- 

	coming from google and the referer is given and it includes a query string
	
 --->

<!--- <cfexit method="exittemplate" /> --->

<!--- 
<cfif FindNoCase( 'google', cgi.HTTP_REFERER ) GT 0 AND ReFindNoCase('q=.',cgi.HTTP_REFERER ) GT 0>

<!--- select the latest string the user has searched for --->
<!--- <cfquery name="qSelectKeywords" datasource="mytunesbutlerlogging">
SELECT
	keywords
FROM
	referer_log
WHERE
	urltoken = <cfqueryparam cfsqltype="cf_sql_varchar" value="#session.SessionID#">
ORDER BY
	dt_created DESC
LIMIT
	1
;
</cfquery> --->

	<!--- keyword found? --->
	<!--- <cfif qSelectKeywords.recordcount GT 0> --->
		<div class="b_all status" style="-moz-border-radius: 6px;-webkit-border-radius: 6px;margin-right:20px;margin-bottom:10px;padding:0px;background-image:URL(http://deliver.tunesbagcdn.com/images/ads/tunesbag-playlist-woman-laptop-small.jpg);background-position: left -30px;background-repeat:no-repeat;" id="idSignupHintBox">
			<cfoutput>

			<!--- <p class="" style="border:0px;-moz-border-radius: 6px;-webkit-border-radius: 6px;margin:0px;padding:10px;font-weight:bold; background-image:url(http://deliver.tunesbagcdn.com/images/skins/default/bg2ndNav-active.png);background-repeat:repeat-x;color:white">Interested in "<i>#htmleditformat( qSelectKeywords.keywords )#</i>"?</p> --->
			<p style="margin:0px;padding:12px;color:black;font-weight:bold;font-size:12px;padding-left:300px;line-height:150%" class="">
				
			<!--- Login now <b>for free</b> using your <!--- <a href="/rd/signup/" onclick="pageTracker._trackPageview( '/signup/se-hint/' )"> ---><!--- <img src="http://deliver.tunesbagcdn.com/images/partner/services/facebook.png" class="si_img" alt="Facebook" /> ---> Facebook<!--- </a> --->, 
			<!--- <a href="/rd/signup/" onclick="pageTracker._trackPageview( '/signup/se-hint/' )"> ---><!--- <img src="http://deliver.tunesbagcdn.com/images/partner/services/googlebookmark.png" class="si_img" alt="Google" /> ---> Google<!--- </a> ---> or
			<!--- <a href="/rd/signup/" onclick="pageTracker._trackPageview( '/signup/se-hint/' )">#application.udf.si_img( 'email' )# ---> Email<!--- </a> ---> account
			
			and explore playlists with this artist/track.
			<br />
			tunesBag provides you with enough space to <b>upload your own tunes and playlists</b> as well!<!---  <a href="/rd/signup/" onclick="pageTracker._trackPageview( '/signup/se-hint/' )">Continue ...</a> --->
			<br /> --->
			
			<!--- Join tunesBag now to get 1000 MB storage for free in order to upload your own tracks and playlists! Use your Facebook or Google account! --->
			
			Hi there -
			<br />
			tunesBag is a service which enables you to listen to your tracks using any browser and share your playlists with friends!
			
			<br />
			<input type="button" value=" Limited offer: Signup now and get 1000 MB for free! " class="btn btnred" onclick="pageTracker._trackPageview( '/signup/se-hint/' );location.href='/rd/signup/';return false" style="margin-top:8px;-moz-border-radius: 4px;" />
<!--- 			<br /><br />
			<a href="/rd/iphone/appstore/"><img src="http://cdn.tunesbag.com/images/partner/app_store_badge.png" width="150" height="49" alt="" title="App Store" /></a> --->
			</p>
			
			</cfoutput>
		</div>
		
		<!--- <script type="text/javascript">
			window.setTimeout( function() {
				$('#idSignupHintBox').slideDown();
				}, 1000);
		</script> --->
	
	<!--- </cfif> --->
</cfif> --->
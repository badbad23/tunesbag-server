<!---

	tracking 

	add google analytics and our own Piwik tracker

 --->

<cfparam name="request.bSubscribers" type="boolean" default="false" />

<cfif request.bSubscribers>
	<cfset sPiwikCode = application.PiwikSiteIDSubscribers />
	<cfset sGoogleCode = application.GoogleAnalyticsCodeSubscribers />
<cfelse>
	<cfset sPiwikCode = application.PiwikSiteID />
	<cfset sGoogleCode = application.GoogleAnalyticsCode />	
</cfif>

<!--- <script type="text/javascript">
var gaJsHost = (("https:" == document.location.protocol) ? "https://ssl." : "http://www.");
document.write(unescape("%3Cscript src='" + gaJsHost + "google-analytics.com/ga.js' type='text/javascript'%3E%3C/script%3E"));
</script>
<script type="text/javascript">
var pageTracker = _gat._getTracker("<cfoutput>#sGoogleCode#</cfoutput>");
pageTracker._initData();
pageTracker._setDomainName("<cfoutput>#application.GoogleAnalyticsDomains#</cfoutput>");
pageTracker._trackPageview();


</script> --->


<script type="text/javascript">

  var _gaq = _gaq || [];
  _gaq.push(['_setAccount', '<cfoutput>#sGoogleCode#</cfoutput>']);
  _gaq.push(['_setDomainName', '<cfoutput>#application.GoogleAnalyticsDomains#</cfoutput>']);
  _gaq.push(['_trackPageview']);

  (function() {
    var ga = document.createElement('script'); ga.type = 'text/javascript'; ga.async = true;
    ga.src = ('https:' == document.location.protocol ? 'https://ssl' : 'http://www') + '.google-analytics.com/ga.js';
    var s = document.getElementsByTagName('script')[0]; s.parentNode.insertBefore(ga, s);
  })();

</script>
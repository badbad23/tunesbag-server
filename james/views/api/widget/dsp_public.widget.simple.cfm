<!---

	Simple widget

--->

<cfinclude template="/common/scripts.cfm">

<cfparam name="url.username" type="string" default="">
<cfparam name="url.bgcolor" type="string" default="white">

<cfset a_struct_user_profile = event.getArg( 'a_struct_user_profile' ) />

<cfif NOT IsStruct( a_struct_user_profile ) OR NOT a_struct_user_profile.result>
	<b>No profile available for user <cfoutput>#htmleditformat( url.username )#</cfoutput></b>
	<cfexit method="exittemplate">
</cfif>

<cfset q_select_favourite_artists = a_struct_user_profile.q_select_favourite_artists />
<cfset q_select_genre_cloud = a_struct_user_profile.q_select_genre_cloud_of_user />
<cfset q_select_playlists = a_struct_user_profile.q_select_playlists />
<cfset a_userdata = a_struct_user_profile.a_userdata />

<!--- add random cols to the various queries ... --->
<cfset QueryAddColumn( q_select_favourite_artists, 'rand', 'Integer', ArrayNew(1) ) />

<cfloop query="q_select_favourite_artists">
	<cfset QuerySetCell( q_select_favourite_artists, 'rand', RandRange( 1, 99999), q_select_favourite_artists.currentrow) />
</cfloop>

<cfquery name="q_select_favourite_artists" dbtype="query">
SELECT
	*
FROM
	q_select_favourite_artists
ORDER BY
	rand
;
</cfquery>

<cfquery name="q_select_genre_cloud" dbtype="query">
SELECT
	*
FROM
	q_select_genre_cloud
ORDER BY
	genre_count DESC
;
</cfquery>

<cfquery name="q_select_playlists" dbtype="query">
SELECT
	*
FROM
	q_select_playlists
WHERE
	[public] = 1
;
</cfquery>

<cfquery name="q_select_lastplayed" datasource="mytunesbutlerlogging" cachedwithin="#CreateTimeSpan( 0, 0, 5, 0 )#">
SELECT
	playeditems.mediaitemkey,
	mediaitems.name,
	mediaitems.artist,
	mediaitems.mb_artistid,
	info.img_revision
FROM
	playeditems
INNER JOIN
	 mytunesbutleruserdata.mediaitems AS mediaitems ON
	 	(mediaitems.entrykey = playeditems.mediaitemkey)
LEFT JOIN
	mytunesbutlercontent.common_artist_information AS info ON (info.artistid = mediaitems.mb_artistid)
WHERE
	playeditems.userkey = <cfqueryparam cfsqltype="cf_sql_varchar" value="#a_userdata.getEntrykey()#">
ORDER BY
	playeditems.dt_created DESC			
LIMIT
	5
;
</cfquery>

<html>
	<head>
		
		<title><cfoutput>#htmleditformat( a_userdata.getUsername() )# @ tunesBag.com</cfoutput></title>
		
		<link rel="stylesheet" href="/res/css/default.css" />


		<style type="text/css" media="all">
			body {
				padding:0px;
				margin:0px;
				font-family:"Lucida Grande",Tahoma,Arial;
				font-size:11px;
				background-color:<cfoutput>#htmleditformat( url.bgcolor )#</cfoutput>;
				}
			td,p,div {
				font-size:11px;
				}
			a {
				text-decoration:none;
				color:#3B5998;
				}
			a:hover {
				text-decoration:underline;
				}
			div.logo {
				background-color:rgb(63,63,63);
				font-size:12px;
				color:white;
				font-weight:bold;
				padding:4px;
				background-image:URL(http://deliver.tunesbagcdn.com/images/skins/default/bgPieceOfheaven.jpg);
				
				}
			div.header {
				background-color:rgb(63,63,63);
				color: rgb(051,051,051);

				font-weight: bold;
				text-transform:uppercase;
				background-image:URL(http://deliver.tunesbagcdn.com/images/skins/default/bg2ndNav.png);
				padding:2px;
				}
			div.container {
				padding:3px;
				}
			img.si_img {
				vertical-align:middle;
				height:16px;
				width:16px;
				padding:2px;
				}
				
			img.artwork {
				border:0px
				}
		</style>
		<base target="_blank" />
	</head>
<body>
	

<div class="logo">
	
	<cfoutput>
	#application.udf.writeDefaultImageContainer( application.udf.getUserImageLink( a_userdata.getUsername(), 75 ),
								a_userdata.getUsername(),
								'http://www.tunesBag.com/user/#htmleditformat( url.username )#?#application.udf.generateGAURLParams( 'widget', 'simplewidget', 'widget', 'user' )#',
								38,
								false,
								true )#
	</cfoutput>
								
<!--- 			<img src="<cfoutput>#application.udf.getUserImageLink( a_userdata.getUsername(), 48 )#</cfoutput>" width="40" height="40" border="0" alt="" style="float:left;padding:4px" /> --->
			
		
			
			<a target="_blank" href="http://www.tunesBag.com/user/<cfoutput>#htmleditformat( url.username )#</cfoutput>?<cfoutput>#application.udf.generateGAURLParams( 'widget', 'simplewidget', 'widget', 'user' )#</cfoutput>" target"_blank" style="color:white;">I'm <cfoutput>#htmleditformat( url.username )#</cfoutput>
			<br />
			on tunesBag.com</a>

			

<div style="clear:both"></div>
</div>
<div class="header">
	<cfoutput>#application.udf.si_img( 'lightning' )# #application.udf.GetLangValSec( 'cm_ph_playlist_recently_played' )#</cfoutput>
</div>
<div class="container">
	
	<table>
	<cfoutput query="q_select_lastplayed">
		<tr>
			<td>
				
				#application.udf.writeDefaultImageContainer( application.udf.getArtistImageByID( q_select_lastplayed.mb_artistid, 48, q_select_lastplayed.img_revision ),
								q_select_lastplayed.name,
								application.udf.generateArtistURL( q_select_lastplayed.artist, q_select_lastplayed.mb_artistid ) & '?' & application.udf.generateGAURLParams( 'widget', 'simplewidget', 'widget', 'artist' ),
								30,
								false,
								true )#
				
			</td>
			<td>
				#htmleditformat( application.udf.ShortenString( q_select_lastplayed.name, 20) )#
				<br />
				#application.udf.GetLangValSec( 'cm_wd_by' )# <a target="_blank" href="#application.udf.generateArtistURL( q_select_lastplayed.artist, q_select_lastplayed.mb_artistid )#?#application.udf.generateGAURLParams( 'widget', 'simplewidget', 'widget', 'artist' )#">#htmleditformat( q_select_lastplayed.artist )#</a>
			</td>
		</tr>	
	</cfoutput>
	</table>

</div>

<div class="header">
	<cfoutput>#application.udf.si_img( 'page_white_cd' )# #application.udf.GetLangValSec( 'cm_wd_playlists' )#</cfoutput>
</div>
<div class="container">
<cfoutput query="q_select_playlists">
	<a title="#htmleditformat( q_select_playlists.description )#" target="_blank" href="#generateURLToPlist( q_select_playlists.entrykey, q_select_playlists.name , true)##application.udf.generateGAURLParams( 'widget', 'simplewidget', 'widget', 'playlist' )#">#htmleditformat( q_select_playlists.name )#</a>,&nbsp;
</cfoutput>...
</div>

<div class="container">
	<cfoutput>
		
		<a target="_blank" href="/user/#UrlEncodedformat( url.username )#?#application.udf.generateGAURLParams( 'widget', 'simplewidget', 'widget', 'user' )#">#application.udf.GetLangValSec( 'cm_ph_view_full_profile' )#</a>
		|
		<a target="_blank" href="/rd/signup/?#application.udf.generateGAURLParams( 'widget', 'simplewidget', 'widget', 'signup' )#">#application.udf.GetLangValSec( 'signup_ph_snup_now' )#</a>
	
	</cfoutput>
</div>


<script type="text/javascript">
var gaJsHost = (("https:" == document.location.protocol) ? "https://ssl." : "http://www.");
document.write(unescape("%3Cscript src='" + gaJsHost + "google-analytics.com/ga.js' type='text/javascript'%3E%3C/script%3E"));
</script>
<script type="text/javascript">
var pageTracker = _gat._getTracker("<cfoutput>#application.GoogleAnalyticsCode#</cfoutput>");
pageTracker._initData();
pageTracker._setDomainName(".tunesbag.com");
pageTracker._trackPageview();
</script>


</body>
</html>

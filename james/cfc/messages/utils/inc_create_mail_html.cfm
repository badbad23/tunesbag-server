<!--- html mail test --->
<cfprocessingdirective pageencoding="utf-8" />
<cfoutput>
<html>
	<head>
		<title>#htmleditformat( arguments.sSubject )#</title>
		<style type="text/css">
			body,a,div,p,td {font-family:'Lucida Grande',Arial,Tahoma;font-size:12px;line-height:140%;}
			h4 { margin-bottom:8px; }
		</style>
	</head>
<body style="padding:0px;background-color:white;margin:0px" margintop="0">

<table style="width:680px;padding-top:20px;border-radius: 6px; -moz-border-radius: 6px;-webkit-border-radius: 6px;" width="680" align="center" cellpadding="4" cellspacing="0">
	<tr>
		<td>
			<a href="http://www.tunesBag.com/?#application.udf.generateGAURLParams( 'email', arguments.sCampaign, 'email', 'logo' )#" title="Open tunesBag.com"><img src="http://cdn.tunesBag.com/images/newsletter/logoNewsletter.png" width="162" height="48" border="0" alt="tunesBag.com" style="padding-bottom:8px" /></a>
		</td>
		<td style="font-size:16px" align="right">
			<b>#htmleditformat( arguments.sSubject )#</b>
		</td>
	</tr>
	<tr>
		<td style="padding:8px;font-size:14px;color:white;font-weight:bold;background-color:##ac2405;background-image:url(http://cdn.tunesBag.com/images/skins/default/bg2ndNav-active.png)" valign="middle">
			
			<cfif arguments.bIsRegisteredUser>
				#application.udf.GetLangValSec( 'nav_welcome_back_username', stUserData.firstname )#!
			<cfelse>
				#application.udf.GetLangValSec( 'cm_ph_salutation_hi' )#
			</cfif>
		</td>
		<td align="right" style="padding:8px;background-color:##ac2405;background-image:url(http://cdn.tunesBag.com/images/skins/default/bg2ndNav-active.png)" valign="middle">
			<cfif arguments.bIsRegisteredUser>
				<a href="http://www.tunesBag.com/rd/start/?#application.udf.generateGAURLParams( 'email', arguments.sCampaign, 'email', 'login' )#" style="color:white;font-weight:bold;">#application.udf.GetLangValSec( 'cm_wd_btn_login' )#</a>
			<cfelse>
				&nbsp;
			</cfif>
		</td>
	</tr>
	<tr>
		<td colspan="2" style="border:silver solid 1px;padding:12px;padding-top:20px;line-height: 160%">
			#arguments.sHTMLContent#
		</td>
	</tr>
	<tr>
		<td colspan="2" style="border: silver solid 1px;border-top-width:0px;padding:8px;text-align:center" align="center">
			<a target="_blank" href="http://www.addthis.com/bookmark.php?pub=tunesbag&url=http%3A%2F%2Fwww.tunesBag.com%2F&title=tunesBag+Online+Music+Library" title="Bookmark and Share"><img src="http://www.tunesBag.com/res/images/partner/button1-share.gif" width="125" height="16" border="0" alt="Bookmark and Share" /></a>
			<a target="_blank" href="http://www.addthis.com/bookmark.php?pub=tunesbag&url=http%3A%2F%2Fwww.tunesBag.com%2F&title=tunesBag+Online+Music+Library" title="Bookmark and Share"> Share / Bookmark tunesBag.com</a>
		</td>
	</tr>
	<tr>
		<td colspan="2" style="border: silver solid 0px;padding:12px;border-top:0px;color:##828282">
		<p>
		<a style="color:##272727" href="http://feedback.tunesBag.com/?#application.udf.generateGAURLParams( 'email', arguments.sCampaign, 'email', 'feedback' )#">#application.udf.GetLangValSec( 'cm_ph_suggestions_vote_features' )#</a>
		|
		<a style="color:##272727" href="http://blog.tunesBag.com/?#application.udf.generateGAURLParams( 'email', arguments.sCampaign, 'email', 'blog' )#">#application.udf.GetLangValSec( 'nav_blog' )#</a>
		|
		<a style="color:##272727" href="http://www.tunesBag.com/rd/contact/?#application.udf.generateGAURLParams( 'email', arguments.sCampaign, 'email', 'contact' )#">#application.udf.GetLangValSec( 'nav_wd_contact' )#</a>
		<cfif arguments.bIsRegisteredUser AND arguments.bNewsletter>
		|
		<a style="color:##272727" href="http://www.tunesBag.com/newsletter/unsubscribe.cfm?username=#urlencodedformat( stUserData.username )#&emailhash=#Hash( stUserData.email )#">#application.udf.GetLangValSec( 'cm_wd_btn_unsubscribe' )#</a>
		</cfif>
		</p>
		<p>
		#application.udf.GetLangValSec( 'mail_ph_newsletter_reason_email' )#
		<br />
		tunesBag is a product of tunesBag.com Limited, Private company incorporated in England &amp; Wales.
		<br />
		Our mailing address is: tunesBag.com Limited | 69 Great Hampton St | Birmingham, B18 6EW | UK
		</p>
		</td>
	</tr>
</table>
	
</body>
</html>
</cfoutput>
<!--- info about apps --->

<div class="headlinebox">
	<p class="title"><cfoutput>#application.udf.GetLangValSec( 'cm_wd_applications_short' )#</cfoutput></p>
	<p><cfoutput>#application.udf.GetLangValSec( 'cm_ph_applications_description' )#</cfoutput></p>
</div>

<cfoutput>
<div style="padding:60px;padding-top:20px">
	<table class="table_overview">
		<tr>
			<td style="text-align:center;padding:12px" class="">
				<a href="/rd/iphone/appstore/" target="_blank"><img src="http://cdn.tunesBag.com/images/partner/app_store_badge.png" style="border:0px" alt="#application.udf.GetLangValSec( 'app_ph_iphone_title' )#" title="#application.udf.GetLangValSec( 'app_ph_iphone_title' )#" /></a>
			</td>
			<td style="padding:12px">
				<a href="/rd/iphone/appstore/" target="_blank"><h3>#application.udf.GetLangValSec( 'app_ph_iphone_title' )#</h3></a>
				<p style="padding-top:8px">
					#application.udf.GetLangValSec( 'app_ph_iphone_desc' )#
				</p>
				<br />
				<p>
					<a href="/rd/iphone/appstore/" target="_blank">#application.udf.GetLangValSec( 'lib_upload_download_software' )#</a>
				</p>
			</td>
		</tr>
		<tr>
			<td style="text-align:center;padding:12px" class="bt">
				<a href="/rd/desktopradio/" target="_blank"><img src="http://cdn.tunesBag.com/images/vista/My-PC.png" style="height:60px;border:0px" alt="#application.udf.GetLangValSec( 'app_ph_desktop_title' )#" title="#application.udf.GetLangValSec( 'app_ph_desktop_title' )#" /></a>
			</td>
			<td style="padding:12px" class="bt">
				<a href="/rd/desktopradio/" target="_blank"><h3>#application.udf.GetLangValSec( 'app_ph_desktop_title' )#</h3></a>
				<p style="padding-top:8px">
					#application.udf.GetLangValSec( 'app_ph_desktop_desc' )#
				</p>
				<br />
				<p>
					<a href="/rd/desktopradio/" target="_blank">#application.udf.GetLangValSec( 'lib_upload_download_software' )#</a>
				</p>
			</td>
		</tr>
		<tr>
			<td style="text-align:center;padding:12px" class="bt">
				<a href="/squeezenetwork/" target="_blank"><img src="http://tunesBag.com/res/images/content/sqbn/sqbn-prod1.jpg" style="height:60px;border:0px" alt="Logitech(r) Squeezenetwork" /></a>
			</td>
			<td style="padding:12px" class="bt">
				<a href="/squeezenetwork/" target="_blank"><h3>Logitech® Squeezenetwork&##0153;</h3></a>
				<p style="padding-top:8px">
					<!--- #application.udf.GetLangValSec( 'app_ph_desktop_desc' )# --->
					Enjoy your entire tunes collection using your Squeezebox without a running computer!
				</p>
				<br />
				<p>
					<a href="/squeezenetwork/" target="_blank"><!--- #application.udf.GetLangValSec( 'lib_upload_download_software' )# --->Setup now</a>
				</p>
			</td>
		</tr>
		<tr>
			<td style="text-align:center;padding:12px" class="bt">
				<a href="/dropbox/" target="_blank"><img src="/res/images/partner/services/dropbox-240x81.png" width="150" alt="" title="Dropbox logo" style="border: 0px" /></a>
			</td>
			<td style="padding:12px" class="bt">
				<a href="/dropbox/" target="_blank"><h3>Dropbox</h3></a>
				<p style="padding-top:8px">
					Connect your Dropbox account to tunesBag and all your media files will automatically appear in your tunesBag library ready to play! 
				</p>
				<br />
				<p>
					<a href="/dropbox/" target="_blank"><!--- #application.udf.GetLangValSec( 'lib_upload_download_software' )# --->Setup now</a>
				</p>
			</td>
		</tr>
		<tr>
			<td style="text-align:center;padding:12px" class="bt">
				<a href="/boxee/" target="_blank"><img style="height:60px;border:0px" src="http://cdn.tunesBag.com/images/partner/services/boxee_logo.png" alt="boxee app" /></a>
			</td>
			<td style="padding:12px" class="bt">
				<a href="/boxee/" target="_blank"><h3>boxee (HDTV)</h3></a>
				<p style="padding-top:8px">#application.udf.GetLangValSec( 'app_ph_boxee_desc' )#</p>
				<br />
				<p>
					<a href="/boxee/" target="_blank">#application.udf.GetLangValSec( 'cm_ph_show_more' )#</a>
				</p>
			</td>
		</tr>
	</table>
</div>
</cfoutput>
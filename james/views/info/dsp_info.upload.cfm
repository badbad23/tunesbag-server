<!--- //

	Module:		Upload information
	Action:		
	Description:	
	
// --->
<!--- 
<cfset a_struct_check_quota = event.getArg( 'a_struct_check_quota' ) />
 --->
<cfinclude template="/common/scripts.cfm">

<!--- request coming from dashboard? --->
<cfparam name="request.bDashboardRequest" type="boolean" default="false" />

<cfif NOT request.bDashboardRequest>
<div class="div_container bt">
	<br /><br />
<cfelse>
	
	<div class="div_container">
	<cfoutput>#application.udf.WriteSectionHeader( application.udf.GetLangValSec( 'lib_upload_info_title' ), '')#</cfoutput>

</cfif>

<!--- <div style="padding-left: 120px;color:gray" class="">
<cfoutput>#application.udf.WriteSectionHeader( application.udf.GetLangValSec( 'start_ph_start_upload' ), '')#</cfoutput>

<cfif NOT a_struct_check_quota.result>
	<div class="status">
		<cfoutput>#application.udf.GetLangValSec( 'err_ph_4100', application.udf.byteConvert( a_struct_check_quota.maxsize ) )#</cfoutput>
	</div>
</cfif>


</div> --->

<!--- <div style="padding-top:40px">
	<p class="">
<cfoutput>#application.udf.GetLangValSec( 'lib_upload_info_intro_possible_ways' )#</cfoutput>
</p>
</div> --->


<h2>Free: Upload to Dropbox</h2>

<div>


<form action="#">
	<div class="status">
				<img src="/res/images/partner/services/dropbox-240x81.png" style="height:48px;float:right" alt="" />
tunesBag supports Dropbox as storage for your media files.
<b>You will get 2 GB of space for free.</b>
<br /><br />
	<input type="button" value="Connect Dropbox and tunesBag" onclick="window.open('/dropbox/');return false" />
	</div>
</form>

</div>

<br /><br />
<h2>Premium - Upload to tunesBag</h2>
<p style="font-weight:bold">Premium users can upload their audio files directly to tunesBag - with up to 200GB of storage!</p>
<form action="#">
	<div class="confirmation">
	<input type="button" value="Show plans and prices" onclick="location.href='#tb:upgrade';return false" />
	</div>
</form>

<table cellpadding="0" cellspacing="0" class="tbl_td_top" style="width:600px;margin-left:auto;margin-right:auto">
<tr>
	<td style="width:50%;padding:18px">

	<a href="##" onclick="OpenUploadWindow( '<cfoutput>#application.udf.GetLangValSec( 'lib_upload_type_browser', false )#</cfoutput>' );LogReq( '/service/upload/browser/' );return false">
	<img src="http://cdn.tunesBag.com/images/vista/Web-page.png" style="width:120px;border:0px" alt="<cfoutput>#application.udf.GetLangValSec( 'lib_upload_type_browser' )#</cfoutput>">
	<h4><cfoutput>#application.udf.GetLangValSec( 'lib_upload_type_browser' )#</cfoutput></h4></a>
	<br />	
	<span class="tag_box tag_box_red"><cfoutput>#application.udf.GetLangValSec( 'lib_upload_type_browser_quick_dirty' )#</cfoutput></span>	
	<br /><br />
	<cfoutput>#application.udf.GetLangValSec( 'lib_upload_type_browser_info' )#</cfoutput>

	
	</td>
	<td style="width:50%;padding:18px">


	<img src="http://cdn.tunesBag.com/images/vista/My-Music.png" style="width:120px;border:0px" alt="<cfoutput>#application.udf.GetLangValSec( 'lib_upload_type_desktop' )#</cfoutput>">
	<h4><cfoutput>#application.udf.GetLangValSec( 'lib_upload_type_desktop' )#</cfoutput></h4>
	<br />
	<cfoutput>#application.udf.GetLangValSec( 'lib_upload_type_desktop_info' )#</cfoutput>
	<br /><br />
	

	<a href="/rd/download/uploader/win/" onclick="LogReq( '/service/upload/win32/' );" target="_blank"><img src="http://cdn.tunesBag.com/images/ico/ico-win.png" alt="Windows Uploader" style="border:0px;vertical-align:middle;padding:6px;">Windows (2000, XP, Vista, 7)</a>
	<br />
	<br />
	<a href="/rd/download/uploader/mac/" onclick="LogReq( '/service/upload/mac/' );" target="_blank"><img src="http://cdn.tunesBag.com/images/ico/ico-osx-uni.png" title="Mac Uploader" alt="Mac Uploader" style="vertical-align:middle;padding:6px;border:0px" /> Mac OS X (10.5 Leopard &amp; 10.6 Snow Leopard)</a>	

	</td>
	<!--- <td style="width:33%;padding:18px">
<cfset a_str_email_adr = application.udf.GetCurrentSecurityContext().username & '@incoming.tunesBag.com' />

	<a onclick="LogReq( '/service/upload/email/' );" href="mailto:<cfoutput>#a_str_email_adr#</cfoutput>">
	<img src="http://cdn.tunesBag.com/images/vista/Envelope.png" style="width:120px;border:0px">
	<h4><cfoutput>#application.udf.GetLangValSec( 'lib_upload_type_email' )#</cfoutput></h4></a>
	<br />
	<cfoutput>#application.udf.GetLangValSec( 'lib_upload_type_email_info', a_str_email_adr )#</cfoutput>

	
	</td> --->
</tr>
</table>

</div>
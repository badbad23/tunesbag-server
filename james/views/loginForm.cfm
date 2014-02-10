<!--- //

	Module:		Login form
	Description: 
	
// --->

<cfset a_bol_login_failed = event.getArg('loginfailed', false) />
<cfset a_str_return_url = event.getArg( 'returnurl' ) />

<!--- maybe an rpx key has been provided --->
<cfset sRPXKey = event.getArg( 'rpxkey' ) />

<cfset bRequestPassword = event.getArg( 'requestpassword', false ) />

<cfset event.setArg( 'PageTitle', application.udf.getLangValSec( 'nav_login' ) ) />

<cfsavecontent variable="request.content.final">

<table width="100%" cellpadding="8" cellspacing="0">
<tr>
<td valign="top" style="padding:12px;width:50%;line-height:160%<cfif Len( sRPXKey ) GT 0>;display:none</cfif>">
		<!--- <h2><cfoutput>#application.udf.GetLangValSec( 'signup_ph_snup_now' )#</cfoutput></h2> --->
		
		<h2><cfoutput>#application.udf.GetLangValSec( 'signup_ph_login_fb_etc' )#</cfoutput></h2>

		<cfset a_str_target_host = 'http://' & cgi.SERVER_NAME & ':' & cgi.SERVER_PORT & '/james/?event=login.rpxnow.landing' />

		<br />
		<iframe src="https://tunesbag.rpxnow.com/openid/embed?token_url=<cfoutput>#UrlEncodedFormat( a_str_target_host )#</cfoutput>&amp;language_preference=<cfoutput>#ListFirst( application.udf.GetCurrentLanguage(), '_' )#</cfoutput>&amp;flags=hide_sign_in_with"
	  		scrolling="no" frameBorder="no" style="width:400px;height:240px;margin-top:20px">
		</iframe>

		<p class="addinfotext" style="margin-bottom:20px">
			<cfoutput>#application.udf.GetLangValSec( 'signup_ph_3rd_party_linking' )#</cfoutput>
		</p>
	</td>
	<td valign="top" style="padding:12px;width:50%;">
	
	<h2 style="padding-bottom:12px"><cfoutput>#application.udf.GetLangValSec( 'login_ph_existing_user' )#</cfoutput></h2>
	
	<cfif a_bol_login_failed AND event.isArgDefined("message")> 
		<div class="status">
			
			<cfoutput>#application.udf.si_img( 'exclamation' )# #event.getArg("message")#</cfoutput>
			
		</div> 
	</cfif>
		
	<form action="index.cfm?event=processLoginAttempt" method="post" name="loginform" onsubmit="addSpinnerSubmit(this)"> 
		
	<!--- the return URL --->
	<input type="hidden" name="returnurl" id="idReturnURL" value="<cfoutput>#htmleditformat( a_str_return_url )#</cfoutput>" />
	
	<!--- rpx key to link to this account --->
	<input type="hidden" name="rpxkey" value="<cfoutput>#htmleditformat( sRPXKey )#</cfoutput>" />
		
	<table class="table_details table_edit tbl_bigform" cellspacing="0"> 
	<cfif Len( sRPXKey ) GT 0>
		<tr>
			<td class="field_name"><cfoutput>#application.udf.GetLangValSec( 'cm_wd_provider' )#</cfoutput></td>
			<td>
				<!--- display data --->
				
				<cfset stRPXData = event.getArg( 'stRPXData' ) />
				
				<cfif stRPXData.result>
					
					<cfoutput>#stRPXData.oitem.getprovider()#</cfoutput>
					
					<input type="hidden" name="provider" value="<cfoutput>#htmleditformat( stRPXData.oitem.getprovider() )#</cfoutput>" />
					
				</cfif>
				
			</td>
		</tr>
	</cfif>
	<tr> 
		<td class="field_name"><cfoutput>#application.udf.GetLangValSec( 'cm_wd_username' )#</cfoutput>:</td> 
		<td> 
			<input type="text" name="username" id="username" size="20" value="<cfoutput>#event.getArg( 'username', '' )#</cfoutput>" /> 
		</td> 
	</tr> 
	<tr>
		<td class="field_name"><cfoutput>#application.udf.GetLangValSec( 'cm_wd_password' )#</cfoutput>:</td> 
		<td> 
			<input type="password" name="password" size="20" /> 
		</td> 
	</tr> 
	<tr>
		<td class="field_name"></td>
		<td>
			<input type="submit" value="<cfoutput>#application.udf.GetLangValSec( 'cm_wd_btn_login' )#</cfoutput>" class="btn" /> 
		</td> 
	</tr> 
	<tr id="id_request_pwd_link">
		<td class="field_name"></td>
		<td>
			<a href="##" id="idRequestPwdLink" onclick="$('#id_request_pwd_link').hide();$('#id_request_pwd_form').show();return false"><cfoutput>#application.udf.GetLangValSec( 'login_ph_lost_password' )#</cfoutput></a>
		</td>
	</tr>
	
	<tr>
		<td class="field_name"><cfoutput>#application.udf.GetLangValSec( 'cm_wd_or' )#</cfoutput></td>
		<td>
			
			<cfoutput>
				<a href="/james/?event=register.start&amp;source=loginform&amp;no3rdparty=true" style="font-weight:bold;font-size:16px">#application.udf.GetLangValSec( 'signup_ph_using_email' )#</a>
<!--- 				<input type="button" class="btn btn_hl" value="#application.udf.GetLangValSec( 'signup_ph_using_email' )#" onclick="location.href = '/james/?event=register.start&amp;source=loginform'" /> --->
			</cfoutput>
		</td>
	</tr>
	
	<!--- <tr>
		<td class="field_name">
			<cfoutput>
			#application.udf.GetLangValSec( 'cm_wd_language' )#
			</cfoutput>
		</td>
		<td>
			<cfoutput>
			
			
			</cfoutput>
		</td>
	</tr> --->
	</table> 
	</form> 
	
	<cfif IsStruct( event.getArg( 'a_struct_send_pwd' ) )>
		<div class="confirmation">
			<cfoutput>#application.udf.GetLangValSec( 'login_ph_pwd_has_been_sent' )#</cfoutput>
		</div>
	</cfif>
		
	<form action="/james/?" method="get">
	<input type="hidden" name="event" value="showLoginForm" />
	<div id="id_request_pwd_form" style="display:none" class="status">
		
		<table class="table_details table_edit">
			<tr>
				<td colspan="2">
					<cfoutput>#application.udf.GetLangValSec( 'login_pg_lost_pwd_request_info' )#</cfoutput>
				</td>
			</tr>
			<tr>
				<td class="field_name">
					<cfoutput>#application.udf.GetLangValSec( 'cm_wd_username' )#</cfoutput>
				</td>
				<td>
					<input type="text" name="username_sendpwd" value="" />
				</td>
			</tr>
			<tr>
				<td class="field_name">
					
				</td>
				<td>
					<input type="submit" value="<cfoutput>#application.udf.GetLangValSec( 'login_ph_request_password' )#</cfoutput>" class="btn btn_hl" />
				</td>
			</tr>
			<tr>
				<td class="field_name"></td>
				<td>
					<a href="mailto:support@tunesBag.com?subject=Password"><cfoutput>#application.udf.GetLangValSec( 'login_ph_pwd_request_send_mail' )#</cfoutput></a>
				</td>
			</tr>
		</table>
		
	</div>
	</form>
	
</td>
	
</tr>
</table>

<script type="text/javascript">
	$("#username").focus();
	
	var sReturnURL = $('#idReturnURL').val();
	
	// nothing added yet?
	if (sReturnURL.indexOf( '#' ) == -1) {
		// add hash
		$('#idReturnURL').val( sReturnURL + location.hash );
		}

</script>

<cfif bRequestPassword>
	<!--- user wants to request the password --->
	<script type="text/javascript">
		$('#idRequestPwdLink').click();
	</script>
</cfif>

</cfsavecontent>
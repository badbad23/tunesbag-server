<!--- //

	Module:		Start reg
	Action:		
	Description:	
	
// --->

<cfprocessingdirective pageencoding="utf-8">

<cfinclude template="/common/scripts.cfm">

<cfset a_int_error = event.getArg( 'error', 0 ) />

<!--- do we have an invitation? --->
<cfset a_struct_invitation = event.getArg( 'a_invitation_check' ) />
<cfset a_bol_invitation = IsStruct( a_struct_invitation ) AND a_struct_invitation.result />
<cfset a_str_invitation_key = event.getArg( 'invitationkey' ) />

<cfset a_str_loadfromsource = event.getArg( 'loadfromsource' ) />

<!--- no 3rd party signup offer (coming from login page ...) --->
<cfset bNo3rdPartyBox = Val(event.getArg( 'no3rdparty', false )) />

<!--- select list of countries --->
<cfset q_select_countries = getProperty( 'beanFactory' ).getBean( 'UserComponent' ).GetCountryList() />

<!--- current country --->
<cfset a_str_country = getProperty( 'beanFactory' ).getBean( 'LicenceComponent' ).IPLookupCountry( cgi.REMOTE_ADDR ) />

<cfif a_bol_invitation AND Len( a_struct_invitation.oItem.getUserkey() ) GT 0 AND a_struct_invitation.a_user_data.result>
	<cfset a_invitor_user = a_struct_invitation.a_user_data.a_struct_item />
</cfif>

<cfset event.setArg( 'PageTitle', application.udf.getLangValSec( 'signup_ph_snup_now' ) ) />

<cfsavecontent variable="request.content.final">

<cfif a_int_error GT 0>
	<cfoutput>#application.udf.WriteCommonErrorMessage( a_int_error )#</cfoutput>
</cfif>


<cfset sCampaign = event.getArg( 'utm_campaign', '' ) />

<cfswitch expression="#sCampaign#">
	<cfcase value="fbsignup20052010">
		
		<div class="status" style="margin-right:30px;height:140px;overflow:auto;padding:12px;line-height:200%">
			<img style="float:right;padding-left:20px" src="http://2.bp.blogspot.com/_o9WN2e1C4No/S_VLrIye5FI/AAAAAAAAAbQ/MLZYpkbRo0s/s400/fb-becomefan.jpg" alt="Signup" />
			<h3>Tell your friends on Facebook which artists you like with a simple click</h3>
			
			<p style="font-weight:bold;">tunesBag is a web-based mediaplayer where you can upload your entire music collection or just your favourite playlists in order to access them anywhere and anytime.</p>
			<p>
				It's now easier than ever to tell your friends on Facebook which artists you like! Below the player you'll now find the famous "Like" - Button and a list of friends and other users who also like the artist of the track you're currently listening to.
				<br />
If you click on this button, a short item in your newsfeed on Facebook will be created (see the screenshot on the right) - a great way to tell your friends which artists you like and show your support for this artist! The list of your favourite artists in your Facebook profile will be updated as well.
<br />
<b>Facebook Like = Fan on tunesBag as well</b>
<br />
When you click on the "Like" - button you'll become a fan of this artist on tunesBag as well - there's no need to click several buttons, just use the "Like" - Button and you're done!


			</p>
		</div>
		
		<cfset a_str_invitation_key = 'fbsignup20052010' />
	</cfcase>
</cfswitch>

<!--- <cfif event.getArg( 'loadfromsource' ) IS 'facebook'>
<cfdump var="#event.getargs()#">


</cfif> --->

<!--- <cfdump var="#event.getargs()#"> --->

<!--- we have an invitation --->
<cfif a_bol_invitation>

<!--- auto - insert the provided email address of the inviting person! --->
<cfif a_struct_invitation.result AND application.udf.ExtractEmailAdr( a_struct_invitation.oItem.getRecipient() ) GT 0 AND Len( event.getArg('frmemail') ) IS 0>

	<cfset event.setArg( 'frmemail', a_struct_invitation.oItem.getRecipient() ) />

</cfif>


	<div class="status">
		
		<!--- invitation by a user --->
		<cfif a_struct_invitation.result AND Len( a_struct_invitation.oItem.getUserkey() ) GT 0>
		<table class="table_overview" style="width:auto">
			<tr>
				<cfif Len( a_invitor_user.getpic() ) GT 0>
				<td>
					<img src="<cfoutput>#a_invitor_user.getpic()#</cfoutput>" width="70" align="absmiddle" />
				</td>
				</cfif>
				<td>
					
					<cfset a_arr_replace = ArrayNew( 1 ) />
					<cfset a_arr_replace[ 1 ] = a_invitor_user.getfirstname() />
					<cfset a_arr_replace[ 2 ] = a_invitor_user.getUsername() />
					
					<cfoutput>#ReplaceNoCase( application.udf.GetLangValSec( 'signup_ph_invitation_hint', a_arr_replace ), Chr(10), '<br />', 'ALL')#</cfoutput>
				
				</td>
			</tr>
		</table>
		<cfelse>
		
			<!--- invitation by a KEYWORD without a certain user --->
			<cfoutput>#application.udf.GetLangValSec( 'signup_ph_invitation_hint_keyword' )#</cfoutput>
		
		</cfif>
	
	</div>
</cfif>
<table cellpadding="12" cellspacing="0" border="0">
<tr>
<td valign="top" style="padding:12px">
<h2><cfoutput>#application.udf.GetLangValSec( 'signup_ph_title' )#</cfoutput></h2>
<br />

<cfsavecontent variable="sHtmlHead">
<script type="text/javascript">
	function submitVerifyData() {
		
		if ($('#frmcatc').attr( 'checked' ) == false) {
			alert('<cfoutput>#JSStringFormat( application.udf.GetLangValSec( 'err_ph_5005'))#</cfoutput>');
			return false;
			}
			
		if ($('#regform').hasClass( 'verificationdone')) {
			return true;
			}
		
		$('#idPleaseRecheck').show();
		
		$('#regform .datacheck').show();
		
		$('#regform input[type=text]').addClass( 'borderless lightbg' );
		$('#regform input[type=password]').addClass( 'borderless lightbg' );
		$('#regform select').addClass( 'borderless lightbg' );
		
		$('#idSubmitBtn').addClass( 'btnred' );
		
		// $('#idSubmitBtnContainer').addClass( 'status' );
		
		$('#regform').addClass( 'verificationdone' );
		
		return false;
		}
		
	function switchBackToEditMode() {

		$('#idPleaseRecheck').slideUp();
		
		$('#regform .datacheck').hide();
		
		$('#regform input').removeClass( 'borderless' ).removeClass( 'lightbg' );
		$('#regform select').removeClass( 'borderless' ).removeClass( 'lightbg' );
		
		$('#idSubmitBtn').removeClass( 'btnred' );
		
		}
		

</script>

<style type="text/css">
	.borderless {
		border: 0px !important;
		}
		
	.datacheck {
		display: none;
		}
</style>
</cfsavecontent>

<cfhtmlhead text="#sHTMLHead#" />

<p class="confirmation hidden" id="idPleaseRecheck">
	<cfoutput>#application.udf.GetLangValSec( 'signup_ph_please_verify' )#</cfoutput>
</p>

<form action="index.cfm?event=register.AttempRegistration" method="post" name="regform" onsubmit="return submitVerifyData();" id="regform">

<input type="hidden" name="invitationkey" value="<cfoutput>#htmleditformat( event.getArg( 'invitationkey', '' ))#</cfoutput>" />
<input type="hidden" name="ext_facebook_uid" value="" />
<input type="hidden" name="ext_facebook_session_key" value="" />

<!--- ref --->
<cfif StructKeyExists( cookie, 'ref' ) AND Len( cookie.ref ) GT 0>
	<cfoutput>
	<input type="hidden" name="ref" value="#htmleditformat( cookie.ref )#" />
	
	<!--- has a custom invitation key? --->
	<cfif Len( a_str_invitation_key ) IS 0>
		<input type="hidden" name="frmsource" value="#htmleditformat( cookie.ref )#" />
	<cfelse>
		<input type="hidden" name="frmsource" value="#htmleditformat(a_str_invitation_key )#" />
	</cfif>
	
	</cfoutput>
	
<cfelse>
	<!--- default case, use invitation code --->
	<input type="hidden" name="frmsource" value="<cfoutput>#htmleditformat( a_str_invitation_key )#</cfoutput>" />	
</cfif>

<table class="table_details table_edit tbl_bigform" cellspacing="0">
	<tr>
		<td class="field_name">
			<label for="frmusername"><cfoutput>#application.udf.GetLangValSec( 'signup_ph_desired_username' )#</cfoutput>:</label>
		</td>
		<td>
			<input type="text" name="frmusername" id="frmusername" value="<cfoutput>#htmleditformat(event.getArg( 'frmusername' ))#</cfoutput>" />
			
			<span class="datacheck">
			<a href="#" onclick="switchBackToEditMode();return false"><cfoutput>#application.udf.si_img( 'pencil' )#</cfoutput></a>
			</span>
			<!--- <br />
			<cfoutput>#application.udf.GetLangVal( 'signup_ph_desired_username_will_be_shown_on_website' )#</cfoutput> --->
		</td>
	</tr>
	<tr>
		<td class="field_name">
			<label for="frmpassword"><cfoutput>#application.udf.GetLangValSec( 'signup_ph_desired_password' )#</cfoutput>:</label>
		</td>
		<td>
			<input type="password" id="frmpassword" name="frmpassword" value="<cfoutput>#htmleditformat( event.getArg( 'frmpassword' ))#</cfoutput>" />
			
			<span class="datacheck">
			<a href="#" onclick="switchBackToEditMode();return false"><cfoutput>#application.udf.si_img( 'pencil' )#</cfoutput></a>
			</span>
		</td>
	</tr>
	<!--- <tr>
		<td class="field_name">
			<label for="frmpassword2"><cfoutput>#application.udf.GetLangValSec( 'signup_ph_please_repeat' )#</cfoutput>:</label>
		</td>
		<td>
			<input type="password" name="frmpassword2" id="frmpassword2" value="" />
		</td>
	</tr> --->
	<tr>
		<td class="field_name">
			<label for="frmfirstname"><cfoutput>#application.udf.GetLangValSec( 'cm_wd_firstname' )#</cfoutput>:</label>
		</td>
		<td>
			<input type="text" name="frmfirstname" id="frmfirstname" value="<cfoutput>#htmleditformat(event.getArg('frmfirstname'))#</cfoutput>" />
			
			<span class="datacheck">
			<a href="#" onclick="switchBackToEditMode();return false"><cfoutput>#application.udf.si_img( 'pencil' )#</cfoutput></a>
			</span>
		</td>
	</tr>
	<tr style="display:none">
		<td class="field_name">
			<label for="frmsurname"><cfoutput>#application.udf.GetLangValSec( 'cm_wd_surname' )#</cfoutput>:</label>
		</td>
		<td>
			<input type="text" name="frmsurname" id="frmsurname" value="<cfoutput>#htmleditformat(event.getArg('frmsurname'))#</cfoutput>" />
			
			<span class="datacheck">
			<a href="#" onclick="switchBackToEditMode();return false"><cfoutput>#application.udf.si_img( 'pencil' )#</cfoutput></a>
			</span>
		</td>
	</tr>
	
	<tr>
		<td class="field_name">
			<label for="frmemail"><cfoutput>#application.udf.GetLangValSec( 'cm_wd_email' )#</cfoutput>:</label>
		</td>
		<td>
			<input type="text" name="frmemail" id="frmemail" value="<cfoutput>#htmleditformat(event.getArg('frmemail'))#</cfoutput>" />
			
			<span class="datacheck">
			<a href="#" onclick="switchBackToEditMode();return false"><cfoutput>#application.udf.si_img( 'pencil' )#</cfoutput></a>
			</span>
		</td>
	</tr>
	<tr>
		<td class="field_name">
			<label for="frmemail2"><cfoutput>#application.udf.GetLangValSec( 'signup_ph_confirm_email' )#</cfoutput>:</label>
		</td>
		<td>
			<input type="text" name="frmemail2" id="frmemail2" value="<cfoutput>#htmleditformat(event.getArg('frmemail2'))#</cfoutput>" />
			
			<span class="datacheck">
			<a href="#" onclick="switchBackToEditMode();return false"><cfoutput>#application.udf.si_img( 'pencil' )#</cfoutput></a>
			</span>
		</td>
	</tr>
	<tr style="display:none">
		<td class="field_name">
			<label for="frmcity"><cfoutput>#application.udf.GetLangValSec( 'cm_wd_city' )#</cfoutput>:</label>
		</td>
		<td>
			<input type="text" name="frmcity" id="frmcity" value="<cfoutput>#htmleditformat(event.getArg('frmcity'))#</cfoutput>" />
			
			<span class="datacheck">
			<a href="#" onclick="switchBackToEditMode();return false"><cfoutput>#application.udf.si_img( 'pencil' )#</cfoutput></a>
			</span>
		</td>
	</tr>	
	<tr>
		<td class="field_name">
			<label for="frmlang_id"><cfoutput>#application.udf.GetLangValSec( 'cm_wd_language' )#</cfoutput>:</label>
		</td>
		<td>
			
			<cfset sCurLang = application.udf.GetCurrentLanguage() />
			
			<select name="frmlang_id">
				<option value="en" <cfif sCurLang IS 'en'>selected="true"</cfif>>English (EN)</option>
				<option value="de" <cfif sCurLang IS 'de'>selected="true"</cfif>>German (DE)</option>
				<option value="es" <cfif sCurLang IS 'es'>selected="true"</cfif>>Español (ES)</option>
				<option value="fr" <cfif sCurLang IS 'fr'>selected="true"</cfif>>Français (FR)</option>
				<option value="it" <cfif sCurLang IS 'it'>selected="true"</cfif>>Italiano (IT)</option>
				<option value="tr" <cfif sCurLang IS 'tr'>selected="true"</cfif>>Türkçe (TK)</option>
				<option value="et" <cfif sCurLang IS 'et'>selected="true"</cfif>>Eesti keel (ET)</option>
				<option value="ru" <cfif sCurLang IS 'ru'>selected="true"</cfif>>русский язык (RU)</option>
				<option value="zh_cn" <cfif sCurLang IS 'zh_cn'>selected="true"</cfif>>Simplified Chinese (CN)</option>
			</select>
			
			<span class="datacheck">
			<a href="#" onclick="switchBackToEditMode();return false"><cfoutput>#application.udf.si_img( 'pencil' )#</cfoutput></a>
			</span>
		</td>
	</tr>
	<tr>
		<td class="field_name">
			<label for="frmcountry"><cfoutput>#application.udf.GetLangValSec( 'cm_wd_country' )#</cfoutput>:</label>
		</td>
		<td>
			
			<cfset a_str_current_country = event.getArg( 'frmcountry' ) />
			
			<cfif Len( a_str_current_country ) IS 0>
				<cfset a_str_current_country = a_str_country />
			</cfif>
			
			<select name="frmcountry">
				<option value="US" <cfif CompareNoCase( a_str_current_country, 'us' ) IS 0>selected</cfif>>United States</option>
				<option value="UK" <cfif CompareNoCase( a_str_current_country, 'uk' ) IS 0>selected</cfif>>United Kingdom</option>
				<option value="AT" <cfif CompareNoCase( a_str_current_country, 'at' ) IS 0>selected</cfif>>Austria</option>
				<option value="DE" <cfif CompareNoCase( a_str_current_country, 'de' ) IS 0>selected</cfif>>Germany</option>
				<option value="CH" <cfif CompareNoCase( a_str_current_country, 'ch' ) IS 0>selected</cfif>>Switzerland</option>
				<cfoutput query="q_select_countries">
					<option <cfif CompareNoCase( a_str_current_country, q_select_countries.iso ) IS 0>selected</cfif> value="#q_select_countries.iso#">#htmleditformat( q_select_countries.printable_name )#</option>
				</cfoutput>
			</select>
			<!--- <input type="text" name="frmcountry" id="frmcountry" value="<cfoutput>#htmleditformat(event.getArg( 'frmcountry' ))#</cfoutput>" /> --->
			
			<span class="datacheck">
			<a href="#" onclick="switchBackToEditMode();return false"><cfoutput>#application.udf.si_img( 'pencil' )#</cfoutput></a>
			</span>
		</td>
	</tr>
	<tr>
		<td class="field_name" style="text-align:right;">
			<input type="checkbox" value="1" name="frmcatc" id="frmcatc" style="width:auto" <cfif event.getArg( 'frmcatc' ) IS 1>checked</cfif> />
		</td>
		<td>
			<label for="frmcatc"><a href="/rd/terms/" target="_blank"><cfoutput>#application.udf.GetLangValSec( 'signup_ph_accept_ctac' )#</cfoutput></a></label>
		</td>
	</tr>
	<tr id="idSubmitBtnContainer">
		<td></td>
		<td>
			<input id="idSubmitBtn" type="submit" value="<cfoutput>#application.udf.GetLangValSec( 'signup_ph_signup_now_btn' )#</cfoutput>" class="btn" />
			
		</td>
	</tr>
</table>
</form>

</td>

<td valign="top" nowrap="true" style="padding:12px">
	
	<cfif NOT bNo3rdPartyBox>
		<h2><cfoutput>#application.udf.GetLangValSec( 'signup_ph_login_fb_etc' )#</cfoutput></h2>
	
		<cfset a_str_target_host = 'http://' & cgi.SERVER_NAME & ':' & cgi.SERVER_PORT & '/james/?event=login.rpxnow.landing' />

		<br />
		<iframe src="https://tunesbag.rpxnow.com/openid/embed?token_url=<cfoutput>#UrlEncodedFormat( a_str_target_host )#</cfoutput>&amp;language_preference=<cfoutput>#ListFirst( application.udf.GetCurrentLanguage(), '_' )#</cfoutput>&amp;flags=hide_sign_in_with"
	  		scrolling="no" frameBorder="no" style="width:400px;height:240px;margin-top:20px">
		</iframe>
		
	</cfif>
	
		<!--- <table cellpadding="12" cellspacing="0" border="0">
		<tr>
			<td valign="top" style="padding:12px">
			<h2>Join now for free and enjoy these services</h2>
			<br /><br />
			<ul class="ul_img_points">
				
				<li>
					Upload and access your music anywhere you want
				</li>
				<li>
					Share music and playlists with friends
				</li>
				<li>
					Backup of your library
				</li>
			</ul>
			
			
			<br /><br />
			<h3>
			<cfoutput>#application.udf.GetLangValSec( 'nav_screenshots' )#</cfoutput>
			</h3>
			
			<a href="/james/?event=info.service.screenshots" title="<cfoutput>#application.udf.GetLangValSec( 'nav_screenshots' )#</cfoutput>"><img style="border:0px;padding:6px" src="http://cdn.tunesbag.com/images/content/screen1.png" width="80" alt="<cfoutput>#application.udf.GetLangValSec( 'nav_screenshots' )#</cfoutput>" /></a>
			<a href="/james/?event=info.service.screenshots" title="<cfoutput>#application.udf.GetLangValSec( 'nav_screenshots' )#</cfoutput>"><img style="border:0px;padding:6px" src="http://cdn.tunesbag.com/images/content/screen6.png" width="80" alt="<cfoutput>#application.udf.GetLangValSec( 'nav_screenshots' )#</cfoutput>" /></a>
			<a href="/james/?event=info.service.screenshots" title="<cfoutput>#application.udf.GetLangValSec( 'nav_screenshots' )#</cfoutput>"><img style="border:0px;padding:6px" src="http://cdn.tunesbag.com/images/content/screen3.png" width="80" alt="<cfoutput>#application.udf.GetLangValSec( 'nav_screenshots' )#</cfoutput>" /></a>
			
			</td>
		</tr>
		</table> --->

</td>
<!--- 
<td valign="top" style="padding:12px;width:400px" class="bl">
	<h3>Are you already using one of these services?</h3>
	Click on the logo and finish signup within seconds
	<br /><br />

	<a href="http://www.facebook.com/login.php?v=1.0&next=signup&api_key=<cfoutput>#application.udf.GetSettingsProperty( 'fb_signup_apikey', '' )#</cfoutput>"><img src="/res/images/partner/facebook_login.gif" border="0" /></a>
	
	<br /><br />
	<a href="#" onclick="$('#id_enter_mystrands').fadeIn();"><img src="/res/images/partner/logo-mystrands.gif" border="0" /></a>
	<div id="id_enter_mystrands" style="display:none">
	
		<div class="status">
		Please enter your MyStrands username (email) and password:
		<form action="/james/?event=register.start&amp;loadfromsource=mystrands&amp;invitationkey=<cfoutput>#Urlencodedformat( a_str_invitation_key )#</cfoutput>" name="signup_mystrands" id="signup_mystrands" method="post">
			<table class="table_details table_edit">
				<tr>
					<td class="field_name">
						<cfoutput>#application.udf.GetLangVal( 'cm_wd_username' )#</cfoutput>:
					</td>
					<td>
						<input type="text" name="frmusername_ext" id="frmusername_ext" />
					</td>
				</tr>
				<tr>
					<td class="field_name">
						<cfoutput>#application.udf.GetLangVal( 'cm_wd_password' )#</cfoutput>:
					</td>
					<td>
						<input type="password" name="frmpassword_ext" id="frmpassword_ext" />
					</td>
				</tr>
				<tr>
					<td class="field_name"></td>
					<td>
						<input type="submit" class="btn" value="Proceed ..." />
					</td>
				</tr>			
			</table>
		</form>
		
		</div>
	
	</div>
</td> --->
</tr>
</table>


<script type="text/javascript">
	$('#frmusername').focus();
</script>


<!--- this is the old invite-only part --->
<!--- <cfelse>

	

	<br />
	<h2><cfoutput>#application.udf.GetLangValSec( 'signup_ph_invitation_code_needed' )#</cfoutput></h2>
	<br />
	<h3><cfoutput>#application.udf.si_img( 'tick' )# #application.udf.GetLangValSec( 'signup_ph_invitation_code_needed_have_code' )#</cfoutput></h3>
	
	<div class="div_container" style="padding-left:40px">
		
		<form action="/james/?">
		<input type="hidden" name="event" value="register.start" />
		<input type="hidden" name="source" value="<cfoutput>#event.getArg( 'source' )#</cfoutput>" />
		<input type="text" name="invitationkey" size="20" style="width:300px;padding:4px" value="" />
		<input type="submit" value="<cfoutput>#application.udf.GetLangValSec( 'cm_wd_btn_activate_now' )#</cfoutput>" class="btn" />
		</form>
		
		<cfif Len( a_str_invitation_key ) GT 0>
		
			<div class="status">
				
				<cfoutput>#application.udf.GetLangValSec( 'signup_ph_invitation_code_invalid_or_overused' )#</cfoutput>
			
			</div>
			
		</cfif>
			
	</div>
	
	<br />
	<h3><cfoutput>#application.udf.si_img( 'information' )# #application.udf.GetLangValSec( 'signup_ph_invitation_howto_get' )#</cfoutput></h3>
	
	<div class="div_container" style="padding-left:40px;font-size:12px">
	
			<cfoutput>#application.udf.GetLangValSec( 'signup_ph_invitation_howto_get_enter_email' )#</cfoutput>
			
			<div id="id_confirm_beta" style="padding-top:20px;padding-bottom:20px;font-size:12px">
			<form action="#" method="get" onsubmit="SubmitNotify( $ ('#email').val(), $('#source').val() );return false">
			
			<input type="hidden" name="source" id="source" value="<cfoutput>#htmleditformat( a_str_invitation_key )#</cfoutput>" />
			<input type="text" name="email" value="" id="email" style="padding:4px;width:300px" />
			
			<input type="submit" value="Notify me!" class="btn" />
			<br />
			<br />
			<a href="/rd/terms/"><cfoutput>#application.udf.GetLangValSec( 'signup_ph_invitation_howto_get_enter_email_privacy' )#</cfoutput></a>
			</div>

		<cfoutput>#application.udf.GetLangValSec( 'signup_ph_invitation_howto_get_ask_friend' )#</cfoutput>
	</div>
	
	<script type="text/javascript">
	
		function SubmitNotify(_adr, _source) {
			
			$.get("/comingsoon/notifyonstart.cfm",
				  { email: _adr, source: _source },
				  function(data){
				  }
				);
			
			$('#id_confirm_beta').html( '<b>We will notify ' + _adr + '. Thank you for your interest!</b>' );
			}
	</script>


</cfif>
--->
</cfsavecontent>
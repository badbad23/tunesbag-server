<!--- finish registration, data powered by rpx

	no binding has been found yet

--->

<cfinclude template="/common/scripts.cfm">

<cfset sDataEntryKey = event.getArg( 'entrykey' ) />
<cfset stRPXData = event.getArg( 'stRPXData' ) />
<cfset sError = event.getArg( 'error' ) />

<!--- data entered by the user --->
<cfset sUsername = event.getArg( 'username' ) />
<cfset sEmail = event.getArg( 'email' ) />
<cfset sFirstname = event.getArg( 'firstname' ) />

<cfif NOT IsStruct( stRPXData ) OR NOT stRPXData.result>
	<cfsavecontent variable="request.content.final">
		No valid data found.
		<br />
		<br />
		<a href="/rd/signup/">Please click here to sign up manually</a>
		<!--- TODO: Redirect --->
	</cfsavecontent>
	<cfexit method="exittemplate">
</cfif>

<cfset oData = stRPXData.oItem />

<cfset sProvider = oData.getProvider() />
<cfset stUnifiedData = DeSerializeJSON( oData.getunified_userdata() ) />
<cfset iError = event.getArg( 'error', 0 ) />


<!--- overwrite with default data if user has not entered data manually --->
<cfif Len( sUsername ) IS 0>
	<cfset sUsername = stUnifiedData.username />
</cfif>

<cfif Len( sFirstname ) IS 0>
	<cfset sFirstname = stUnifiedData.firstname />
</cfif>

<cfif Len( sEmail ) IS 0>
	<cfset sEmail = stUnifiedData.email />
</cfif>


<cfsavecontent variable="request.content.final">
<!--- <cfdump var="#stRPXData.oItem.getcomplete_data()#"> --->
<div class="div_container">
<table>
	<tr>
		<td valign="middle">
			
		<cfif StructKeyExists( stUnifiedData.complete_data.profile, 'photo' )>
			
			<cfoutput>
			<img src="#stUnifiedData.complete_data.profile.photo#" style="vertical-align:middle;height:48px;border:0px" alt="That's you!" />
			</cfoutput>
			
		</cfif>
	</td>
	<td style="line-height:200%;padding:8px" valign="middle">
	
			<cfif Len( sFirstname ) GT 0><b><cfoutput>#htmleditformat( sFirstname )#</cfoutput>,</b><br /></cfif>
				
				<cfoutput>#application.udf.GetLangValSec( 'signup_ph_ext_please_adjust_profile' )#</cfoutput>
		
			<br />
			<cfoutput>
			<a href="/rd/login/?rpxkey=#urlencodedformat( sDataEntryKey )#">#application.udf.GetLangValSec( 'signup_ph_ext_link_to_existing_account' )#</a>
			</cfoutput>
		</td>
	</tr>
</table>
</div>

<cfif iError GT 0>
	<cfoutput>#application.udf.WriteCommonErrorMessage( iError )#</cfoutput>
</cfif>

<cfsavecontent variable="sHTMLHead">
	<script type="text/javascript">
	function submitVerifyData() {
		
		if ($('#acceptctac').attr( 'checked' ) == false) {
			alert('<cfoutput>#JSStringFormat( application.udf.GetLangValSec( 'err_ph_5005'))#</cfoutput>');
			return false;
			}
			
		// already checked?		
		if ($('#regform').hasClass( 'verificationdone')) {
			return true;
			}
			
		$('#idPleaseRecheck').show();
		
		$('#regform .datacheck').show();
		
		$('#regform input[type=text]').addClass( 'borderless lightbg' );
		$('#regform input[type=password]').addClass( 'borderless lightbg' );
		$('#regform select').addClass( 'borderless lightbg' );
		
		$('#idSubmitBtn').addClass( 'btnred' );
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

<cfoutput>
<form action="/james/?event=register.externalsource.finish" method="post" name="regform" id="regform" onsubmit="return submitVerifyData();" >
<input type="hidden" name="action" value="createaccount" />

<cfif StructKeyExists( cookie, 'ref' ) AND Len( cookie.ref ) GT 0>
	<cfset event.setArg( 'source', cookie.ref ) />
</cfif>

<input type="hidden" name="source" value="#htmleditformat( event.getArg( 'source') )#" />
<input type="hidden" name="entrykey" value="#htmleditformat( sDataEntrykey )#" />

<table class="table_details table_edit tbl_bigform" cellspacing="0">
	<tr>
		<td class="field_name">
			#application.udf.GetLangValSec( 'cm_wd_provider' )#
		</td>
		<td>
			#htmleditformat( stUnifiedData.provider )#
		</td>
	</tr>
	<tr>
		<td class="field_name">
			#application.udf.GetLangValSec( 'cm_wd_username' )#
		</td>
		<td>
			<input type="text" name="username" value="#htmleditformat( sUsername )#" />&nbsp;
			
			<span class="datacheck">
			<a href="##" onclick="switchBackToEditMode();return false"><cfoutput>#application.udf.si_img( 'pencil' )#</cfoutput></a>
			</span>
			*
		</td>
		<td class="addinfotext">
			#application.udf.GetLangValSec( 'signup_ph_desired_username_will_be_shown_on_website' )#
		</td>
	</tr>
	<cfif Len( stUnifiedData.firstname ) IS 0>
	<tr>
		<td class="field_name">
			#application.udf.GetLangValSec( 'cm_wd_firstname' )#
		</td>
		<td>
			<input type="text" name="firstname" value="#htmleditformat( sfirstname )#" />&nbsp;
			
			<span class="datacheck">
			<a href="##" onclick="switchBackToEditMode();return false"><cfoutput>#application.udf.si_img( 'pencil' )#</cfoutput></a>
			</span>
			
			*
		</td>
	</tr>
	<cfelse>
		<input type="hidden" name="firstname" value="#htmleditformat( sFirstname )#" />
	</cfif>
	<cfif Len( stUnifiedData.email ) IS 0>
	<tr>
		<td class="field_name">
			#application.udf.GetLangValSec( 'cm_wd_email' )#
		</td>
		<td>
			<input type="text" name="email" value="#htmleditformat( sEmail )#" />&nbsp;
			
			<span class="datacheck">
			<a href="##" onclick="switchBackToEditMode();return false"><cfoutput>#application.udf.si_img( 'pencil' )#</cfoutput></a>
			</span>
			
			*
		</td>
		<td class="addinfotext">
			Password requests, important notifications
		</td>
	</tr>
	<cfelse>
		<input type="hidden" name="email" value="#htmleditformat( semail )#" />
	</cfif>
	<tr>
		<td class="field_name">
			<label for="frmlang_id">#application.udf.GetLangValSec( 'cm_wd_language' )#</label>
		</td>
		<td>
			<cfset sCurLang = application.udf.GetCurrentLanguage() />
			
			<select name="frmlang_id" id="frmlang_id">
				<option value="en" <cfif sCurLang IS 'en'>selected="true"</cfif>>English (EN)</option>
				<option value="de" <cfif sCurLang IS 'de'>selected="true"</cfif>>German (DE)</option>
				<option value="es" <cfif sCurLang IS 'es'>selected="true"</cfif>>Español (ES)</option>
				<option value="fr" <cfif sCurLang IS 'fr'>selected="true"</cfif>>Français (FR)</option>
				<option value="it" <cfif sCurLang IS 'it'>selected="true"</cfif>>Italiano (IT)</option>
				<option value="tr" <cfif sCurLang IS 'tr'>selected="true"</cfif>>Türkçe (TK)</option>
				<option value="et" <cfif sCurLang IS 'et'>selected="true"</cfif>>Eesti keel (ET)</option>
				<option value="ru" <cfif sCurLang IS 'ru'>selected="true"</cfif>>русский язык (RU)</option>
				<option value="zh_cn" <cfif sCurLang IS 'zh_cn'>selected="true"</cfif>>Simplified Chinese (CN)</option>
				<!--- <option value="zh_tw" <cfif sCurLang IS 'zh_tw'>selected="true"</cfif>>Traditional Chinese (TW)</option>
				<option value="nl" <cfif sCurLang IS 'nl'>selected="true"</cfif>>Nederlands/Dutch (NL)</option>
				<option value="pl" <cfif sCurLang IS 'pl'>selected="true"</cfif>>język polski (PL)</option>
				<option value="pt_br" <cfif sCurLang IS 'pt_br'>selected="true"</cfif>>Português  (PT_BR)</option> --->
				<!--- <option value="pl" <cfif sCurLang IS 'pl'>selected="true"</cfif>>język polski (PL)</option> --->
			</select>
		</td>
	</tr>
	<tr>
		<td class="field_name"></td>
		<td>
			<input type="checkbox" value="1" name="acceptctac" id="acceptctac" <cfif event.getArg( 'acceptctac' ) IS 1>checked="true"</cfif> /> 
			
			&nbsp;
			<a href="/rd/terms">#application.udf.GetLangValSec( 'signup_ph_accept_ctac' )#</a>
		</td>
	</tr>
	<tr>
		<td class="field_name"></td>
		<td>
			<input type="submit" value="#application.udf.GetLangValSec( 'cm_wd_btn_activate_now' )#" id="idSubmitBtn" />
		</td>
	</tr>
	<tr>
		<td class="field_name"></td>
		<td>* = #application.udf.GetLangValSec( 'cm_wd_required' )#</td>
	</tr>
</table>
</form>

</cfoutput>

<cfset stData = DeSerializeJSON( stRPXData.oItem.getcomplete_data() ) />

<!--- <cfif StructKeyExists( stData, 'friends' ) AND IsArray( stData.friends )>
	
	<cfquery name="qSelectPossibleFriends" datasource="mytunesbutleruserdata">
	SELECT
		users_externalidentifiers.userkey,
		users.username,
		users.photoindex,
		users_externalidentifiers.provider,
		users.firstname,
		users.city,
		users.countryisocode
	FROM
		users_externalidentifiers
	LEFT JOIN
		users ON (users.entrykey = users_externalidentifiers.userkey)
	WHERE
		users_externalidentifiers.identifier IN (<cfqueryparam cfsqltype="cf_sql_varchar" value="#ArrayToList( stData.friends )#" list="true">)
	;
	</cfquery>
	
	<cfif qSelectPossibleFriends.recordcount GT 0>
		<h4><cfoutput>#application.udf.GetLangValSec( 'signu_ph_ext_already_members' )#</cfoutput></h4>
	
		<cfoutput query="qSelectPossibleFriends" maxrows="5">
		<img src="#application.udf.getUserImageLink( qSelectPossibleFriends.username, 48 )#" style="width:48px;float:left;margin:6px" />
		</cfoutput>
		<div class="clear"></div>
		
	</cfif>
</cfif> --->
	
</cfsavecontent>
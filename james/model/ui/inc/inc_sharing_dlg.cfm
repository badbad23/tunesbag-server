<!---  sharing dialog  --->
<cfprocessingdirective pageencoding="utf-8">

<cfset a_str_recipients = getProperty( 'beanFactory' ).getBean( 'UserComponent' ).GetPreference( userkey = application.udf.GetCurrentSecurityContext().entrykey,
						name = 'share_email_addresses',
						defaultvalue = '' ) />

<cfoutput>
	
<div class="header">
	
	
	<cfswitch expression="#event.getArg( 'itemtype' )#">
		<cfcase value="1">
			#application.udf.si_img( 'music' )#
		</cfcase>	
		<cfcase value="2">
			#application.udf.si_img( 'page_white_cd' )#
		</cfcase>
		<cfdefaultcase>
			#application.udf.si_img( 'bullet_orange' )#
		</cfdefaultcase>
	</cfswitch>
	
	 #application.udf.GetLangValSec( 'cm_wd_share' )# "<b>#htmleditformat( application.udf.ShortenString( urldecode( event.getArg( 'title' ) ), 50 ))#</b>"
</div>
	
	

<form id="frmsharefriends" onsubmit="DoAjaxSubmit( {'formid': this.id } );return false" action="/james/?event=bgaction&amp;type=item.share" method="post">

<!--- all needed parameters --->
<input type="hidden" name="url" value="#htmleditformat( event.getArg( 'url') )#" />
<input type="hidden" name="itemtype" value="#htmleditformat( event.getArg( 'itemtype') )#" />	
<input type="hidden" name="identifier" value="#htmleditformat( event.getArg( 'identifier') )#" />
<input type="hidden" name="title" value="#htmleditformat( event.getArg( 'title') )#" />


<div class="div_container_small">
	
<table class="tbl_td_top table_details" style="width:100%">
	<tr>
		<td>
			#application.udf.si_img( 'email' )#
		</td>
		<td>
		<input type="text" name="recipients_mailto" id="recipients_mailto" value="Enter one or more email addresses" class="b_all addinfotext" onclick="checkInactiveInput(this)" title="Enter one or more email addresses" style="width:300px;padding:4px" />
		<cfif Len( a_str_recipients ) GT 0>
			<p>
				<cfloop list="#a_str_recipients#" index="a_str_recipient">
					<!--- todo --->
					<a href="##" onclick="checkInactiveInput($('##recipients_mailto'));$('##recipients_mailto').val(  '#JsStringFormat( a_str_recipient )#' + ', ' + $('##recipients_mailto').val() );return false">#htmleditformat( a_str_recipient )#</a>, 
					
				</cfloop>...
			</p>
		</cfif>
		<p class="addinfotext">
			
		</p>
		</td>
	</tr>
	<cfif q_select.recordcount GT 0>
	<tr>
		<td>
			#application.udf.si_img( 'group' )#
		</td>
		<td>
			<!--- height:220px; --->
			
			<cfif q_select.recordcount GT 8>
				<cfset a_int_height = '140px' />
			<cfelse>
				<cfset a_int_height = 'auto' />
			</cfif>
			
			<div class="b_all" style="height:#a_int_height#;overflow-x:auto;margin-bottom: 12px;width:300px" id="id_share_dlg_select_users">
			<!--- <table class="tbl_td_top table_details"> --->
			<ul class="ul_nopoints">
			<cfloop query="q_select">
				<li style="float:left; width:120px; margin-bottom:4px;">
					<input type="checkbox" name="recipients" value="user:#htmleditformat( q_select.displayname )#" style="vertical-align:middle;width:auto" />
					<img src="#application.udf.getUserImageLink( q_select.displayname, 48 )#" width="24" height="26" style="vertical-align:middle;border:0px" />
					#htmleditformat( application.udf.ShortenString( q_select.displayname, 10) )#
				</li>
			</cfloop>
			</ul>
			<!--- 
			</table> --->
			</div>
			<div class="clear"></div>
		
		</td>
	</tr>
	</cfif>
	<tr>
		<td>
			#application.udf.si_img( 'comment' )#
		</td>
		<td>
			<input type="text" name="comment" value="#application.udf.GetLangValSec( 'cm_wd_comment' )#" class="b_all addinfotext" style="width:300px;padding: 4px" onclick="checkInactiveInput(this)" />
		</td>
	</tr>
	<tr>
		<td></td>
		<td>
			<input type="submit" value="#application.udf.GetLangValSec( 'cm_wd_share' )#" class="btn" />
		</td>
	</tr>
</table>

</div>
</form>

<!--- social sharing ... Values are already URL encoded! --->
<cfset a_str_title = urlDecode( event.getArg( 'title' )) />
<cfset a_str_description = '' />
<cfset a_str_href = event.getArg( 'url' ) />

<cfset a_str_title =  '♫ ' & a_str_title & ' (@tunesBag.com)' />
<cfset a_str_title = urlEncodedFormat( a_str_title ) />

<!--- web sharing --->
<div class="header"><img src="http://cdn.tunesBag.com/images/si/tag.png" class="si_img" /> Web</div>
<div class="div_container web_form" style="padding-bottom:6px">
	
	<ul class="ul_nopoints">
	
	<li><a onclick="LogReq( '/share/facebook/' );CloseShareDialog()" target="_blank" href="http://www.facebook.com/sharer.php?u=#a_str_href#&t=#a_str_title#"><img src="/res/images/partner/services/facebook.png" class="si_img" /> Facebook</a></li>
	
	<li><a onclick="LogReq( '/share/myspace/' );CloseShareDialog()" href="http://www.myspace.com/Modules/PostTo/Pages/?t=#a_str_title#&c=Play%20this%20item%20now&u=#a_str_href#&l=3" target="_blank"><img src="/res/images/partner/services/myspace.png" class="si_img" /> myspace</a></li>
	
	<li><a onclick="LogReq( '/share/twitter/' );CloseShareDialog()" target="_blank" href="http://twitter.com/home?status=#a_str_title#%20#a_str_href#"><img src="/res/images/partner/twitter-icon.png" class="si_img" /> twitter</a></li>
	
	<li><a onclick="LogReq( '/share/friendfeed/' );CloseShareDialog()" href="http://friendfeed.com/?url=#a_str_href#&title=#a_str_title#" target="_blank"><img src="/res/images/partner/services/friendfeed.png" class="si_img" /> Friendfeed</a></li>
	
	<li><a onclick="LogReq( '/share/delicious/' );CloseShareDialog()" target="_blank" href="http://del.icio.us/post?url=#a_str_href#&title=#a_str_title#"><img src="/res/images/partner/services/delicious.png" class="si_img" /> Delicious</a></li>
	
	<li><a onclick="LogReq( '/share/stumbleupon/' );CloseShareDialog()" href="http://www.stumbleupon.com/submit?url=#a_str_href#&title=#a_str_title#" target="_blank"><img src="/res/images/partner/services/stumbleupon.gif" class="si_img" /> stumbleupon</a></li>
	
	<!--- <li><a onclick="LogReq( '/share/yahoobuzz/' );CloseShareDialog()" href="http://buzz.yahoo.com/submit?submitUrl=#a_str_href#&submitHeadline=#a_str_title#" target="_blank"><img src="/res/images/partner/services/yahoobuzz.png" class="si_img" /> Yahoo! Buzz</a></li> --->
	
	<li><a onclick="LogReq( '/share/digg/' );CloseShareDialog()" target="_blank" href="http://digg.com/submit?phase=2&url=#a_str_href#"><img src="/res/images/partner/services/digg.png" class="si_img" /> digg</a></li>
	
	<li><a onclick="LogReq( '/share/google/' );CloseShareDialog()" href="http://www.google.com/bookmarks/mark?op=add&labels=music&bkmk=#a_str_href#&title=#a_str_title#" target="_blank"><img src="/res/images/partner/services/googlebookmark.png" class="si_img" /> Google</a></li>
	
	<li><a onclick="LogReq( '/share/bebo/' );CloseShareDialog()" href="http://www.bebo.com/c/share?Url=#a_str_href#&Title=#a_str_title#" target="_blank"><img src="/res/images/partner/services/bebo.gif" class="si_img" /> Bebo</a></li>
							
	</ul>
	<div class="clear"></div>

	<div class="div_container_small">
	<form name="embedForm" id="embedForm">
		#application.udf.si_img( 'page_white_link' )# <input type="text" readonly="" style="width:300px;padding: 4px" class="b_all" onclick="this.focus();this.select();" value="#Replace( htmleditformat( UrlDecode(event.getArg( 'url' ) )), ' ', '+', 'ALL' )#" name="embed_code" id="embed_code"/>
	</form>
	</div>

</div>
<div class="clear"></div>
</cfoutput>
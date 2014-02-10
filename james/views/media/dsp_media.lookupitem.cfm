<!---

	lookup

--->

<cfinclude template="/common/scripts.cfm">

<cfset a_str_artist = event.getArg( 'artist' ) />
<cfset a_str_name = event.getArg( 'name' ) />
<cfset a_search_result = event.getArg( 'a_search_result' ) />

<cfset q_select_items = a_search_result.q_select_items />

<cfsavecontent variable="request.content.final">

<!--- <cfdump var="#q_select_items#"> --->
	
<cfoutput><div class="div_right_small_link"><a href="##" onclick="$( '##id_top_lookup_info' ).slideUp();">#application.udf.GetLangValSec( 'cm_wd_action_hide' )#</a></div></cfoutput>
<span id="id_lookup_item_recordcount" style="display:none"><cfoutput>#q_select_items.recordcount#</cfoutput></span>

<cfoutput>
<b>#application.udf.GetLangValSec( 'cm_ph_searching_for_msg', '"' & a_str_name & ' - ' & a_str_artist & '"' )#</b>
</cfoutput>
	
<br />
<!--- <cfoutput>#application.udf.GetLangValSec( 'lib_ph_artist_info_what_your_local_tracks' )#</cfoutput> --->
<cfif q_select_items.recordcount GT 0>
		
	<cfset a_str_uuid_div = application.udf.ReturnJSUUID() />

	<div class="div_container_small" id="id_div_tracks_of_this_artist<cfoutput>#a_str_uuid_div#</cfoutput>"></div>
	
	<cfset a_struct_return = application.udf.SimpleBuildOutput(  securitycontext = application.udf.GetCurrentSecurityContext(),
								query = q_select_items,
								type = 'internal',
								target = '##id_div_tracks_of_this_artist#a_str_uuid_div#',
								force_id = '',
								columns = 'album,name,action,rating',
								lastkey = '',
								setActive = false,
								playlistkey = '',
								options = '' ) />
			
	<cfoutput>
	<script type="text/javascript">

		var a_items_info = HandleRecordSet( '#JsStringFormat( a_struct_return.data_json )#', '#JsStringFormat( a_struct_return.meta_json )#', false );
		
		<!--- more than 0 hits? start playing ... --->
		if (a_items_info.count > 0) {
			recSet.SetCurrentRecordsetID( a_items_info.id );
			recSet.SetCurrentRecordsetCurIndex( 0, true );
			}
			
		// exactly one hit?
		if (a_items_info.count == 1) {
			$('##id_top_lookup_info').fadeOut();
			}
		
	</script>
	</cfoutput>
	
	<!--- <div class="div_container_small">
		<cfoutput>
		<a href="##" onclick="SimpleInpagePopup( '#JsStringFormat( a_str_artist & ': ' & a_str_name )#', '/james/?event=ui.simple.dialog&amp;type=findytvideo&amp;artist=#UrlEncodedformat( a_str_artist )#&amp;name=#UrlEncodedFormat( a_str_name )#');return false;">#application.udf.si_img( 'television' )# #application.udf.GetLangValSec( 'cm_ph_search_qry_start_yt' )#</a>
		</cfoutput>
	</div> --->	
		
<cfelse>
	<div class="status">
		<cfoutput>#application.udf.GetLangValSec( 'cm_ph_no_items_found' )#</cfoutput>
		
		<!--- ask user to perform internet / youtube lookup --->
		
	</div>

	<cfoutput><b>#application.udf.GetLangValSec( 'cm_ph_search_query_other_sources' )#</b></cfoutput>
		
	<div class="div_container">
		<cfoutput>
		<a href="##" onclick="SimpleInpagePopup( '#JsStringFormat( a_str_artist & ': ' & a_str_name )#', '/james/?event=ui.simple.dialog&amp;type=findytvideo&amp;artist=#UrlEncodedformat( a_str_artist )#&amp;name=#UrlEncodedFormat( a_str_name )#');return false;">#application.udf.si_img( 'television' )# #application.udf.GetLangValSec( 'cm_ph_search_qry_start_yt' )#</a>
		</cfoutput>
		&nbsp;&nbsp;
	
	
		<cfif ListFindNoCase( 'funkymusic,blundstone', application.udf.GetCurrentSecurityContext().username ) GT 0>
		<cfoutput>
		<a href="##" onclick="$('##id_top_lookup_info').html( sImgLoadingStatus );$.get('/james/?event=ui.simple.dialog&type=searchinternet&artist=#UrlEncodedformat( a_str_artist )#&name=#UrlEncodedFormat( a_str_name )#' ,
				{},
			  function(data){
			  	PlayerTogglePlayPause();
			    $('##id_top_lookup_info').html( data ).fadeIn( 'slow' );
			  }
			);return false;">#application.udf.si_img( 'world' )# #application.udf.GetLangValSec( 'cm_ph_search_qry_start_internet' )#</a>
		</cfoutput>	
		</cfif>
	</div>
		
</cfif>

<div id="id_top_lookup_info_internet_search"></div>
</cfsavecontent>
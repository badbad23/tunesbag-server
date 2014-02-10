<!--- //

	Module:		tunesBag
	Description:
	Type: 		page-view
	Page view: 	home
	
// --->

<cfinclude template="/common/scripts.cfm">


<cfsavecontent variable="request.content.final">
	
<div id="idLibrarySelectorTop">

<div class="filterstatusrow">
	<span style="float:right">
		<a href="#" onclick="$('#idSelectorFilter').slideToggle('slow', function() { AdoptPageDimensions() } );return false">
			<img src="http://cdn.tunesBag.com/images/space1x1.png" class="sprite-smallimages sprite-btnToogleMaximizeRed" alt="Min/Max" />
		</a>
	</span>
	<cfoutput>#application.udf.GetLangValSec( 'cm_wd_filter' )#</cfoutput>
</div>

<!--- call the selector tag --->
<div id="idSelectorFilter">
	<cfinclude template="../inc/inc_top_selector.cfm">
</div>

<!--- search options --->
<div id="id_search_options"></div>
</div>

<!--- content output --->
<cfset qProperty = event.getArg( 'q_select_preferences' ) />

<!--- hint in case this is a brand new library --->
<cfquery name="qSelectProperty" dbtype="query">
SELECT
	[value]
FROM
	qProperty
WHERE
	name = 'display.library.prefilledhint'
</cfquery>

<!--- 
<cfif qSelectProperty.recordcount IS 0 OR Val( qSelectProperty.value ) NEQ 0>
<div class="div_containe bb" id="idhintprefilled">
	<div class="status" style="border:0px;margin:0px;">
		<cfoutput>
		<span style="float:right"><a href="##" id="idPrefilledHintCloseBtn" onclick="$('##idhintprefilled').slideUp();SetUserPreference( 'display.library.prefilledhint', 0 );return false">#application.udf.GetLangValSec( 'cm_wd_close' )#</a></span>
		<b>#application.udf.GetLangValSec( 'cm_wd_information' )#</b>: #application.udf.GetLangValSec( 'cm_ph_prefilled_hint' )#
		<a href="##" onclick="SimpleBGOperation( 'items.prefilled.clear', '', function() { librariesSet.ReloadBaseLibrary( function() { RefreshItemListing() } ); } );$('##idPrefilledHintCloseBtn').click();return false">#application.udf.GetLangValSec( 'cm_ph_prefilled_delete_all' )#</a>
		<div style="height:8px" class="clear"></div>
		<div class="btn btnred" style="width:auto;float:left">
		<a href="##tb:upload">#application.udf.si_img( 'arrow_up' )# #application.udf.GetLangValSec( 'start_ph_start_upload' )#</a>&nbsp;
		</div>
		<div class="clear"></div>
		
		</cfoutput> 
		
	</div>
</div>
</cfif>
 --->

<!--- 
<script type="text/javascript">
	window.setTimeout( function() { exposeObject( $('#idexpose'), 3000); }, 1000);
</script>
 --->



<div id="id_content_library">

	<div style="padding:80px;text-align:center;height:600px" class="bt"><cfoutput>#application.udf.GetLangValSec( 'cm_ph_loading_please_wait' )#</cfoutput></div>

</div>

<!--- <div id="idLibraryData"></div> --->

<!--- no items found? --->
<!--- cfoutput>
<div id="id_items_count_container_no_items" style="display:none" class="status">
	#application.udf.GetLangValSec( 'cm_ph_no_items_found' )#
	<div>
	<a href="##" style="font-weight:bold" onclick="SimpleInpagePopup( '#JsStringFormat( application.udf.GetLangValSec( 'nav_add_media' ) )#', '/james/?event=info.upload&amp;height=480&amp;width=640', false );return false;">#application.udf.si_img( 'add' )# #application.udf.GetLangValSec( 'lib_upload_info_title' )#</a>
	<p>
	#application.udf.GetLangValSec( 'start_ph_start_upload' )#
	</p>
	</div>
</div>
</cfoutput> --->

</cfsavecontent>
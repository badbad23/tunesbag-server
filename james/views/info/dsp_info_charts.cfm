<!--- //

	Module:		Info.Charts
	Action:		
	Description:Dummy for now	
	
// --->
<cfinclude template="/common/scripts.cfm">

<cfset q_select_artists = event.getArg( 'q_select_artists' ) />

<cfif q_select_artists.recordcount IS 0>
	<!--- no data --->
	<cfsavecontent variable="request.content.final">
	<div class="status">
		<cfoutput>#application.udf.GetLangValSec( 'cm_ph_charts_no_data_available' )#</cfoutput>
	</div>
	</cfsavecontent>
<!--- 	<cfset request.content.final = 'No data available' /> --->
	
	<cfexit method="exittemplate">
</cfif>


<cfset a_int_max = q_select_artists[ 'artist_count' ][ 1 ] />
<cfset a_int_one_perc = (a_int_max / 100 ) />

<cfsavecontent variable="request.content.final">
	
<div class="headlinebox">
	<p class="title"><cfoutput>#application.udf.WriteSectionHeader( application.udf.GetLangValSec( 'lib_ph_most_popular' ), '' )#</cfoutput></p>
	<p><cfoutput>#application.udf.GetCurrentSecurityContext().username#</cfoutput></p>
</div>


<div class="div_container">

<cfoutput>
#application.udf.WriteSectionHeader( application.udf.GetLangValSec( 'lib_ph_most_popular' ), '' )#
<p>
#application.udf.GetLangValSec( 'cm_wd_timeframe' )#:

<a href="/james/?event=info.charts&amp;days=7" title="#application.udf.GetLangValSec( 'cm_wd_charts' )#" class="add_as_tab">#application.udf.GetLangValSec( 'cm_ph_timeframe_last_n_days', 7 )#</a>
|
<a href="/james/?event=info.charts&amp;days=30" title="#application.udf.GetLangValSec( 'cm_wd_charts' )#" class="add_as_tab">#application.udf.GetLangValSec( 'cm_ph_timeframe_last_n_days', 30 )#</a>
|
<a href="/james/?event=info.charts&amp;days=90" title="#application.udf.GetLangValSec( 'cm_wd_charts' )#" class="add_as_tab">#application.udf.GetLangValSec( 'cm_ph_timeframe_last_n_days', 90 )#</a>
|
<a href="/james/?event=info.charts&amp;days=180" title="#application.udf.GetLangValSec( 'cm_wd_charts' )#" class="add_as_tab">#application.udf.GetLangValSec( 'cm_ph_timeframe_last_n_days', 180 )#</a>
|
<a href="/james/?event=info.charts&amp;days=365" title="#application.udf.GetLangValSec( 'cm_wd_charts' )#" class="add_as_tab">#application.udf.GetLangValSec( 'cm_ph_timeframe_last_n_days', 365 )#</a>
</p>
<!--- <p>
	#application.udf.GetLangValSec( 'cm_wd_filter' )#:
	
	<a href="">
</p>
 ---></cfoutput>

<!--- <br /><br />
Filter: My account | Me and friends | All users
 --->
<table class="table_overview" style="width:auto;margin-top:20px">
<cfoutput query="q_select_artists">
	
<cfset a_int_share = q_select_artists.artist_count / a_int_one_perc />
	
	<tr>
		<td class="addinfotext" style="text-align:right">
			###q_select_artists.currentrow#
		</td>
		<td>
			<a href="#application.udf.generateArtistURL(q_select_artists.artist, 0)#" title="#q_select_artists.artist#" class="add_as_tab">#htmleditformat( q_select_artists.artist )#</a>
		</td>
		<td style="width:500px">
			<div class="addinfotext" style="width:#a_int_share#%;padding:4px;background-color:##A9CEE3">
			#q_select_artists.artist_count#
			</div>
		</td>
	</tr>
</cfoutput>
</table>


					
					<!--- <cffeed action="read" query="q_select_items" source="http://ax.phobos.apple.com.edgesuite.net/WebObjects/MZStore.woa/wpa/MRSS/topsongs/sf=143445/genre=7/limit=10/rss.xml">
					<cfoutput query="q_Select_items">
						<a href="##" onclick="DoRequest( 'search', { 'search' : '#JsStringFormat( q_select_items.title )#' });return false;">#htmleditformat( q_select_items.title )#</a><br />
					</cfoutput>

		Provided by iTunes --->
</div>
</cfsavecontent>
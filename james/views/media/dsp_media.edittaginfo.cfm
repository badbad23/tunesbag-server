<!--- //

	Module:		Edit tag information
	Action:		
	Description:	
	
// --->

<cfinclude template="/common/scripts.cfm">

<cfset qItems = event.getArg( 'qItems', 0) />
<cfset a_struct_item = event.getArg( 'a_struct_item') />
<cfset q_select_genre_list = event.getArg( 'q_select_genre_list' ) />

<cfif NOT isQuery( qItems )>
	<cfset request.content.final = 'Item not found' />
	<cfexit method="exittemplate">
</cfif>

<cfset bMultipleItems = (qItems.recordcount GT 1) />

<cfsavecontent variable="request.content.final">
<div class="div_container">
<cfoutput>
<form action="/james/?event=bgaction&amp;type=items.edit" method="post" name="formedittag" id="formedittag" onsubmit="DoAjaxSubmit( { formid: this.id, success: function() { librariesSet.ReloadBaseLibrary();tb_remove(); } } );return false;">
	
<!--- prepare for multiple entrykeys --->
<input type="hidden" name="entrykeys" value="#htmleditformat( ValueList( qItems.entrykey ) )#" />

<img src="<cfoutput>#application.udf.getArtistImageByID( qItems.mb_artistid, 120)#</cfoutput>" style="float:right" />

<table class="table_details table_edit">
	<cfif bMultipleItems>
	<tr>
		<td class="status" colspan="2">
			<cfoutput>#application.udf.GetLangValSec( 'lib_ph_edit_hint_multiple_items' )#</cfoutput>
		</td>
	</tr>
	</cfif>
	
	<!--- no multi edit for titles ... --->
	<cfif NOT bMultipleItems>
		<tr>
			<td class="field_name">
				#application.udf.GetLangValSec( 'cm_wd_title' )#
			</td>
			<td>
				<input type="text" name="name" value="#htmleditformat( qItems.name )#" />
				
				<input type="hidden" name="edit_name" value="true" />
			</td>
		</tr>
	</cfif>
	<tr>
		<td class="field_name">
			#application.udf.GetLangValSec( 'cm_wd_artist' )#
		</td>
		<td>
			<input type="text" name="artist" value="#htmleditformat( qItems.artist )#" />
			
			<cfif bMultipleItems>
				<input type="checkbox" name="edit_artist" value="true" />
			<cfelse>
				<input type="hidden" name="edit_artist" value="true" />
			</cfif>
		</td>
	</tr>
	<tr>
		<td class="field_name">
			#application.udf.GetLangValSec( 'cm_wd_album' )#
		</td>
		<td>
			<input type="text" name="album" value="#htmleditformat( qItems.album )#" />
			
			<cfif bMultipleItems>
				<input type="checkbox" name="edit_album" value="true" />
			<cfelse>
				<input type="hidden" name="edit_album" value="true" />
			</cfif>
		</td>
	</tr>	
	<tr>
		<td class="field_name">
			#application.udf.GetLangValSec( 'cm_wd_genre' )#
		</td>
		<td>
			
			<cfset a_str_genre_list = ValueList( q_select_genre_list.name, '|' ) />
			
			<input type="text" name="genre" id="idgenre" value="#htmleditformat( qItems.genre )#" />
			
			<select name="frmgenrelist" onChange="document.formedittag.genre.value = this.value" style="width:auto">
				<option value="">#application.udf.GetLangValSec( 'cm_ph_please_select' )#</option>
				<cfloop query="q_select_genre_list">
					<option value="#htmleditformat( q_select_genre_list.name )#">#htmleditformat( q_select_genre_list.name )#</option>
				</cfloop>
			</select>
			
			<cfif bMultipleItems>
				<input type="checkbox" name="edit_genre" value="true" />
			<cfelse>
				<input type="hidden" name="edit_genre" value="true" />
			</cfif>
		</td>
	</tr>
	
	<!--- no common edit of track numbers --->
	<cfif NOT bMultipleItems>
	<tr>
		<td class="field_name">
			#application.udf.GetLangValSec( 'cm_ph_track_number' )#
		</td>
		<td>
			<input type="text" name="trackno" value="#htmleditformat( qItems.TrackNumber )#" />
			
			<input type="hidden" name="edit_trackno" value="true" />
		</td>
	</tr>
	</cfif>
	
	<tr>
		<td class="field_name">
			#application.udf.GetLangValSec( 'cm_wd_year' )#
		</td>
		<td>
			<input type="text" name="year" value="#htmleditformat( qItems.yr )#" />
			
			<cfif bMultipleItems>
				<input type="checkbox" name="edit_year" value="true" />
			<cfelse>
				<input type="hidden" name="edit_year" value="true" />
			</cfif>
		</td>
	</tr>		
	<!--- <tr>
		<td class="field_name">
			#application.udf.GetLangValSec( 'cm_wd_rating' )#
		</td>
		<td>
			<input type="radio" name="rating" <cfif Val( a_struct_item.getRating() ) IS 0>checked</cfif> value="0" style="width:auto" /> #application.udf.si_img( 'rating-none' )#
			<input type="radio" name="rating" <cfif Val( a_struct_item.getRating() ) IS 20>checked</cfif> value="20" style="width:auto" /> #application.udf.si_img( 'rating' )#
			<input type="radio" name="rating" <cfif Val( a_struct_item.getRating() ) IS 40>checked</cfif> value="40" style="width:auto" /> #application.udf.si_img( 'rating' )##application.udf.si_img( 'rating' )#
			<input type="radio" name="rating" <cfif Val( a_struct_item.getRating() ) IS 60>checked</cfif> value="60" style="width:auto" /> #application.udf.si_img( 'rating' )##application.udf.si_img( 'rating' )##application.udf.si_img( 'rating' )#
			<input type="radio" name="rating" <cfif Val( a_struct_item.getRating() ) IS 80>checked</cfif> value="80" style="width:auto" /> #application.udf.si_img( 'rating' )##application.udf.si_img( 'rating' )##application.udf.si_img( 'rating' )##application.udf.si_img( 'rating' )#
			<input type="radio" name="rating" <cfif Val( a_struct_item.getRating() ) IS 100>checked</cfif> value="100" style="width:auto" /> #application.udf.si_img( 'rating' )##application.udf.si_img( 'rating' )##application.udf.si_img( 'rating' )##application.udf.si_img( 'rating' )##application.udf.si_img( 'rating' )#
		</td>
	</tr>	 --->	
	<tr>
		<td class="field_name"></td>
		<td>
			<input type="submit" value="#application.udf.GetLangValSec( 'cm_wd_btn_save' )#" class="btn" />
		</td>
	</tr>
</table>
</form>
</cfoutput>
</div>
</cfsavecontent>

<!--- //
$Log$
//--->
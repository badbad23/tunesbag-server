<!--- //

	Module:		Play music
	Description: 
	
// --->

<cfinclude template="/common/scripts.cfm">

<!--- get the items --->
<cfset a_struct_item = event.getarg('a_struct_item') />
<cfset a_str_source = event.getArg( 'source', 'tb' ) />


<!--- skiping and moving allowed (not for ads) --->
<cfset a_bol_allow_skip = true />

<!--- type ... MP3 or FLV --->
<cfset a_str_player_type = 'sound' />

<!--- preview? --->
<cfset a_int_preview = event.getArg( 'preview', 0 ) />
<!--- 



<!--- community info --->

<cfsavecontent variable="a_str_content_meta">

</cfsavecontent>

 --->

<cfset a_str_file = event.getArg( 'deliver_info' ).location />

<cfset a_str_full_len_display = '' />

<cfif Val( a_struct_item.getTotalTime() ) GT 0>
							
	<cfset a_int_total_time = a_struct_item.getTotalTime() />
	<cfset a_int_min = Int( a_int_total_time / 60 ) />
	<cfset a_int_sec = a_int_total_time - ( a_int_min * 60 ) />

	<cfset a_str_full_len_display = a_int_min & ':' & a_int_sec />

</cfif>

<cfset stData = StructNew() />
<cfset stData.fn = a_struct_item.getname() />
<cfset stData.fullname = a_struct_item.getname() & ' ' & application.udf.GetLangValSec( 'cm_wd_by' ) & ' ' & a_struct_item.getartist() />
<cfset stData.href = a_str_file />
<cfset stData.artist = a_struct_item.getartist() />
<cfset stData.tb_skip = a_bol_allow_skip />
<cfset stData.tb_type = a_str_player_type />
<cfset stData.tb_fulllength = Val( a_struct_item.getTotalTime() ) />
<cfset stData.photo = '' />
<cfset stData.tb_fulllength_display = a_str_full_len_display />
<cfset stData.tb_mbalbumid = a_struct_item.getmb_albumid() />
<cfset stData.tb_mbartistid = a_struct_item.getmb_artistid() />
<cfset stData.tb_customartwork = a_struct_item.getcustomartwork() />
<cfset stData.artist = a_struct_item.getartist() />
<cfset stData.album = a_struct_item.getalbum() />
<cfset stData.source = a_struct_item.getsource() />
<cfset stData.licence_type = a_struct_item.getlicence_type() />
<cfset stData.owntrack = (a_struct_item.getUserkey() IS application.udf.GetCurrentSecurityContext().entrykey ) />

<!--- add share link --->
<cfset stData.share_link = WriteShareButton( 1, a_struct_item.getEntrykey(), a_struct_item.getName() & ' - ' & a_struct_item.getArtist(), 'http://www.tunesBag.com' & generateGenericURLToTrack( a_struct_item.getArtist(), a_struct_item.getName(), a_struct_item.getMB_TrackID(), a_struct_item.getEntrykey() ), 1 ) />

<cfoutput>#SerializeJSON( stData )#</cfoutput>

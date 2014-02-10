<!---

	UI component

--->

<cfcomponent displayName="MP3" hint="Reads ID3 information from an MP3" output="false">
	
	<cfinclude template="/common/scripts.cfm">
	
	<cffunction access="public" name="init" returntype="james.cfc.content.ui" output="false">
		<cfreturn this />
	</cffunction>
	
	<cffunction access="public" name="GenerateSelectorInformation" output="false" returntype="struct" hint="Return selector html output">
		<cfargument name="securitycontext" type="struct" required="true">
		<cfargument name="type" type="string" required="true"
			hint="Which section is needed? GENRE ARTIST ALBUM MOODTAG RATING EPOCH">
		<cfargument name="genres" type="string" required="true"
			hint="current values ...">
		<cfargument name="librarykeys" type="string" required="true">
		<cfargument name="artists" type="string" required="true">
		<cfargument name="albums" type="string" required="true">
		<cfargument name="epoch" type="string" required="true">
		<cfargument name="tags" type="string" required="true">
		<cfargument name="rating" type="string" required="true">
		<cfargument name="advanced" type="string" required="false" default="">
		
		<cfset var stReturn = application.udf.GenerateReturnStruct() />
		<cfset var a_str_content = '' />
		<cfset var q_select_distinct_genres = 0 />
		<cfset var a_int_size = 0 />
		<cfset var q_select_friends = 0 />
		<cfset var a_str_possible_librarykeys = application.beanFactory.getBean( 'MediaItemsComponent' ).GetAllPossibleLibrarykeysForLibraryAccess( arguments.securitycontext ) />
		
		<cfinclude template="utils/inc_generate_selector.cfm">
		
		<cfset stReturn.a_str_content = a_str_content />
		
		<cfreturn application.udf.SetReturnStructSuccessCode(stReturn) />
	
	</cffunction>

	
	<cffunction access="public" name="DoSimpleBuildOutput" returntype="struct"
			hint="Take a query, convert to JSON and make it ready for the JS based output!">
		<cfargument name="securitycontext" type="struct" required="true"
			hint="the sec context + rights of the requesting user" />
		<cfargument name="query" type="query" required="true"
			hint="query holding the data">
		<cfargument name="force_id" type="string" required="false" default=""
			hint="force the given ID to be used">
		<cfargument name="lastkey" type="string" required="false" default=""
			hint="the last key known for good (important for synchronization)">
		<cfargument name="type" type="string" required="true">
		<cfargument name="target" type="string" required="false" default=""
			hint="target where we should output the data">
		<cfargument name="setActive" type="boolean" required="false" default="false"
			hint="set this recordset to active by default or not">
		<cfargument name="columns" type="string" required="false" default=""
			hint="Columns to display">
		<cfargument name="playlistkey" type="string" required="false" default=""
			hint="in playlist mode? give playlist key">
		<cfargument name="options" type="string" required="false" default=""
			hint="various options">
		<cfargument name="stLicencePermissions" type="struct" required="true"
			hint="permissions on this recordset" />

		<cfset var stReturn = application.udf.GenerateReturnStruct() />
		<cfset var sHTMLContent = '' />
		<cfset var a_str_id = 'id_recordset_' & ReplaceNoCase( CreateUUID(), '-', '', 'ALL' ) />
		<cfset var a_arr_meta = ArrayNew( 1 ) />
		<cfset var stLocal = {} />
		
		<cfif Len( arguments.force_id ) GT 0>
			<cfset a_str_id = arguments.force_id />
		</cfif>
		
		<!--- return the meta in CFMX and as JSON 
		
			id of recordset
			type
			recordcount
			columns
			lastkey
			set as active?
			plistkey
			options
			all available columns
			permissions for this set		
		
		--->
		<cfset stReturn.meta = { ID = a_str_id,
										TARGET = arguments.target,
										TYPE = arguments.type,
										RECORDCOUNT = arguments.query.recordcount,
										COLUMNS = arguments.columns,
										LASTKEY = arguments.lastkey,
										SETACTIVE = arguments.setActive,
										PLAYLISTKEY = arguments.playlistkey,
										OPTIONS = arguments.options,
										FULLCOLUMNLIST = arguments.query.columnlist,
										PERMISSIONS = arguments.stLicencePermissions } />
		
		<cfset stReturn.meta_json = SerializeJSON( stReturn.meta ) />
		
		<!--- the JS raw data --->
		<cfset stReturn.data_json = SerializeJSON( arguments.query ) />
		
		<!--- debugging stuff --->
		<cfset stReturn.stLicencePermissions = arguments.stLicencePermissions />
		
		<!--- no on demand streaming ... build radio station string --->
		<cfif NOT arguments.stLicencePermissions.ondemand>
			
			<!--- ok, continue! --->
			<cfif arguments.stLicencePermissions.INTERACTIVERADIO>
				
				<!--- build the radio station string --->
				<cfsavecontent variable="sHTMLContent">
					<div style="padding-left:20px;width:auto;<cfif arguments.query.recordcount IS 0>display:none</cfif>" class="bb bt">
						<cfoutput>
						
						<table class="" style="width:400px;">
							<tr>
								<td valign="middle">
									<a href="##" onclick="recSet.SetCurrentRecordsetID( '#a_str_id#' );recSet.SetCurrentRecordsetCurIndex( 0, true );return false"><img src="http://cdn.tunesBag.com/images/skins/default/playerBtnPlay.png" style="margin:6px" border="0" alt="#application.udf.GetLangValSec( 'cm_wd_play' )#" /></a>
								</td>
								<td valign="middle">
									<a class="add_as_tab" href="#application.udf.generateArtistURL( arguments.query.artist, arguments.query.mb_artistid)#"><img src="#application.udf.getArtistImageByID( arguments.query.mb_artistid, 48 )#" style="margin:6px;border:0px" class="img48x36" alt="#htmleditformat( arguments.query.artist )#" /></a>
								</td>
								<td valign="middle" style="padding:10px">
									
									<cfsavecontent variable="stLocal.sArtistLink"><a href="#application.udf.generateArtistURL( arguments.query.artist, arguments.query.mb_artistid)#" class="add_as_tab">#htmleditformat( arguments.query.artist )#</a> - #htmleditformat( arguments.query.name )#</cfsavecontent>
									
									<cfset stlocal.stTranslation = application.udf.GetLangValSec( 'lib_ph_interactive_listen_plist_artist' ) />
									
									#ReplaceNoCase( stLocal.stTranslation, '{1}', stLocal.sArtistLink)#
										
								
								</td>
							</tr>
						</table>
						</cfoutput>
					</div>
					<div class="clear"></div>
				</cfsavecontent>
				
			</cfif>
			
		</cfif>
		
		<!--- generate the full JS output --->
		<cfsavecontent variable="sHTMLContent">
			
			<!--- <cfdump var="#arguments.securitycontext#"> --->
			
			<!--- include string which has maybe already been created --->
			<cfoutput>#sHTMLContent#</cfoutput>
			
			<cfif Len( arguments.target ) GT 0>
				
				
				<div id="<cfoutput>#arguments.target#</cfoutput>"></div>
				<!--- <cfdump var="#arguments.stLicencePermissions#"> --->
				
				<cfoutput>
				<!--- data, meta, false (no unique information provided), type --->
				<script type="text/javascript">					
					HandleRecordSet( '#JsStringFormat( stReturn.data_json )#',
									 '#JsStringFormat( stReturn.meta_json )#',
									 false,
									 'plistitems',
									 '' );
				</script>
				</cfoutput>
			</cfif>
		
		</cfsavecontent>
		
		<cfset stReturn.html_content = Trim( sHTMLContent ) />
		
		<cfreturn application.udf.SetReturnStructSuccessCode(stReturn) />
	</cffunction>
	
</cfcomponent>
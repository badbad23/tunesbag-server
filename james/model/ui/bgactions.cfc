<!--- //

	Module:		background actions
	Action:		
	Description:	
	
// --->


<cfcomponent name="logger" displayname="UI component"output="false" extends="MachII.framework.Listener" hint="UI for tunesBag application">

<cfinclude template="/common/scripts.cfm">

<cffunction name="configure" access="public" output="false" returntype="void" hint="Configures this listener as part of the Mach-II  framework"> 
	<!--- do nothing --->
</cffunction>

<cffunction access="public" name="CheckBGPageLayout" output="false" returntype="void"
		hint="Check if we've an iframe and we need to modify the layout page">
	<cfargument name="event" type="MachII.framework.Event" required="true" />
	<cfset var a_bol_ignore_page_layout = event.getArg( 'IgnorePageLayout', false ) />
	<cfset var a_str_set_page_layout = event.getArg( 'pageLayout' ) />
	<cfset var a_str_type = event.getArg( 'type' ) />
	
	<!--- for certain types, use layout.simple.output only! --->
	<cfif ListFindNoCase( ',playlist.deleteitems,item.download,item.lyrics,searchinternet,friend.requestfriendship,friend.cancelfriendship,addfriend,addressbookimport,playlist.resort,playlist.new,playlist.edit,playlist.delete,addcomment,items.uploadrun.autoadd2plist', a_str_type ) GT 0>
		<cfset a_str_set_page_layout = 'layout.simple.output' />
	</cfif>
	
	<!--- use a specific page layout --->
	<cfif Len( a_str_set_page_layout ) GT 0>
		<cfset event.setArg( 'layoutEvent', a_str_set_page_layout ) />
	</cfif>
	
	<!--- if the pagelayout should be ignored, set this variable --->
	<cfif a_bol_ignore_page_layout>
		<cfset event.setArg( 'disableLayoutManager', true) />
	</cfif>

</cffunction>

<cffunction access="public" name="CheckPreProcessBGAction" output="false" returntype="void"
		hint="check for certain action types">
	<cfargument name="event" type="MachII.framework.Event" required="true" />
	
	<cfset var a_str_type = event.getArg( 'type' ) />
	<cfset var a_return = 0 />
	<cfset var a_struct_filter = 0 />
	<cfset var a_struct_dl_ticket = 0 />
	
	<cfswitch expression="#a_str_type#">
		<cfcase value="findytvideo">
			
			<!--- query youtube --->
			<cfset a_return = getProperty( 'beanFactory' ).getBean( 'YouTubeComponent' ).SearchForYoutubeClips( search = event.getArg( 'artist' ) & ' ' & event.getArg( 'name' ),
								storeTemporaryEntrykeys = false ) />
								
			<cfset event.setArg( 'a_struct_search_result', a_return ) />			
			
		</cfcase>
		<cfcase value="searchinternet">
		
			<!--- search skreemr --->
			<cfset a_return = getProperty( 'beanFactory' ).getBean( 'SkreemrComponent' ).QuerySkreemr( artist = event.getArg( 'artist' ), name = event.getArg( 'name' ) ) />
					
			<cfset event.setArg( 'a_struct_search_result', a_return ) />	
		
		</cfcase>
		<cfcase value="item.info,item.lyrics">
			
			<cfset a_struct_filter = { entrykeys = event.getArg( 'entrykey', 'doesnotexist') } />
			
			<cfset a_return = getProperty( 'beanFactory' ).getBean( 'MediaItemsComponent' ).GetUserContentData( librarykeys = '',
													type = 'mediaitems',
													securitycontext = application.udf.GetCurrentSecurityContext(),
													filter = a_struct_filter ) />
					
			<cfif a_return.result>
			
				<cfset event.setArg( 'a_struct_item_info', a_return.q_select_items ) />	
				
				<cfif a_str_type IS 'item.lyrics'>
					<cfset event.setArg( 'a_struct_lyrics', getProperty( 'beanFactory' ).getBean( 'lyrics' ).getSongLyrics( artist = a_return.q_select_items.artist,
																							name = a_return.q_select_items.name ) ) />			
				</cfif>
						
			</cfif>
			
		</cfcase>
		<cfcase value="item.download">
			<!--- user wants to download an item --->
			<cfset a_return = getProperty( 'beanFactory' ).getBean( 'MediaItemsComponent' ).GetMediaItem(securitycontext = application.udf.GetCurrentSecurityContext(),
						entrykey = event.getArg( 'entrykey' ),
						source = 'download',
						operation_reason = 'download',
						deliver_mode = true ) />
						
			<!--- ok? --->
			<cfif NOT a_return.result>
				<cfreturn />
			</cfif>
			
			<!--- check userkey --->
			<cfif a_return.item.getUserkey() NEQ application.udf.GetCurrentSecurityContext().entrykey>
				<cfreturn />
			</cfif>
						
			<!--- in case we've a file, create a download ticket --->
			<cfif a_return.deliver_info.type IS 'file'>
		
				<cfset a_struct_dl_ticket = application.beanFactory.getBean( 'StorageComponent' ).CreateDownloadTicketForFile( a_return.deliver_info ) />
			
				<!--- createDLTicket --->
				<cfset a_return.deliver_info.location = a_struct_dl_ticket.url />
			
			</cfif>	
		
			<cfset arguments.event.setArg( 'a_download_item' , a_return ) />
			
		</cfcase>
	</cfswitch>

</cffunction>

<cffunction name="CheckBGAction" access="public" output="false" returntype="void"
		hint="Store log information in database">
	<cfargument name="event" type="MachII.framework.Event" required="true" />
	
	<cfset var a_str_type = event.getArg( 'type' ) />
	<cfset var a_cmp = 0 />
	<cfset var a_struct_result = StructNew() />
	<cfset var a_bol_result = false />
	<cfset var a_str_message = '' />
	<cfset var a_str_js_execute = '' />
	<!--- the error number --->
	<cfset var a_int_error = 0 />
	<cfset var a_str_data = '' />
	<cfset var a_str_recipient = '' />
	<cfset var a_str_recipients = '' />
	<cfset var a_str_mediaitem_key = '' />
	<cfset var a_struct_data = 0 />
	<cfset var a_int_count = 0 />
	<cfset var q_select = 0 />
	<cfset var a_str_title = '' />
	<cfset var oComp = 0 />
	<cfset var a_str_description = '' />
	<cfset var a_str_href = '' />
	<cfset var a_str_known_recipients = '' />
	<cfset var q_update_autoadd2playlist = 0 />
	<cfset var cffile = 0 />
	<cfset var local = {} />
	
	<!--- content to return --->
	<cfset local.sContent = '' />
		
	<cfswitch expression="#a_str_type#">
		<cfcase value="service.ping">
			
			<!--- ping keepalive --->
			
			<!--- set user online status to true --->
			<cfset getProperty( 'beanFactory' ).getBean( 'UserComponent' ).UpdateUserOnlineStatus( securitycontext = application.udf.GetCurrentSecurityContext() ) />
			
			<!--- load userdata --->
			<cfset a_struct_data = getProperty( 'beanFactory' ).getBean( 'UserComponent' ).GetUserData( userkey = application.udf.GetCurrentSecurityContext().entrykey ).a_struct_item />
			
			<!--- check for queue status --->
			<cfset a_int_count = getProperty( 'beanFactory' ).getBean( 'UploadComponent' ).getProcessingQueueSizeForUser( userkey = application.udf.GetCurrentSecurityContext().entrykey ) />
			
			<!--- check for friends updates --->
			
			<!--- check for new messages --->
			
			<!--- number of recommendations (shared items) --->
			<cfset event.setArg( 'UnreadSharedItems', a_struct_data.getstatus_unreadshareditems() ) />
			
			<!--- number of unread messages --->
			<cfset event.setArg( 'UnreadMessages', a_struct_data.getstatus_unreadmessages() ) />
			
			<!--- open friendship requests --->
			<cfset event.setArg( 'OpenFriendShipRequests', a_struct_data.getstatus_openfriendshiprequests() ) />
			
			<!--- check if the host lib has changed --->
			<cfset a_str_data = getProperty( 'beanFactory' ).getBean( 'MediaItemsComponent' ).GetLibraryLastkey( event.getArg( 'librarykey' )) />
			
			<!--- has changed! ... reload host library in this case --->
			<cfif CompareNoCase( a_str_data, event.getarg( 'lastkey' ) ) NEQ 0>
				<cfset a_str_js_execute = 'fireHostLibraryHasChanged("' & JsStringFormat( a_str_data ) & '");' />
				<!--- <cfset a_str_message = 'your lastkey was ' & event.getarg( 'lastkey' ) & '  compared to  ' & a_str_data /> --->
			</cfif>
			
			<cfset event.setArg( 'UploadQueueSize' , a_int_count ) />
			
			<cfset a_bol_result = true />		
		
		</cfcase>
		<cfcase value="play.ping">
			<!--- send a ping back --->
			
			<cfset getProperty( 'beanFactory' ).getBean( 'LogComponent' ).LogMediaItemPlayPing( securitycontext = application.udf.GetCurrentSecurityContext(),
						secondsplayed = Val(Int( Val(event.getArg( 's' )))),
						mediaitemkey = event.getArg( 'mediaitemkey' ) ) />

			<cfset a_bol_result = true />
		
		</cfcase>
		<cfcase value="message.delete">
			<!--- delete a message --->
			<cfset getProperty( 'beanFactory' ).getBean( 'MessagesComponent' ).DeleteMessage( securitycontext = application.udf.GetCurrentSecurityContext(),
								entrykey = event.getArg( 'entrykey' )) />
								
			<cfset a_bol_result = true />
			<cfset a_str_message = application.udf.GetLangValSec( 'cm_ph_msg_has_been_deleted' ) />			
		
		</cfcase>
		<cfcase value="message.send">
			<!--- send a message / store --->
			<cfset getProperty( 'beanFactory' ).getBean( 'MessagesComponent' ).StoreMessage( securitycontext = application.udf.GetCurrentSecurityContext(),
								subject = event.getArg( 'subject' ),
								body = event.getArg( 'body' ),
								userkey_to = getProperty( 'beanFactory' ).getBean( 'UserComponent' ).getEntrykeyByUsername( event.getArg( 'recipient' ) ),
								notify_recipient = true ) />
								
			<cfset a_bol_result = true />
			<cfset a_str_message = application.udf.GetLangValSec( 'cm_ph_msg_has_been_sent' ) />				
		
		</cfcase>

		<!--- request a friendship --->
		<cfcase value="friend.requestfriendship">

			<cfset a_cmp = getProperty( 'beanFactory' ).getBean( 'SocialComponent' ) />
			
			<cfset a_struct_result = a_cmp.RequestFriendShip( securitycontext = application.udf.GetCurrentSecurityContext(),
							otheruserkey = getProperty( 'beanFactory' ).getBean( 'UserComponent' ).getEntrykeyByUsername( event.getArg( 'username' ) ),
							customtext = event.getArg( 'customtext')) />
			
			<cfset a_str_message = '' />
			<cfset a_bol_result = a_struct_result.result />
		
		</cfcase>		
		
		<!--- answer to friendship request --->
		<cfcase value="friend.requestfriendship.answer">
			
			<cfset a_cmp = getProperty( 'beanFactory' ).getBean( 'SocialComponent' ) />
			
			<cfset a_struct_result = a_cmp.FriendShipRequestAnswer( securitycontext = application.udf.GetCurrentSecurityContext(),
							requestkey = event.getArg( 'entrykey' ),
							answer = event.getArg( 'answer' , 1 )) />
			
			<cfset a_str_message = ''/>
			<cfset a_bol_result = a_struct_result.result />
		
		</cfcase>

		<!--- automatically add a friend with just one click ... only valid for certain users --->
		<cfcase value="friend.autoadd">
			
			<cfset a_str_data = event.getArg( 'username' ) />
			
			<!--- list of valid users --->
			<cfif ListFindNoCase( 'free.music', a_str_data ) GT 0>
			
				<cfset a_struct_result = getProperty( 'beanFactory' ).getBean( 'SocialComponent' ).AddFriend( securitycontext = application.udf.GetCurrentSecurityContext(),
								source = 0,
								name = a_str_data,
								accesslibrary = 1,
								otherusername = a_str_data ) />
				
				<cfset a_bol_result = true />
				
			</cfif>
			
		</cfcase>
		
		<!--- remove a friendship from the list --->
		<cfcase value="friend.cancelfriendship">
		
			<cfset a_cmp = getProperty( 'beanFactory' ).getBean( 'SocialComponent' ) />
			
			<cfset a_struct_result = a_cmp.CancelFriendship( securitycontext = application.udf.GetCurrentSecurityContext(),
							friendshipkey = event.getArg( 'entrykey' )) />
			
			<cfset a_str_message = ''/>
			<cfset a_bol_result = a_struct_result.result />
			
		
		</cfcase>
		
		<!--- revoke / grant access --->
		<cfcase value="friend.revokeaccess,friend.grantaccess">
			
			<!--- access allowed or not? --->
			<cfif a_str_type IS 'friend.revokeaccess'>
				<cfset a_str_data = 0 />
			<cfelse>
				<cfset a_str_data = 1 />
			</cfif>
			
			<!--- a friend is no longer allowed to access the user's library
				
				direction is important!
				
				0 = User A does not want to access library B any more
				1 = User A does not want B to access his library any more
				
				SO ...
					0 = seen from current user
					1 = seen from other user!
				
				 --->
			<cfset a_struct_result = getProperty( 'beanFactory' ).getBean( 'SocialComponent' ).EditLibraryAccess( securitycontext = application.udf.GetCurrentSecurityContext(),
							access = a_str_data,
							direction = event.getArg( 'direction', 0 ),
							otheruserkey = event.getArg( 'otheruserkey' )) />
			
			<cfset a_bol_result = true />
		
		</cfcase>
		<cfcase value="addressbookimportergetcontacts">
			
			<cfset local.oImporter = getProperty( 'beanFactory' ).getBean( 'AddressbookImporter' ) />
			<cfset local.sUsername = event.getArg( 'username' ) />
			<cfset local.sPassword = event.getArg( 'password' ) />
			<!--- 
				is this address supported at all?
			 --->
			<cfset local.bIsSupported = local.oImporter.getAddressBookImporter().isSupported( local.sUsername ) />
			
			<cfif NOT local.bIsSupported>
				<cfset a_str_message = 'not supported' />
			<cfelse>
			
				<cfset local.stImport = local.oImporter.getContactsAsQuery( local.sUsername, local.sPassword ) />
				
				<cfif local.stImport.result>
					<cfsavecontent variable="local.sContent">
						<div class="div_container">
							
						<table class="table_overview">
							<cfoutput>
							<thead>
								<th>
									<input type="checkbox" value="" />
								</th>
								<th>
									#application.udf.GetLangValSec( 'cm_wd_name' )#
								</th>
								<th>
									#application.udf.GetLangValSec( 'cm_wd_email' )#
								</th>
							</thead>
							</cfoutput>
						<tbody>
						<cfoutput query="local.stImport.qcontacts">
							<tr>
								<td>
									<input type="checkbox" checked="true" />
								</td>
								<td>
									#htmleditformat( local.stImport.qcontacts.name )#
								</td>
								<td>
									#htmleditformat( local.stImport.qcontacts.email )#
								</td>
							</tr>
						</cfoutput>
						</tbody>
						</table>
						Einladungen werden versendet auf <select name="language"><option value="en">English</option><option value="de">Deutsch</option></select>
						<br />
						<input type="submit" class="btn" value="Einladen">
						
						</div>
					</cfsavecontent>
					
					<cfset a_bol_result = true />
				</cfif>
			</cfif>
			
		</cfcase>
		<cfcase value="add_webupload">
			
			<!--- add a file from web --->
		
					
		</cfcase>
		<cfcase value="preference.set">
			<!--- set a user preference ... no special return --->
			
			<cfset getProperty( 'beanFactory' ).getBean( 'UserComponent' ).StorePreference( userkey = application.udf.GetCurrentSecurityContext().entrykey,
						name = event.getArg( 'name' ),
						value = event.getArg( 'value' ) ) />
						
			<cfset a_str_message = '' />
			<cfset a_bol_result = true />
						
		</cfcase>
		<cfcase value="preference.3prdparty.removeservice">
			
			<!--- remove a 3rd party service --->
			<cfset a_struct_result = getProperty( 'beanFactory' ).getBean( 'UserComponent' ).DeleteExternalSiteID( securitycontext = application.udf.GetCurrentSecurityContext(),
					servicename = event.getArg( 'servicename' )) />
			
			<cfset a_str_message = a_struct_result.errormessage />
			<cfset a_bol_result = a_struct_result.result />
		
		</cfcase>
		<cfcase value="preference.get">
			<!--- set a user preference ... no special return --->
			
			<cfset a_str_message = getProperty( 'beanFactory' ).getBean( 'UserComponent' ).GetPreference( userkey = application.udf.GetCurrentSecurityContext().entrykey,
						name = event.getArg( 'name' ),
						defaultvalue = event.getArg( 'defaultvalue' ) ) />
						
			<cfset a_bol_result = true />
						
		</cfcase>	
		<cfcase value="ui.customradio.createstation.done">
			<!--- a custom radio station has been created --->
			
			<cfif Len( event.getArg( 'newplaylistkey') ) GT 0>
				<cfset a_str_js_execute = 'DoNavigateToURL( "tb:loadplist&plistkey=' & event.getArg( 'newplaylistkey') &'" );' />
				<cfset a_bol_result = true />
			</cfif>
			
		</cfcase>
		<cfcase value="addfriend">
			<!--- add a friend --->
			<cfset a_cmp = getProperty( 'beanFactory' ).getBean( 'SocialComponent' ) />
			
			<cfset a_struct_result = a_cmp.AddFriend( securitycontext = application.udf.GetCurrentSecurityContext(),
							name = event.getArg( 'username' ),
							source = 0,
							otherusername = event.getArg( 'username' ),
							accesslibrary = 1) />
			
			<cfset a_str_message = 'hello' />
			<cfset a_bol_result = false />
		</cfcase>
		<cfcase value="item.recommendation.click">
		
			<!--- user clicked on recommendation, log this --->
<!--- 
			<cfset getProperty( 'beanFactory' ).getBean( 'MyStrandsComponent' ).InsertStrandsEvent( mediaitemkey = event.getArg( 'entrykey' ),
					itemtype = 0,
					action = 1,
					dt_action = Now(),
					username = application.udf.GetCurrentSecurityContext().username,
					unique_identifier = event.getArg( 'unique_hash' ) ) />
 --->
		
			<!--- own track? start playing! --->
			<cfset a_return = getProperty( 'beanFactory' ).getBean( 'MediaItemsComponent' ).GetMediaItem(securitycontext = application.udf.GetCurrentSecurityContext(),
						entrykey = event.getArg( 'entrykey' ),
						source = 'recommendation',
						deliver_mode = false,
						context = 4 ) />
			
			<!--- item is accessible --->			
			<cfif a_return.result>
				<cfset event.setArg( 'fullyplayable', true ) />
			<cfelse>
				<cfset event.setArg( 'fullyplayable', false ) />
			</cfif>
						
			<!--- <cfset event.setArg( 'a_return', a_return ) /> --->
		
			<cfset a_bol_result = true />
		
		</cfcase>
		<cfcase value="item.metadata.autofix">
			
			<!--- autofix meta data ... --->
			
			<!--- ignore this item? --->
			<cfif event.getArg( 'ignore', 0) IS 1>
				
				<!--- ignore it ... set status to 10 --->
				<cfset a_struct_data = { puid_analyzed = 10 } />
				
				<!--- store item --->
				<cfset a_struct_result = getProperty( 'beanFactory' ).getBean( 'MediaItemsComponent' ).SaveMediaItemInformation( securitycontext = application.udf.GetCurrentSecurityContext(),
											entrykey = event.getArg( 'entrykey' ),
											newvalues = a_struct_data ) />
			<cfelse>
				
				<cfset getProperty( 'beanFactory' ).getBean( 'MusicBrainz' ).AutoFixMetaInformationByPUIDMatch( securitycontext = application.udf.GetCurrentSecurityContext(),
						mediaitemkey = event.getArg( 'entrykey' ),
						mb_identifier = event.getArg( 'mb_identifier') ) />
			</cfif>
			
			<cfset a_bol_result = true />
		
		</cfcase>
		
		<cfcase value="items.edit">
			<!--- edit one or more items (mediaitem) --->
			
			<cfset local.sEntrykeys = event.getArg( 'entrykeys' ) />
			
			<cfloop list="#local.sEntrykeys#" index="local.sEntrykey">
				
				<cfset local.stUpdate = {} />
				
				<!--- basic fields to edit --->
				<cfset local.sFields = 'name,album,artist,year,genre,trackno' />
				
				<!--- loop over fields and check if data has been provided and enabled --->
				<cfloop list="#local.sFields#" index="local.sField">
					
					<cfif Len( event.getArg( local.sField)) AND event.getArg( 'edit_' & local.sField, false)>
						<cfset local.stUpdate[ local.sField ] = event.getArg( local.sField ) />
					</cfif>
				
				</cfloop>
				
				<!--- anything to update? --->
				<cfif StructCount( local.stUpdate ) GT 0>
			
					<cfset a_struct_result = getProperty( 'beanFactory' ).getBean( 'MediaItemsComponent' ).SaveMediaItemInformation( securitycontext = application.udf.GetCurrentSecurityContext(),
											entrykey = local.sEntrykey,
											newvalues = local.stUpdate ) /> >
				</cfif>
			
			</cfloop>
											
			<cfset a_bol_result = a_struct_result.result />
			<cfset a_str_message = a_struct_result.errormessage />		
		</cfcase>
		
		<cfcase value="addtemporaryitemtomylibrary">
		
			<!--- add temporary item to my own library --->
			<cfset a_cmp = getProperty( 'beanFactory' ).getBean( 'MediaItemsComponent' ) />
			
			<cfset a_struct_result = a_cmp.AddTemporaryItemToOwnLibrary(securitycontext = application.udf.GetCurrentSecurityContext(),
												temporarykey = event.getArg( 'temporarykey' ),
												source = event.getArg( 'source' ) ) />
												
			<cfset a_bol_result = a_struct_result.result />
			<cfset a_str_message = a_struct_result.errormessage />
		
		</cfcase>
		<cfcase value="createeditplaylist">
			
			<!--- Create a playlist --->
			<cfset a_cmp = getProperty( 'beanFactory' ).getBean( 'PlaylistsComponent' ) />
			
			<cfset a_struct_result = a_cmp.CreateEditPlaylist(securitycontext = application.udf.GetCurrentSecurityContext(),
												entrykey = event.getArg( 'frmentrykey' ),
												librarykey = event.getArg( 'frmlibrarykey' ),
												name = event.getArg( 'frmname' ),
												description = event.getArg( 'frmdescription' ),
												tags = event.getArg( 'frmtags' ),
												public = Val( event.getArg( 'frmpublic', 0) ),
												temporary = 0,
												dynamic = event.getArg( 'dynamic', 0),
												dynamic_criteria = event.getArg( 'dynamic_criteria', '' ),
												additems = event.getArg( 'frmadditemkeys', '' ) ) />
												
												
			<cfset a_bol_result = a_struct_result.result />
			<cfset a_str_message = a_struct_result.errormessage />
			
			<!--- in case a new playlist has been created, switch to the list! --->
			<!--- <cfif a_bol_result AND Len( event.getArg( 'entrykey' ) IS 0)>
			
				<cfset a_str_js_execute = 'DoRequest("list", { "playlistkey" : "' & JSStringFormat( event.getArg( 'newplaylistkey') ) & '"});' />
			</cfif> --->
			
		</cfcase>
		<cfcase value="playlist.resort">
			
			<!--- resort a playlist --->
			<cfif Len( event.getArg( 'plistkey' ) ) GT 0>
				
				<cfset a_cmp = getProperty( 'beanFactory' ).getBean( 'PlaylistsComponent' ) />
				
				<!--- yes, call clearing ... --->
				<cfset a_cmp.ClearPlaylistItems(securitycontext = application.udf.GetCurrentSecurityContext(),
						playlistkey = event.getArg( 'plistkey' )) />
					
				<!--- now add the items again --->	
				<cfloop list="#event.getArg( 'itemkeys' )#" delimiters="," index="a_str_data">

					<!--- add! --->
					<cfset a_cmp.AddItemToPlaylist(securitycontext = application.udf.GetCurrentSecurityContext(),
												librarykey = '',
												mediaitemkey = a_str_data,
												playlistkey = event.getArg( 'plistkey' ),
												updateplistcount = false ) />
			
				</cfloop>
				
				<!--- update plist count --->
				<cfset a_cmp.UpdatePlaylistItemsCount( event.getArg( 'plistkey' ) ) />
				
				<!--- return true --->
				<cfset a_bol_result = true />
				<cfset a_str_message = '' />
				
			</cfif>
		
		</cfcase>
		<cfcase value="playlist.linktolibrary">
			
			<!--- link a plist to local lib --->
			<cfset a_struct_result = getProperty( 'beanFactory' ).getBean( 'PlaylistsComponent' ).LinkPlaylisttoLibrary( securitycontext = application.udf.GetCurrentSecurityContext(),
												playlistkey = event.getArg( 'playlistkey' ),
												playlistuserkey = event.getArg( 'playlistuserkey' ) ) />
			
			<cfset a_bol_result = a_struct_result.result />
			<cfset a_str_message = a_struct_result.errormessage />
			
		</cfcase>
		<cfcase value="plist.removelinked">
		
			<!--- remove a link to a plist --->
			<cfset a_struct_result = getProperty( 'beanFactory' ).getBean( 'PlaylistsComponent' ).RemovePlaylistLink( securitycontext = application.udf.GetCurrentSecurityContext(),
												playlistkey = event.getArg( 'plistkey' )) />
			
			<cfset a_bol_result = a_struct_result.result />
			<cfset a_str_message = a_struct_result.errormessage />
		
		</cfcase>
		<cfcase value="items.uploadrun.autoadd2plist">
			
			<!--- update the autoaddtoplaylist column of this uploadrun --->
			<cfif Len( event.getArg( 'playlist' ) ) GT 0>
				
				<cfquery name="q_update_autoadd2playlist" datasource="mytunesbutleruserdata">
				DELETE FROM
					uploaded_autoadd_plist
				WHERE
					userkey = <cfqueryparam cfsqltype="cf_sql_varchar" value="#application.udf.GetCurrentSecurityContext().entrykey#">
					AND
					uploadkey = <cfqueryparam cfsqltype="cf_sql_varchar" value="#event.getArg( 'uploadrunkey' )#">
				;
				</cfquery>
				
				<!--- insert --->
				<cftry>
					<cfquery name="q_update_autoadd2playlist" datasource="mytunesbutleruserdata">
					INSERT INTO
						uploaded_autoadd_plist
						(
						userkey,
						uploadkey,
						plistname
						)
					VALUES
						(
						<cfqueryparam cfsqltype="cf_sql_varchar" value="#application.udf.GetCurrentSecurityContext().entrykey#">,
						<cfqueryparam cfsqltype="cf_sql_varchar" value="#event.getArg( 'uploadrunkey' )#">,
						<cfqueryparam cfsqltype="cf_sql_varchar" value="#event.getArg( 'playlist' )#">
						)
					;
					</cfquery>
				<cfcatch type="any"></cfcatch>
				</cftry>
				
				<cfset a_bol_result = true />
				
			</cfif>
		
		</cfcase>
		<cfcase value="playlist.delete">
			
			<!--- delete a playlist --->
			<cfset a_cmp = getProperty( 'beanFactory' ).getBean( 'PlaylistsComponent' ) />
			
			<cfset a_struct_result = a_cmp.DeletePlaylist( securitycontext = application.udf.GetCurrentSecurityContext(),
												entrykey = event.getArg( 'playlistkey' ) ) />
			
			<cfset a_bol_result = a_struct_result.result />
			<cfset a_str_message = a_struct_result.errormessage />
			
		</cfcase>
		<cfcase value="playlist.deleteitems">
			
			<!--- delete one or more items from a playlist --->					
			<cfset a_struct_result = getProperty( 'beanFactory' ).getBean( 'PlaylistsComponent' ).DeletePlaylistitems( securitycontext = application.udf.GetCurrentSecurityContext(),
										entrykeys = event.getArg( 'entrykeys' ),
										playlistkey = event.getArg( 'playlistkey' ) ) />
			
			<cfset a_bol_result = a_struct_result.result />
			<cfset a_str_message = a_struct_result.errormessage />
			
		</cfcase>
		<cfcase value="addtoplaylist">
			
			<!--- add an item to a playlist --->
			<cfset a_cmp = getProperty( 'beanFactory' ).getBean( 'PlaylistsComponent' ) />

			<cfloop list="#event.getArg( 'mediaitemkeys' )#" index="a_str_mediaitem_key" delimiters=",">
			
			<cfset a_struct_result = a_cmp.AddItemToPlaylist(securitycontext = application.udf.GetCurrentSecurityContext(),
												librarykey = event.getArg( 'librarykey' ),
												mediaitemkey = a_str_mediaitem_key,
												playlistkey = event.getArg( 'playlistkey' )) />
			</cfloop>
															
			<cfset a_bol_result = a_struct_result.result />
			<cfset a_str_message = a_struct_result.errormessage />												
														
		</cfcase>
		<cfcase value="sendinvitation">
			
			<!--- send an invitation --->
			<cfset a_cmp = getProperty( 'beanFactory' ).getBean( 'SocialComponent' ) />
			
			<cfset a_struct_result = a_cmp.CreateInvitation( securitycontext = application.udf.GetCurrentSecurityContext(),
											recipient = event.getArg( 'frmemail' ),
											customtext = event.getArg( 'frmcustomtext' )) />
											
			<cfset a_bol_result = a_struct_result.result />
			<cfset a_str_message = a_struct_result.errormessage />
			<cfset a_int_error = a_struct_result.error />
			
			<cfif a_bol_result>
				<cfset a_str_message = application.udf.GetLangValSec( 'social_ph_invitation_sent' ) />
			</cfif>										
			
		</cfcase>
		<cfcase value="invitation.delete">
		
			<!--- delete an invitation --->
			<!--- send an invitation --->
			<cfset a_cmp = getProperty( 'beanFactory' ).getBean( 'SocialComponent' ) />
			
			<cfset a_struct_result = a_cmp.DeleteInvitation( securitycontext = application.udf.GetCurrentSecurityContext(),
											entrykey = event.getArg( 'entrykey' )) />
											
			<cfset a_bol_result = a_struct_result.result />
			<cfset a_str_message = a_struct_result.errormessage />
			<cfset a_int_error = a_struct_result.error />
					
		
		</cfcase>
		<cfcase value="item.rate">
			
			<!--- rate an item --->
			<cfset a_cmp = getProperty( 'beanFactory' ).getBean( 'MediaItemsComponent' ) />
			
			<!--- call item rating ... --->
			<cfset a_struct_result = a_cmp.RateItem(securitycontext = application.udf.GetCurrentSecurityContext(),
												librarykey = event.getArg( 'librarykey' ),
												rating = event.getArg( 'rating', 0 ),
												itemtype = event.getArg( 'itemtype', 0),
												mediaitemkey = event.getArg( 'mediaitemkey' ),
												mbid = Val(event.getArg( 'mbid' ))) />
												
			<cfset a_bol_result = a_struct_result.result />
			<cfset a_str_message = a_struct_result.errormessage />												
			
		</cfcase>
		<cfcase value="addcomment">
			
			<!--- add a comment --->
			<cfset a_struct_result = getProperty( 'beanFactory' ).getBean( 'CommentsComponent' ).AddComment(
											securitycontext = application.udf.GetCurrentSecurityContext(),
											comment = event.getArg( 'comment' ),
											posttotwitter = ( event.getArg( 'posttotwitter', 0) IS '1'),
											linked_objectkey = event.getArg( 'itemkey' ),
											linked_object_type = Val( event.getArg( 'itemtype' ) ) ) />
												
			<cfset a_bol_result = a_struct_result.result />
			<cfset a_str_message = a_struct_result.errormessage />			
		
		</cfcase>
		<cfcase value="items.prefilled.clear">
			
			<!--- remove all prefilled items from the library --->
			<cfset getProperty( 'beanFactory' ).getBean( 'ContentComponent' ).removePrefilledTracks( application.udf.GetCurrentSecurityContext() ) />
			
			<cfset a_bol_result = true />
			
		</cfcase>
		<cfcase value="items.delete">
			
			<cfif ListLen( event.getArg( 'itemkeys' ) ) IS 0>
				<cfset a_bol_result = false />
			<cfelse>
			
			
				<!--- delete an item from the library --->
				<cfset a_cmp = getProperty( 'beanFactory' ).getBean( 'MediaItemsComponent' ) />
				
				<!--- delete item by item --->
				<cfloop list="#event.getArg( 'itemkeys' )#" index="a_str_data">
					
					<cfset a_struct_result = a_cmp.RemoveItemFromLibrary(securitycontext = application.udf.GetCurrentSecurityContext(),
															entrykey = a_str_data ) />
												
				</cfloop>
				
				<!--- return result of last delete operation --->
				<cfset a_str_message = a_struct_result.errormessage />
				<cfset a_bol_result = a_struct_result.result />
			
			</cfif>
			
			
		</cfcase>
		<cfcase value="item.share">
			
			<!--- get known recipients --->
			<cfset a_str_known_recipients = getProperty( 'beanFactory' ).getBean( 'UserComponent' ).GetPreference( userkey = application.udf.GetCurrentSecurityContext().entrykey,
						name = 'share_email_addresses',
						defaultvalue = '' ) />
			
			<!--- decode list of tunesBag users --->
			<cfset a_str_recipients = urlDecode( event.getArg( 'recipients' )) />
			
			<!--- email addresses provided? --->
			<cfif Len( event.getArg( 'recipients_mailto' )) GT 0>
			
				<!--- add prefix to all email addresses --->
				<cfloop list="#urlDecode( event.getArg( 'recipients_mailto' ))#" delimiters=", ;" index="a_str_data">
					
					<cfset a_str_data = application.udf.ExtractEmailAdr( a_str_data ) />
					
					<cfif Len( a_str_data ) GT 0>
						<cfset a_str_recipients = ListAppend( a_str_recipients, 'mailto:' & a_str_data ) />
						
						<!--- add to list of known addresses --->
						<cfif ListFindNoCase( a_str_known_recipients, a_str_data ) IS 0>
							<cfset a_str_known_recipients = ListPrepend( a_str_known_recipients, a_str_data ) />
						</cfif>
						
					</cfif>
					
				</cfloop>
				
				<!--- save known addresses --->
				<cfset a_str_known_recipients = getProperty( 'beanFactory' ).getBean( 'UserComponent' ).StorePreference( userkey = application.udf.GetCurrentSecurityContext().entrykey,
					name = 'share_email_addresses',
					value = a_str_known_recipients ) />
			
			</cfif>
			
			<cflog application="false" file="tb_share" log="Application" text="#a_str_recipients#" type="information">
		
			<!--- an item is shared ... --->
			<cfif Len( a_str_recipients ) GT 0>
			
				<cfset a_cmp = getProperty( 'beanFactory' ).getBean( 'SocialComponent' ) />
				
				<cfset a_struct_result = a_cmp.ShareItem( securitycontext = application.udf.GetCurrentSecurityContext(),
												itemtype = Val( event.getArg( 'itemtype' )),
												title = urlDecode( event.getArg( 'title' )),
												identifier = UrlDecode( event.getArg( 'identifier' )),
												recipients = a_str_recipients,
												comment = urlDecode( event.getArg( 'comment' )),
												url = urlDecode( event.getArg( 'url' ))) />
												
				<cfset a_bol_result = true />
				
			</cfif>
		
		</cfcase>
		<!--- 
			
			search flickr for photos for sidebar
			
		 --->
		<cfcase value="ui.flickr.searchphotos.json">
			
			<cfset stPhotos = application.beanFactory.getBean( 'Flickr' ).searchForImages( sSearch = event.getArg( 'search' ),
					sLoadResolutions = 'size_medium',
					iHits = 15 ) />
					
			<cfset local.aData = ArrayNew(1) />
			
			<cfif stPhotos.result>
				
				<cfloop query="stPhotos.QRESULT">
					<cfset local.aData[ stPhotos.qResult.currentrow ] = { username = stPhotos.qResult.username, size_large = stPhotos.qResult.size_medium } />
				</cfloop>
				
			</cfif>
			
			<cfset local.sContent = SerializeJSON( local.aData ) />
		
		</cfcase>
		<!--- 
			
			search flickr for photos
		
		 --->
		<cfcase value="ui.flickr.searchphotos">
			
			<!---  --->
			<cfset stPhotos = getProperty( 'beanFactory' ).getBean( 'Flickr' ).searchForImages( sSearch = event.getArg( 'search' ) ) />
			
			<!--- no hits or hits? --->
			<cfif stPhotos.result>
				
				<cfsavecontent variable="a_str_data">
					
					<div>
					
					<cfoutput query="stPhotos.qResult">
						<div class="cBox cBox135" onclick="handleFlickrImageClick( '#JsStringFormat( stPhotos.qResult.size_medium )#', '100', 'http://www.flickr.com/photos/#stPhotos.qResult.userid#/#stPhotos.qResult.id#/'  )" style="margin:12px">
							<span class="header" title="#htmleditformat( stPhotos.qResult.title )#">#htmleditformat( application.udf.ShortenString( stPhotos.qResult.title, 25) )#</span>
							<div class="content" style="background-image:URL('#stPhotos.qResult.size_medium#');">
								<img class="playbtn" alt="Take this!" src="http://cdn.tunesbag.com/images/vista/Symbol-Add-64x64.png" />
							</div>
						
						</div>
						
					</cfoutput>
					
					</div>
					
				</cfsavecontent>
			<cfelse>
				
				<cfsavecontent variable="a_str_data">
				<div class="div_container addinfotext">
					<cfoutput>#application.udf.GetLangValSec( 'cm_ph_no_items_found' )#</cfoutput>
				</div>
				</cfsavecontent>
			
			</cfif>
			
			
			<cfset event.setArg( 'flickr_search', a_str_data ) />
			
		
		</cfcase>
		
		<cfcase value="sync.forcenow">
			
			<!--- force a sync process --->
			<cfset getProperty( 'beanFactory' ).getBean( 'Sync' ).forceSyncNow(
				stContext 		= application.udf.GetCurrentSecurityContext(),
				sServicename	= event.getArg('servicename'),
				bResetSyncinfo	= true
				) />
			
			<cfset a_bol_result = true />
			
		</cfcase>
		<cfcase value="ui.sharedlg">
			
			<cfset q_select = getProperty( 'beanFactory' ).getBean( 'SocialComponent' ).GetFriendsList( securitycontext = application.udf.GetCurrentSecurityContext(), realusers_only = true  ).q_select_friends />
			
			<!--- create content --->
			<cfsavecontent variable="a_str_data">
				<cfinclude template="inc/inc_sharing_dlg.cfm">
			</cfsavecontent>
			
			<cfset a_str_data = ReplaceNoCase( a_str_data, '  ', ' ', 'ALL' ) />
			
			<cfset event.setArg( 'friends_form', a_str_data ) />
			
			<cfset a_bol_result = true />
		
		</cfcase>
		<cfcase value="item.sharedlg.getinfo">
			
			<!--- get necessary info for share dlg --->
			<cfswitch expression="#event.getArg( 'itemtype', -1 )#">
				<cfcase value="1">
					
					<!--- return link for a media item --->
					<cfset a_struct_result = getProperty( 'beanFactory' ).getBean( 'MediaItemsComponent' ).GetMediaItem(securitycontext = application.udf.GetCurrentSecurityContext(),
						entrykey = event.getArg( 'identifier' ),
						deliver_mode = false ) />
						
					<cfif a_struct_result.result>
					
						<!--- alright, read data and return --->
						<cfset a_struct_result = a_struct_result.item />
						
						<cfset event.setArg( 'title', a_struct_result.getName() & ' - ' & a_struct_result.getArtist() ) />
						<cfset event.setArg( 'url', 'http://www.tunesBag.com' & GenerateGenericURLToTrack( a_struct_result.getArtist(), a_struct_result.getName(), a_struct_result.getMB_TrackID(), a_struct_result.getEntrykey() ) ) />						

						<cfset a_bol_result = true />					
					</cfif>

					
				</cfcase>		
				<cfcase value="plist">
					
					<cfset a_struct_return = getProperty( 'beanFactory' ).getBean( 'PlaylistsComponent' ).getSimplePlaylistInfo( playlistkey = event.getArg( 'identifier' ), loaditems = false ) />
					
					<cfif a_struct_return.result>
						<!--- return the plist info --->
						<cfset event.setArg( 'title', a_struct_return.q_select_simple_plist_info.name ) />
						<cfset event.setArg( 'url', generateURLToPlist( a_struct_return.q_select_simple_plist_info.Entrykey, a_struct_return.q_select_simple_plist_info.name, true )) />
					
						<cfset a_bol_result = true />
					</cfif>
					
				</cfcase>		
				<cfcase value="item.share.removerecommendation">
					<!--- remove a recommendation --->
					
					<cfset getProperty( 'beanFactory' ).getBean( 'SocialComponent' ).DeleteSharedItem( securitycontext = application.udf.GetCurrentSecurityContext(),
									entrykey = event.getArg( 'entrykey' )) />
				
					<cfset a_str_message = '' />
					<cfset a_bol_result = true />
					
				</cfcase>
				<cfdefaultcase>
					
					<cfset a_bol_result = false />
				</cfdefaultcase>
			</cfswitch>

			
		
		</cfcase>
	</cfswitch>
	
	<!--- result is false but no error message? --->
	<cfif NOT a_bol_result AND Len( a_str_message ) IS 0 AND ( a_int_error GT 0 )>
		<cfset a_str_message = application.udf.GetLangValSec( 'err_ph_' & a_int_error) />
	</cfif>
	
	<!--- set result --->
	<cfset event.setArg( 'result' , a_bol_result ) />
	
	<!--- set error number --->
	<cfset event.setArg( 'error' , a_int_error ) />	
	
	<!--- set return message --->
	<cfset event.setArg( 'message' , a_str_message ) />
	
	<!--- set HTML Content to return --->
	<cfset event.setArg( 'content' , local.sContent ) />
	
	<!--- set optional JS to execute --->
	<cfset event.setArg( 'exec_js', a_str_js_execute ) />
	
</cffunction>

</cfcomponent>
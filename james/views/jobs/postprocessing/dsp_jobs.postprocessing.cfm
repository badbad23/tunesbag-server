<!---

	perform post processing ...
	
	generate log infos, last.fm submit info etc

--->

<cfinclude template="/common/scripts.cfm">

<cfset a_transfer = getProperty( 'beanFactory' ).getBean( 'LogTransfer' ).getTransfer() />
<!--- <cfset a_strands = getProperty( 'beanFactory' ).getBean( 'MyStrandsComponent' ) /> --->

<cfquery name="q_select_log_items" datasource="mytunesbutlerlogging">
SELECT
	playeditems.dt_created,
	playeditems.ip,
	playeditems.mediaitemkey,
	playeditems.userkey,
	playeditems.itemdata,
	users.username,
	mediaitems.artist,
	mediaitems.album,
	mediaitems.name,
	mediaitems.totaltime,
	playeditems.secondsplayed,
	3rdparty_ids.username AS username_lastfm,
	playeditems.id
FROM
	playeditems USE INDEX (postprocessingdone)
LEFT JOIN
	mytunesbutleruserdata.3rdparty_ids AS 3rdparty_ids ON (3rdparty_ids.userkey = playeditems.userkey) AND (3rdparty_ids.servicename = 'lastfm')
LEFT JOIN
	mytunesbutleruserdata.mediaitems AS mediaitems ON (mediaitems.entrykey = playeditems.mediaitemkey)
LEFT JOIN
	mytunesbutleruserdata.users AS users ON (users.entrykey = playeditems.userkey)
WHERE
	playeditems.postprocessingdone = 0
	AND
	playeditems.secondsplayed > 30
	AND
	/* at least seven minutes in the past */
	playeditems.dt_created < <cfqueryparam cfsqltype="cf_sql_timestamp" value="#DateAdd( 'n', -5, Now() )#" />
LIMIT
	200
</cfquery>

<cfdump var="#q_select_log_items#">

<cfloop query="q_select_log_items">
	
<!--- make ready to submit to strands service --->
<!--- 
<cfset a_strands.InsertStrandsEvent( mediaitemkey = q_select_log_items.mediaitemkey,
					action = 0,
					itemtype = 0,
					dt_action = q_select_log_items.dt_created,
					username = q_select_log_items.username,
					unique_identifier = getHashValueArtistTrack( q_select_log_items.artist, q_select_log_items.name )) />
 --->

<!--- submit to audioscrobbler? --->
<cfif Len( q_select_log_items.username_lastfm ) GT 0>

	<cfset a_new_item = a_transfer.new( 'logging.lastfm_submit_data' ) />
	
	<cfset a_new_item.setUserkey( q_select_log_items.userkey ) />
	<cfset a_new_item.setdt_played( q_select_log_items.dt_created ) />
	<cfset a_new_item.setartist( q_select_log_items.artist ) />
	<cfset a_new_item.setalbum( q_select_log_items.album ) />
	<cfset a_new_item.setname( q_select_log_items.name ) />
	<cfset a_new_item.settracklen( Val( q_select_log_items.totaltime ) ) />
	
	<!--- take a default value --->
	<cfif a_new_item.gettracklen() IS 0>
		<cfset a_new_item.settracklen( 240 ) />
	</cfif>
	
	<cfset a_new_item.sethandled( 0 ) />
	
	<cftry>
	<cfset a_transfer.Save( a_new_item ) />
	<cfcatch type="any"> </cfcatch>
	</cftry>

</cfif>


<cfquery name="q_update_handled" datasource="mytunesbutlerlogging">
UPDATE
	playeditems
SET
	postprocessingdone = 1
WHERE
	id = <cfqueryparam cfsqltype="cf_sql_integer" value="#q_select_log_items.id#">
;
</cfquery>

</cfloop>
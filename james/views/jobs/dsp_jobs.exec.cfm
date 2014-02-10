<!---

	execute a certain job

--->

<cfset a_str_type = event.getArg( 'type' ) />

<cfoutput>#a_str_type#</cfoutput>

<cfswitch expression="#a_str_type#">
	
	<cfcase value="performancereporting">
		<cfinclude template="performancereporting/dsp_jobs.performancereporting.cfm">
	</cfcase>
	
	<cfcase value="checkcommonalbuminfo">
		<cfinclude template="checkcommonalbuminfo/dsp_jobs.checkcommonalbuminfo.cfm">
	</cfcase>
	
	<cfcase value="calcartistpopularity">
		<cfinclude template="calculateartistpopularity/dsp_calc_artist_popularity.cfm">
	</cfcase>
		
	<cfcase value="postprocessing">
		<cfinclude template="postprocessing/dsp_jobs.postprocessing.cfm">
	</cfcase>
	
	<cfcase value="submitlastfm">
		<cfinclude template="submitlastfm/dsp_jobs.submitlastfm.cfm">
	</cfcase>
	
	<cfcase value="cleanup">
		<cfinclude template="cleanup/dsp_jobs.cleanup.cfm">
	</cfcase>
	
	<cfcase value="syncprefillmusic">
		<cfinclude template="syncprefillmusic/dsp_syncprefillmusic.cfm">
	</cfcase>
	
	<cfcase value="synccdn">
		<cfinclude template="synccdn/dsp_synccdn.cfm">
	</cfcase>
	
	<cfcase value="updateserverpool">
		<cfinclude template="updateserverpool/dsp_updateserverpool.cfm">
	</cfcase>
	
	<cfcase value="deleteoldfiles">
		<cfinclude template="deleteoldfiles/dsp_deleteoldfiles.cfm">
	</cfcase>
	
	<!--- scan the dropbox accounts --->
	<cfcase value="scandropbox">
		<cfinclude template="scandropbox/dsp_scandropbox.cfm" />
	</cfcase>
	
	<cfcase value="dropboxhint">
		<cfinclude template="dropboxhint/dsp_dropboxhint.cfm" />
	</cfcase>
	
	<cfcase value="execblacklist">
		<cfinclude template="execblacklist/dsp_execblacklist.cfm" />
	</cfcase>
		
	<cfdefaultcase>
		unknown type
	</cfdefaultcase>

</cfswitch>
<br /><br />
<i>job done.</i>
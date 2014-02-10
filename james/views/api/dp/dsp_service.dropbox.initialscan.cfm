<!--- 

	initial scan results
 --->

<cfinclude template="/common/scripts.cfm" />

<cfset stContent = event.getARg( 'stContent' ) />

<cfsavecontent variable="request.content.final">

		<div class="confirmation" style="margin-right:20px;margin-bottom: 20px">
			Thank you, the selected directory will be scanned now and the media items should be available in your library soon.
			<br /><br />
			<a href="/start/" style="font-weight:bold">Switch to your library now</a>
		</div>


</cfsavecontent>
<!--- 
<cfset bStored = event.getArg( 'stored', false) />

<!--- show a short confirmation message --->
<cfif bStored>
	
	<cfsavecontent variable="request.content.final">
	
		<div class="confirmation" style="margin-right:20px">
			Thank you, the selected directory will be scanned now and the media items should be available in your library soon.
			<br /><br />
			<a href="/start/" style="font-weight:bold">Switch to your library now</a>
		</div>
	
	</cfsavecontent>
	
	<cfexit method="exittemplate" />
</cfif>

<cfsavecontent variable="request.content.final">
<h1>Please select a source folder or start with the main folder</h1>
<div class="status" style="margin-right:20px">
<!--- The media items will be available in your library soon. Please give our servers a minute. --->

<!--- <br /><br />
<a href="/start/" style="font-weight:bold">Switch to your library now</a> --->
tunesBag will limit the number of scanned directories and stop at a certain directory level depth in order to guarantee the best performance.
Our recommendation is to use a distinct folder for storing your music.
<br />
You can change the folder later in your preferences.
</div>

<br />

<form action="<cfoutput>#cgi.SCRIPT_NAME#?#cgi.QUERY_STRING#</cfoutput>" method="post">
	
<!--- notify event handler about stored data --->
<input type="hidden" name="stored" value="true" />
	
<cfoutput>	<input type="radio" value="" checked="true" name="sourcefolder" /> #application.udf.si_img( 'folder_table')# <b>Dropbox main folder ("/")</b></cfoutput>
	<br />
	<div style="padding:20px">
<cfloop collection="#stKnowndata#" item="sItem">
	
<cfif
	(
		ListLen( sItem, '/' ) IS 1 AND ListLen( sItem, '.') IS 1
	)>
	
<cfoutput>
		
	<input type="radio" value="#htmleditformat( sItem )#" name="sourcefolder" /> #application.udf.si_img( 'folder_table')# #htmleditformat( ListFirst( sItem, '/') )#<br />

</cfoutput>

</cfif>

	
<!--- <cfoutput>#application.udf.si_img( 'folder_table' )# #htmleditformat( sItem )#<br /></cfoutput> --->
</cfloop>
</div>
<br />
<input type="submit" class="btn" value="Save and synchronize now" />&nbsp;&nbsp;|&nbsp;&nbsp;<a href="#" onclick="location.reload();return false">Reload folder structure</a>
<br /><br />


</form>
</cfsavecontent>
 --->
<cfset event.setArg( 'PageTitle', 'Dropbox source select') />
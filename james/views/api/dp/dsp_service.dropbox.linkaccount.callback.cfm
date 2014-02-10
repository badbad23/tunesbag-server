<cfset stAccess = event.getArg( 'stAccess' ) />

<cfinclude template="/common/scripts.cfm">

<!--- success? perform a sync now --->
<cfif stAccess.result>
		
</cfif>


<cfsavecontent variable="request.content.final">
<!--- <cfdump var="#event.getArgs()#">

<cfdump var="#session.stTempDPAuth#"> --->

<h1>Success - Your Dropbox account has successfully been added!</h4>

<div class="status">
<img class="si_img" src="/res/images/spinner-16x16.gif" /> <cfoutput>#application.udf.GetLangValSec( 'cm_ph_dropbox_scanning_started' )#</cfoutput>
</div>

</cfsavecontent>

<cfsavecontent variable="sHead">
<meta http-equiv="refresh" content="0;URL=?event=service.dropbox.initialscan" />
</cfsavecontent>

<cfhtmlhead text="#sHead#" />
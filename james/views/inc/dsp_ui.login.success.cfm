<!--- //

	Module:		Login successfully handled
	Action:		
	Description:	
	
// --->

<cfinclude template="/common/scripts.cfm">

<cfset a_str_return_url = event.getArg( 'returnurl' ) />

<cfif Len( a_str_return_url ) IS 0>
	<cfset a_str_return_url = '/start/' />
</cfif>

<html>
	<head>
		<title>Redirecting ...</title>
		<meta http-equiv="refresh" content="0;URL=<cfoutput>#htmleditformat( a_str_return_url )#</cfoutput>">
		<link rel="stylesheet" href="/res/css/default.css" />
	</head>
<body style="padding:100px;padding-top:0px" class="body_main">
	
	
	<table align="center" style="margin-left:auto;margin-right:auto;width:auto" border="0">
		<tr>
			<td valign="top">
				<a href="<cfoutput>#htmleditformat( a_str_return_url )#</cfoutput>" style="text-decoration:underline;"><img src="http://cdn.tunesBag.com/images/skins/default/bgLogoLeftTop.png" style="vertical-align:middle" border="0" alt="tunesBag"></a>
			</td>
			<td valign="middle" style="padding:20px;font: Normal 26px 'Lucida Grande', Arial, sans-serif; padding-top:200px">
				<cfoutput>#application.udf.GetLangValSec( 'login_ph_redirecting_library' )#</cfoutput>
				<p style="margin-top:12px">
				<a href="<cfoutput>#htmleditformat( a_str_return_url )#</cfoutput>" style="color:black;font-weight:bold;text-decoration:underline;"><cfoutput>#application.udf.GetLangValSec( 'cm_ph_click_here_to_proceed' )#</cfoutput></a>
				</p>
			</td>
		</tr>
	</table>
	
	
</body>
</html>
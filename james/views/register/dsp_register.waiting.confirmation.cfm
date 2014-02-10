<cfinclude template="/common/scripts.cfm">
<cfsavecontent variable="request.content.final">
<h1><cfoutput>#application.udf.GetLangValSec( 'signup_ph_take_time_activate' )#</cfoutput></h1>

<div class="status" style="font-size:18px;margin-right:40px">
	<p>Account activation mail has been sent to:</p>
	<h2><cfoutput>#htmleditformat( event.getArg( 'frmemail' ))#</cfoutput></h2>
	<p>In the e-mail click on the activate link to confirm your registration</p>
</div>
<h4>Didn't receive an e-mail from us?</h4>
<p>Check your spam or junk folder</p>
<br /><br />


<h4>Don't forget</h4>
<br />
<iframe src="http://www.facebook.com/plugins/like.php?href=http%3A%2F%2Fwww.tunesBag.com%2F&amp;layout=standard&amp;show_faces=false&amp;width=450&amp;action=like&amp;colorscheme=light&amp;height=80" scrolling="no" frameborder="0" style="border:none; overflow:hidden; width:450px; height:40px;" allowTransparency="true"></iframe>
<br /><br />

<!--- <h4>Still can't find it?</h4>
<p>We can resend the e-mail</p> --->
<!--- <cfdump var="#event.getargs()#"> --->
</cfsavecontent>
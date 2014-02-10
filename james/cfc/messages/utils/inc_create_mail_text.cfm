<!--- text version ---><cfprocessingdirective pageencoding="utf-8" /><cfoutput><cfif arguments.bIsRegisteredUser>#application.udf.GetLangValSec( 'nav_welcome_back_username', stUserData.firstname )#</cfif>

#arguments.sTextContent#

--- Important links ---
Blog: http://blog.tunesBag.com | Suggest and vote for new features: http://feedback.tunesBag.com/
<cfif arguments.bIsRegisteredUser AND arguments.bNewsletter>
Unsubscribe: http://www.tunesBag.com/newsletter/unsubscribe.cfm?username=#urlencodedformat( stUserData.username )#&emailhash=#Hash( stUserData.email )#
</cfif>
#application.udf.GetLangValSec( 'mail_ph_newsletter_reason_email' )#

tunesBag is a product of tunesBag.com Limited, Private company incorporated in England & Wales. Our mailing address is: tunesBag.com Limited | 69 Great Hampton St | Birmingham, B18 6EW | UK
</cfoutput>
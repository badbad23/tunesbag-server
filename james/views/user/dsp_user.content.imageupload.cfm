<!--- output JSON of image check --->
<cfsavecontent variable="request.content.final">

<cfoutput>#SerializeJSON( event.getArg( 'a_struct_img_upload_result' ) )#</cfoutput>

</cfsavecontent>
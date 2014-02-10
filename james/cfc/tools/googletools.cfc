<!--- 

	Google Tools

	google qr code generator

 --->

<cfcomponent output="false" hint="Google tools (including QR code generator)">
	
	<cffunction access="public" name="init" returntype="any" hint="constructor">
		<cfreturn this />
	</cffunction>
	
	<cffunction access="public" name="generateQRCode" output="false" returntype="struct"
			hint="Generate QR code of a given string">
		<cfargument name="sText" type="string" required="true"
			hint="The string to convert to a QR code, might be an URL, telephone number or simple text" />
		<cfargument name="sImageSize" type="string" required="false" default="150x150"
			hint="Size of generated QR image" />
		
		<cfset var stReturn = application.udf.GenerateReturnStruct() />
		
		<cfif Len( Trim(arguments.sText) ) IS 0>
			<cfreturn application.udf.SetReturnStructErrorCode(stReturn, 404, 'Please provide some text') />
		</cfif>
		
		<cfset local.sFileName = GetTempDirectory() & CreateUUID() & '.png' />
		
		<cftry>
		
			<cfhttp method="get" result="local.cfhttp" url="http://chart.apis.google.com/chart?chs=#UrlEncodedFormat( arguments.sImageSize )#&cht=qr&chl=#UrlEncodedFormat( sText )#&choe=UTF-8" getasbinary="true">
			</cfhttp>
			
			<cffile action="write" file="#local.sFileName#" output="#local.cfhttp.FileContent#" />
			
			<cfset stReturn.sFilename = local.sFileName />
		
			<cfcatch type="any">
				
				<cfreturn application.udf.SetReturnStructErrorCode(stReturn, 500, 'Failed. Error message is: ' & cfcatch.Message ) />
			
			</cfcatch>
		</cftry>
		
		<cfreturn application.udf.SetReturnStructSuccessCode( stReturn ) />

	</cffunction>

	<cffunction access="public" name="getTTSFile" output="false" returntype="struct"
			hint="Get a TTS from google">
		<cfargument name="sLang" type="string" required="false" default="en" />
		<cfargument name="sMsg" type="string" required="true" />
		
		<cfset var stReturn = application.udf.GenerateReturnStruct() />
		
		<cfhttp charset="utf-8" url="http://translate.google.com/translate_tts?tl=#arguments.sLang#&q=#UrlEncodedFormat( arguments.smsg )#&rand=#CreateUUID()#" result="local.stHTTP"></cfhttp>
		
		<cfset stReturn.stHTTP = local.stHTTP />
		
		<cfreturn application.udf.SetReturnStructSuccessCode( stReturn ) />
		
	</cffunction>

</cfcomponent>
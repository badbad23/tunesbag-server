<!--- 
	
	PayPal component
	
	
	developer center
	
	https://cms.paypal.com/us/cgi-bin/?&cmd=_render-content&content_ID=developer/home_UK
	
	https://cms.paypal.com/uk/cgi-bin/?cmd=_render-content&content_ID=developer/e_howto_api_NVPAPIBasics

 --->

<cfcomponent output="false">

	<cfinclude template="/common/scripts.cfm">
	
	<cfset variables.stPayPalAccessData = {} />
	
	<cffunction access="public" name="Init" returntype="james.cfc.shop.paypal">
		
		<!--- set variables ... --->
		
		<!--- testuser: seller_1257284258_biz@hansjoergposch.com --->
		<cfset variables.stPayPalAccessData[ 'serverURL' ] = application.udf.GetSettingsProperty( 'PPServerURL', 'https://api-3t.sandbox.paypal.com/nvp' ) />
		<cfset variables.stPayPalAccessData[ 'APIuserName' ] = application.udf.GetSettingsProperty( 'PPAPIuserName', 'seller_1257284258_biz_api1.hansjoergposch.com' ) />
		<cfset variables.stPayPalAccessData[ 'APIPassword' ] = application.udf.GetSettingsProperty( 'PPAPIPassword', '1257284287' ) />
		<cfset variables.stPayPalAccessData[ 'APISignature' ] = application.udf.GetSettingsProperty( 'PPAPISignature', 'An5ns1Kso7MWUdW4ErQKJJJ4qi4-AFbmsByH5LKqPOTEJ-skbVpMNs3L' ) />
		<cfset variables.stPayPalAccessData[ 'PayPalURL' ] = application.udf.GetSettingsProperty( 'PayPalURL', 'https://www.sandbox.paypal.com/cgi-bin/webscr?cmd=_express-checkout&token=' ) />
		<cfset variables.stPayPalAccessData[ 'PayPalVersion' ] = application.udf.GetSettingsProperty( 'PayPalVersion', '55.0' ) />
		
		<cfreturn this />
	</cffunction>
	
	<cffunction access="private" name="getPayPalAccessData" returntype="struct" output="false"
			hint="return the paypayl access data">
		
		<cfreturn variables.stPayPalAccessData />

	</cffunction>
	
	<cffunction access="public" name="PayPalGetExpressCheckoutDetails" output="false" returntype="struct" hint="get details of express checkout">
		<cfargument name="token" type="string" required="true">
		
		<cfset var stRequest = {} />
		<cfset var stReturn = application.udf.GenerateReturnStruct() />
		<cfset var httpresponse = '' />
		
		<!--- meta --->
		<cfset stRequest.METHOD = 'GetExpressCheckoutDetails' />
		<CFSET stRequest.USER = getPayPalAccessData().APIuserName />
		<CFSET stRequest.PWD = getPayPalAccessData().APIPassword />		
		<CFSET stRequest.SIGNATURE = getPayPalAccessData().APISignature />
		<CFSET stRequest.VERSION = getPayPalAccessData().PayPalVersion />
		<cfset stRequest.TOKEN = arguments.token />		

		<cfset httpresponse = doHttppost( stRequest ) />
		
		<cfset stReturn.response = getNVPResponse( httpresponse ) />
		
		<!--- get the payment details --->
		<cfset stReturn.oPaymentContext = application.beanFactory.getBean( 'ShopComponent' ).getPaymentContext( stReturn.response.CUSTOM ) />

		<cfreturn application.udf.SetReturnStructSuccessCode(stReturn) />		
	
	</cffunction>
	
	<cffunction access="public" name="CreateRecurringPaymentsProfile" output="false" returntype="struct" hint="create the recurring payment profile">
		<cfargument name="data" type="struct" required="true" hint="structure with data from PayPal" />
		<cfargument name="period" type="string" required="true" hint="Year or Month" />
		<cfargument name="startdate" type="date" default="#Now()#" required="false"
			hint="when to start" />
		
		<cfset var stRequest = {} />
		<cfset var stReturn = application.udf.GenerateReturnStruct() />
		<cfset var httpresponse = '' />
		<cfset var sDescription = getOrderDescription( sProduct = application.udf.GetLangValSec( 'cm_wd_upgrade' ),
						sRecurring = true,
						sCurrency = arguments.data.currencycode, 
						sPrice = arguments.data.amount,
						sPeriod = arguments.period) />
						
		<!--- make sure it's written correctly --->
		<cfif arguments.period IS 'year'>
			<cfset arguments.period = 'Year' />
		</cfif>
		
		<cfif arguments.period IS 'month'>
			<cfset arguments.period = 'Month' />
		</cfif>		
		<!--- <cfmail from="office@tunesbag.com" to="office@tunesbag.com" subject="lslsl" type="html">
		<cfdump var="#arguments#">
		</cfmail> --->
		
		<cfset stRequest.METHOD = 'CreateRecurringPaymentsProfile' />
		<CFSET stRequest.USER = getPayPalAccessData().APIuserName />
		<CFSET stRequest.PWD = getPayPalAccessData().APIPassword />		
		<CFSET stRequest.SIGNATURE = getPayPalAccessData().APISignature />
		<CFSET stRequest.VERSION = getPayPalAccessData().PayPalVersion />
		
		<!--- process token --->
		<cfset stRequest.TOKEN = arguments.data.token />	
		
		<!--- inital payment --->	
		<cfset stRequest.INITAMT = arguments.data.initialamount />
		
		<!--- recurring starts today? so do not charge one time fees --->
		<cfif DateDiff('d', arguments.startdate, Now() ) IS 0>
			<cfset StructDelete( stRequest, 'INITAMT' ) />
		</cfif>
		
		<!--- amount --->
		<cfset stRequest.AMT = arguments.data.amount />	
		<cfset stRequest.CURRENCYCODE = arguments.data.currencycode />	
		<cfset stRequest.BILLINGPERIOD = arguments.period />
		<cfset stRequest.PROFILESTARTDATE = DateFormat(arguments.startdate, 'yyyy-mm-dd') & 'T00:00:00Z' />
		<cfset stRequest.BILLINGFREQUENCY = 1 />
		<cfset stRequest.DESC = sDescription />
						
		<!--- custom ... = payment key --->
		<cfset stRequest.CUSTOM = createUUID() />

		<cfset stRequest.BILLINGTYPE = 'RecurringPayments' />
		<!--- <cfset stRequest.BILLINGAGREEMENTDESCRIPTION = sDescription /> --->
		
		<!--- contact paypal server --->
		<cfset httpresponse = doHttppost( stRequest ) />
			
		<!--- analyze the response --->
		<cfset stReturn.response = getNVPResponse( httpresponse ) />
		
		<cfif StructKeyExists( stReturn.response, 'ACK' ) AND stReturn.response.ACK IS 'Success'>
			<!--- return result --->
			<cfreturn application.udf.SetReturnStructSuccessCode(stReturn) />	
		<cfelse>
			<!--- failure! --->
			<cfreturn application.udf.SetReturnStructErrorCode( stReturn, 500, 'Error' ) />
		</cfif>
		
	</cffunction>
	
	<cffunction access="public" name="getRecurringPaymentProfileStatus" output="false" returntype="struct"
			hint="return the status of a recurring payment profile">
		<cfargument name="sProfileID" type="string" required="true" />
		
		<cfset var stRequest = {} />
		<cfset var stReturn = application.udf.GenerateReturnStruct() />
		
		<cfset stRequest.METHOD = 'GetRecurringPaymentsProfileDetails' />
		<CFSET stRequest.USER = getPayPalAccessData().APIuserName />
		<CFSET stRequest.PWD = getPayPalAccessData().APIPassword />		
		<CFSET stRequest.SIGNATURE = getPayPalAccessData().APISignature />
		<CFSET stRequest.VERSION = getPayPalAccessData().PayPalVersion />
		<CFSET stRequest.ProfileID = arguments.sProfileID />
		
		
		<!--- contact paypal server --->
		<cfset var httpresponse = doHttppost( stRequest ) />
			
		<!--- analyze the response --->
		<cfset stReturn.response = getNVPResponse( httpresponse ) />
		
		<cfif StructKeyExists( stReturn.response, 'ACK' ) AND stReturn.response.ACK IS 'Success'>
			<!--- return result --->
			<cfreturn application.udf.SetReturnStructSuccessCode(stReturn) />	
		<cfelse>
			<!--- failure! --->
			<cfreturn application.udf.SetReturnStructErrorCode( stReturn, 500, 'Error' ) />
		</cfif>

	</cffunction>
	
	<cffunction access="public" name="getOrderDescription" output="false" returntype="string"
			hint="return the subject of the order">
		<cfargument name="sProduct" type="string" required="true" />
		<cfargument name="sRecurring" type="boolean" required="true" />
		<cfargument name="sCurrency" type="string" required="true" />	
		<cfargument name="sPrice" type="string" required="true" />
		<cfargument name="sPeriod" type="string" required="true" />
		
		<cfset var sReturn = '' />
		
		<!--- <cfset sReturn = application.udf.GetLangValSec( 'shop_ph_paypal_subject' ) & ' - ' & arguments.sProduct & ' / ' & arguments.sCurrency & ' ' & arguments.sPrice & ' / ' & arguments.sPeriod /> --->

		<cfreturn application.udf.GetLangValSec( 'shop_ph_paypal_subject' ) />

		<cfreturn sReturn />
	
	</cffunction>
	
	<cffunction access="public" name="PayPalExpressCheckoutPerformPayment" output="false" returntype="struct" hint="perform the payment">
		<cfargument name="data" type="struct" required="true" hint="structure with data from PayPal">
		
		
		<cfset var stRequest = {} />
		<cfset var stReturn = application.udf.GenerateReturnStruct() />
		<cfset var httpresponse = '' />
		
		<cfset stRequest.METHOD = 'DoExpressCheckoutPayment' />
		<CFSET stRequest.USER = getPayPalAccessData().APIuserName />
		<CFSET stRequest.PWD = getPayPalAccessData().APIPassword />		
		<CFSET stRequest.SIGNATURE = getPayPalAccessData().APISignature />
		<CFSET stRequest.VERSION = getPayPalAccessData().PayPalVersion />
		<cfset stRequest.TOKEN = data.token />		
		<cfset stRequest.PAYERID = data.payerid />	
		<cfset stRequest.PAYMENTACTION = 'sale' />	
		<cfset stRequest.AMT = data.amount />	
		<!--- <cfset stRequest.AMT = 1 /> --->
		<cfset stRequest.CURRENCYCODE = data.currencycode />	
		
		<!--- contact paypal server --->
		<cfset httpresponse = doHttppost( stRequest ) />
		
		<!--- analyze the response --->
		<cfset stReturn.response = getNVPResponse( httpresponse ) />
		
		<!--- add response to log --->

		<cfreturn application.udf.SetReturnStructSuccessCode(stReturn) />		
		
	</cffunction>
	
	<cffunction access="public" name="PreparePayPalRequest" output="false" returntype="struct" hint="fill structure for request">
		<cfargument name="method" type="string" required="true" hint="SetExpressCheckout etc">
		<cfargument name="paymentaction" type="string" required="false" default="sale">
		<cfargument name="currencycode" type="string" required="true">
		<cfargument name="amt" type="numeric" required="true" hint="amount">
		<cfargument name="description" type="string" required="true">
		<cfargument name="custom" type="string" required="true">
		<cfargument name="period" type="string" required="true"
			hint="YEAR or MONTH" />
		<cfargument name="redirect_cancel" type="string" required="true" />
		<cfargument name="redirect_return" type="string" required="true" />
		<cfargument name="bRecurring" type="boolean" required="true" />
		<cfargument name="sCountrycode" type="string" required="true"
			hint="country code for displaying the login page in the right language">
		
		<cfset var stRequest = {} />
		<cfset var local = {} />
		<cfset var sDescription = getOrderDescription( sProduct = application.udf.GetLangValSec( 'cm_wd_upgrade' ),
						sRecurring = arguments.bRecurring,
						sCurrency = arguments.currencycode, 
						sPrice = arguments.amt,
						sPeriod = arguments.period ) />
		
		<!--- meta --->
		<cfset stRequest.METHOD = arguments.method />
		<cfset stRequest.PAYMENTACTION = arguments.paymentaction />
		<CFSET stRequest.USER = getPayPalAccessData().APIuserName />
		<CFSET stRequest.PWD = getPayPalAccessData().APIPassword />		
		<CFSET stRequest.SIGNATURE = getPayPalAccessData().APISignature />
		<CFSET stRequest.VERSION = getPayPalAccessData().PayPalVersion />
		
		<!---  amout etc --->
		<CFSET stRequest.CURRENCYCODE = arguments.currencycode />
		<CFSET stRequest.AMT = arguments.amt />
		
		<!--- our context ID  (paymentkey)... --->
		<cfset stRequest.CUSTOM = arguments.custom />
		
		<!--- description --->
		<cfset stRequest.DESC = sDescription />	
		
		<!--- language used for login page --->
		
		<!--- supported: AU, DE, FR, GB, IT, ES, JP, US --->
		<cfset local.sSupportedCountryCodes = 'AU,DE,FR,GB,IT,ES,JP,US' />
		
		<cfif ListFindNoCase( local.sSupportedCountryCodes, arguments.sCountrycode )>
			<cfset stRequest.LOCALECODE = uCase( arguments.sCountrycode ) />
		<cfelse>
			<!--- default = US --->
			<cfset stRequest.LOCALECODE = 'US' />
		</cfif>
		
		<cfset stRequest.BILLINGTYPE = 'RecurringPayments' />
		
		<!--- important: this has to be the same description as the further calls --->
		<cfset stRequest.BILLINGAGREEMENTDESCRIPTION = sDescription />
		
		<!--- various --->
		
		<!--- don't request shipping address as there is nothing to ship --->
		<cfset stRequest.NoShipping = 1 />
		
		<!--- include header image --->
		<cfset stRequest.HDRIMG = 'http://cdn.tunesbag.com/images/skins/default/bgLogoLeftTop.png' />
		
		<!--- redirects --->
		<cfset stRequest.CancelURL = arguments.redirect_cancel />
		<cfset stRequest.ReturnURL = arguments.redirect_return />
	
		<cfreturn stRequest />
	
	</cffunction>
	
	<cffunction access="public" name="getLocalURLRedirectsForRequest" output="false" returntype="struct" hint="return OK / Cancel URL">
		<cfargument name="paymentaction" type="string" required="true" />
		<cfargument name="paymentAmount" type="string" required="true" />
		<cfargument name="currencyCodeType" type="string" required="true" />
		
		<cfset var stReturn = {} />
		<cfset var serverName = CGI.SERVER_NAME />
		<cfset var serverPort = CGI.SERVER_PORT />
		<cfset var contextPath = GetDirectoryFromPath(cgi.SCRIPT_NAME) />
		<cfset var protocol = CGI.SERVER_PROTOCOL />
		
		<cfset stReturn.cancelUrlPath = "http://" & serverName & ":" & serverPort & '/rd/upgrade/' />
		<cfset stReturn.returnUrlPath = "http://" & serverName & ":" & serverPort & "/james/?event=user.account.upgrade.paypal.expresscheckout.details&amt=" & arguments.paymentAmount & "&currencycode=" & arguments.currencyCodeType & "&paymentaction=" & UrlEncodedFormat( arguments.paymentaction ) />
	
		<cfreturn stReturn />
	</cffunction>	
	
	<!---
		This method has following parameters
		Request Data - Hold the NVP request String
		ServerURL - End Point
		
		proxyName - need to pass proxy hostName 
		proxyPort - need to pass proxy port name
	--->

	<cffunction name="doHttppost" access="public" returntype="string">
		<cfargument name="requestData" type="struct" required="yes">
		
		<cfset var cfhttp = 0 />
		<cfset var key = '' />
		
		<cflock name="#createUUID()#" timeout="10">
			<CFHTTP URL="#getPayPalAccessData().serverURL#" METHOD="POST" result="cfhttp">
			  <cfloop collection=#requestData# item="key">
				  <CFHTTPPARAM NAME="#key#" VALUE="#requestData[key]#" TYPE="FormField" ENCODED="YES">
			  </cfloop>
			</CFHTTP>
		</cflock>
		
		<cfreturn cfhttp.FileContent />

	</cffunction>
	
	<cffunction access="public" name="getRedirectPaymentURL" returntype="string">
		<cfargument name="data" type="struct" required="true">
		
		<cfreturn getPayPalAccessData().PayPalURL & data.TOKEN />
	
	</cffunction>
	
	<!---
		This method will take response from the server and display accordingly in the browser 
	--->
	<cffunction name="getNVPResponse" access="public" returntype="struct">
		<cfargument name="nvpString" type="string" required="yes" >
		
		<cfset var responseStruct = StructNew() />
		<cfset var ii = 0 />
		<cfset var tempStruct = ListToArray( arguments.nvpString, '&' ) />
		
		<cfloop from="1" to="#ArrayLen( tempStruct )#" index="ii">
			<cfset responseStruct[ ListFirst( tempStruct[ ii ], '=')] = UrlDecode(ListLast( tempStruct[ ii ], '=')) />
		</cfloop>
		
		<cfreturn responseStruct / >
	</cffunction>

</cfcomponent>
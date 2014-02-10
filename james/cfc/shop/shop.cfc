<!--- 
	
	Shopping / Paypal component

 --->

<cfcomponent displayname="Shopping / Buying" output="false">

	<cfinclude template="/common/scripts.cfm">

	<cffunction access="public" name="Init" returntype="james.cfc.shop.shop" output="false">
		<cfreturn this />
	</cffunction>
	
	<cffunction access="public" name="getPlans" output="false" returntype="struct">
		
		<cfset var stReturn = {} />
		
		<!--- 1GB / 16 MB filesize --->
		<cfset stReturn[ 'basic' ] = { quota = (1 * 1024 * 1024 * 1024), maxfilesize = (12 * 1024 * 1024),
				accounttype = 0,
				prices_month = { 'EUR' = 0 },
				prices_year = { 'EUR'  = 0 },
				desktop_uploader = 0,
				displayads = 1 } />

		<!--- 10 GB / 50 MB --->
		<cfset stReturn[ 's' ] = { quota = (10 * 1024 * 1024 * 1024), maxfilesize = (50 * 1024 * 1024),
				accounttype = 10,
				prices_month = { 'EUR' = 2.9 },
				prices_year = { 'EUR'  = 29 },
				desktop_uploader = 1,
				displayads = 0 } />
				
		<!--- 40 GB / 50 MB --->
		<cfset stReturn[ 'm' ] = { quota = (40 * 1024 * 1024 * 1024), maxfilesize = (50 * 1024 * 1024),
				accounttype = 50,
				prices_month = { 'EUR' = 5.9 },
				prices_year = { 'EUR'  = 59 },
				desktop_uploader = 1,
				displayads = 0 } />
		
		<!--- 200 GB / 50 MB --->
		<cfset stReturn[ 'l' ] = { quota = (200 * 1024 * 1024 * 1024), maxfilesize = (50 * 1024 * 1024),
				accounttype = 100,
				prices_month = { 'EUR' = 14.9 },
				prices_year = { 'EUR'  = 149 },
				desktop_uploader = 1,
				displayads = 0 } />
				
		<!--- MASTER 200 GB / 50 MB --->
		<cfset stReturn[ 'master' ] = { quota = (200 * 1024 * 1024 * 1024), maxfilesize = (50 * 1024 * 1024),
				accounttype = 999,
				prices_month = { 'EUR' = 14.9 },
				prices_year = { 'EUR'  = 149 },
				desktop_uploader = 1,
				displayads = 0 } />				
		
		<cfreturn stReturn />
		
	</cffunction>
	
	<!--- <cffunction access="public" name="createInvoice" output="false" returntype="struct" hint="create a PDF invoice and return the filename">
		
		<cfset var a_str_filename = '' />
		
		<cfdocument filename="/tmp/invoice.pdf" format="pdf" overwrite="true" orientation="portrait" pagetype="A4">

		<h1>Rechnung ## 198</h1>
		
		</cfdocument>
	
	</cffunction> --->
	
	<cffunction access="public" name="AdaptUserAccountToOrderedServices" output="false" returntype="void"
			hint="update user account preferences according to bought services (or disable them)">
		<cfargument name="securitycontext" type="struct" required="true" />
		
		<!--- find out current plan --->
		<cfset var stPlans = getPlans() />
		<cfset var local = {} />
		<cfset var sPlan = 'basic' />
		
		<!--- find which plan is active ... take the newest! --->
		<cfquery name="local.qSelectPlan" datasource="mytunesbutleruserdata">
		SELECT
			productid
		FROM
			paypalorderinformation
		WHERE
			userkey = <cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.securitycontext.entrykey#">
			AND
			productgroup = 'PLANS'
			AND
			status = 1
		ORDER BY
			dt_created DESC
		LIMIT
			1
		;
		</cfquery>
		
		<!--- default ... --->
		<cfif local.qSelectPlan.recordcount IS 0>
			<cfset sPlan = 'basic' />
		<cfelse>
			<cfset sPlan = local.qSelectPlan.productid />
		</cfif>
		
		<cfif NOT StructKeyExists( stPlans, sPlan)>
			<cfthrow message="Plan #sPlan# not found for user #arguments.userkey#">
		</cfif>
		
		<!--- update account type --->
		<cfset application.beanFactory.getBean( 'UserComponent' ).UpdateUserData( securitycontext = arguments.securitycontext, newvalues = { accounttype = stPlans[sPlan].accounttype } ) />
		
		<!--- update quota --->
		<cfset application.beanFactory.getBean( 'StorageComponent' ).SetMaxSizeQUotaOfUser( userkey = arguments.securitycontext.entrykey,
											iQuota = stPlans[sPlan].quota) />
	
	</cffunction>
	
	<cffunction access="public" name="sendEmailConfirmationUpgrade" output="false" returntype="void"
			hint="confirm upgrade by email">
		<cfargument name="securitycontext" type="struct" required="true" />
		<cfargument name="oPaymentContext" type="any" required="true" />
		
		<cfset var oMsg = application.beanFactory.getBean( 'MessagesComponent' ) />
		<cfset var oTransfer = application.beanFactory.getBean( 'UsersTransfer' ).getTransfer() />
		<cfset var oUser = oTransfer.readByProperty( 'users.user', 'entrykey', arguments.securitycontext.entrykey ) />
		<cfset var stUserdata = {} />
		<cfset var sHTMLMail = ''/>
		<cfset var sTextMail = '' />
		<cfset var oMsg = application.beanFactory.getBean( 'MessagesComponent' ) />
			
		<cfset stUserdata = { entrykey = oUser.getEntrykey(), firstname = oUser.getFirstname(), email = oUser.getEmail(), username = oUser.getUsername() } />
		
<cfsavecontent variable="sTExtMail">
#oUser.getFirstname()# -

Thank you for upgrading!

This is a summary of your order

Product ID: #oPaymentContext.getProductID()#
Price per period: #oPaymentContext.getcurrencycode()# #DecimalFormat( oPaymentContext.getamount() )#
Period: #oPaymentContext.getPeriod()#
Start date: #LsDateFormat( oPaymentContext.getrecurringdatestart(), 'dd.mm.yyyy' )#

You can use this product as long as the recurring payment agreement is active.

Best regards, Your tunesBag.com Team
</cfsavecontent>
<cfsavecontent variable="sHTMLMail">
<cfoutput>
<p>#oUser.getFirstname()# -</p>
<p>Thank you for upgrading!</p>
<p>This is a summary of your order</p>
<p>
	<b>Product ID</b>: #oPaymentContext.getProductID()# <b>Price per period</b>: #oPaymentContext.getcurrencycode()# #DecimalFormat( oPaymentContext.getamount() )# (<b>Period</b>: #oPaymentContext.getPeriod()#,
	Start #LsDateFormat( oPaymentContext.getrecurringdatestart(), 'dd.mm.yyyy' )#)
</p>
<p>
	You can use this product as long as the recurring payment agreement is active.
</p>
<p>
	Best regards, Your tunesBag.com Team
</p>
</cfoutput>

</cfsavecontent>		
	
		<cfset oMsg.sendGenericEmail( bIsRegisteredUser = true, sSubject = application.udf.GetLangValSec( 'shop_ph_account_updated' ),
					sSender = 'tunesBag.com Office <office@tunesBag.com>',
					sTo = stUserdata.firstname & ' <' & stUserdata.email & '>',
					sHTMLContent = sHTMLMail,
					sTextContent = sTextMail,
					stUserData = stUserData ) />


	</cffunction>
	
	
	<cffunction access="public" name="updatePaymentWithNVPData" output="false" returntype="void" hint="">
		<cfargument name="httpresponse" type="string" required="true">
		<cfargument name="paymentkey" type="string" required="true">
		
		<cfset var oTransfer = application.beanFactory.getBean( 'UsersTransfer' ).getTransfer() />
		<cfset var a_item = oTransfer.get( 'shop.paymentrequests', arguments.paymentkey ) />
		<cfset a_item.sethttpresponse( arguments.httpresponse ) />
		<cfset oTransfer.save( a_item ) />		
	
	</cffunction>
	
	<cffunction access="public" name="SavePayPalRecurringProfile" output="false" returntype="struct" hint="save recurring profile">
		<cfargument name="paymentkey" type="string" required="true">
		<cfargument name="securitycontext" type="struct" required="true">
		<cfargument name="productgroup" type="string" required="false" default="PLANS"
			hint="product grops">
		<cfargument name="productid" type="string" required="true"
			hint="which product">
		<cfargument name="period" type="string" required="true"
			hint="if possible ... M or Y (month or year)">
		<cfargument name="amt" type="numeric" required="true">
		<cfargument name="currencycode" type="string" required="true">
		<cfargument name="profileid" type="string" required="true">
		<cfargument name="profilestatus" type="string" required="true">

		<cfset var stReturn = application.udf.GenerateReturnStruct() />
		<cfset var oTransfer = application.beanFactory.getBean( 'UsersTransfer' ).getTransfer() />
		<cfset var a_item = oTransfer.new( 'shop.paypalorderinformation' ) />
		<cfset var a_entrykey = createUUID() />
		<cfset var local = {}/>
		
		<cfset a_item.setEntrykey( a_entrykey ) />
		<cfset a_item.setuserkey( arguments.securitycontext.entrykey ) />
		<cfset a_item.setpaymentkey( arguments.paymentkey ) />
		<cfset a_item.setcurrencycode( arguments.currencycode ) />
		<cfset a_item.setdt_created( Now() ) />
		<cfset a_item.setperiod( arguments.period ) />
		<cfset a_item.setproductgroup( arguments.productgroup ) />
		<cfset a_item.setproductid( arguments.productid ) />
		<cfset a_item.setstatus( 1 ) />
		<cfset a_item.setamt( arguments.amt ) />
		<cfset a_item.setprofileid( arguments.profileid ) />
		<cfset a_item.setprofilestatus( arguments.profilestatus ) />
		<cfset a_item.setdt_lastcheckprofile( Now() ) />
		
		<cfset oTransfer.create( a_item ) />
		
		<cfset stReturn.entrykey = a_entrykey />
		
		<cfquery name="local.qUpdateStatus" datasource="mytunesbutleruserdata">
		UPDATE
			paymentrequests
		SET
			status = 1
		WHERE
			entrykey = <cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.paymentkey#">
		;
		</cfquery>
		
		<cfreturn application.udf.SetReturnStructSuccessCode(stReturn) />

	</cffunction>
	
	<cffunction access="public" name="getPaymentContext" returntype="any" hint="return the payment content">
		<cfargument name="sPaymentKey" type="string" required="true" />
		
		<cfset var oTransfer = application.beanFactory.getBean( 'UsersTransfer' ).getTransfer() />
		
		<cfreturn oTransfer.get( 'shop.paymentrequests', arguments.sPaymentKey ) />
		
	</cffunction>
	
	<cffunction access="public" name="logShoppingRequests" output="false" returntype="void"
			hint="logging">
		<cfargument name="sPaymentkey" type="string" required="true" />
		<cfargument name="sOperation" type="string" required="true" />
		<cfargument name="sLog" type="string" required="true" />
		
		<cfset var oTransfer = application.beanFactory.getBean( 'LogTransfer' ).getTransfer() />
		<cfset var oItem = oTransfer.new( 'logging.shoplog' ) />
		
		<cfset oItem.setdt_Created( now() ) />
		<cfset oItem.setpaymentkey( arguments.sPaymentkey ) />
		<cfset oItem.setoperation( arguments.sOperation ) />
		<cfset oItem.setlogdata( arguments.sLog ) />
		
		<cfset oTransfer.create( oItem ) />
		
	</cffunction>

	<cffunction access="public" name="createPaymentContext" output="false" returntype="struct" hint="create and save this payment request">
		<cfargument name="securitycontext" type="struct" required="true">
		<cfargument name="productgroup" type="string" required="false" default="PLANS"
			hint="product grops">
		<cfargument name="productid" type="string" required="true"
			hint="which product">
		<cfargument name="period" type="string" required="true"
			hint="if possible ... M or Y (month or year)">
		<cfargument name="ip" type="string" required="true">
		<cfargument name="recurring" type="numeric" required="false" default="1" />
		<cfargument name="recurringdatestart" type="date" required="false" default="#Now()#"
			hint="when to start if recurring is true">
		<cfargument name="currency" type="string" required="true" default="EUR" />
		<cfargument name="initialamount" type="numeric" default="0" required="false"
			hint="an initial payment, in case it's 0 and recurring is true, the default amount is used" />
		
		<cfset var stReturn = application.udf.GenerateReturnStruct() />
		<cfset var paymentkey = createUUID() />
		<cfset var oTransfer = application.beanFactory.getBean( 'UsersTransfer' ).getTransfer() />
		<cfset var a_item = oTransfer.new( 'shop.paymentrequests' ) />
		<cfset var a_str_currency = arguments.currency />		
		<!--- get amount --->
		<cfset var a_int_amount = getPaymentAmount( productid = arguments.productid,
													period = arguments.period,
													currency = a_str_currency ) />
		
		<!--- if no initial payment has been given ... set the initial payment to the regular price --->
		<cfif arguments.initialamount IS 0>
			<cfset arguments.initialamount = a_int_amount />
		</cfif>
		
		<!--- save --->
		<cfset a_item.setuserkey( arguments.securitycontext.entrykey ) />
		<cfset a_item.setdt_created( Now() ) />
		<cfset a_item.setstatus = 0 />
		<cfset a_item.setentrykey( paymentkey ) />
		<cfset a_item.setip( arguments.ip ) />
		<cfset a_item.setproductgroup( arguments.productgroup ) />
		<cfset a_item.setproductid( arguments.productid ) />
		<cfset a_item.setperiod( arguments.period ) />
		<cfset a_item.setrecurring( arguments.recurring ) />
		<cfset a_item.setrecurringdatestart( arguments.recurringdatestart ) />
		<cfset a_item.setamount( a_int_amount ) />
		<cfset a_item.setinitialamount( arguments.initialamount ) />
		<cfset a_item.setcurrencycode( a_str_currency ) />
		<cfset a_item.sethttpresponse( '' ) />
		
		<cfset oTransfer.create( a_item ) />
		
		<!--- return variables --->
		<cfset stReturn.paymentkey = paymentkey />
		<cfset stReturn.amount = a_int_amount />
		<cfset stReturn.currency = a_str_currency />
		<cfset stReturn.recurringdatestart = arguments.recurringdatestart />
		<cfset stReturn.initialamount = arguments.initialamount />
		
		<cfreturn application.udf.SetReturnStructSuccessCode(stReturn) />
	
	</cffunction>
	
	<cffunction access="public" name="getPaymentAmount" output="false" returntype="numeric">
		<cfargument name="productid" type="string" required="true">
		<cfargument name="period" type="string" required="true">
		<cfargument name="currency" type="string" required="true" hint="always in EUR">
		
		<cfset var iAmount = 0 />
		<cfset var stPlans = getPlans() />
		
		<cfif arguments.period IS 'month'>
			
			<cfreturn stPlans[ arguments.productid ].prices_month.EUR />
			
		<cfelse>
			
			<cfreturn stPlans[ arguments.productid ].prices_year.EUR />	
		
		</cfif>
		
	</cffunction>

</cfcomponent>
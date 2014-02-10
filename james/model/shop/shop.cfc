<!--- 

	shopping / affiliate
	
 --->


<cfcomponent name="shopping" displayname="shopping component"output="false" extends="MachII.framework.Listener" hint="shopping cmp for tunesBag application">

<cfinclude template="/common/scripts.cfm">

<cffunction name="configure" access="public" output="false" returntype="void" hint="Configures this listener as part of the Mach-II  framework"> 
	<!--- do nothing --->
</cffunction> 

<cffunction access="public" name="HandleUpgradePlanSelect" output="false" returntype="void" hint="user has selected a package">
	<cfargument name="event" type="MachII.framework.Event" required="true" />
	
	<!--- 
	
		S / M / L
		
		small / medium / large
	
	 --->
	<cfset var a_str_plan = event.getArg( 'plan', 'l') />
	
	<!--- 
	
		MONTH / YEAR
	
		monthly or yearly
	
	 --->
	<cfset var a_str_period = event.getArg( 'period', 'year' ) />
	
	<cfset var a_str_currency = event.getArg( 'currency', 'EUR' ) />
	
	<!--- a special? --->
	<cfset var sSpecial = event.getArg( 'special', '' ) />
	
	<cfset var a_http_response = '' />
	<cfset var stNVP = {} />
	<cfset var a_paypal_redirect_urls = 0 />
	<cfset var a_paypal_req = 0 />
	<cfset var local = {} />
	
	<cfset var oPaypal = getProperty( 'beanFactory' ).getBean( 'ShopPayPalComponent' ) />
	
	<!--- <cfset sSpecial = 'betauserupgrade' /> --->
	
	<cfswitch expression="#sSpecial#">
		<cfcase value="betauserupgrade">
			
			<!---
				preferred upgrade ... user of the beta version
				
				1 EUR for the first yeah, whichever product
				
				recurring will start one year later
				--->

			<cfset var stPaymentContext = getProperty( 'beanFactory' ).getBean( 'ShopComponent' ).createPaymentContext( securitycontext = application.udf.GetCurrentSecurityContext(),
								productid = a_str_plan,
								currency = a_str_currency,
								period = a_str_period,
								initialamount = 1,
								recurringdatestart = DateAdd('yyyy',1, Now()),
								ip = cgi.REMOTE_ADDR ) />
			
			
		
		</cfcase>
		<cfcase value="freeuser">
			
			<cfset var stPaymentContext = getProperty( 'beanFactory' ).getBean( 'ShopComponent' ).createPaymentContext( securitycontext = application.udf.GetCurrentSecurityContext(),
								productid = a_str_plan,
								currency = a_str_currency,
								period = a_str_period,
								initialamount = 1,
								recurringdatestart = DateAdd('d', 60, Now()),
								ip = cgi.REMOTE_ADDR ) />
			
		
		</cfcase>
		<cfdefaultcase>
			
			<!--- get price etc
			
				no inital payment but starting today
			 --->
			<cfset var stPaymentContext = getProperty( 'beanFactory' ).getBean( 'ShopComponent' ).createPaymentContext( securitycontext = application.udf.GetCurrentSecurityContext(),
								productid = a_str_plan,
								currency = a_str_currency,
								period = a_str_period,
								ip = cgi.REMOTE_ADDR ) />
		</cfdefaultcase>
	</cfswitch>
	

	
	
	<cfset event.setArg( 'PaymentContext', stPaymentContext ) />
	
	<cfif NOT stPaymentContext.result>
		<cfreturn />
	</cfif>
	
	<!--- get redirect URLs --->
	<cfset a_paypal_redirect_urls = oPaypal.getLocalURLRedirectsForRequest( paymentaction = 'sale',
										paymentAmount = stPaymentContext.amount,
										currencyCodeType = stPaymentContext.currency ) />
	
	<!--- prepare the request --->
	<cfset a_paypal_req = oPaypal.PreparePayPalRequest( sCountrycode = application.udf.GetCurrentSecurityContext().countryisocode,
												method = 'SetExpressCheckout',
												currencycode = stPaymentContext.currency,
												amt = stPaymentContext.initialamount,
												description = application.udf.GetLangValSec( 'shop_ph_paypal_subject' ),
												custom = stPaymentContext.paymentkey,
												bRecurring = true,
												period = a_str_period,
												redirect_cancel = a_paypal_redirect_urls.cancelURLPath,
												redirect_return = a_paypal_redirect_urls.returnURLPath ) />

	
	
	<!--- perform http request --->	
	<cfset a_http_response = oPaypal.doHttppost( requestData = a_paypal_req) />
	
	<!--- parse result --->
	<cfset stNVP = oPaypal.getNVPResponse( a_http_response ) />
	
	<cfset getProperty( 'beanFactory' ).getBean( 'ShopComponent' ).updatePaymentWithNVPData( paymentkey = stPaymentContext.paymentkey, httpresponse = a_http_response ) />
	
	<!--- store result --->	
	<cfset event.setArg( 'a_paypal_req', a_paypal_req ) />
	<cfset event.setArg( 'getNVPResponse', stNVP ) />
	
	<cfif StructKeyExists( stNVP, 'ack' ) AND stNVP.ack IS 'SUCCESS'>
		<cfset a_str_paypal_url = oPaypal.getRedirectPaymentURL( stNVP ) />
		
		<cfset event.setArg( 'PayPalRedirect', a_str_paypal_url ) />
		
	</cfif>
	
	
	<cfset event.setArg( 'ok', true ) />

</cffunction>


<cffunction access="public" name="PayPalGetExpressCheckoutDetails" output="false" returntype="void" hint="get details of the express checkout process">
	<cfargument name="event" type="MachII.framework.Event" required="true" />
	
	<cfset var stCall = getProperty( 'beanFactory' ).getBean( 'ShopPayPalComponent' ).PayPalGetExpressCheckoutDetails( token = event.getArg( 'token' )) />
	
	<cfset event.setArg( 'ExpressCheckoutDetails', stCall ) />

</cffunction>


<cffunction access="public" name="PayPalExpressCheckoutPerformPayment" output="false" returntype="void" hint="perform the payment (ONE TIME)">
	<cfargument name="event" type="MachII.framework.Event" required="true" />
	
	<cfset var a_call = getProperty( 'beanFactory' ).getBean( 'ShopPayPalComponent' ).PayPalExpressCheckoutPerformPayment( data = event.getArgs() ) />
	
	<cfset event.setArg( 'PerformPaymentDetails', a_call ) />

</cffunction>

<cffunction access="public" name="PayPalCreateRecurringPaymentsProfile" output="false" returntype="void" hint="create recurring payment profile (RECURRING)">
	<cfargument name="event" type="MachII.framework.Event" required="true" />
	
	<!--- get payment content ... --->
	<cfset var sPaymentkey = event.getArg( 'paymentkey' ) />
	<cfset var stPaypalData = event.getArgs() />
	<cfset var local = {} />
	
	<!--- decrypt the amount to pay --->
	<cfset stPaypalData.amount = Decrypt( ToBinary( event.getArg( 'amount')), '+sdgks8df3?&$sibdu') />
	
	<!---  get the payment context --->
	<cfset var oPaymentContext = getProperty( 'beanFactory' ).getBean( 'ShopComponent' ).getPaymentContext( sPaymentkey ) />

	<!--- create the recurring payment ... --->
	
	<cfset local.stPayPalData = event.getArgs() />
	
	<!--- recurring? do not take the inital amount, have a look at the amount ---> 
	<cfif oPaymentContext.getRecurring() IS 1>
		<cfset local.stPayPalData.amount = oPaymentContext.getAmount() />
	</cfif>
	
	<!--- set the initial amount --->
	<cfset local.stPayPalData.initialamount = oPaymentContext.getInitialAmount() />
	
	<!--- if the recurring schema starts today, do not charge a one-time fee --->
	
	
	<cfset var a_call = getProperty( 'beanFactory' ).getBean( 'ShopPayPalComponent' ).CreateRecurringPaymentsProfile( data = local.stPayPalData,
				period =  oPaymentContext.getPeriod(),
				startdate = oPaymentContext.getrecurringdatestart() ) />
	
	<!--- log the answer --->
	<cfset getProperty( 'beanFactory' ).getBean( 'ShopComponent' ).logShoppingRequests( sPaymentkey = sPaymentkey,
				sOperation = 'CreaRecuPayPro',
				sLog = SerializeJSON( a_call )) />

	<cfset event.setArg( 'RecurringPaymentDetails', a_call ) />
		
	<!--- announce an error event and exit! --->
	<cfif NOT a_call.result>
		<cfset announceEvent( 'user.account.upgrade.paypal.expresscheckout.failure', event.getArgs() ) />
		<cfreturn />
	</cfif>
	
	<!--- store payment profile --->
	<cfset getProperty( 'beanFactory' ).getBean( 'ShopComponent' ).SavePayPalRecurringProfile( securitycontext = application.udf.GetCurrentSecurityContext(),
							paymentkey = sPaymentkey,
							productgroup = oPaymentContext.getProductGroup(),
							productid = oPaymentContext.getProductID(),
							period = oPaymentContext.getPeriod(),
							amt = oPaymentContext.getAmount(),
							currencycode = oPaymentContext.getCurrencyCode(),
							profileid = a_call.response.profileid,
							profilestatus = a_call.response.profilestatus ) />
							
	<!--- adopt user features --->
	<cfset getProperty( 'beanFactory' ).getBean( 'ShopComponent' ).AdaptUserAccountToOrderedServices( securitycontext = application.udf.GetCurrentSecurityContext() ) />	
	
	<!--- reload security context --->
	<cfset session.a_struct_usercontext = getProperty( 'beanFactory' ).getBean( 'SecurityComponent' ).GetUserContextByUserkey( application.udf.GetCurrentSecurityContext().entrykey ) />
	
	<!--- email! --->
	<cfset getProperty( 'beanFactory' ).getBean( 'ShopComponent' ).sendEmailConfirmationUpgrade( securitycontext = application.udf.GetCurrentSecurityContext(), oPaymentContext = oPaymentContext ) />
	
	<cflocation addtoken="false" url="?event=user.account.upgrade.paypal.expresscheckout.success&sPaymentkey=#urlEncodedFormat( sPaymentkey )#" />
	
</cffunction>

<cffunction access="public" name="GetPaymentRecurringProfileDetails" output="false" returntype="void" hint="get payment details and recurring profile data">
	<cfargument name="event" type="MachII.framework.Event" required="true" /> 
	
	<cfset var sPaymentKey = event.getArg( 'sPaymentkey' ) />
	
	<cfset var oPaymentContext = getProperty( 'beanFactory' ).getBean( 'ShopComponent' ).getPaymentContext( sPaymentkey ) />
	
	<cfset event.setArg( 'oPaymentContext', oPaymentContext ) />

</cffunction>

<cffunction access="public" name="HandleAffiliateHit" output="false" returntype="void" hint="Handle an affiliate hit">
	<cfargument name="event" type="MachII.framework.Event" required="true" /> 
	
	<cfset var app = event.getArg( 'app' ) />
	<cfset var artist = Trim( event.getArg( 'artist' )) />
	<cfset var album = trim( event.getArg( 'album' )) />
	<cfset var title = trim( event.getArg( 'title' )) />
	<cfset var device = event.getArg( 'device' ) />
	<cfset var userkey = Event.getArg( 'userkey' ) />
	<cfset var referer = trim(event.getARg( 'ref' )) />
	<cfset var a_entrykey = CreateUUID() />
	<cfset var a_ip = event.getArg( 'ip' ) />
	<cfset var a_transfer = getProperty( 'beanFactory' ).getBean( 'LogTransfer' ).getTransfer() />
	<cfset var a_vendor = 0 />
	<cfset var q_select_vendor = QueryNew( 'name,link,image,description' ) />
	<cfset var a_country = getProperty( 'beanFactory' ).getBean( 'LicenceComponent' ).IPLookupCountry( a_ip ) />
	<cfset var a_str_itunes_url = 'http://phobos.apple.com/WebObjects/MZSearch.woa/wa/advancedSearchResults?artistTerm=' & urlEncodedFormat( artist ) & '&songTerm=' & urlEncodedFormat( title ) & '&partnerid=2003' />
	<!--- albumTerm=' & urlEncodedFormat( album ) & '& --->
	<cfset var a_item = 0 />
	<cfset var a_str_url = 0 />
	
	<!--- decide which affiliate to user or let the user choose ... --->
	
	
	<!--- <cfset a_country = 'us' /> --->
	<!--- device ... iPhone? --->
	<cfif app IS application.const.S_APPKEY_IPHONE>
	
		<!--- iphone app --->
		<cfset a_str_url = 'http://clk.tradedoubler.com/click?p=23708&a=1565356&url=' & urlencodedFormat( a_str_itunes_url ) />
				
		<cfset QueryAddRow( q_select_vendor, 1 ) />
		<cfset QuerySetCell( q_select_vendor, 'name', 'Apple iTunes Music Store', 1 ) />
		<cfset QuerySetCell( q_select_vendor, 'link', a_str_url, 1 ) />
		<cfset QuerySetCell( q_select_vendor, 'image', '', 1 ) />
		<cfset QuerySetCell( q_select_vendor, 'description', '', 1 ) />	
		
		<cfset event.setArg( 'q_select_vendor', q_select_vendor ) />
		
		<!--- that's it! --->
		<cfreturn />	
		
	</cfif>
	
	<!--- switch amazon URLs (different countries) --->
	<cfswitch expression="#a_country#">
		<cfcase value="uk">
			<!--- amazon UK --->
			<cfset QueryAddRow( q_select_vendor, 1 ) />
			<cfset QuerySetCell( q_select_vendor, 'name', 'Amazon', 1 ) />
			<cfset QuerySetCell( q_select_vendor, 'link', 'http://www.amazon.co.uk/gp/search?ie=UTF8&keywords=' & UrlEncodedFormat( artist & ' ' & title ) & '&tag=tunesbagcom08-21&index=digital-music&linkCode=ur2&camp=1789&creative=9325', 1 ) />
			<cfset QuerySetCell( q_select_vendor, 'image', '', 1 ) />
			<cfset QuerySetCell( q_select_vendor, 'description', 'US only', 1 ) />
		</cfcase>
		<cfcase value="de,at,ch">
			
			<cfset QueryAddRow( q_select_vendor, 1 ) />
			<cfset QuerySetCell( q_select_vendor, 'name', 'Amazon', 1 ) />
			<cfset QuerySetCell( q_select_vendor, 'link', 'http://www.amazon.de/gp/search?ie=UTF8&keywords=' & UrlEncodedFormat( artist & ' ' & title ) & '&tag=tunesbagcom-21&index=digital-music&linkCode=ur2&camp=1789&creative=9325', 1 ) />
			<cfset QuerySetCell( q_select_vendor, 'image', '', 1 ) />
			<cfset QuerySetCell( q_select_vendor, 'description', 'GSA only', 1 ) />
			
		</cfcase>
		<cfcase value="fr">

			<cfset QueryAddRow( q_select_vendor, 1 ) />
			<cfset QuerySetCell( q_select_vendor, 'name', 'Amazon', 1 ) />
			<cfset QuerySetCell( q_select_vendor, 'link', 'http://www.amazon.fr/gp/search?ie=UTF8&keywords=' & UrlEncodedFormat( artist & ' ' & title ) & '&tag=tunesbagco068-21&index=digital-music&linkCode=ur2&camp=1789&creative=9325', 1 ) />
			<cfset QuerySetCell( q_select_vendor, 'image', '', 1 ) />
			<cfset QuerySetCell( q_select_vendor, 'description', 'JP only', 1 ) />
		
		</cfcase>
		<cfcase value="jp">
			
			<cfset QueryAddRow( q_select_vendor, 1 ) />
			<cfset QuerySetCell( q_select_vendor, 'name', 'Amazon', 1 ) />
			<cfset QuerySetCell( q_select_vendor, 'link', 'http://www.amazon.jp/gp/search?ie=UTF8&keywords=' & UrlEncodedFormat( artist & ' ' & title ) & '&tag=tunesbag01-22&index=digital-music&linkCode=ur2&camp=1789&creative=9325', 1 ) />
			<cfset QuerySetCell( q_select_vendor, 'image', '', 1 ) />
			<cfset QuerySetCell( q_select_vendor, 'description', 'JP only', 1 ) />
		</cfcase>
		<cfdefaultcase>
			<!--- amazon US --->
			<cfset QueryAddRow( q_select_vendor, 1 ) />
			<cfset QuerySetCell( q_select_vendor, 'name', 'Amazon', 1 ) />
			<cfset QuerySetCell( q_select_vendor, 'link', 'http://www.amazon.com/gp/search?ie=UTF8&keywords=' & UrlEncodedFormat( artist & ' ' & title ) & '&tag=tunesbagcom-20&index=digital-music&linkCode=ur2&camp=1789&creative=9325', 1 ) />
			<cfset QuerySetCell( q_select_vendor, 'image', '', 1 ) />
			<cfset QuerySetCell( q_select_vendor, 'description', 'Worldwide', 1 ) />
							
		</cfdefaultcase>
	</cfswitch>

	<!--- always add the other vendors --->
	
	<!--- 7digital --->
	
	<cfset a_str_url = 'http://scripts.affiliatefuture.com/AFClick.asp?affiliateID=201273&merchantID=2473&programmeID=6574&mediaID=0&tracking=#a_country#&url=' & UrlEncodedFormat( 'http://www.7digital.com/Search?search=' & UrlEncodedFormat( artist & ' ' & title )) />
	
	<cfset QueryAddRow( q_select_vendor, 1 ) />
	<cfset QuerySetCell( q_select_vendor, 'name', '7digital', 2 ) />					
	<cfset QuerySetCell( q_select_vendor, 'link', a_str_url, 2 ) />
	<cfset QuerySetCell( q_select_vendor, 'image', '', 2 ) />
	<cfset QuerySetCell( q_select_vendor, 'description', '', 2 ) />
	

	<!--- unknown country ... add itunes --->
	<cfswitch expression="#a_country#">
		<cfcase value="uk">
			<cfset a_str_url = 'http://clk.tradedoubler.com/click?p=23708&a=1565356&url=' & urlencodedFormat( a_str_itunes_url ) />		
		</cfcase>
		<cfcase value="us">
			<!--- todo: insert linkshare code --->
		</cfcase>
		<cfdefaultcase>
			<cfset a_str_url = 'http://clk.tradedoubler.com/click?p=23708&a=1565356&url=' & urlencodedFormat( a_str_itunes_url ) />		
		</cfdefaultcase>
	</cfswitch>


	<cfset QueryAddRow( q_select_vendor, 1 ) />
	<cfset QuerySetCell( q_select_vendor, 'name', 'iTunes', 3 ) />
	<cfset QuerySetCell( q_select_vendor, 'link', a_str_url, 3 ) />
	<cfset QuerySetCell( q_select_vendor, 'image', '', 3 ) />
	<cfset QuerySetCell( q_select_vendor, 'description', '', 3 ) />
	
	<!--- amie street --->
	
	<cfset a_str_url = 'http://amiestreet.com/search?noredir=1&query=' & UrlEncodedFormat( artist & ' ' & title ) & '&pytr=tunesbag' />
	<cfset QueryAddRow( q_select_vendor, 1 ) />
	<cfset QuerySetCell( q_select_vendor, 'name', 'amiestreet', 4 ) />
	<cfset QuerySetCell( q_select_vendor, 'link', a_str_url, 4 ) />
	<cfset QuerySetCell( q_select_vendor, 'image', '', 4 ) />
	<cfset QuerySetCell( q_select_vendor, 'description', '', 4 ) />
	
	
	<!--- log request --->
	<!--- <cfset a_item = a_transfer.new( 'affiliate.affiliaterequests' ) />
	<cfset a_item.setEntrykey( a_entrykey ) />
	<cfset a_item.setdt_created( Now() ) />
	<cfset a_item.setip( a_ip ) />
	<cfset a_item.setapplicationkey( app ) />
	<cfset a_item.setdevice( Left( device, 100) ) />
	<cfset a_item.setuserkey( userkey ) />
	<cfset a_item.setartist( Left( artist, 100 ) ) />
	<cfset a_item.setalbum( Left( album, 100) ) />
	<cfset a_item.settitle( Left( title, 100) ) />
	<cfset a_item.setreferer( referer ) />
	<cfset a_item.setvendor( a_vendor ) />
	
	<cfset a_transfer.create( a_item ) /> --->
	
	<cfset event.setArg( 'q_select_vendor', q_select_vendor ) />

</cffunction>

<cffunction access="public" name="GetPlans" output="false" returntype="void"
		hint="return supported plans">
	<cfargument name="event" type="MachII.framework.Event" required="true" />
	
	<cfset event.setArg( 'stPlans', getProperty( 'beanFactory' ).getBean( 'ShopComponent' ).getPlans() ) />

</cffunction>

</cfcomponent>
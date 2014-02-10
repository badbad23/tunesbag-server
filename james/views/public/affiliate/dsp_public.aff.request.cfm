<!--- handle affiliate requests --->

<cfset q_select_vendor = event.getArg( 'q_select_vendor' ) />

<cfparam name="url.provider" type="string" default="" />

<cfif q_select_vendor.recordcount IS 1>
	<cflocation addtoken="false" url="#q_select_vendor.link#" />
</cfif>

<cfsavecontent variable="request.content.final">
	

<cfif q_select_vendor.recordcount IS 0>
	
	<!--- no link? --->
	Sorry, we've not been able to find an appropriate music store for your location.

<cfelse>

	<cfif Len( url.provider ) GT 0>
		
		<cfquery name="qSelectLink" dbtype="query">
		SELECT
			*
		FROM
			q_select_vendor
		WHERE
			name = <cfqueryparam cfsqltype="cf_sql_varchar" value="#url.provider#">
		;
		</cfquery>
		
		<!--- hit! --->
		<cfif qSelectLink.recordcount IS 1>
			<cflocation addtoken="false" url="#qSelectLink.link#" />
		</cfif>
		
	</cfif>

	<!--- more than one link? --->
	
	<html>
		<head>
			<link rel="stylesheet" href="/res/css/default.css" media="all"></link>
			<title>Buy a track</title>
		</head>
	<body style="font-size:14px;background-color:#EEEEEE;padding-top:60px">
		
		<div style="padding:20px;width:480px;margin-left:auto;margin-right:auto;font-size:14px;background-color:white" class="b_all">
			
		<span style="font-weight:bold">Please select your favourite music store</span>
		
		<br /><br />
		
		<cfoutput query="q_select_vendor">
			<a href="#q_select_vendor.link#" style="font-size:14px">#htmleditformat( q_select_vendor.name )#</a>
			<br /><br />
		</cfoutput>
		
		</div>
	
	</body>
	</html>
	
	

</cfif>

</cfsavecontent>
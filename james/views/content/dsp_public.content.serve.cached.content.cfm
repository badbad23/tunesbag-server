<!--- hint for myself ... --->
<cfheader name="X-tb-Cached" value="true" />

<cfset oItem = Event.getArg( 'stCachedVersionExists' ).oItem />

<cfsavecontent variable="request.content.final">

<cfoutput>#oItem.content#</cfoutput>

</cfsavecontent>

<cfsavecontent variable="sHTMLHeader">
<!-- cached: true -->

<cfoutput>#Trim( oItem.HTMLHeader )#</cfoutput>
</cfsavecontent>

<cfhtmlhead text="#Trim( sHTMLHeader )#">

<cfset event.setArg( 'PageDescription',oItem.description) />
<cfset event.setArg( 'PageTitle',oItem.title ) />
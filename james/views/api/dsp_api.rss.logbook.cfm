

	RSS API logbook

--->


<!--- Get the feed data as a query from the orders table. --->
<cfset getOrders = QueryNew( 'ORDERDATE,content,title,href')>

<cfset QueryAddRow(getOrders, 10) />

<cfoutput query="getOrders">
	<cfset QuerySetCell( getOrders, 'title', CreateUUID(), getOrders.currentrow) />
	<cfset QuerySetCell( getOrders, 'href', 'http://www.tunesBag.com/rd/rss/?', getOrders.currentrow) />
	<cfset QuerySetCell( getOrders, 'content', 'hsdf', getOrders.currentrow) />	
</cfoutput>

<!--- Map the orders column names to the feed query column names. --->
<cfset columnMapStruct = StructNew()>
<cfset columnMapStruct.publisheddate = "ORDERDATE"> 
<cfset columnMapStruct.content = "content"> 
<cfset columnMapStruct.title = "title"> 
<cfset columnMapStruct.rsslink = "href">

<!--- Set the feed metadata. --->
<cfset meta.title = "Art Orders">
<cfset meta.link = "http://feedlink">
<cfset meta.description = "Orders at the art gallery"> 
<cfset meta.version = "rss_2.0">

<!--- Create the feed. --->
<cffeed action="create" 
    query="#getOrders#" 
    properties="#meta#"
    columnMap="#columnMapStruct#" 
    xmlvar="rssXML">

<cfcontent type="text/xml" reset="true">
<cfoutput>#rssXML#</cfoutput>
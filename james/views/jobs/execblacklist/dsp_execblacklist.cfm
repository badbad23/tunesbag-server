<!--- 

	remove blacklist items

 --->


<!--- Spermicide --->
<cfset sBlackListArtistIDs = '265911' />


<cfloop list="#sBlackListArtistIDs#" index="iArtistID">

	<cfquery name="qRemoveArtistTracks" datasource="mytunesbutler_mb">
	DELETE FROM	track
	WHERE		artist = <cfqueryparam cfsqltype="cf_sql_integer" value="#iArtistID#" />
	</cfquery>
	
	<cfquery name="qRemoveAlbums" datasource="mytunesbutler_mb">
	DELETE FROM	album
	WHERE		artist = <cfqueryparam cfsqltype="cf_sql_integer" value="#iArtistID#" />
	</cfquery>
	
	<cfquery name="qRemoveArtist" datasource="mytunesbutler_mb">
	DELETE FROM	artist
	WHERE		id = <cfqueryparam cfsqltype="cf_sql_integer" value="#iArtistID#" />
	</cfquery>


</cfloop>
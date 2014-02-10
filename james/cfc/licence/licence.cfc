<!---

	check licence information
	
	
	licence status of a track plist can be
	
	0 = default
	
	100 = creative commons
	
	mediaitem.licence_type
	
	playlists.licence_type

--->

<cfcomponent output="false" hint="Licence CFC">
	
	<cfinclude template="/common/scripts.cfm">
	
	<cfset variables.qLicenceDefault = 0 />
	<cfset variables.qLicenceCustom = 0 />
	<cfset variables.stLicenceDefault = {} />

<cffunction name="init" access="public" output="false" returntype="james.cfc.licence.licence"> 
	<!--- do nothing --->
	
	<cfset SetLicenceInfo() />
	
	<cfreturn this />
</cffunction>

<cffunction access="private" name="SetLicenceInfo" output="false" returntype="void" hint="load licence info from DB and set var">
	
	<cfset var oTransfer = application.beanFactory.getBean( 'UsersTransfer' ).getTransfer() />
	<cfset variables.qLicenceDefault = oTransfer.list( 'licence.featureset_defaults' ) />
	<cfset variables.qLicenceCustom = oTransfer.list( 'licence.featureset_custom' ) />
	
	<!--- set the very defaults ... (will be overwritten by database) --->
	
	<!--- interactive / radio / browse / preview --->
	<cfset variables.stLicenceDefault[ 'playlist' ] = application.udf.getRecordsetDefaultLicencePermissionStructure() />
	
	<cfset variables.stLicenceDefault[ 'content' ][ 'lyrics' ] = 0 />
	
	<cfset variables.stLicenceDefault[ 'library' ] = application.udf.getRecordsetDefaultLicencePermissionStructure() />
	<!--- NEXT: Go to database --->
	
	<!--- copy the default vars to a structure --->
	<cfloop query="variables.qLicenceDefault">
		<cfset variables.stLicenceDefault[ variables.qLicenceDefault.feature ][ variables.qLicenceDefault.action ] = variables.qLicenceDefault.enabled />
	</cfloop>
		
</cffunction>

<cffunction access="private" name="GetLicenceInfoDefaults" output="false" returntype="struct" hint="Return default licence information qry">
	<cfreturn variables.stLicenceDefault />
</cffunction>

<cffunction access="public" name="GetLicenceInfoCustom" output="false" returntype="query" hint="Return licence information qry">
	<cfreturn variables.qLicenceCustom />
</cffunction>

<cffunction access="public" name="CheckBlacklistEntry" output="false" returntype="boolean"
		hint="return true if an item has been blacklisted, e.g. an artist is not playable for other users at all">
	<cfargument name="securitycontext" type="struct" required="true"
		hint="security of the user asking for the action" />
	<cfargument name="itemtype" type="numeric" required="true"
		hint="0 = artist, 1 = album, 2 = track" />		
	<cfargument name="mbid" type="numeric" required="true"
		hint="musicbrainz ID" />
		
	<cfreturn false />
	
</cffunction>

<cffunction access="public" name="applyLicencePermissionsToRequest" output="false" returntype="struct"
		hint="take the default licence permissions and apply to return structure">
	<cfargument name="securitycontext" type="struct" required="true" />
	<cfargument name="sRequest" type="string" required="true"
		hint="PLAYLIST or LIBRARY" />
	<cfargument name="bOwnDataOnly" type="boolean" default="false"
		hint="do we have own elements only?" />
	
	<cfset var stReturn = application.udf.getRecordsetDefaultLicencePermissionStructure() />
	<cfset var sItem = '' />
	
	<!--- WORKAROUND: it's all own data --->
	<cfset arguments.bOwnDataOnly = true />
	
	<!--- own data only? --->
	<cfif arguments.bOwnDataOnly>
		<cfloop list="#StructKeyList( stReturn )#" index="sItem">
			<cfset stReturn[ sItem ] = 1 />
		</cfloop>
		
		<!--- everything ok, continue! --->
		<cfreturn stReturn />
	</cfif>
	
	<!--- now loop through the request and apply the default permissions ... --->
	<cfloop list="#StructKeyList( stReturn )#" index="sItem">
		
		<!--- apply basics --->
		<cfif arguments.securitycontext.rights[ arguments.sRequest ][ sItem ] IS 1>
			<cfset stReturn[ sItem ] = 1 />
		</cfif>
		
	</cfloop>
	
	<cfreturn stReturn />

</cffunction>

<cffunction access="public" name="GetFeatureSetForUser" output="false" returntype="struct"
		hint="return the featureset for this user as struct ... will be added to the securitycontext">
	<cfargument name="securitycontext" type="struct" required="true" />

	<!--- duplicate the default structure holding the rights --->
	<cfset var stRights = Duplicate( variables.stLicenceDefault ) />
	<cfset var qLicenceCustom = GetLicenceInfoCustom() />
	
	<!--- licence default *must* define all default properties --->

	<cfloop query="qLicenceCustom">
		
		<!--- hit country code? take default property (accounttype = 0) --->
		<cfif CompareNoCase( arguments.securitycontext.countryisocode, qLicenceCustom.countrycode ) IS 0 AND qLicenceCustom.accounttype IS 0>
			<cfset stRights[ qLicenceCustom.feature ][ qLicenceCustom.action ] = qLicenceCustom.enabled />
		</cfif>
		
		<!--- special account type? --->
		<cfif (CompareNoCase( arguments.securitycontext.countryisocode, qLicenceCustom.countrycode ) IS 0) AND
			  (CompareNoCase( arguments.securitycontext.accounttype, qLicenceCustom.accounttype) IS 0)>
			<cfset stRights[ qLicenceCustom.feature ][ qLicenceCustom.action ] = qLicenceCustom.enabled />
		</cfif>
		
		<!--- special admin --->
		<cfif (CompareNoCase( arguments.securitycontext.accounttype, 999) IS 0)>
			<cfset stRights[ qLicenceCustom.feature ][ qLicenceCustom.action ] = 1 />
		</cfif>
		
	</cfloop>
	
	<cfreturn stRights />

</cffunction>

<cffunction access="public" name="FeatureEnabledForUser" output="false" returntype="struct"
		hint="check if a certain feature is enabled and if yes, in which way ... return the possible options">
	<cfargument name="ip" type="string" required="true"
		hint="the remote address" />
	<cfargument name="securitycontext" type="struct" required="true"
		hint="security of the user asking for the action" />
	<cfargument name="feature" type="string" required="true"
		hint="part of the service, e.g. PLAYLIST or LIBRARY or CONTENT" />
	<cfargument name="action" type="string" required="false" default=""
		hint="name of the action ... if provided, check if this certain action is allowed" />
	
	<cfset var stReturn = application.udf.GenerateReturnStruct() />
	<cfset var qLicenceDefault = GetLicenceInfoDefaults() />
	<cfset var qLicenceCustom = GetLicenceInfoCustom() />
	<!--- list of allowed actions --->
	<cfset var sActions = '' />
	
	<cflog application="false" file="tb_licence" log="Application" type="information" text="licencing question: #arguments.feature# #arguments.securitycontext.countryisocode#">
	
	<!---
		
		feature
		which feature?
		
		PLAYLIST
		LIBRARY
		CONTENT
	

		RESULT will define if access in general is allowed
		
		true / false
		
		plus ACTIONS ... allowed actions
		
		currently
		
		PLAYLIST
			fullcontrol		- full on demand access (navigate, skip, pause etc)
			radio	 		- radio style
			
		LIBRARY
			browse			- browse through libary
			preview			- play 30 sec of track
			ondemand		- on demand streaming with full control
			
		CONTENT
			lyrics			- access to lyrics
	
	 --->
	
	<cfswitch expression="#arguments.feature#">
		
		<cfcase value="playlist">
			
			<!--- austria: fullcontrol --->
			<cfif ListFindNoCase( 'at', arguments.securitycontext.COUNTRYISOCODE ) GT 0>
				<cfset ListAppend( sActions, 'fullcontrol' ) />
			</cfif>
			
			<!--- other countries: radio --->
			<cfif ListFindNoCase( 'de,us,uk', arguments.securitycontext.COUNTRYISOCODE ) GT 0>
				<cfset ListAppend( sActions, 'radio' ) />
			</cfif>			
		</cfcase>
		<cfcase value="library">
		
			
		
		</cfcase>
	
	</cfswitch>

	<cfset stReturn.actions = sActions />
	
	<!--- if actions are allowed, return true, otherwise false --->
	<cfif Len( sActions ) GT 0>
		<cfreturn application.udf.SetReturnStructSuccessCode( stReturn ) />	
	<cfelse>
		<cfreturn application.udf.SetReturnStructErrorCode( stReturn, 999 ) />
	</cfif>
		
</cffunction>

<cffunction access="public" name="IPLookupCountry" returntype="string"
		hint="take the IP and return the country">
	<cfargument name="ip" type="string" required="true">

	<cfset var a_str_return = 'at' />
	<cfset var a_ip_num = 0 />
	<!--- ip address --->
	<cfset var q_select = 0 />
	
	<!--- invalid data? --->
	<cfif NOT Len( arguments.ip ) GT 8>
		<cfset arguments.ip = '127.0.0.1' />
	</cfif>
	
	<cfset a_ip_num = (ListFirst( arguments.ip, '.' ) * (256*256*256)) + (ListGetAt( arguments.ip, 2, '.' ) * (256*256)) + (ListGetAt( arguments.ip, 3, '.' ) * 256) + ListLast( arguments.ip, '.' ) />

	<cfquery name="q_select" datasource="mytunesbutlercontent" cachedwithin="#CreateTimeSpan(0,1,0,0)#">
	SELECT
		COUNTRYSHORT AS countryisocode
	FROM
		ipcountry
	WHERE
		(IPFROM <= <cfqueryparam cfsqltype="cf_sql_bigint" value="#a_ip_num#"> AND IPTO >= <cfqueryparam cfsqltype="cf_sql_bigint" value="#a_ip_num#">)
	ORDER BY 
		IPFROM DESC, IPTO DESC
	LIMIT
		1
	;
	</cfquery>
	
	<cfif q_select.recordcount IS 1>
		<cfset a_str_return = q_select.countryisocode />
	</cfif>
	
	<!--- return lower case! --->
	<cfreturn lcase( a_str_return ) />

</cffunction>

<cffunction access="public" name="mapISRCCodesToMusicBrainzTrackID" returntype="struct" output="false"
		hint="map the musicbrainz ID to the ISRC code">
	<cfargument name="iStartRow" type="numeric" required="true"
		hint="LIMIT start row for tracks" />
	<cfargument name="iMaxRows" type="numeric" required="true"
		hint="number of rows to examine" />
		
	<cfset var stReturn = application.udf.GenerateReturnStruct() />
	<cfset var qSelectTracks = 0 />
	<cfset var sISRC = '' />
	<cfset var iAccuracy = 0 />
	<cfset var sArtistNames = '' />
	<cfset var stLocal = {} />
	<cfset var iNoHits = 0 />
	
	<cfquery name="qSelectTracks" datasource="mytunesbutler_mb">
	SELECT
		track.id AS track_id,
		track.artist AS artist_id,
		track.name AS track_name,
		artist.name AS artist_name,
		track.length
	FROM
		track
	LEFT JOIN
		artist ON (artist.id = track.artist)
	LIMIT
		#Val( arguments.iStartRow )#, #arguments.iMaxRows#
	;
	</cfquery>

	<!--- loop over tracks --->
	<cfoutput query="qSelectTracks">
		
		<cfset sISRC = '' />
		<cfset iAccuracy = 0 />
		<cfset sArtistNames = qSelectTracks.artist_name />
		
		<!--- find possible names or artist, including alias names --->
		<cfquery name="stLocal.qSelectArtistNames" datasource="mytunesbutler_mb">
		SELECT
			TRIM(name) AS name
		FROM
			artistalias
		WHERE
			artistalias.ref = <cfqueryparam cfsqltype="cf_sql_integer" value="#qSelectTracks.artist_ID#">
		;
		</cfquery>
		
		<cfif stLocal.qSelectArtistNames.recordcount GT 0>
			<cfset sArtistNames = ListAppend( sArtistNames, ValueList( stLocal.qSelectArtistNames.name )) />
		</cfif>
		
		<!--- first track: direct hit --->
		<cfquery name="stLocal.qSelectISRC" datasource="mytunesbutlercontent">
		SELECT
			*,
			ABS(CONVERT(<cfqueryparam cfsqltype="cf_sql_integer" value="#qSelectTracks.length#"> / 1000, DECIMAL) - vendor_track_duration) AS lendifference
		FROM
			reportinginfo
		WHERE
			vendor_artist_name IN (<cfqueryparam cfsqltype="cf_sql_varchar" value="#sArtistNames#" list="true" />)
			AND
			vendor_track_name = <cfqueryparam cfsqltype="cf_sql_varchar" value="#qSelectTracks.track_name#" />
		ORDER BY
			lendifference
		LIMIT 1
		;
		</cfquery>
		
		<!--- hit or not? --->
		<cfif stLocal.qSelectISRC.recordcount IS 1>
			<cfset sISRC = stLocal.qSelectISRC.isrc />			
		<cfelse>
		
			<!--- 2nd hit: try to use LIKE, maybe the track has  --->
			<cfquery name="stLocal.qSelectISRC2nd" datasource="mytunesbutlercontent">
			SELECT
				*,
				ABS(CONVERT(<cfqueryparam cfsqltype="cf_sql_integer" value="#qSelectTracks.length#"> / 1000, DECIMAL) - vendor_track_duration) AS lendifference
			FROM
				reportinginfo
			WHERE
				vendor_artist_name IN (<cfqueryparam cfsqltype="cf_sql_varchar" value="#sArtistNames#" list="true" />)
				AND
				vendor_track_name LIKE <cfqueryparam cfsqltype="cf_sql_varchar" value="#qSelectTracks.track_name#%" />
			ORDER BY
				lendifference
			LIMIT 1
			;
			</cfquery>
			
			
			<!--- hit? --->
			<cfif stLocal.qSelectISRC2nd.recordcount IS 1>
				<cfset sISRC = stLocal.qSelectISRC2nd.isrc />
				<cfset iAccuracy = 1 />
			<cfelse>
			
				<!--- third try ... SOUNDS similar --->
				<cfquery name="stLocal.qSelectISRC_3rd" datasource="mytunesbutlercontent">
				SELECT
					*,
					ABS(STRCMP( SOUNDEX( reportinginfo.vendor_track_name ), SOUNDEX( <cfqueryparam cfsqltype="cf_sql_varchar" value="#qSelectTracks.track_name#"> ))) AS SOUNDEX_COMPARE,
					ABS(CONVERT(<cfqueryparam cfsqltype="cf_sql_integer" value="#qSelectTracks.length#"> / 1000, DECIMAL) - vendor_track_duration) AS lendifference
				FROM
					reportinginfo
				WHERE
					vendor_artist_name IN (<cfqueryparam cfsqltype="cf_sql_varchar" value="#sArtistNames#" list="true" />)
				ORDER BY
					SOUNDEX_COMPARE,
					lendifference
				LIMIT
					1
				;
				</cfquery>
				
				<!--- hit? --->
				<cfif stLocal.qSelectISRC_3rd.recordcount AND stLocal.qSelectISRC_3rd.soundex_compare IS 0>
					<cfset iAccuracy = 2 />
					<cfset sISRC = stLocal.qSelectISRC_3rd.isrc />
				<cfelse>
				
					<!--- next try .. just the first five chars ... --->
					<cfquery name="stLocal.qSelectISRC_4th" datasource="mytunesbutlercontent">
					SELECT
						*,
						ABS(STRCMP( SOUNDEX( reportinginfo.vendor_track_name ), SOUNDEX( <cfqueryparam cfsqltype="cf_sql_varchar" value="#qSelectTracks.track_name#"> ))) AS SOUNDEX_COMPARE,
						ABS(CONVERT(<cfqueryparam cfsqltype="cf_sql_integer" value="#qSelectTracks.length#"> / 1000, DECIMAL) - vendor_track_duration) AS lendifference
					FROM
						reportinginfo
					WHERE
						vendor_artist_name IN (<cfqueryparam cfsqltype="cf_sql_varchar" value="#sArtistNames#" list="true" />)
						AND
						LEFT( vendor_track_name, 8) = <cfqueryparam cfsqltype="cf_sql_varchar" value="#Left( qSelectTracks.track_name, 8)#" />
					ORDER BY
						SOUNDEX_COMPARE,
						lendifference
					LIMIT
						1
					;
					</cfquery>
					
					<!--- rather bad hit ... --->
					<cfif stLocal.qSelectISRC_4th.recordcount>
						<cfset iAccuracy = 3 />
						<cfset sISRC = stLocal.qSelectISRC_4th.isrc />
					<cfelse>
					
						<cfquery name="stLocal.qSelectISRC_5th" datasource="mytunesbutlercontent">
						SELECT
							*,
							ABS(STRCMP( SOUNDEX( reportinginfo.vendor_track_name ), SOUNDEX( <cfqueryparam cfsqltype="cf_sql_varchar" value="#qSelectTracks.track_name#"> ))) AS SOUNDEX_COMPARE,
							ABS(CONVERT(<cfqueryparam cfsqltype="cf_sql_integer" value="#qSelectTracks.length#"> / 1000, DECIMAL) - vendor_track_duration) AS lendifference
						FROM
							reportinginfo
						WHERE
							vendor_artist_name IN (<cfqueryparam cfsqltype="cf_sql_varchar" value="#sArtistNames#" list="true" />)
							AND
							RIGHT( vendor_track_name, 6) = <cfqueryparam cfsqltype="cf_sql_varchar" value="#Right( qSelectTracks.track_name, 6)#" />
						ORDER BY
							SOUNDEX_COMPARE,
							lendifference
						LIMIT
							1
						;
						</cfquery>
						
						<cfif stLocal.qSelectISRC_5th.recordcount>
							<cfset iAccuracy = 4 />
							<cfset sISRC = stLocal.qSelectISRC_5th.isrc />
						<cfelse>
							<cfset iNohits = iNohits + 1 />
						</cfif>
						
					</cfif>
					
					
				</cfif>
				
			
			</cfif>
			
		</cfif>
		
		
		<!--- 
			
			check if we've a hit and insert it
			
		 --->
		<cfif Len( sISRC ) GT 0 AND FindNoCase( '7dig', sISRC ) neq 1>
			
			<cftry>
			<cfquery name="local.qInsertMapping" datasource="mytunesbutlercontent">
			INSERT INTO
				mapping_mb_isrc
				(
				mb_trackid,
				isrc,
				accuracy
				)
			VALUES
				(
				<cfqueryparam cfsqltype="cf_sql_integer" value="#qSelectTracks.track_id#">,
				<cfqueryparam cfsqltype="cf_sql_varchar" value="#sISRC#">,
				<cfqueryparam cfsqltype="cf_sql_integer" value="#iAccuracy#">
				)
			;
			</cfquery>
			<cfcatch type="any"></cfcatch>
			</cftry>
			
		</cfif>

	</cfoutput>

	<cfset stReturn.qTracks = qSelectTracks />
	<cfset stReturn.stArgs = arguments />
	<cfset stReturn.iNohits = iNohits />
	<cfreturn application.udf.SetReturnStructSuccessCode( stReturn ) />	

</cffunction>

</cfcomponent>
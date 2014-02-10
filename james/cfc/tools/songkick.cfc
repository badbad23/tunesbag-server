<cfcomponent output="false">

	<cfset variables.sAffiliateKey = "" />
	<cfset variables.sBaseURL = "http://api.songkick.com/api/3.0" />
	<cfset variables.iMaxAgeEventCheck = 5 />
	
	<cfinclude template="/common/scripts.cfm" />
	
	<cffunction name="init" access="public" output="false" returntype="any">
		<cfargument name="sAffiliateKey" type="string" required="false" default="1xp9pcTRrCGYoYUm" />
		
		<cfset variables.sAffiliateKey = arguments.sAffiliateKey />
		
		<cfreturn this />
	</cffunction>
	
	<cffunction name="getAffiliateKey" output="false" returntype="string">
		<cfreturn variables.sAffiliateKey />
	</cffunction>
	
	<cffunction name="getBaseURL" output="false" returntype="string">
		<cfreturn variables.sBaseURL />
	</cffunction>
	
	<cffunction name="getMaxageEvents" output="false" returntype="numeric">
		<cfreturn variables.iMaxAgeEventCheck />
	</cffunction>
	
	<cffunction name="getEvents" access="public" output="false" returntype="struct" hint="Return events">
		<cfargument name="iMB_ArtistID" type="numeric" required="true" />
		<cfargument name="bFetchFromProvider" type="boolean" required="false" default="false"
			hint="Fetch data from service" />
		
		<cfset var stReturn = application.udf.GenerateReturnStruct() />
		<cfset var local = {} />
		
		<cfif Val( arguments.iMB_ArtistID ) IS 0>
			<cfreturn application.udf.SetReturnStructErrorCode(stReturn, 404, 'Not found' ) />
		</cfif>
		
		<cfset local.iRuntime = GetTickCount() />
		
		<!--- check lastload --->
		
		<cfquery name="local.qSelectLastChecked" datasource="mytunesbutlercontent">
		SELECT
			dt_lastupdate_songkick,
			artist.gid AS gid
		FROM
			common_artist_information
		LEFT JOIN
			mytunesbutler_mb.artist AS artist ON (artist.id = common_artist_information.artistid)
		WHERE
			artistid = <cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.iMB_ArtistID#" />
		;
		</cfquery>
		
		<cfset local.sMBArtistID = local.qSelectLastChecked.gid />
	
		<!--- never loaded before or outdated --->	
		<cfset local.bOutdated = (
					!(IsDate( local.qSelectLastChecked.dt_lastupdate_songkick ))
						OR
						(Int( DateDiff( 'd', local.qSelectLastChecked.dt_lastupdate_songkick, Now() )) GT getMaxageEvents())
					) />
		
		<!--- force reload? outdated + fetch from provider --->
		<cfset local.bForceReload = (local.bOutdated AND arguments.bFetchFromProvider) />
		
		<cfif local.bForceReload>
			
			<!--- load data from server --->
			<cftry>
				<cfhttp timeout="5" url="#getBaseURL()#/artists/mbid:#UrlEncodedFormat( local.sMBArtistID )#/events.json?apikey=#getAffiliateKey()#&per_page=50" result="local.stHTTP"></cfhttp>
				
				<!---  #getBaseURL()#/artists/mbid:#UrlEncodedFormat( local.sMBArtistID )#/events.json?apikey=#getAffiliateKey()#&per_page=50 --->				
				<cflog application="false" file="tb_songkick" log="Application" type="information" text="Loading events for #arguments.iMB_Artistid#" />
				
				<cfset local.stResponse = DeSerializeJSON( local.stHTTP.filecontent ).resultsPage />
				
				<!--- items exist? --->
				<cfif StructKeyExists( local.stResponse.results, 'event' )>
				
					<cfset local.aTmpEvents = local.stResponse.results.event />
			
					<cfloop from="1" to="#ArrayLen( local.aTmpEvents )#" index="local.ii">
						
						<!--- try to load and update an item --->
						<cfset local.oRecord = entityLoad( 'songkickdata', { mb_artistid = arguments.iMB_ArtistID, songkick_ID = local.aTmpEvents[ local.ii ].id }, true ) />
						
						<!--- New! --->
						<cfif IsNull( local.oRecord )>
							<cfset local.oRecord = entityNew( 'songkickdata' ) />
						</cfif>
						
						<cfset local.oRecord.setMB_ArtistID( arguments.iMB_ArtistID ) />
						<cfset local.oRecord.setdStart( local.aTmpEvents[ local.ii ].start.date ) />
						
						<cfset local.oRecord.setdisplayname( local.aTmpEvents[ local.ii ].displayname ) />
						<cfset local.oRecord.setsongkick_id( local.aTmpEvents[ local.ii ].id ) />
						
						<cftry>
						<cfset local.oRecord.setlon( local.aTmpEvents[ local.ii ].location.lng ) />
							<cfcatch type="any">
								<cfset local.oRecord.setlon( 0 ) />
							</cfcatch>
						</cftry>
						
						<cftry>
						<cfset local.oRecord.setlat( local.aTmpEvents[ local.ii ].location.lat ) />
							<cfcatch type="any">
								<cfset local.oRecord.setlat( 0 ) />							
							</cfcatch>
						</cftry>
						
						<cftry>
							
						<cfset local.oRecord.setlocation_city( local.aTmpEvents[ local.ii ].location.city ) />
							<cfcatch type="any">
								<cfset local.oRecord.setlocation_city( '' ) />
							</cfcatch>
						</cftry>
						
						<cfset local.oRecord.seturi( local.aTmpEvents[ local.ii ].uri ) />
						
						<cfset entitySave( local.oRecord ) />
						
					</cfloop>
					
				</cfif>
				
				<cfquery name="local.qSelectLastChecked" datasource="mytunesbutlercontent">
				UPDATE
					common_artist_information
				SET
					dt_lastupdate_songkick = CURRENT_TIMESTAMP					
				WHERE
					artistid = <cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.iMB_ArtistID#" />
				;
				</cfquery>
			
				<cfcatch type="any">
					<cfset stReturn.cfcatch = cfcatch />
					<cfset stReturn.sResponse = local.stHTTP.Filecontent />
					<cfreturn application.udf.SetReturnStructErrorCode(stReturn, 500, 'Failed. Error message is: ' & cfcatch.Message ) />
				</cfcatch>
			</cftry>
		
		<cfelseif local.bOutdated AND NOT arguments.bFetchFromProvider>
			
			<!--- do not fetch information from the internet, perform a delayed query --->
			<cfreturn application.udf.SetReturnStructErrorCode(stReturn, 201, 'Please try using the ajax request' ) />
			
		</cfif>
		
		<!--- continue, select --->
		<cfquery name="local.qEvents" datasource="mytunesbutlercontent">
		SELECT
	        mb_artistid,
	        lon,
	        dstart,
	        songkick_id,
	        location_city,
	        uri,
	        lat,
	        displayname 
	    from
	        songkickdata 
	    where
	        mb_artistid=<cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.iMB_ArtistID#" />
	        AND
	        dstart > <cfqueryparam cfsqltype="cf_sql_date" value="#DateAdd( 'd', -1, Now() )#" />
		ORDER BY
			dstart
		</cfquery>
		
		<cfset stReturn.qEvents = local.qEvents />
		
		<cfset stReturn.iRuntime = GetTickCount() - local.iRuntime />
		<cfreturn application.udf.SetReturnStructSuccessCode( stReturn ) />
		
	</cffunction>
	
	<cffunction name="formatEventData" access="public" returntype="string" output="false">
			<cfargument name="qEvents" type="query" required="true" />
			
			<cfset var sReturn = '' />
			<cfset var local = {} />
			
			<cfif arguments.qEvents.recordcount IS 0>
				<cfreturn '' />
			</cfif>
			
			<cfsavecontent variable="sReturn">
				<!--- <h3><cfoutput>#application.udf.GetLangValSec( 'cm_wd_events' )#</cfoutput> (<cfoutput>#arguments.qEvents.recordcount#</cfoutput>+)</h3> --->
				<img title="<cfoutput>#application.udf.GetLangValSec( 'cm_wd_events' )#</cfoutput> (<cfoutput>#arguments.qEvents.recordcount#</cfoutput>+)" src="/res/images/partner/services/songkick-114x30.png" style="padding:12px;padding-left:0px;" alt="" width="114" height="30" />
				<ul class="concerts">
				<cfoutput query="arguments.qEvents">
					<li class="<cfif arguments.qEvents.currentrow GT 10> hidden</cfif>">
						
						<a href="#htmleditformat( arguments.qEvents.uri )#" target="_blank" title="#htmleditformat( arguments.qEvents.displayname )#" rel="nofollow"><span class="date">#LSDateFormat( arguments.qEvents.dstart, "mmm dd" )#</span>
						<span class="city">#htmleditformat( application.udf.ShortenString( arguments.qEvents.location_city, 15 ))#</span>
						<!--- <br />
						<span>#htmleditformat( application.udf.ShortenString( arguments.qEvents.displayname, 40) )#</span> --->
						</a>
					</li>
				</cfoutput>
				<cfif arguments.qEvents.recordcount GT 10>
					<cfoutput>
					<li><a href="##" onclick="$('.concerts li').removeClass( 'hidden' );return false">#application.udf.si_img( 'add' )# Show all</a></li>
					</cfoutput>
				</cfif>
				
				</ul>
				<div class="clear"></div>
			
			</cfsavecontent>
			
			<cfreturn sReturn />
			
		</cffunction>
	
</cfcomponent>
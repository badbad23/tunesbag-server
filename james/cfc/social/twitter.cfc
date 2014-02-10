<!--- //

	Module:		
	Action:		
	Description:	
	
// --->


<cfcomponent output="no">
	
	<cfinclude template="/common/scripts.cfm">

	<cffunction name="init" access="public" returntype="james.cfc.social.twitter" output="false">
		<cfreturn this />
	</cffunction>
	
	<cffunction access="public" name="PerformSearchForArtistTweets" output="false" returntype="struct" hint="Search for tweets with this arist name">
		<cfargument name="mb_artistid" type="numeric" required="true"
			hint="the musicbrainz artist id">
		<cfargument name="artist" type="string" required="true"
			hint="the name of the artist">
		<cfargument name="lang" type="string" required="false" default="en"
			hint="language">
			
		<cfset var cfhttp = 0 />
		<cfset var a_hits = '' />
		<!--- load last update --->
		<cfset var a_last_update = 0 />
		<cfset var stReturn = application.udf.GenerateReturnStruct() />
		<cfset var a_data = 0 />
		<cfset var a_tweet = 0 />
		<cfset var qInsert = 0 />
		<cfset var a_map = {} />
		<cfset var a_db_item = 0 />
		<cfset var ii = 0 />
		<cfset var a_str_url = 0 />
		<cfset var a_since_info = getTwitterSinceData( arguments.mb_artistid ) />
		
		<cfif Len( arguments.artist ) LT 2>
			<cfreturn application.udf.SetReturnStructErrorCode(stReturn, 999) />
		</cfif>
		
		<!--- no update more then one time all 20 min --->
		<cfif a_since_info.getispersisted() AND DateDiff('n', a_since_info.getlastupdate(), Now() ) LT 20>
			<cfreturn application.udf.SetReturnStructErrorCode(stReturn, 999) />
		</cfif>
		
		<cfset a_str_url = "http://search.twitter.com/search.json?q=#UrlEncodedFormat( arguments.artist )#&rpp=50&lang=#UrlEncodedFormat( arguments.lang )#&since_id=#Val( a_since_info.getsinceid() )#" />
			
		<cftry>
		<cfhttp url="#a_str_url#" timeout="10"
				method="Get" charset="UTF-8"
				useragent="tunesBag.com twittersearch 1.0"></cfhttp>
		
		<cfcatch type="any">
			<cfset stReturn.a_str_url = a_str_url />
			<cfreturn application.udf.SetReturnStructErrorCode(stReturn, 999) />
		</cfcatch>
		</cftry>
	
		<!--- convert json to text --->
		<cftry>
		<cfset a_data = DeSerializeJSON( cfhttp.FileContent.toString() ) />
		
			<!--- error --->
			<cfcatch type="any">
				<cfreturn application.udf.SetReturnStructErrorCode(stReturn, 999) />
			</cfcatch>
		</cftry>
		
		<cfset stReturn.url = a_str_url />
		
		<cftry>
		<cfset a_hits = a_data.results />
			<cfcatch type="any">
				<cfreturn application.udf.SetReturnStructErrorCode(stReturn, 999) />
			</cfcatch>
		</cftry>
		
		<cfset setTwitterSinceID( mb_artistid = arguments.mb_artistid, since_id = a_data.since_id ) />
		
		<cfloop from="1" to="#ArrayLen( a_hits )#" index="ii">
			<cfset a_tweet = a_hits[ ii ] />
			
			<!--- 
			
				filter:
				- no replies
				- No "Now on"
			
			 --->
			<cfif (FindNoCase( '@', a_tweet.text ) IS 0) AND
				  (FindNoCase( 'lala.com', a_tweet.text ) IS 0) AND
				  (FindNoCase( 'Now on', a_tweet.text ) IS 0) AND
				  (FindNoCase( 'Now playing', a_tweet.text ) IS 0) AND
				  (FindNoCase( 'On Air:', a_tweet.text ) IS 0) AND
				  (FindNoCase( 'Playing now:', a_tweet.text ) IS 0)>
				
				<cftry>
				<cfquery name="qInsert" datasource="mytunesbutlercontent">
				INSERT INTO
					twitterstream
					(
					twitterid,
					dt_created,
					body,
					from_user,
					langcode,
					mb_artistid,
					profile_image_url
					)
				VALUES
					(
					<cfqueryparam cfsqltype="cf_sql_bigint" value="#a_tweet.id#">,
					<cfqueryparam cfsqltype="cf_sql_timestamp" value="#ParseDateTime( a_tweet.created_at )#">,
					<cfqueryparam cfsqltype="cf_sql_varchar" value="#a_tweet.text#">,
					<cfqueryparam cfsqltype="cf_sql_varchar" value="#a_tweet.from_user#">,
					<cfqueryparam cfsqltype="cf_sql_varchar" value="#a_tweet.iso_language_code#">,
					<cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.mb_artistid#">,
					<cfqueryparam cfsqltype="cf_sql_varchar" value="#a_tweet.profile_image_url#">
					)
				;
				</cfquery>
				
				<cfcatch type="any"></cfcatch>
				</cftry>
				
			</cfif>
		</cfloop>
		
		<cfreturn application.udf.SetReturnStructSuccessCode(stReturn) />
		
	</cffunction>
	
	<cffunction access="public" name="getArtistTweets" output="false" returntype="struct" hint="return tweets">
		<cfargument name="mb_artistid" type="numeric" required="true">
		<cfargument name="artist" type="string" required="true">
		<cfargument name="maxitems" type="numeric" default="10" required="false">
		<cfargument name="lang" type="string" required="false" default="en">
		<cfargument name="exec_search" type="boolean" default="false">
		
		<cfset var stReturn = application.udf.GenerateReturnStruct() />
		<cfset var oTransfer = application.beanFactory.getBean( 'ExtContentTransfer' ).getTransfer() />
		<cfset var a_tweets = 0 />
		
		<cfif arguments.mb_artistid IS 0>
			<cfreturn application.udf.SetReturnStructErrorCode(stReturn, 999) />
		</cfif>
		
		<!--- perform real http based REST search? ... --->
		<cfif arguments.exec_search>
			<cfset PerformSearchForArtistTweets( mb_artistid = arguments.mb_artistid, artist = arguments.artist, lang = arguments.lang ) />
		</cfif>
		
		<!--- load tweets --->
		<cfset a_tweets = oTransfer.listByProperty( 'cache.twitterstream', 'mb_artistid', arguments.mb_artistid, 'dt_created', false ) />
		
		<cfset stReturn.q_select_tweets = a_tweets />
		
		<cfreturn application.udf.SetReturnStructSuccessCode(stReturn) />
		
	</cffunction>

	<cffunction access="private" name="getTwitterSinceData" output="false" returntype="any">
		<cfargument name="mb_artistid" type="numeric" required="true">
		<cfset var oTransfer = application.beanFactory.getBean( 'ExtContentTransfer' ).getTransfer() />
		<cfset var a_item = oTransfer.get( 'cache.twittersinceid', arguments.mb_artistid ) />
		<cfreturn a_item />		
	</cffunction>
	
	<cffunction access="private" name="setTwitterSinceID" output="false" returntype="void">
		<cfargument name="mb_artistid" type="numeric" required="true">
		<cfargument name="since_id" type="numeric" required="true">
		
		<cfset var oTransfer = application.beanFactory.getBean( 'ExtContentTransfer' ).getTransfer() />
		<cfset var a_item = oTransfer.get( 'cache.twittersinceid', arguments.mb_artistid ) />
		
		<cfset a_item.setmb_artistid( arguments.mb_artistid ) />
		<cfset a_item.setsinceid( arguments.since_id ) />
		<cfset a_item.setlastupdate( Now() ) />

		<cfset oTransfer.save( a_item ) />
	
	</cffunction>
	
	<cffunction access="public" name="SendTwitterMessage" output="false" returntype="struct"
			hint="send a comment to twitter">
		<cfargument name="securitycontext" type="struct" required="true">
		<cfargument name="message" type="string" required="true">
		
		<cfset var stReturn = application.udf.GenerateReturnStruct() />
		<cfset var a_struct_twitter_data = application.beanFactory.getBean( 'UserComponent' ).GetExternalSiteID( securitycontext = arguments.securitycontext,
											servicename = 'twitter' ) />
		<cfset var cfhttp = 0 />
								
		<cfif NOT a_struct_twitter_data.result>
			<cfreturn application.udf.SetReturnStructErrorCode(stReturn, 999) />
		</cfif>		
		
		<cftry>
		<cfhttp url="http://twitter.com/statuses/update.xml" timeout="15" method="POST"
			username="#a_struct_twitter_data.a_item.getUsername()#" password="#a_struct_twitter_data.a_item.getPwd()#" charset="UTF-8">
		        <cfhttpparam type="FORMFIELD" name="status" value="#arguments.message#">
		        <cfhttpparam type="formfield" name="source" value="tunesbag">
		</cfhttp> 
		
		<cfcatch type="any">
			<cfreturn application.udf.SetReturnStructErrorCode(stReturn, 999) />
		</cfcatch>
		</cftry>
	
		<cfreturn application.udf.SetReturnStructSuccessCode(stReturn) />
			
	</cffunction>
	
</cfcomponent>
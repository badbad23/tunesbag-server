<!--- //

	YT integration
	
// --->

<cfcomponent output="no">
	
	<cfinclude template="/common/scripts.cfm">

	<cffunction name="init" access="public" returntype="james.cfc.social.youtube" output="false">
		<cfreturn this />
	</cffunction>
	
	<cffunction access="public" name="SimpleParseYTInformation" output="false" returntype="struct"
			hint="Return the redirect URL by parsing the webpage">
		<cfargument name="YouTubeURL" type="string" required="true"
			hint="e.g. http://www.youtube.com/watch?v=gQhl001WL9I">

		<cfset var stReturn = application.udf.GenerateReturnStruct() />
		<cfset var a_str_id = ListLast( arguments.YouTubeURL, '=') />
		<cfset var a_params = 0 />
		<cfset var cfhttp = 0 />
		<cfset var a_str_fullscreen_info = '' />
		<cfset var a_string = '' />
		<cfset var a_str_video_id = '' />
		<cfset var ii = 0 />
		<cfset var a_struct_params = StructNew() />
		<cfset var a_str_new_id = '' />
		<cfset var a_str_url = '' />
		<cfset var a_str_key = '' />
		<cfset var a_str_value = '' />
		
		<cftry>
		<cfhttp url="#arguments.YouTubeURL#" method="get" useragent="Mozilla/4.0 (compatible; MSIE 6.0; Windows NT 5.1)" timeout="10"></cfhttp>
		
		<cfcatch type="any">
			<cfreturn application.udf.SetReturnStructErrorCode(stReturn, 999) />
		</cfcatch>
		</cftry>
		
		<!--- find the "fullscreen" line --->
		<cfset a_str_fullscreen_info = ReFindNoCase('watch_fullscreen?[^'']*', cfhttp.FileContent, 1, true) />
		
		<!--- get the whole line --->
		<cfset a_string = Mid( cfhttp.FileContent, a_str_fullscreen_info.pos[1], a_str_fullscreen_info.len[1]) />

		<!--- split --->
		<cfset a_params = ListToArray( a_string, '&') />
		<cfset a_struct_params = StructNew() />

		<cfloop from="1" to="#ArrayLen( a_params )#" index="ii">
			
			<cfset a_str_key = ListFirst( a_params[ii], '=') />
			<cfset a_str_value = ListLast( a_params[ii], '=') />
			
			<cfset a_struct_params[ a_str_key ] = a_str_value />
			
		</cfloop>

		<!--- build the string and return --->
		<cfset a_str_new_id = a_str_id & '&t=' & a_struct_params.t & '&sk=' & a_struct_params.sk />
		<cfset a_str_url = 'http://youtube.com/get_video.php?video_id=' & a_str_new_id />

		<cfset stReturn.url = a_str_url />
	
		<cfreturn application.udf.SetReturnStructSuccessCode(stReturn) />		
		
		
	</cffunction>
	
	<cffunction access="public" name="ParseYTInformation" output="false" returntype="struct"
			hint="parse youtube page and get out information">
		<cfargument name="securitycontext" type="struct" required="true">
		<cfargument name="entrykey" type="string" required="true"
			hint="the entrykey">
			
		<cfset var stReturn = application.udf.GenerateReturnStruct() />
		<cfset var a_yt_info_req = GetTemporaryYTItemInformation( securitycontext = arguments.securitycontext, entrykey = arguments.entrykey ) />
		<cfset var a_yt_info = 0 />
		
		<cfif NOT a_yt_info_req.result>
			<cfreturn a_yt_info_req />
		</cfif>
		
		<!--- get the info item --->
		<cfset a_yt_info = a_yt_info_req.a_yt_item />
		
		<cfreturn SimpleParseYTInformation( a_yt_info.GetPageLink() ) />
		
	</cffunction>
	
	<cffunction access="public" name="GetTemporaryYTItemInformation" output="false" returntype="struct">
		<cfargument name="securitycontext" type="struct" required="true">
		<cfargument name="entrykey" type="string" required="true"
			hint="the entrykey">
			
		<cfset var stReturn = application.udf.GenerateReturnStruct() />
		<cfset var oTransfer = application.beanFactory.getBean( 'LogTransfer' ).getTransfer() />
		<cfset var a_item = oTransfer.get( 'cache.youtube_id_temp_mapper', arguments.entrykey ) />
		
		<cfset stReturn.a_yt_item = a_item />
		
		<!--- return information --->
		<cfreturn application.udf.SetReturnStructSuccessCode(stReturn) />
			
	</cffunction>
	
	<cffunction access="private" name="StoreTemporaryMappingForYTID" output="false" returntype="void"
			hint="Store temporary mapping between YT ID and entrykey">
		<cfargument name="youtube_id" type="string" required="true">
		<cfargument name="entrykey" type="string" required="true">
		<cfargument name="userkey" type="string" required="true">
		<cfargument name="artist" type="string" required="true">
		<cfargument name="name" type="string" required="true">
		<cfargument name="username" type="string" required="true">
		<cfargument name="pagelink" type="string" required="true">
		<cfargument name="tags" type="string" required="true">

		<cfset var oTransfer = application.beanFactory.getBean( 'LogTransfer' ).getTransfer() />	
		<cfset var a_item = oTransfer.new( 'cache.youtube_id_temp_mapper' ) />
		
		<cfset a_item.setEntrykey( arguments.entrykey ) />
		<cfset a_item.setyoutube_id( arguments.youtube_id ) />
		<cfset a_item.setdt_created( Now() ) />
		<cfset a_item.setuserkey( arguments.userkey ) />
		<cfset a_item.setartist( arguments.artist ) />
		<cfset a_item.setname( arguments.name ) />
		<cfset a_item.setusername( arguments.username ) />
		<cfset a_item.setpagelink( arguments.pagelink ) />
		<cfset a_item.settags( arguments.tags ) />
		
		<cfset oTransfer.Save( a_item ) />

	</cffunction>
	
	<cffunction access="public" name="IsTemporaryYouTubeClip" output="false" returntype="boolean"
			hint="Check if this is a temporary item">
		<cfargument name="entrykey" type="string" required="true">
		
		<cfset var oTransfer = application.beanFactory.getBean( 'LogTransfer' ).getTransfer() />
		
		<cfreturn (CompareNoCase( oTransfer.get( 'cache.youtube_id_temp_mapper', arguments.entrykey ).getEntrykey(), arguments.entrykey) IS 0) />
		
	</cffunction>
	
	<cffunction access="public" name="searchForYoutubeClipsSimple" output="false" returntype="struct"
			hint="simple youtube search">
		<cfargument name="securitycontext" type="struct" required="false" default="#StructNew()#" />
		<cfargument name="search" type="string" required="true" />
		<cfargument name="iMaxHits" type="numeric" required="false" default="2" />
		
		<cfset var stReturn = application.udf.GenerateReturnStruct() />
		<cfset var cfhttp = 0 />
		<cfset var local = {} />
		<cfset var oCache = application.beanFactory.getBean( 'CacheComponent' ) />
		<cfset var sHashID = Hash( 'youtube_clips_' & arguments.search & '_' & arguments.iMaxHits ) />
		<cfset var stCacheCheck = oCache.CheckAndGetStoredElement( hashvalue = sHashID ) />
		
		<cfif Len( arguments.search ) IS 0>
			<cfreturn application.udf.SetReturnStructErrorCode(stReturn, 9991) />
		</cfif>
		
		<!--- stored in cache? --->
		<cfif stCacheCheck.result>
			<cfset stReturn.cached = true />
			<cfset stReturn.aHits = stCacheCheck.data />
			<cfreturn application.udf.SetReturnStructSuccessCode(stReturn) />
		</cfif>
		
		<!--- call yt link --->
		<cftry>
			<cfhttp url="http://gdata.youtube.com/feeds/videos/-/Music/?vq=#urlencodedformat( arguments.search )#&start-index=1&max-results=20&alt=rss" result="cfhttp"></cfhttp>
		
		<cfcatch type="any">
			<cfreturn application.udf.SetReturnStructErrorCode(stReturn, 999) />
		</cfcatch>
		</cftry>
		
		<cfset local.xHits = XMLParse( cfhttp.FileContent.toString() ) />

		<cfset local.xHits = XMLSearch( local.xHits, '/rss/channel/item' ) />
		
		<!--- any hits? --->
		<cfif ArrayLen( local.xHits ) IS 0>
			<cfreturn application.udf.SetReturnStructErrorCode(stReturn, 404) />
		</cfif>

		<cfset local.aHits = ArrayNew( 1 ) />
		
		<cfif ArrayLen( local.xHits ) LT arguments.iMaxHits>
			<cfset arguments.iMaxHits = ArrayLen( local.xHits ) />
		</cfif>

		<cfloop from="1" to="#arguments.iMaxHits#" index="local.ii">
			
			<cfset local.xHit = local.xHits[ local.ii ] />
			
			<cfset local.aHits[ local.ii ] = StructNew() />
			<cfset local.aHits[ local.ii ].title = local.xHit.title.xmltext />
			<cfset local.aHits[ local.ii ].description = local.xHit.description.xmltext />
			
		</cfloop>
		
		<cfset stReturn.aHits = local.aHits />
		
		<!--- store in cache --->
		<cfset oCache.StoreCacheElement( hashvalue = sHashID,
								system = 'youtube',
								description = 'youtube_clips: ' & arguments.search,
								data = local.aHits,
								expiresmin = 800 ) />		
		
		<cfreturn application.udf.SetReturnStructSuccessCode( stReturn ) />

	</cffunction>
	
	<!--- <cffunction access="public" name="SearchForYoutubeClips" output="false" returntype="struct"
			hint="execute a search for clips on youtube">
		<cfargument name="securitycontext" type="struct" required="false" default="#StructNew()#">
		<cfargument name="search" type="string" required="true">
		<cfargument name="storeTemporaryEntrykeys" type="boolean" default="true" required="false"
			hint="Store temporary mapping between YT ID and entrykey">
		
		<cfset var stReturn = application.udf.GenerateReturnStruct() />
		<cfset var cfhttp = 0 />
		<cfset var q_select_rss = 0 />
		<cfset var tmp = 0 />
		<cfset var a_str_entrykey = '' />
		<cfset var a_str_yt_id = '' />
		<cfset var a_cmp_cache = application.beanFactory.getBean( 'CacheComponent' ) />
		<cfset var a_str_hash_item = Hash( 'youtube_clips_' & arguments.search ) />
		<cfset var q_select_items = QueryNew( 'entrykey,name,artist,pagelink,id,videolink,dt_created,tags,username,rating', 'VarChar,VarChar,VarChar,VarChar,VarChar,VarChar,date,VarChar,VarChar,Integer') />
		<cfset var a_struct_cache = a_cmp_cache.CheckAndGetStoredElement( hashvalue = a_str_hash_item ) />
		<cfset var a_str_split_name = '' />
		<cfset var a_str_yt_artist = '' />
		<cfset var a_str_yt_name = '' />		
		
		<cfif Len( arguments.search ) IS 0>
			<cfreturn application.udf.SetReturnStructErrorCode(stReturn, 9991) />
		</cfif>
		
		<!--- stored in cache? --->
		<cfif a_struct_cache.result>
			<cfset stReturn.cached = true />
			<cfset stReturn.q_select_items = a_struct_cache.data />
			<cfreturn application.udf.SetReturnStructSuccessCode(stReturn) />
		</cfif>
		
		<!--- if the sec context is not valid, do NEVER store the mapping data --->
		<cfif NOT StructKeyExists( arguments.securitycontext, 'entrykey' )>
			<cfset arguments.storeTemporaryEntrykeys = false />
		</cfif>
		
		<!--- get the rss information --->
		<cftry>
			<cffeed action="read" query="q_select_rss" source="http://gdata.youtube.com/feeds/videos/-/Music/?vq=#urlencodedformat( arguments.search )#&start-index=1&max-results=20&alt=rss">
		
		<cfcatch type="any">
			<cfreturn application.udf.SetReturnStructErrorCode(stReturn, 999) />
		</cfcatch>
		</cftry>
		
		<!--- no hit --->
		<cfif q_select_rss.recordcount IS 0>
			<cfreturn application.udf.SetReturnStructErrorCode(stReturn, 999) />
		</cfif>
		
		<cfset QueryAddRow( q_select_items, q_select_rss.recordcount ) />
		
		<cfloop query="q_select_rss">
			
			<cfset a_str_entrykey = CreateUUID() />
			<cfset a_str_yt_id = ListLast( q_select_rss.rsslink, '=') />
			
			<cfset a_str_split_name = q_select_rss.title />
				
			<cfif ListLen( a_str_split_name, '-') GT 0>
				<cfset a_str_yt_artist = Trim( ListFirst( a_str_split_name, '-') ) />
				<cfset a_str_yt_name = Trim( ListLast( a_str_split_name, '-') ) />
			<cfelse>
				<cfset a_str_yt_artist = 'Various' />
				<cfset a_str_yt_name = a_str_split_name />
			</cfif>			
			
			<!--- store mapping if wanted by caller --->
			<cfif arguments.storeTemporaryEntrykeys>
				
				<cfset StoreTemporaryMappingForYTID( youtube_id = a_str_yt_id,
								entrykey = a_str_entrykey,
								userkey = arguments.securitycontext.entrykey,
								artist = a_str_yt_artist,
								name = a_str_yt_name,
								pagelink = q_select_rss.rsslink,
								tags = q_select_rss.CATEGORYLABEL,
								username = q_select_rss.AUTHOREMAIL ) />
								
			</cfif>
			
			<!--- set entrykey, id and so on --->
			<cfset QuerySetCell( q_select_items, 'entrykey', a_str_entrykey, q_select_rss.currentrow ) />
			<cfset QuerySetCell( q_select_items, 'id', a_str_yt_id, q_select_rss.currentrow ) />
			<cfset QuerySetCell( q_select_items, 'artist', a_str_yt_artist, q_select_rss.currentrow ) />
			<cfset QuerySetCell( q_select_items, 'pagelink', q_select_rss.rsslink, q_select_rss.currentrow ) />
			<cfset QuerySetCell( q_select_items, 'name', a_str_yt_name, q_select_rss.currentrow ) />
			<cfset QuerySetCell( q_select_items, 'tags', q_select_rss.CATEGORYLABEL, q_select_rss.currentrow ) />
			<cfset QuerySetCell( q_select_items, 'username', q_select_rss.AUTHOREMAIL, q_select_rss.currentrow ) />
			<cfset QuerySetCell( q_select_items, 'dt_created', ParseDateTime( q_select_rss.PUBLISHEDDATE ), q_select_rss.currentrow ) />
			<cfset QuerySetCell( q_select_items, 'rating', 100, q_select_rss.currentrow ) />
		</cfloop>
		
		<!--- store data in cache for later usage --->		
		<cfset tmp = a_cmp_cache.StoreCacheElement( hashvalue = a_str_hash_item,
								system = 'youtube',
								description = 'youtube_clips: ' & arguments.search,
								data = q_select_items ) />		
		
		<cfset stReturn.q_select_items = q_select_items />
		
		<cfreturn application.udf.SetReturnStructSuccessCode(stReturn) />
		
	</cffunction> --->
	

</cfcomponent>
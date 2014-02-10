<!---

	tools

--->

<cfcomponent output="false" hint="Tools CFC">
	
	<cfinclude template="/common/scripts.cfm">

<cffunction name="init" access="public" output="false" returntype="james.cfc.tools.tools"> 
	<!--- do nothing --->
	<cfreturn this />
</cffunction>

<cffunction name="getFileHash" returntype="string" output="false" hint="Function to create an MD5 checksum of a binary Byte array similar to md5sum command on linux.  This is useful for creating md5 sums of jpg/png images for integrity verification" >
	<cfargument name="filename" type="string" required="true">
	<cfargument name="algorithm" type="string" required="false" default="SHA-1" hint="Any algorithm supported by java MessageDigest - eg: MD5, SHA-1,SHA-256, SHA-384, and SHA-512.  Reference: http://java.sun.com/javase/6/docs/technotes/guides/security/StandardNames.html##MessageDigest">
	<cfset var i = "">
	<cfset var checksumByteArray = "">
	<cfset var checksumHex = "">
	<cfset var hexCouplet = "">
	<cfset var myBinaryFile = 0 />
	<cfset var digester = createObject("java","java.security.MessageDigest").getInstance(arguments.algorithm) />
	<cfset var cffile = 0 />
	
	<cfif NOT FileExists( arguments.filename )>
		<cfreturn '' />
	</cfif>	
	
	<cffile result="cffile" action="readbinary" file="#arguments.filename#" variable="myBinaryFile">
	
	<cfset digester.update(myBinaryFile,0,len( myBinaryFile ))>
	<cfset checksumByteArray = digester.digest()>
	
	<!--- Convert byte array to hex values --->
	<cfloop from="1" to="#len(checksumByteArray)#" index="i">
		<cfset hexCouplet = formatBaseN(bitAND(checksumByteArray[i],255),16)>
		<!--- Pad with 0's --->
		<cfif len(hexCouplet) EQ 1>
			<cfset hexCouplet = "0#hexCouplet#">
		</cfif>
		<cfset checkSumHex = "#checkSumHex##hexCouplet#">
	</cfloop>
	<cfreturn lCase( checkSumHex ) />
</cffunction>

<cffunction access="public" name="createRelationByEntrykeys" output="false" returntype="void"
		hint="create relation by entrykeys">
	<cfargument name="sRelation" type="string" required="true"
		hint="the relation to manage" />
		
	<cfswitch expression="#arguments.sRelation#">
		<cfcase value="rel_library_mediaitem">
			
			<!--- invalid --->
			<cfif Len( arguments.librarykey ) IS 0 OR Len( arguments.mediaitemkey ) IS 0>
				<cfreturn />
			</cfif>
		
			<!--- TODO: Fix issue, mediaitem_ID could become NULL --->
			<cfquery name="local.qInsertRelation" datasource="mytunesbutleruserdata">
			INSERT INTO
				rel_library_mediaitem
				(
				library_id,
				mediaitem_id
				)
			VALUES
				(
				(SELECT libraries.id FROM libraries WHERE libraries.entrykey = <cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.librarykey#" />),
				(SELECT mediaitems.id FROM mediaitems WHERE mediaitems.entrykey = <cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.mediaitemkey#" />)
				)
			;
			</cfquery>
		
		</cfcase>		
	</cfswitch>

</cffunction>

	<cffunction access="public" name="deleteRelationByCriteria" output="false" returntype="void"
			hint="remove a 1:n or n:n relationship by a criteria">
		<cfargument name="sRelation" type="string" required="true"
			hint="which relationship (e.g. rel_library_mediaitem or rel_user_mediaitem)" />
		<cfargument name="stCriteria" type="struct" required="true"
			hint="what to search for" />
			
		<cfset var stLocal = {} />
		<cfset var ii = 0 />
		<cfset var stMap = {} />
		<cfset var oItem = 0 />
		
		<cfswitch expression="#arguments.sRelation#">
			<cfcase value="rel_library_mediaitem">
				
				<cfquery name="stLocal.qDelete" datasource="mytunesbutleruserdata">
				DELETE FROM
					rel_library_mediaitem
				WHERE
					
					<cfif StructKeyExists( arguments.stCriteria, 'mediaitemkey' )>
				
					mediaitem_id = (SELECT id FROM mediaitems WHERE entrykey = <cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.stCriteria.mediaitemkey#">)
					
					<cfelse>
						(1 = 0)
					</cfif>
				</cfquery>
				
			
			</cfcase>
			<cfcase value="rel_user_mediaitem">
			
				<cfquery name="stLocal.qDelete" datasource="mytunesbutleruserdata">
				DELETE FROM
					rel_user_mediaitem
				WHERE
					
					<cfif StructKeyExists( arguments.stCriteria, 'mediaitemkey' )>
				
					mediaitem_id = (SELECT id FROM mediaitems WHERE entrykey = <cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.stCriteria.mediaitemkey#">)
					
					<cfelse>
						(1 = 0)
					</cfif>
				</cfquery>
			
			</cfcase>
		</cfswitch>

	<!--- TODO: Implement further cases --->
	</cffunction>

<!--- copied from /james/tests/db/ --->
	<cffunction access="public" name="ManageRelation" output="false" returntype="void">
	<cfargument name="sRelation" type="string" required="true"
		hint="which relation do we want to manage ... name = transfer name (e.g. rel_user_mediaitem) ... supporting relationships with ONE result (1:n)">
	<cfargument name="aManageRel" type="array" default="#ArrayNew( 1 )#" />
	
	<cfset var oTransfer = application.beanFactory.getBean( 'ContentTransfer' ).getTransfer() />
	<cfset var ii = 0 />
	<cfset var stMap = {} />
	<cfset var oItem = 0 />
	
	<cfloop from="1" to="#ArrayLen( arguments.aManageRel )#" index="ii">
		
		<cfswitch expression="#arguments.sRelation#">
			<cfcase value="rel_user_mediaitem">
				
				<!--- try read this item ...only one item might exist with this mapping, so make sure an unique index exists --->
				<cfset stMap = { user_id = arguments.aManageRel[ ii ].user_id, mediaitem_id = arguments.aManageRel[ ii ].mediaitem_id } />
				
			</cfcase>
			<cfcase value="rel_library_mediaitem">
				
				<cfset stMap = { library_id = arguments.aManageRel[ ii ].library_id, mediaitem_id = arguments.aManageRel[ ii ].mediaitem_id } />
			
			</cfcase>
			<cfcase value="rel_user_playlist">
				
				<cfset stMap = { user_id = arguments.aManageRel[ ii ].user_id, playlist_id = arguments.aManageRel[ ii ].playlist_id } />
			
			</cfcase>
			<cfcase value="rel_library_playlist">
			
				<cfset stMap = { library_id = arguments.aManageRel[ ii ].library_id, playlist_id = arguments.aManageRel[ ii ].playlist_id } />
			
			</cfcase>
			<cfcase value="rel_user_user">
				
				<cfset stMap = { user1_id = arguments.aManageRel[ ii ].user1_id, user2_id = arguments.aManageRel[ ii ].user2_id } />
				
			</cfcase>
		</cfswitch>
		
		
		<!--- try to read item --->
		<cfset oItem = oTransfer.ReadByPropertyMap( 'relations.' & arguments.sRelation, stMap ) />
				
		<cfswitch expression="#arguments.aManageRel[ ii ].sOperation#">
			<cfcase value="set">
				<!--- create or update ... in case it does not exist, create it ...  --->
				
				<cfif NOT oitem.getIsPersisted()>
					
					<cfswitch expression="#arguments.sRelation#">
						
						<!--- user to mediaitem --->
						<cfcase value="rel_user_mediaitem">
							<cfset oItem.setuser_id( arguments.aManageRel[ ii ].user_id ) />
							<cfset oItem.setmediaitem_id( arguments.aManageRel[ ii ].mediaitem_id ) />
						</cfcase>
						<!--- library to mediaitem --->
						<cfcase value="rel_library_mediaitem">
							<cfset oItem.setlibrary_id( arguments.aManageRel[ ii ].library_id ) />
							<cfset oItem.setmediaitem_id( arguments.aManageRel[ ii ].mediaitem_id ) />
						</cfcase>
						<!--- user to playlist --->
						<cfcase value="rel_user_playlist">
							<cfset oItem.setuser_id( arguments.aManageRel[ ii ].user_id ) />
							<cfset oItem.setplaylist_id( arguments.aManageRel[ ii ].playlist_id ) />
						</cfcase>
						<!--- library to playlist --->
						<cfcase value="rel_library_playlist">
							<cfset oItem.setlibrary_id( arguments.aManageRel[ ii ].library_id ) />
							<cfset oItem.setplaylist_id( arguments.aManageRel[ ii ].playlist_id ) />
						</cfcase>
						<!--- user to user --->
						<cfcase value="rel_user_user">
							<cfset oItem.setuser1_id( arguments.aManageRel[ ii ].user1_id ) />
							<cfset oItem.setuser2_id( arguments.aManageRel[ ii ].user2_id ) />
						</cfcase>
					</cfswitch>
					
					<cfset oTransfer.save( oItem ) />
				</cfif>
				
			</cfcase>
			<cfcase value="delete">
				<!--- TODO: delete relation --->
			</cfcase>
		</cfswitch>
		
	</cfloop>
	
</cffunction>

<!--- compress javascript --->

<cffunction access="public" name="generateJSInclude" output="false" returntype="struct">
	<cfargument name="arJSFiles" type="array" required="true" />
	
	<cfset var bFilesCached = false />
	<cfset var stReturn = application.udf.GenerateReturnStruct() />
	<cfset var sRootDirectory = GetPageContext().getRootTemplateDirectory() />
	<cfset var sJSPath = sRootDirectory & '/res/js/' />
	<cfset var qFiles = 0 />
	<cfset var sContent = '' />
	<cfset var ii = 0 />
	<cfset var sCacheHash = Hash( arguments.arJSFiles.toString() ) />
	<cfset var sJSCombination = '' />
	<cfset var sCacheDirectory = application.udf.GetLocalContentDirectory() & '/album_artwork/jscache/' />
	<cfset var sCacheFilename = sCacheDirectory & sCacheHash & '.js' />
	<cfset var sTempFile = '' />
	
	<!--- only reload data if a reinit is given or if we're in dev mode --->
	<cfset local.bRefreshCache = StructKeyExists(url, 'reinit' ) OR NOT FileExists( sCacheFilename ) />
		
	<!--- make sure all existing JS files are cached ... refresh only on a testing server or if forces --->
	<cflock name="lck_check_cached_js_exists" timeout="3" type="readonly">
		<cfset local.bCacheExists = StructKeyExists( application, 'stJSFileCache' ) />
	</cflock>
	
	<!--- reload cache? --->
	<cfif local.bRefreshCache>
		<cfset StructDelete( application, 'stJSFileCache' ) />
	</cfif>

	<cfif NOT StructKeyExists( application, 'stJSFileCache' )>
		
		<cflock name="lck_create_js_cache" type="exclusive" timeout="60">
		
			<cfset application.stJSFileCache = {} />
		
			<!--- read files & compress --->
			<cfdirectory action="list" filter="*.js" recurse="true" directory="#sJSPath#" name="qFiles" />
			
			<cfloop query="qFiles">			
				<cffile action="read" file="#qFiles.Directory#/#qFiles.name#" variable="sContent" charset="utf-8" />			
				<cfset application.stJSFileCache[ qFiles.directory & '/' & qFiles.name ] = sContent />
			</cfloop>
			
			<cfloop from="1" to="#ArrayLen( arJSFiles )#" index="ii">
				<cfset sTempFile = sJSPath & arJSFiles[ ii ] />
				
				<cfif StructKeyExists( application.stJSFileCache, sTempFile )>
					<cfset sJSCombination = sJSCombination & Chr( 10 ) & application.stJSFileCache[ sTempFile ] />
				</cfif>
			</cfloop>
			
			<!--- ok, this is our string --->		
			<cfset sTempFile = GetTempDirectory() & '/compress-' & CreateUUID() & '.js' />
						
			<cffile action="write" file="#sTempFile#" output="#sJSCombination#" charset="utf-8" />
			
			<!--- make sure the cache directory exists at all --->
			<cfif NOT DirectoryExists( sCacheDirectory )>
				<cfdirectory action="create" directory="#sCacheDirectory#" />
			</cfif>
						
			<cfexecute name="#application.udf.GetJavaPath()#" arguments="-jar #sRootDirectory#/tools/yuicompressor-2.4.2.jar -o #sCacheFilename# #sTempFile#" timeout="30"></cfexecute>
			
			<!--- remove the temp file --->
			<cffile action="delete" file="#sTempFile#" />
		
		</cflock>
		
	</cfif>
			
	<cfset stReturn.bCached = true />
	
	<!--- ok, check if string has already been cached --->
	<cfset stReturn.sFilename = sCacheFilename />
	
	<!--- return the relative location ... mapping must have been created using apache --->
	<cfset stReturn.sLocation = '/res/images/artwork/jscache/' & GetFileFromPath( sCacheFilename ) />
	<cfreturn application.udf.SetReturnStructSuccessCode( stReturn ) />

</cffunction>
</cfcomponent>
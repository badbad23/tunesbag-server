<cfsetting requesttimeout="60" />

<cfquery name="qPlists" datasource="mytunesbutleruserdata">
SELECT
	*
FROM
	playlists
WHERE
	IFNULL( img_revision, 0 ) = 0
	AND
	imageset = 1
<!--- 	AND
	artistid = 559418 --->
LIMIT
	3
;
</cfquery>

<cfdump var="#qPlists#">


<cfloop query="qPlists">
	
	<!--- new revision --->
	<cfset iRevision = Val( qPlists.img_revision ) + 1 />
	
	<cfset bFailed = false />
	
	<!--- search --->
	<cfdirectory action="list" filter="#qPlists.entrykey#.*.jpg" name="qFiles" directory="#getLocalPlaylistImagePath( qPlists.entrykey )#" />
	
	<cfdump var="#getLocalPlaylistImagePath( qPlists.entrykey )#">
	
	<cfdump var="#qFiles#">
	
	<cfif qFiles.recordcount GT 0>
		
		<cfloop query="qFiles">
			
			<!--- ignore the originally fetched file ... this one can stay on the local host --->
			
			<cfset sDestFilename = ListDeleteAt( qFiles.name, ListLen( qFiles.name, '.'), '.') & '-' & iRevision & '.' & ListLast( qFiles.name, '.') />
				
				<!--- <cfdump var="#sDestFilename#"> --->
				
				<cfset sDestPath = application.udf.getCommonAlbumPlaylistFilePath( qPlists.entrykey ) />
				
				<cfset bUpload = oS3.putObject( bucketName = application.S3ContentCDNBucketname,
							fileKey = qFiles.Directory & '/' & qFiles.name,
							remotepath = sDestPath,
							remotefilename = sDestFilename,
							contenttype = 'image/jpeg',
							bPublicReadable = true,
							CacheControl = '' ) />
							  
				<cfif NOT bUpload>
					<cfset bFailed = true />
					<b>Upload failed</b>
				</cfif>
			
			
		</cfloop>
		
		<!--- update revision --->
		<cfif NOT bFailed>
			
			<cfquery name="qUpdate" datasource="mytunesbutleruserdata">
			UPDATE
				playlists
			SET
				img_revision = <cfqueryparam cfsqltype="cf_sql_integer" value="#iRevision#" />
			WHERE
				entrykey = <cfqueryparam cfsqltype="cf_sql_varchar" value="#qPlists.entrykey#" />
			</cfquery>
			
		</cfif>
	</cfif>
	<cfflush>	
	
</cfloop>
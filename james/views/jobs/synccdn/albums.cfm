
<cfquery name="qSelectUnsyncedAlbumImages" datasource="mytunesbutlercontent">
SELECT
	*
FROM
	common_album_information
WHERE
	IFNULL( img_revision, 0 ) = 0
	AND
	Length( artwork ) > 0
<!--- 	AND
	albumid = 4 --->
LIMIT
	30
;
</cfquery>

<cfdump var="#qSelectUnsyncedAlbumImages#">


<cfloop query="qSelectUnsyncedAlbumImages">
	
	<!--- new revision --->
	<cfset iRevision = Val( qSelectUnsyncedAlbumImages.img_revision ) + 1 />
	
	<cfset bFailed = false />
	
	<!--- search --->
	<cfdirectory action="list" filter="#qSelectUnsyncedAlbumImages.albumid#.*.jpg" name="qFiles" directory="#getLocalAlbumImagePath( qSelectUnsyncedAlbumImages.albumid )#" />
	
	<cfdump var="#getLocalAlbumImagePath( qSelectUnsyncedAlbumImages.albumid )#">
	
	<cfdump var="#qFiles#">
	
	<!--- wrong number of files ... --->
	<cfif qFiles.recordcount LT 3>
		<cfdump var="#getProperty( 'beanFactory' ).getBean( 'ContentComponent' ).fetchAlbumImage( iAlbum_ID = qSelectUnsyncedAlbumImages.albumid, sHTTPUrl = qSelectUnsyncedAlbumImages.artwork )#" label="fetch album image">
	</cfif>
	
	<!--- hits? if not at least some files, something went wrong here --->
	<cfif qFiles.recordcount GT 3>
		
		<cfloop query="qFiles">
			
			<!--- ignore the originally fetched file ... this one can stay on the local host --->
			
			<cfif Right( qFiles.name, 11) NEQ 'fetched.jpg'>
			
				<cfset sDestFilename = ListDeleteAt( qFiles.name, ListLen( qFiles.name, '.'), '.') & '-' & iRevision & '.' & ListLast( qFiles.name, '.') />
				
				<!--- <cfdump var="#sDestFilename#"> --->
				
				<cfset sDestPath = application.udf.getCommonAlbumImageFilePath( qSelectUnsyncedAlbumImages.albumid ) />
				
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
			
			</cfif>
			
		</cfloop>
		
		<!--- update revision --->
		<cfif NOT bFailed>
			
			<cfquery name="qUpdate" datasource="mytunesbutlercontent">
			UPDATE
				common_album_information
			SET
				img_revision = <cfqueryparam cfsqltype="cf_sql_integer" value="#iRevision#" />
			WHERE
				albumid = <cfqueryparam cfsqltype="cf_sql_integer" value="#qSelectUnsyncedAlbumImages.albumid#" />
			</cfquery>
			
		</cfif>
	
	</cfif>
	<cfflush>
</cfloop>
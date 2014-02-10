<cfsetting requesttimeout="60" />

<cfquery name="qSelectUnsyncedArtistImages" datasource="mytunesbutlercontent">
SELECT
	*
FROM
	common_artist_information
WHERE
	IFNULL( img_revision, 0 ) = 0
	AND
	Length(artistimg ) > 0
<!--- 	AND
	artistid = 559418 --->
LIMIT
	30
;
</cfquery>
<cfdump var="#qSelectUnsyncedArtistImages#">
<cfloop query="qSelectUnsyncedArtistImages">
	
	<!--- new revision --->
	<cfset iRevision = Val( qSelectUnsyncedArtistImages.img_revision ) + 1 />
	
	<cfset bFailed = false />
	
	<!--- search --->
	<cfdirectory action="list" filter="#qSelectUnsyncedArtistImages.artistid#.*.jpg" name="qFiles" directory="#application.udf.getLocalArtistImagePath( qSelectUnsyncedArtistImages.artistid )#" />
	
	<cfdump var="#qFiles#">
	
	<!--- wrong number of files ... --->
	<cfif qFiles.recordcount LT 3>
		<cfset getProperty( 'beanFactory' ).getBean( 'ContentComponent' ).fetchArtistImage( iArtist_ID = qSelectUnsyncedArtistImages.artistid, sHTTPUrl = qSelectUnsyncedArtistImages.artistimg ) />
	</cfif>
	
	<!--- hits? if not at least some files, something went wrong here --->
	<cfif qFiles.recordcount GT 3>
		
		<cfloop query="qFiles">
			
			<!--- ignore the originally fetched file ... this one can stay on the local host --->
			
			<cfif Right( qFiles.name, 11) NEQ 'fetched.jpg'>
			
				<cfset sDestFilename = ListDeleteAt( qFiles.name, ListLen( qFiles.name, '.'), '.') & '-' & iRevision & '.' & ListLast( qFiles.name, '.') />
				
				<!--- <cfdump var="#sDestFilename#"> --->
				
				<cfset sDestPath = application.udf.getCommonArtistImageFilePath( qSelectUnsyncedArtistImages.artistid ) />
				
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
				common_artist_information
			SET
				img_revision = <cfqueryparam cfsqltype="cf_sql_integer" value="#iRevision#" />
			WHERE
				artistid = <cfqueryparam cfsqltype="cf_sql_integer" value="#qSelectUnsyncedArtistImages.artistid#" />
			</cfquery>
			
		</cfif>
	
	</cfif>
	<cfflush>
</cfloop>
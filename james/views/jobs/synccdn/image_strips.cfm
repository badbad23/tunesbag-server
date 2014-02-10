<!--- upload strips --->

<cfquery name="qUploadStrips" datasource="mytunesbutlercontent">
SELECT
	*
FROM
	image_strips
WHERE
	img_revision = 0
	AND
	img_type = 0
LIMIT
	20
;
</cfquery>

<cfdump var="#qUploadStrips#">

<cfoutput query="qUploadStrips">
	
	<!--- new revision --->
	<cfset iRevision = Val( qUploadStrips.img_revision ) + 1 />
	
	<cfset bFailed = false />
	
	<cfset sLocalFilename = application.udf.getLocalArtistImagePath( qUploadStrips.mbid ) & application.udf.getStripFilename( qUploadStrips.mbid, 2, qUploadStrips.ImgWidth, qUploadStrips.ImgHeight ) />
	
	<cfif FileExists( sLocalFilename )>
		
		<!--- upload --->
		<cfset sDestPath = application.udf.getCommonArtistStripFilePath( qUploadStrips.mbid ) />
		<cfset sDestFilename = application.udf.getStripFilename( qUploadStrips.mbid, 2, qUploadStrips.ImgWidth, qUploadStrips.ImgHeight, iRevision ) />
				
		<cfset bUpload = oS3.putObject( bucketName = application.S3ContentCDNBucketname,
					fileKey = sLocalFilename,
					remotepath = sDestPath,
					remotefilename = sDestFilename,
					contenttype = 'image/jpeg',
					bPublicReadable = true,
					CacheControl = '' ) />
		
		<cfif bUpload>
			<cfquery name="qUpdate" datasource="mytunesbutlercontent">
			UPDATE
				image_strips
			SET
				img_revision = <cfqueryparam cfsqltype="cf_sql_integer" value="#iRevision#" />
			WHERE
				id = <cfqueryparam cfsqltype="cf_sql_integer" value="#qUploadStrips.id#" />
			</cfquery>
		</cfif>
		
	</cfif>
	
</cfoutput>
<!--- 

	upload files to S3 in order to serve them later via CloudFront
	
	We upload /res/*

 --->

<cfinclude template="/common/scripts.cfm">

<cfsetting requesttimeout="90" />

<cfset oS3 = getProperty( 'beanFactory' ).getBean( 'AWSS3' ).init( accessKeyId = application.AWSAccessKeyId, secretAccessKey = application.AWSsecretAccessKey ) />

<cfinclude template="image_strips.cfm">

<cfinclude template="artists.cfm">

<!--- <cfinclude template="playlists.cfm"> --->

<!--- <cfinclude template="albums.cfm"> --->

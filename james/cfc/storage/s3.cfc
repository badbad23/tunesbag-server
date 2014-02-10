<!--- //

	Module:		Amazon S3 Wrapper
	Action:		
	Description:	
	
// --->
<cfcomponent name="s3" displayname="Amazon S3 REST Wrapper v1.2">
	
<cfsetting requesttimeout="2000">

<!---
Amazon S3 REST Wrapper

Written by Joe Danziger (joe@ajaxcf.com) with much help from
dorioo on the Amazon S3 Forums.  See the readme for more
details on usage and methods.

Version 1.2 - Released: October 4, 2006
--->

	<cfset variables.accessKeyId = "" />
	<cfset variables.secretAccessKey = "" />
	
	<cfinclude template="/common/scripts.cfm">

	<cffunction name="init" access="public" returnType="james.cfc.storage.s3" output="false"
				hint="Returns an instance of the CFC initialized.">
		<cfargument name="accessKeyId" type="string" required="true" hint="Amazon S3 Access Key ID.">
		<cfargument name="secretAccessKey" type="string" required="true" hint="Amazon S3 Secret Access Key.">
		
		<cfset variables.accessKeyId = arguments.accessKeyId />
		<cfset variables.secretAccessKey = arguments.secretAccessKey />
		
		<cfreturn this>
	</cffunction>
	
	<cffunction access="private" name="S3Log" output="false" returntype="string"
			hint="log s3 operaton, return entrykey of log item">
		<cfargument name="reqtype" type="string" required="true"
			hint="type of req">		
		<cfargument name="url" type="string" required="true"
			hint="url called">
		<cfargument name="Authorization" type="string" required="true"
			hint="req Authorization">

		<cfset var a_str_entrykey = CreateUUID() />
		<cfset var q_insert_s3_log = 0 />
		
		<cfinclude template="queries/q_insert_s3_log.cfm">
		
		<cfreturn a_str_entrykey />

	</cffunction>
	
	<cffunction access="private" name="UpdateS3LogResult" output="false" returntype="void"
			hint="update with cfhttp response">
		<cfargument name="entrykey" type="string" required="true"
			hint="entrykey of log item">
		<cfargument name="cfhttp_response" type="any" required="true">
		<cfargument name="success" type="numeric" required="true"
			hint="0/1">
		
		<cfset var q_update_s3_log_response = 0 />
		<cfset var a_str_response = '' />
		
		<cfwddx action="cfml2wddx" input="#arguments.cfhttp_response#" output="a_str_response">
		
		<cfinclude template="queries/q_update_s3_log_response.cfm">

	</cffunction>
	
	<cffunction name="Hex2Bin" returntype="any" hint="Converts a Hex string to binary">
		<cfargument name="inputString" type="string" required="true" hint="The hexadecimal string to be written.">
	
		<cfset var outStream = CreateObject("java", "java.io.ByteArrayOutputStream").init() />
		<cfset var inputLength = Len(arguments.inputString) />
		<cfset var outputString = "" />
		<cfset var i = 0 />
		<cfset var ch = "" />
	
		<cfif inputLength mod 2 neq 0>
			<cfset arguments.inputString = "0" & inputString>
		</cfif>
	
		<cfloop from="1" to="#inputLength#" index="i" step="2">
			<cfset ch = Mid(inputString, i, 2)>
			<cfset outStream.write(javacast("int", InputBaseN(ch, 16)))>
		</cfloop>
	
		<cfset outStream.flush()>
		<cfset outStream.close()>
	
		<cfreturn outStream.toByteArray()>
	</cffunction>


	<cffunction name="getBuckets" access="public" output="false" returntype="array" 
				description="List all available buckets.">
		
		<cfset var signature = "">
		<cfset var data = "">
		<cfset var bucket = "">
		<cfset var buckets = "">
		<cfset var thisBucket = "">
		<cfset var allBuckets = "">
		<cfset var dateTimeString = GetHTTPTimeString(Now())>
		<cfset var digest = 0 />
		<cfset var cfhttp = 0 />
		<cfset var x = 0 />
		
		<!--- Create a canonical string to send --->
		<cfset var cs = "GET\n\n\n#dateTimeString#\n/">
		
		<!--- Replace "\n" with "chr(10) to get a correct digest --->
		<cfset var fixedData = replace(cs,"\n","#chr(10)#","all")>

		<!--- Calculate the hash of the information --->
		<cf_hmac hash_function="sha1" data="#fixedData#" key="#variables.secretAccessKey#">
		
		<!--- fix the returned data to be a proper signature --->
		<cfset signature = ToBase64(Hex2Bin( digest )) />
		
		<!--- get all buckets via REST --->
		<cfhttp method="GET" url="http://s3.amazonaws.com" result="cfhttp">
			<cfhttpparam type="header" name="Date" value="#dateTimeString#">
			<cfhttpparam type="header" name="Authorization" value="AWS #variables.accessKeyId#:#signature#">
		</cfhttp>
		
		<cfset data = xmlParse(cfhttp.FileContent) />
		<cfset buckets = xmlSearch(data, "//:Bucket") />

		<!--- create array and insert values from XML --->
		<cfset allBuckets = arrayNew(1)>
		<cfloop index="x" from="1" to="#arrayLen(buckets)#">
		   <cfset bucket = buckets[x]>
		   <cfset thisBucket = structNew()>
		   <cfset thisBucket.Name = bucket.Name.xmlText>
		   <cfset thisBucket.CreationDate = bucket.CreationDate.xmlText>
		   <cfset arrayAppend(allBuckets, thisBucket)>   
		</cfloop>
		
		<cfreturn allBuckets />
	</cffunction>
	
	
	<cffunction name="putBucket" access="public" output="false" returntype="boolean" 
				description="Creates a bucket.">
		<cfargument name="bucketName" type="string" required="yes">
		
		<cfset var signature = "">
		<cfset var dateTimeString = GetHTTPTimeString(Now())>
		<cfset var digest = 0 />
		<cfset var cfhttp = 0 />

		<!--- Create a canonical string to send based on operation requested ---> 
		<cfset var cs = "PUT\n\ntext/html\n#dateTimeString#\n/#arguments.bucketName#"> 

		<!--- Replace "\n" with "chr(10) to get a correct digest --->
		<cfset var fixedData = replace(cs,"\n","#chr(10)#","all")> 

		<!--- Calculate the hash of the information ---> 
		<cf_hmac hash_function="sha1" data="#fixedData#" key="#variables.secretAccessKey#">

		<!--- fix the returned data to be a proper signature --->
		<cfset signature = ToBase64(Hex2Bin( digest )) />

		<!--- put the bucket via REST --->
		<cfhttp method="PUT" url="http://s3.amazonaws.com/#arguments.bucketName#" charset="utf-8" result="cfhttp">
			<cfhttpparam type="header" name="Content-Type" value="text/html">
			<cfhttpparam type="header" name="Date" value="#dateTimeString#">
			<cfhttpparam type="header" name="Authorization" value="AWS #variables.accessKeyId#:#signature#">
		</cfhttp>
		
		<cfreturn true />
	</cffunction>
	
	
	<cffunction name="getBucket" access="public" output="false" returntype="array" 
				description="Get a bucket.">
		<cfargument name="bucketName" type="string" required="yes">
		<cfargument name="prefix" type="string" required="false" default="">
		<cfargument name="marker" type="string" required="false" default="">
		<cfargument name="maxKeys" type="string" required="false" default="">
		
		<cfset var signature = "">
		<cfset var data = "">
		<cfset var content = "">
		<cfset var contents = "">
		<cfset var thisContent = "">
		<cfset var allContents = "">
		<cfset var dateTimeString = GetHTTPTimeString(Now())>
		<cfset var digest = 0 />
		<cfset var cfhttp = 0 />
		<cfset var x = '' />

		<!--- Create a canonical string to send --->
		<cfset var cs = "GET\n\n\n#dateTimeString#\n/#arguments.bucketName#">

		<!--- Replace "\n" with "chr(10) to get a correct digest --->
		<cfset var fixedData = replace(cs,"\n","#chr(10)#","all")>

		<!--- Calculate the hash of the information --->
		<cf_hmac hash_function="sha1" data="#fixedData#" key="#variables.secretAccessKey#">

		<!--- fix the returned data to be a proper signature --->
		<cfset signature = ToBase64(Hex2Bin( digest ))>

		<!--- get the bucket via REST --->
		<cfhttp method="GET" url="http://s3.amazonaws.com/#arguments.bucketName#" result="cfhttp">
			<cfhttpparam type="header" name="Date" value="#dateTimeString#">
			<cfhttpparam type="header" name="Authorization" value="AWS #variables.accessKeyId#:#signature#">
			<cfif compare(arguments.prefix,'')>
				<cfhttpparam type="URL" name="prefix" value="#arguments.prefix#"> 
			</cfif>
			<cfif compare(arguments.marker,'')>
				<cfhttpparam type="URL" name="marker" value="#arguments.marker#"> 
			</cfif>
			<cfif isNumeric(arguments.maxKeys)>
				<cfhttpparam type="URL" name="max-keys" value="#arguments.maxKeys#"> 
			</cfif>
			<!--- <cfhttpparam type="header" name="Range" value="0-60000"> --->
		</cfhttp>
		
		<cfset data = xmlParse(cfhttp.FileContent)>
		<cfset contents = xmlSearch(data, "//:Contents")>

		<!--- create array and insert values from XML --->
		<cfset allContents = arrayNew(1)>
		<cfloop index="x" from="1" to="#arrayLen(contents)#">
			<cfset content = contents[x]>
			<cfset thisContent = structNew()>
			<cfset thisContent.Key = content.Key.xmlText>
			<cfset thisContent.LastModified = content.LastModified.xmlText>
			<cfset thisContent.Size = content.Size.xmlText>
			<cfset arrayAppend(allContents, thisContent)>   
		</cfloop>

		<cfreturn allContents>
	</cffunction>
	
	
	<!--- <cffunction name="deleteBucket" access="public" output="false" returntype="boolean" 
				description="Deletes a bucket.">
		<cfargument name="bucketName" type="string" required="yes">	
		
		<cfset var signature = "">
		<cfset var dateTimeString = GetHTTPTimeString(Now())>
		<cfset var digest = 0 />
		<cfset var cfhttp = 0 />
		
		<!--- Create a canonical string to send based on operation requested ---> 
		<cfset var cs = "DELETE\n\n\n#dateTimeString#\n/#arguments.bucketName#"> 
		
		<!--- Replace "\n" with "chr(10) to get a correct digest --->
		<cfset var fixedData = replace(cs,"\n","#chr(10)#","all")> 
		
		<!--- Calculate the hash of the information ---> 
		<cf_hmac hash_function="sha1" data="#fixedData#" key="#variables.secretAccessKey#">
		
		<!--- fix the returned data to be a proper signature --->
		<cfset signature = ToBase64(Hex2Bin( digest ))>
		
		<!--- delete the bucket via REST --->
		<cfhttp method="DELETE" url="http://s3.amazonaws.com/#arguments.bucketName#" charset="utf-8">
			<cfhttpparam type="header" name="Date" value="#dateTimeString#">
			<cfhttpparam type="header" name="Authorization" value="AWS #variables.accessKeyId#:#signature#">
		</cfhttp>
		
		<cfreturn true>
	</cffunction>	 --->
	
	<cffunction name="CreateFolder" access="public" output="false" returntype="boolean" 
				description="Create a new folder">
		<cfargument name="bucketName" type="string" required="yes">
		<cfargument name="foldername" type="string" required="yes">
		<cfargument name="contentType" type="string" required="false" default="">
		<cfargument name="HTTPtimeout" type="numeric" required="no" default="300">
		
		<cfset var signature = "" />
		<cfset var binaryFileData = "" />
		<cfset var dateTimeString = GetHTTPTimeString(Now()) />
		<cfset var digest = 0 />
		<cfset var cfhttp = 0 />
		<cfset var a_str_http_response = '500 Error' />

		<!--- Create a canonical string to send --->
		<cfset var cs = "PUT\n\n#arguments.contentType#\n#dateTimeString#\n/#arguments.bucketName#/#arguments.foldername#_$folder$">
		
		<!--- Replace "\n" with "chr(10) to get a correct digest --->
		<cfset var fixedData = replace(cs,"\n","#chr(10)#","all")>
		
		<!--- Calculate the hash of the information --->
		<cf_hmac hash_function="sha1" data="#fixedData#" key="#variables.secretAccessKey#">
		
		<!--- fix the returned data to be a proper signature --->
		<cfset signature = ToBase64(Hex2Bin(digest))>
		
		<!--- Send the file to amazon. The "X-amz-acl" controls the access properties of the file --->
		<cfhttp method="PUT" url="http://s3.amazonaws.com/#arguments.bucketName#/#arguments.foldername#_$folder$" timeout="#arguments.HTTPtimeout#" result="cfhttp">
			  <cfhttpparam type="header" name="Authorization" value="AWS #variables.accessKeyId#:#signature#">
			  <cfhttpparam type="header" name="Content-Type" value="#arguments.contentType#">
			  <cfhttpparam type="header" name="Date" value="#dateTimeString#">
			  <!--- <cfhttpparam type="header" name="x-amz-acl" value="public-read">
			  <cfhttpparam type="body" value="#binaryFileData#"> --->
		</cfhttp> 		
		
		<cfreturn true />
	</cffunction>	
	
	<cffunction access="public" name="GenerateUploadInformation" output="false" returntype="struct"
				hint="collect all the necessary information for the real upload by one our satellites">
		<cfargument name="bucketName" type="string" required="true" />
		<cfargument name="remotepath" type="string" required="true"
			hint="path on S3" />
		<cfargument name="remotefilename" type="string" required="true" />
		<cfargument name="contentType" type="string" required="true" />
		
		<cfset var dateTimeString = GetHTTPTimeString(Now()) />		
		<!--- Create a canonical string to send --->
		<cfset var cs = "PUT\n\n#arguments.contentType#\n#dateTimeString#\n/#arguments.bucketName#/#arguments.remotepath#/#arguments.remotefilename#" />
		
		<!--- Replace "\n" with "chr(10) to get a correct digest --->
		<cfset var fixedData = replace(cs,"\n", chr(10),"all") />
		<cfset var signature = '' />
		<cfset var digest = 0 />
		<cfset var sURL = '' />
		<cfset var stReturn = {} />
		
		<cfif Len( arguments.bucketName ) IS 0>
			<cfthrow message="invalid bucketname" />
		</cfif>
		
		<!--- Calculate the hash of the information --->
		<cf_hmac hash_function="sha1" data="#fixedData#" key="#variables.secretAccessKey#">
		
		<!--- fix the returned data to be a proper signature --->
		<cfset signature = ToBase64(Hex2Bin( digest ))>
		
		<cfset sURL = "http://s3.amazonaws.com/#arguments.bucketName#/#arguments.remotepath#/#arguments.remotefilename#" />

		<cfset stReturn.remotepath = arguments.remotepath />
		<cfset stReturn.remotefilename = arguments.remotefilename />
		<cfset stReturn.contenttype = arguments.contenttype />		
		<cfset stReturn.bucketName = arguments.bucketName />
		<cfset stReturn.sURL = sURL />
		<cfset stReturn.sContentType = arguments.contentType />
		<cfset stReturn.sDate = dateTimeString />
		<cfset stReturn.Authorization = "AWS #variables.accessKeyId#:#signature#" />
		
		<cfreturn stReturn />
	</cffunction>
	
	<cffunction name="putObject" access="public" output="false" returntype="boolean" 
				description="Puts an object into a bucket.">
		<cfargument name="bucketName" type="string" required="yes">
		<cfargument name="fileKey" type="string" required="yes">
		<cfargument name="remotepath" type="string" required="true">
		<cfargument name="remotefilename" type="string" required="true">
		<cfargument name="contentType" type="string" required="yes">
		<cfargument name="HTTPtimeout" type="numeric" required="no" default="300">
		<cfargument name="bPublicReadable" type="boolean" required="false" default="false"
			hint="public readable?" />
		<cfargument name="CacheControl" type="string" required="false" default=""
			hint="Cache-Control" />
		
		<cfset var signature = "">
		<cfset var binaryFileData = "">
		<cfset var dateTimeString = GetHTTPTimeString(Now())>
		<cfset var digest = 0 />
		<cfset var cfhttp = 0 />
		<cfset var a_str_http_result = '500 Error' />
		<cfset var a_str_log_key = '' />
		<cfset var a_str_url = '' />
		<cfset var a_struct_log = StructNew() />
		
		<cfif arguments.bPublicReadable>
			<cfset var sACL = 'public-read' />
		<cfelse>
			<cfset var sACL = 'private' />		
		</cfif>

		<!--- Create a canonical string to send --->
		<cfset var cs = "PUT\n\n#arguments.contentType#\n#dateTimeString#\nx-amz-acl:#sACL#\n/#arguments.bucketName#/#arguments.remotepath#/#arguments.remotefilename#">
		
		<cfif Len( arguments.cacheControl )>
			<cfset cs = ReplaceNoCase( cs, '$CACHE_CONTROL$', 'cache-control:' & arguments.CacheControl & '\n') />
		<cfelse>
			<cfset cs = ReplaceNoCase( cs, '$CACHE_CONTROL$', '') />
		</cfif>
		
		<!--- Replace "\n" with "chr(10) to get a correct digest --->
		<cfset var fixedData = replace(cs,"\n","#chr(10)#","all")>
		
		<cfif Len( arguments.remotepath ) IS 0 OR Len( arguments.remotefilename ) IS 0>
			<cfthrow message="invalid S3 object path">
		</cfif>
		
		<cfif NOT FileExists( arguments.fileKey )>
			<cfthrow message="source file #arguments.fileKey# does not exist">
		</cfif>
		
		<!--- Calculate the hash of the information --->
		<cf_hmac hash_function="sha1" data="#fixedData#" key="#variables.secretAccessKey#">
		
		<!--- fix the returned data to be a proper signature --->
		<cfset signature = ToBase64(Hex2Bin( digest ))>
		
		<!--- Read the image data into a variable --->
		<cffile action="readBinary" file="#arguments.fileKey#" variable="binaryFileData">
		
		<cfset a_str_url = "http://s3.amazonaws.com/#arguments.bucketName#/#arguments.remotepath#/#arguments.remotefilename#" />
		
		<cfset a_str_log_key = S3Log( reqtype = 'putObject', url = a_str_url, Authorization = "#cs# AWS #variables.accessKeyId#:#signature#" ) />
		
		<!--- Send the file to amazon. The "X-amz-acl" controls the access properties of the file --->
		<cftry>
			<cfhttp method="PUT" url="#a_str_url#" timeout="#arguments.HTTPtimeout#" result="cfhttp">
				  <cfhttpparam type="header" name="Authorization" value="AWS #variables.accessKeyId#:#signature#" />
				  <cfhttpparam type="header" name="Content-Type" value="#arguments.contentType#" />
				  <cfhttpparam type="header" name="Date" value="#dateTimeString#" />
 				  <cfhttpparam type="header" name="x-amz-acl" value="#sACL#" />
	
				  <cfif Len( arguments.CacheControl ) GT 0>
				  	<cfhttpparam type="header" name="cache-control" value="#arguments.CacheControl#" />
				  </cfif>
				  
				  <cfhttpparam type="body" value="#binaryFileData#">
			</cfhttp>
			
			<cfset a_str_http_result = cfhttp.StatusCode />
			
			<!--- error? --->
			<cfif FindNoCase('200', a_str_http_result) IS 1>
			
				<!--- no, everything's fine --->	
				<cfset UpdateS3LogResult( entrykey = a_str_log_key, cfhttp_response = cfhttp, success = 1 ) />
			
			<cfelse>
			
				<!--- an error occured! --->
				<cfset a_struct_log.cfhttp = cfhttp />
				
				<cfset UpdateS3LogResult( entrykey = a_str_log_key, cfhttp_response = a_struct_log, success = 0 ) />				
			
			</cfif>
			
		<cfcatch type="any">
			
			<!--- a hard eception happend! --->
			<cfset a_struct_log.cfhttp = cfhttp />
			<cfset a_struct_log.cfcatch = cfcatch />
			
			<cfset UpdateS3LogResult( entrykey = a_str_log_key, cfhttp_response = a_struct_log, success = 0 ) />
			
			<cfrethrow>
			
			<cfset a_str_http_result = '500 Error' />
		</cfcatch>	
		</cftry>
		
		<!--- only true if 200 found --->
		<cfreturn (FindNoCase('200', a_str_http_result) IS 1) />
	</cffunction>	
		

	<cffunction name="getObject" access="public" output="false" returntype="string" 
				description="Returns a link to an object.">
		<cfargument name="bucketName" type="string" required="yes">
		<cfargument name="fileKey" type="string" required="yes">
		<cfargument name="minutesValid" type="string" required="false" default="60">
		
		<cfset var signature = "" />
		<cfset var timedAmazonLink = "" />
		<cfset var epochTime = DateDiff("s", DateConvert("utc2Local", "January 1 1970 00:00"), now()) + (arguments.minutesValid * 60) />
		<cfset var digest = 0 />

		<!--- Create a canonical string to send --->
		<cfset var cs = "GET\n\n\n#epochTime#\n/#arguments.bucketName#/#arguments.fileKey#">

		<!--- Replace "\n" with "chr(10) to get a correct digest --->
		<cfset var fixedData = replace(cs,"\n","#chr(10)#","all")>

		<!--- Calculate the hash of the information --->
		<cf_hmac hash_function="sha1" data="#fixedData#" key="#variables.secretAccessKey#">

		<!--- fix the returned data to be a proper signature --->
		<cfset signature = URLEncodedFormat(ToBase64(Hex2Bin( digest ))) />

		<!--- Create the timed link for the image --->
		<cfset timedAmazonLink = "http://s3.amazonaws.com/#arguments.bucketName#/#arguments.fileKey#?AWSAccessKeyId=#variables.accessKeyId#&Expires=#epochTime#&Signature=#signature#">

		<cfreturn timedAmazonLink />
	</cffunction>	
		

	<cffunction name="deleteObject" access="public" output="false" returntype="boolean" 
				description="Deletes an object.">
		<cfargument name="bucketName" type="string" required="yes">
		<cfargument name="fileKey" type="string" required="yes">

		<cfset var signature = "">
		<cfset var dateTimeString = GetHTTPTimeString(Now()) />
		<cfset var cfhttp = 0 />
		<cfset var digest = 0 />

		<!--- Create a canonical string to send based on operation requested ---> 
		<cfset var cs = "DELETE\n\napplication/x-www-form-urlencoded; charset=UTF-8\n#dateTimeString#\n/#arguments.bucketName#/#arguments.fileKey#"> 

		<!--- Replace "\n" with "chr(10) to get a correct digest --->
		<cfset var fixedData = replace(cs,"\n","#chr(10)#","all")> 

		<cflog application="false" file="s3_delete" text="fixedData: #fixedData#" />

		<!--- Calculate the hash of the information ---> 
		<cf_hmac hash_function="sha1" data="#fixedData#" key="#variables.secretAccessKey#">

		<!--- fix the returned data to be a proper signature --->
		<cfset signature = ToBase64(Hex2Bin(digest,"hex"))> 

		<!--- delete the object via REST --->
		<cfhttp method="DELETE" url="http://s3.amazonaws.com/#arguments.bucketName#/#arguments.fileKey#" result="cfhttp">
			<cfhttpparam type="header" name="Date" value="#dateTimeString#">
			<cfhttpparam type="header" name="Authorization" value="AWS #variables.accessKeyId#:#signature#">
		</cfhttp>
		
		<cflog application="false" file="s3_delete" text="#cfhttp.FileContent#" />

		<cfreturn true />
	</cffunction>
	
</cfcomponent>
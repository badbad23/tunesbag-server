<!--- //

	Module:		Converter
	Action:		
	Description:	
	
// --->

<cfcomponent displayName="converter" hint="convert file formats" output="false">
	
	<cfinclude template="/common/scripts.cfm">
	
	<cffunction access="public" name="init" returntype="any" output="false">
		<cfreturn this />
	</cffunction>
		
	<cffunction access="public" name="getStreamingJobConvertdata" output="false" returntype="struct">
		<cfargument name="jobkey" type="string" required="true">

		<cfset var stReturn = application.udf.GenerateReturnStruct() />
		
		<cfquery name="local.qSelectReq" datasource="mytunesbutlerlogging">
		SELECT
			req.handled,
			req.http_location,
			req.ip,
			req.bitrate,
			req.format,
			req.seconds,
			mediaitem.hashvalue,
			/* source format (e.g. mp3, m4a etc) */
			metainfo.format_ID AS srcformat_ID
		FROM
			streaming_convert_requests AS req
		LEFT JOIN
			mytunesbutleruserdata.mediaitems AS mediaitem ON (mediaitem.entrykey = req.mediaitemkey)
		LEFT JOIN
			mytunesbutleruserdata.mediaitems_metainformation AS metainfo ON (metainfo.mediaitemkey = req.mediaitemkey)
		WHERE
			req.entrykey = <cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.jobkey#" />
		;
		</cfquery>
		
		<cfif local.qSelectReq.recordcount IS 0>
			<cfreturn application.udf.SetReturnStructErrorCode(stReturn, 1002, 'Item does not exist' ) />
		</cfif>
		
		<!--- already used --->
		<cfif local.qSelectReq.handled IS 1>
			<cfreturn application.udf.SetReturnStructErrorCode(stReturn, 1002, 'Item does not exist' ) />
		</cfif>
		
		<cfset stReturn.source = local.qSelectReq.http_location />
		<cfset stReturn.srcformat_ID = local.qSelectReq.srcformat_ID />
		<cfset stReturn.address = local.qSelectReq.ip />
		<cfset stReturn.bitrate = local.qSelectReq.bitrate />
		<cfset stReturn.format = local.qSelectReq.format />
		<cfset stReturn.seconds = local.qSelectReq.seconds />
		<cfset stReturn.hashvalue = local.qSelectReq.hashvalue />
		
		<!--- TODO: set as handled! --->
		
		<!--- return success! --->
		<cfreturn application.udf.SetReturnStructSuccessCode(stReturn) />
	
	</cffunction>
	
	<cffunction access="public" name="getMediaItemAsCertainFormat" output="false" returntype="struct">
		<cfargument name="securitycontext" type="struct" required="true">
		<cfargument name="mediaitem" type="any" required="true"
			hint="the media item as transfer object">
		<cfargument name="deliver_info" type="struct" required="true"
			hint="the deliver information for the original item (location etc)">
		<cfargument name="format" type="string" required="true"
			hint="mp3,m4a,3gp,swf,aac">
		<cfargument name="bitrate" type="numeric" required="false" default="0"
			hint="convert to the given bitrate">
		<cfargument name="seconds" type="numeric" required="false" default="0"
			hint="how many seconds?">
			
		<cfset var stReturn = application.udf.GenerateReturnStruct() />
		<cfset var a_str_perl_script = '' />
		<cfset var a_str_jobkey = CreateUUID() />
		<cfset var a_pl_script_file = application.udf.GetTBTempDirectory() & 'output_ticket/' & a_str_jobkey & '_deliver.pl' />
		<cfset var a_str_contenttype = 'audio/mpeg' />
		<!--- <cfset var oTransfer = application.beanFactory.getBean( 'LogTransfer' ).getTransfer() />
		<cfset var a_db_item = oTransfer.new( 'logging.streaming_convert_requests' ) /> --->
		<cfset var a_map_check_item_exists = StructNew() />
		<cfset var a_str_ffmpeg_path = application.udf.GetSettingsProperty( 'ffmpeg', 'ffmpeg' ) />
		<cfset var a_str_wget_path = application.udf.GetSettingsProperty( 'wget', 'wget' ) />		
		<cfset var a_streaming = application.beanFactory.getBean( 'Server' ).getStreamingEngineAssignment( arguments.securitycontext ).sServerName />
		<!--- stage server type ... 0 = LIVE, > 0 ... a certain stage server (currently: 1=local, 2 = stage.tunesBag.com) --->
		<cfset var iStage = application.udf.GetSettingsProperty( 'StageServerType' , '0' ) />
		
		<!--- does the item exist? --->
		<cfif NOT arguments.mediaitem.getIsPersisted()>
			<cfreturn application.udf.SetReturnStructErrorCode(stReturn, 1002, 'Item does not exist' ) />
		</cfif>		

		<!--- set default format if nothing is given --->
		<cfif Len( arguments.format ) IS 0>
			<cfset arguments.format = 'mp3' />
		</cfif>
		
		<!--- return the jobkey and content type for all requests ... the default content-length IS -1 --->
		<cfset stReturn.jobkey = a_str_jobkey />
		<cfset stReturn.contenttype = a_str_contenttype />
		<cfset stReturn.contentlength = -1 />
						
		<!--- directory for convert scripts --->
		<cfif NOT DirectoryExists( GetDirectoryFromPath( a_pl_script_file ) )>
			<cfdirectory action="create" directory="#GetDirectoryFromPath( a_pl_script_file )#">
		</cfif>		
		
		<!--- we only support MP3 & aac at the moment --->
		<cfif ListFindNoCase( 'mp3,aac', arguments.format ) IS 0>
			<cfreturn application.udf.SetReturnStructErrorCode(stReturn, 4800, 'Unsupported format "' & arguments.format & '"' ) />
		</cfif>
		
		<!--- valid bitrates --->
		<cfif ListFindNoCase( '24,32,40,48,64,96,128,192,320,0', arguments.bitrate ) IS 0>
			<cfreturn application.udf.SetReturnStructErrorCode(stReturn, 4801, 'Unsupported bitrate - ' & arguments.bitrate ) />
		</cfif>
		
		<cfswitch expression="#arguments.format#">
			<cfcase value="mp3">
				<cfset a_str_contenttype = 'audio/mpeg' />
			</cfcase>
			<cfcase value="aac">
				<cfset a_str_contenttype = 'audio/aac' />
				
				<!--- default AAC to 48 ... 0 is not possible --->
				<cfif arguments.bitrate IS 0>
					<cfset arguments.bitrate = 48 />
				</cfif>
				
			</cfcase>
		</cfswitch>
		
		<!--- insert streaming request version --->
		<cfquery name="local.qInsertStreamingReq" datasource="mytunesbutlerlogging">
		INSERT INTO
			streaming_convert_requests
			(
			mediaitemkey,
			userkey,
			bitrate,
			format,
			http_location,
			ip,
			dt_created,
			entrykey,
			convertdone,
			seconds			
			)
		VALUES
			(
			<cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.mediaitem.getEntrykey()#" />,
			<cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.securitycontext.entrykey#" />,
			<cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.bitrate#" />,
			<cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.format#" />,
			<cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.deliver_info.location#" />,
			<cfqueryparam cfsqltype="cf_sql_varchar" value="#cgi.REMOTE_ADDR#" />,
			<cfqueryparam cfsqltype="cf_sql_timestamp" value="#Now()#" />,
			<cfqueryparam cfsqltype="cf_sql_varchar" value="#a_str_jobkey#" />,
			<cfqueryparam cfsqltype="cf_sql_integer" value="0" />,
			<cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.seconds#" />	
			)
		;
		</cfquery>
		
		<<!--- cfset a_db_item = oTransfer.new( 'logging.streaming_convert_requests' ) />
		<cfset a_db_item.setmediaitemkey( arguments.mediaitem.getEntrykey() ) />
		<cfset a_db_item.setuserkey( arguments.securitycontext.entrykey ) />
		<cfset a_db_item.setbitrate( arguments.bitrate ) />
		<cfset a_db_item.setformat( arguments.format ) />
		<cfset a_db_item.sethttp_location( arguments.deliver_info.location) />
		<cfset a_db_item.setip( cgi.REMOTE_ADDR ) />
		<cfset a_db_item.setdt_created( Now() ) />
		<cfset a_db_item.setentrykey( a_str_jobkey ) />
		<cfset a_db_item.setconvertdone( 0 ) />
		<cfset a_db_item.setseconds( arguments.seconds ) />

		<cfset oTransfer.save( a_db_item ) /> --->
		<!--- 
		<!--- create a perl script; return URL to perl script --->
<cfsavecontent variable="a_str_perl_script">#!/usr/bin/perl
$| =1;
print "Server: tunesBag Converter 0.1\n";
print "Content-Type: <cfoutput>#a_str_contenttype#</cfoutput>\n";
# print "Content-Length: -1\n";
print "Content-Transfer-Encoding: binary\n";
# last line with two breaks
print "Connection: close\n\n";

open(FILE_OUTPUT, "><cfoutput>#a_str_temp_output#</cfoutput>");
binmode FILE_OUTPUT;

# faq: http://www.perl.com/doc/FAQs/cgi/wwwsf5.html
# doc: http://perldoc.perl.org/functions/open.html

<cfif arguments.deliver_info.type IS 'file'>
<!--- read from file --->
open(FILE,"<cfoutput>#a_str_ffmpeg_path#</cfoutput> -f mp3 -i '<cfoutput>#arguments.deliver_info.location#</cfoutput>' -ab <cfoutput>#arguments.bitrate#</cfoutput>k -f <cfoutput>#arguments.format#</cfoutput> - 2>/dev/null |");
<cfelse>
<!---  we're reading from a http source--->
open(FILE,"<cfoutput>#a_str_wget_path#</cfoutput> '<cfoutput>#arguments.deliver_info.location#</cfoutput>' --quiet -O - 2>/dev/null | <cfoutput>#a_str_ffmpeg_path#</cfoutput> -y -f mp3 -i - -ab <cfoutput>#arguments.bitrate#</cfoutput>k -f <cfoutput>#arguments.format#</cfoutput> 2>/dev/null - |");
</cfif>

binmode FILE;

while($a=<FILE>) {
	print $a;
	print FILE_OUTPUT $a;
	}

close(FILE);
close( FILE_OUTPUT );

# tell the server that we're ready
system("<cfoutput>#a_str_wget_path#</cfoutput> 'http://<cfoutput>#cgi.SERVER_NAME#:#cgi.server_port#/james/?event=jobs.exec&type=items.createaltversiondone&jobkey=#UrlEncodedFormat( a_str_jobkey )#</cfoutput>' --quiet -O - >/dev/null 2>/dev/null");
</cfsavecontent>
		
		<!--- executable by everyone --->
		<cffile action="write" output="#a_str_perl_script#" mode="755" file="#a_pl_script_file#">
		
		<cfset stReturn.type = 'http' />
		<cfset stReturn.location = 'http://' & cgi.SERVER_NAME & ':' & cgi.SERVER_PORT & '/deliver/ticket/' & a_str_jobkey & '_deliver.pl' />
		<cfset stReturn.script = a_pl_script_file /> --->
		
		<cfset stReturn.type = 'http' />
		<!--- <cfset stReturn.location = 'http://' & cgi.SERVER_NAME & ':' & cgi.SERVER_PORT & '/deliver/ticket/' & a_str_jobkey & '_deliver.pl' /> --->
		
		<!--- <cfif ListFindNoCase( 'funkymusic,demo',arguments.securitycontext.username ) GT 0>
			<cfset a_streaming = '67.23.9.171' />
		</cfif> --->
		
		<cfset stReturn.location = 'http://' & a_streaming & '/deliver.php?jobkey=' & a_str_jobkey & '&mediaitemkey=' & mediaitem.getEntrykey() & '&rand=' & CreateUUID() & 'host=' & UrlEncodedFormat( cgi.SERVER_NAME ) & '&stage=' & iStage />
		<cfset stReturn.script = a_pl_script_file />
		
		<!--- development server --->
		<!--- <cfif application.udf.GetSettingsProperty( 'servertype', 0 ) IS 2>
			<cfset stReturn.location = 'http://' & cgi.SERVER_NAME & ':' & cgi.server_port & '/repository/php/deliver.php?stage=' & iStage & '&jobkey=' & a_str_jobkey & '&mediaitemkey=' & mediaitem.getEntrykey() & '&rand=' & CreateUUID() />
		</cfif> --->

		<cfreturn application.udf.SetReturnStructSuccessCode(stReturn) />
	
	</cffunction>
	

	<cffunction access="public" name="CreateConvertFileJob" output="false" returntype="struct"
			hint="reduce the bitrate of a MP3 file ... will work asynchronous">
		<cfargument name="userkey" type="string" required="true">
		<cfargument name="source" type="string" required="true">
		<cfargument name="operation" type="numeric" required="true"
			hint="the desired operation ... 1 = reduce bitrate; 2 = M4a2MP3, 3= WMA2MP3, 4 = OGG 2 MP3">
		<cfargument name="bitrate" type="numeric" default="192" required="false"
			hint="the target bitrate">
		<cfargument name="id3tags" type="struct" required="false" default="#StructNew()#"
			hint="the original data before the reduction of the bitrate (will save the file later with this data again)">
		
		<cfset var stReturn = application.udf.GenerateReturnStruct() />
		<!---  jobkey --->
		<cfset var a_str_jobkey = CreateUUID() />		
		<cfset var oTransfer = application.beanFactory.getbean( 'ContentTransfer' ).getTransfer() />
		<!--- is this file already under processing? --->
		<cfset var a_item = oTransfer.new( 'converter.convertjobs' ) />
		<!--- destination file --->
		<cfset var a_str_dest_file = application.udf.GetTBTempDirectory() & 'converted_' & CreateUUID() & '.mp3' />
		<cfset var a_str_dir = application.udf.GetTBTempDirectory() & 'converts/' />
		<cfset var stReturn_converter = 0 />
		
		<cfif NOT DirectoryExists( a_str_dir )>
			<cfdirectory action="create" directory="#a_str_dir#">
		</cfif>
		
		<!--- store job in the database --->
		<cfset a_item.setuserkey( arguments.userkey ) />
		<cfset a_item.setentrykey( a_str_jobkey ) />
		<cfset a_item.setdt_created( now() ) />
		<cfset a_item.setoperation( arguments.operation ) />
		<cfset a_item.setsourcefile( arguments.source ) />
		<cfset a_item.setdestfile( a_str_dest_file ) />
		<cfset a_item.settargetbitrate( arguments.bitrate ) />
		<cfset oTransfer.save( a_item ) />
		
		<cfset stReturn.jobkey = a_str_jobkey />
		
		<cfswitch expression="#arguments.operation#">
			<cfcase value="1">
			
				<!--- reduce bitrate of a MP3 --->
				<cfset stReturn_converter = CreateConvertJob(jobkey = a_str_jobkey,
							audiosourcetype = arguments.operation,
							source = arguments.source,
							destination = a_str_dest_file,
							currentbitrate = arguments.id3tags.bitrate,
							targetbitrate = arguments.bitrate ) />
							
				<cfif NOT stReturn_converter.result>
					<cfreturn stReturn_converter />
				</cfif>
			
			</cfcase>
			<cfcase value="2,3,4">
			
				<!--- m4a / WMA / OGG to MP3 --->
				<cfset stReturn_converter = CreateConvertJob(jobkey = a_str_jobkey,
							audiosourcetype = arguments.operation,
							source = arguments.source,
							destination = a_str_dest_file,
							currentbitrate = arguments.id3tags.bitrate,
							targetbitrate = arguments.bitrate ) />
							
				<cfif NOT stReturn_converter.result>
					<cfreturn stReturn_converter />
				</cfif>			
				
			
			</cfcase>
		</cfswitch>
		
		<!--- save script to database --->
		<cfset a_item.setshellscript( stReturn_converter.script ) />
		<cfset oTransfer.save( a_item ) />
		
		<cfreturn application.udf.SetReturnStructSuccessCode(stReturn) />		

	</cffunction>
	
	<cffunction access="public" name="NotifyConvertJobDone" output="false" returntype="void"
			hint="A converting job has been executed successfully">
		<cfargument name="jobkey" type="string" required="true">
		<cfargument name="ffmpegresult" type="numeric" required="true"
			hint="return code of ffmpeg">
		
		<cfset var oTransfer = application.beanFactory.getbean( 'ContentTransfer' ).getTransfer() />
		<cfset var a_item = oTransfer.get( 'converter.convertjobs', arguments.jobkey ) />
		<!--- set job done in the main table of incoming items --->
		<cfset var a_item_queue = oTransfer.readByProperty( 'storage.uploaded_items', 'convertjobkey', arguments.jobkey ) />
		<!--- the location of the ffmpeg logfile --->
		<cfset var a_str_ffmpeg_log_file = application.udf.GetTBTempDirectory() & 'converts/ffmpeg_log_' & arguments.jobkey & '.txt' />
		<cfset var a_str_ffmpeg_log = '' />
		<cfset var a_struct_id3 = 0 />
		
		<cfif NOT a_item.getIsPersisted()>
			<cfreturn />
		</cfif>
		
		<cfif FileExists( a_str_ffmpeg_log_file )>
			<cffile action="read" file="#a_str_ffmpeg_log_file#" variable="a_str_ffmpeg_log">
		</cfif>
		
		<!---  set done and store --->
		
		<!--- everything OK? --->
		<cfif arguments.ffmpegresult IS 0>
			<cfset a_item.setdone( 1 ) />
		</cfif>

		<!--- store output --->
		<cfset a_item.setffmpeglog( a_str_ffmpeg_log ) />
		<cfset a_item.seterrorno( arguments.ffmpegresult ) />
		<cfset oTransfer.update( a_item ) />
		
		<!--- job failed; exit --->
		<cfif NOT arguments.ffmpegresult IS 0>
			<cfreturn />
		</cfif>
				
		<cfif NOT a_item_queue.getisPersisted()>
			<cfreturn />
		</cfif>
		
		<!--- tag new converted file with original informations --->
		<cfwddx input="#a_item_queue.getoriginalid3tags()#" output="a_struct_id3" action="wddx2cfml">
		<cfset application.beanFactory.getBean( 'MP3ID3Parser' ).TagMP3FileWithGivenData( filename = a_item.getdestfile(), metainfo = a_struct_id3 ) />
		
		<!--- replace original incoming file with new, converted one and proceed; mark file already as processed --->
		<!--- re-throw in the queue with a higher priority! --->
		<cfset a_item_queue.setlocation( a_item.getdestfile() ) />
		<cfset a_item_queue.setpriority( 5 ) />
		<!--- set back to un-handled --->
		<cfset a_item_queue.sethandled( 0 ) />
		<!--- uploading ... --->
		<cfset a_item_queue.setstatus( 2 ) />
		
		<!--- already normalized, save status --->
		<cfset a_item_queue.setaudionormalizedone( 1 ) />
		
		<!--- delete old original file if it still exists --->
		<cfif FileExists( a_item.getsourcefile() )>
			<cffile action="delete" file="#a_item.getsourcefile()#">
		</cfif>
		
		<cfset oTransfer.save( a_item_queue ) />

	</cffunction>	
	

	<cffunction access="public" name="CreateConvertJob" output="false" returntype="struct"
			hint="create the bitrate reduction job">
		<cfargument name="audiosourcetype" type="numeric" required="true"
			hint="integer, type of source">
		<cfargument name="jobkey" type="string" required="true"
			hint="entrykey for this job">
		<cfargument name="source" type="string" required="true"
			hint="source file">
		<cfargument name="destination" type="string" required="true"
			hint="destination file">
		<cfargument name="currentbitrate" type="numeric" required="true"
			hint="the current bitrate">
		<cfargument name="targetbitrate" type="numeric" required="true"
			hint="target bitrate">
			
		<cfset var stReturn = application.udf.GenerateReturnStruct() />
		<cfset var a_str_sh_file = application.udf.GetTBTempDirectory() & 'converts/convert_' & arguments.audiosourcetype & '_format_' & arguments.jobkey & '.sh' />
		<cfset var a_str_sh_content = '' />
		<cfset var a_str_host_info = application.udf.getCurrentServerURI() />
		<cfset var a_str_ffmpeg_log_file = application.udf.GetTBTempDirectory() & 'converts/ffmpeg_log_' & arguments.jobkey & '.txt' />
		<cfset var a_str_target_bitrate = arguments.targetbitrate />
		
		<!--- do not create a file with a HIGHER bitrate --->
		<cfif (arguments.currentbitrate GT 0) AND (arguments.currentbitrate LT arguments.targetbitrate)>
			<cfset a_str_target_bitrate = arguments.currentbitrate />
		</cfif>
		

		<!--- write sh script:
		
		- convert
		
		let ffmpeg convert the file to WAV and lame do the encoding with VBR quality 2 and max bitrate given as argument
		write ffmpeg log to given file
		
		http://forum.doom9.org/archive/index.php/t-130499.html
		- notify engine that job is done
		
		LAME quality
		http://www.mpex.net/info/lame.html
		
		LAME commands
		http://lame.cvs.sourceforge.net/*checkout*/lame/lame/USAGE
		- exit
		
		OLD: <!--- nice -n 10 ffmpeg -y -i "#arguments.source#" -ab #a_str_target_bitrate#k #arguments.destination# 2> #a_str_ffmpeg_log_file# --->
		
		added nice to lame so that we take as few resources as possible
		 --->
<cfsavecontent variable="a_str_sh_content"><cfoutput>
ffmpeg -i "#arguments.source#" -vn -f wav - 2> #a_str_ffmpeg_log_file# | nice -n 19 lame -V 2 --abr #a_str_target_bitrate# - #arguments.destination#
FFMPEGRESULT=$?
mp3gain #arguments.destination#
wget "#a_str_host_info#/james/?event=jobs.exec&type=notify.converter.m4a.done&jobkey=#UrlEncodedFormat( arguments.jobkey )#&ffmpegresult=$FFMPEGRESULT" > /dev/null
</cfoutput></cfsavecontent>	

		<cfif FileExists( a_str_sh_file )>
			<cffile action="delete" file="#a_str_sh_file#">
		</cfif>

		<!--- <cffile action="write" output="#a_str_sh_content#" file="#a_str_sh_file#" addnewline="false" charset="utf-8"> --->
		
		<!--- write content to database for later execution --->
		
		<!--- <cfexecute name="sh" arguments="#a_str_sh_file#" timeout="0"></cfexecute>		 --->
		
		<cfset stReturn.script = Trim( a_str_sh_content ) />
	
		<cfreturn application.udf.SetReturnStructSuccessCode(stReturn) />

	</cffunction>
	
	<cffunction access="public" name="GetNextOpenConvertJobs" output="false" returntype="struct"
			hint="return the ONE next open convert jobs to execute">
				
		<cfset var q_select_open_convert_jobs = 0 />
		<cfset var stReturn = application.udf.GenerateReturnStruct() />
		<cfset var oTransfer = application.beanFactory.getbean( 'ContentTransfer' ).getTransfer() />
		<cfset var a_item = 0 />
		<cfset var a_str_sh_script = '' />
		<cfset var q_select_convert_active_processes = 0 />
		
		<!--- just get the NEXT job (ONE item max) --->
		<cfinclude template="queries/q_select_open_convert_jobs.cfm">

		<cfif q_select_open_convert_jobs.recordcount IS 0>
			<cfreturn application.udf.SetReturnStructErrorCode(stReturn, 999) />
		</cfif>
		
		<!--- more than 3 jobs should not be running at the same time ... --->
		<cfif q_select_convert_active_processes.count_open_jobs GT 2>
			<cfreturn application.udf.SetReturnStructErrorCode(stReturn, 999) />
		</cfif>
		
		<!--- loop over jobs --->
		<cfloop query="q_select_open_convert_jobs">

			<!--- set handled --->
			<cfset a_item = oTransfer.get( 'converter.convertjobs', q_select_open_convert_jobs.entrykey ) />
			<cfset a_item.sethandled( 1 ) />
			<cfset a_item.setdt_started( Now() ) />
			<cfset oTransfer.update( a_item ) />
			
			<!--- <cfset a_str_sh_script = a_str_sh_script & chr( 10 ) & q_select_open_convert_jobs.shellscript /> --->
		</cfloop>
		
		<cfset stReturn.q_select_open_convert_jobs = q_select_open_convert_jobs />
		
		<cfreturn application.udf.SetReturnStructSuccessCode(stReturn) />
			
	</cffunction>
	
</cfcomponent>
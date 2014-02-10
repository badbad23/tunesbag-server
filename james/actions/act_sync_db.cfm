<!--- //

	Module:		Synchronize database
	
	Moved from XML to JSON
	
// --->

<cfinclude template="/common/scripts.cfm">

<!--- the format to return ... XML or JSON --->
<cfset a_str_format = event.getArg( 'format', 'json' ) />
<cfset a_str_datatype = event.getArg( 'type', 'mediaitems' ) />
<cfset q_select_items = event.getArg( 'q_select_items' ) />
<cfset a_bol_preview = event.getArg( 'preview', false ) />

<!--- simple version of data (array) --->
<cfset arSimpleData = event.getArg( 'arSimpleData' ) />

<!--- plist info available? --->
<cfset stPlistInfo = event.getArg( 'a_struct_playlist' ) />

<cfif NOT IsQuery( q_select_items )>
	<cfset request.content.final = 'Invalid request.' />
	<cfexit method="exittemplate">
</cfif>

<!--- licence rights for this recordset --->

<cfset stLicencePermissions = event.getArg( 'stLicencePermissions', application.udf.getRecordsetDefaultLicencePermissionStructure() ) />

<!--- link information? --->
<cfset a_struct_unique_genres = event.getArg( 'a_struct_unique_genres' ) />

<cfset a_bol_use_custom_recordset_return_id = event.getArg( 'force_custom_recset_return_id', false )>

<cfif Len( event.getArg( 'librarykey' ) ) GT 0>
	<cfset a_str_lastkey = getProperty( 'beanFactory' ).getBean( 'MediaItemsComponent' ).GetLibraryLastkey( event.getArg( 'librarykey' )) />
<cfelse>
	<cfset a_str_lastkey = '' />
</cfif>

<cfswitch expression="#a_str_format#">

	<cfcase value="xml">
		
		<!--- return special format - XML for jw mp3 player --->
		<cfset event.setArg( 'contentType', 'text/xml; charset=UTF-8') />
		
		<cfsavecontent variable="request.content.final">
		<rss version="2.0" xmlns:media="http://search.yahoo.com/mrss/" xmlns:itunes="http://www.itunes.com/dtds/podcast-1.0.dtd">
			<channel>
				<title>Playlist</title>
				<link>http://www.tunesBag.com/</link>
				<description>Playlist</description>
				
				<cfoutput query="q_select_items">
		
				<cfset a_str_file = '/james/index.cfm?event=play.deliverfile&entrykey=' & urlencodedformat(q_select_items.entrykey) & '&preview=' & urlEncodedFormat( a_bol_preview ) />
		
				<item>
					<title>#XMLFormat( q_select_items.name )#<cfif Len( q_select_items.album ) GT 0> (#XMLFormat( q_select_items.album )#)</cfif></title>
					<guid>#XMLFormat( q_select_items.entrykey )#</guid>
					<author>#XMLFormat( q_select_items.artist )#</author>
					<enclosure url="#a_str_file#" type="audio/mpeg" />
				</item>
				</cfoutput>
		
			</channel>
		</rss>
		
		</cfsavecontent>

	</cfcase>
	
	<cfdefaultcase>
		<!--- default format, return everything as usual --->
		
		
		<!--- build the simple output
		
			force the ID to the entrykey of the library (provided in the URL)
			
			no distinct target, no column restriction
			
			--->
	
		<cfif a_bol_use_custom_recordset_return_id>
			<cfset a_str_force_id = 'ID_CUSTOM_' & application.udf.ReturnJSUUID() />
		<cfelse>
			<cfset a_str_force_id = 'ID_LIB_' & event.getArg( 'librarykey' ) />
		</cfif>
<!--- 
			<cfmail from="hp@inbox.cc" to="hp@inbox.cc" subject="stLicencePermissions before SimpleBuildOutput" type="html">
<cfdump var="#stLicencePermissions#">

</cfmail>
 --->
		<!--- set playlistkey if available --->
		<cfset a_struct_return = application.udf.SimpleBuildOutput( securitycontext = application.udf.GetCurrentSecurityContext(),
									query = q_select_items,
									type = 'internal',
									target = '',
									force_id = a_str_force_id,
									columns = '',
									lastkey = a_str_lastkey,
									setActive = false,
									playlistkey = event.getArg( 'playlistkey', '' ),
									options = '',
									stLicencePermissions = stLicencePermissions ) />
		<!--- <cfmail from="office@tunesbag.com" to="office@tunesbag.com" subject="stReturn" type="html">
		<cfdump var="#a_struct_return#">
		</cfmail> --->

		<!--- create a more simple structure with just data / meta and output --->
		<cfset a_struct_output = StructNew() />
		
		<!--- data --->
		<cfset a_struct_output.data_json = a_struct_return.data_json />
		
		<!--- meta (including permissions) --->
		<cfset a_struct_output.meta_json = a_struct_return.meta_json />
	
		<!--- html content if given --->
		<cfif StructKeyExists( a_struct_return, 'html_content' )>

			<!---  transport as meta data ... --->
			<cfset a_struct_output.html_content = a_struct_return.html_content />
		</cfif>
	
		<!--- return unique data --->
		<cfset a_struct_output.unique = StructNew() />
		
		<cfset q_select_libs = QueryNew( 'librarykey,index', 'varchar,integer' ) />
		<!--- event.getArg( 'librarykey' ) /> --->
		<!--- librarykeys --->
		<cfset a_struct_output.unique.librarykeys = q_select_libs />
		
		<cfif isStruct( a_struct_unique_genres )>
			<cfset a_struct_output.uniqueGenres = a_struct_unique_genres />
		</cfif>
		
		<!--- plist info available? --->
		<cfif IsStruct( stPlistInfo ) AND StructKeyExists( stPlistInfo, 'q_select_items' )>
			<cfset a_struct_output.plist = {} />
			
			<cfloop list="#stPlistInfo.q_select_items.columnlist#" index="sColumn">
				<cfset a_struct_output.plist[ sColumn ] = stPlistInfo.q_select_items[ sColumn ][ 1 ] />
			</cfloop>
			
		</cfif>
		
		<!--- JSON' it! --->
		<cfset request.content.final = SerializeJSON( a_struct_output ) />
	
	</cfdefaultcase>
</cfswitch>

<cffunction name="EscapeExtendedChars" returntype="string">
	<cfargument name="str" type="string" required="true">
	<cfset var buf = CreateObject("java", "java.lang.StringBuffer")>
	<cfset var len = Len(arguments.str)>
	<cfset var char = "">
	<cfset var charcode = 0>
	<cfset buf.ensureCapacity(JavaCast("int", len+20))>
	<cfif NOT len>
		<cfreturn arguments.str>
	</cfif>
	<cfloop from="1" to="#len#" index="i">
		<cfset char = arguments.str.charAt(JavaCast("int", i-1))>
		<cfset charcode = JavaCast("int", char)>
		<cfif (charcode GT 31 AND charcode LT 127) OR charcode EQ 10
			OR charcode EQ 13 OR charcode EQ 9>
				<cfset buf.append(JavaCast("string", char))>
		<cfelse>
			<cfset buf.append(JavaCast("string", "&##"))>
			<cfset buf.append(JavaCast("string", charcode))>
			<cfset buf.append(JavaCast("string", ";"))>
		</cfif>
	</cfloop>
	<cfreturn buf.toString()>
</cffunction>

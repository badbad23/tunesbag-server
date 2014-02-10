<!--- //

	Module:		Language CFC
	Action:		
	Description:Load language data
	
// --->

<cfcomponent displayname="Language CFC" output="false">

	<cffunction access="public" name="init" output="false" returntype="james.cfc.i18n.lang">
		
		<cfset var a_cmp_rb = application.beanfactory.getbean( 'javaRB' ) />
		<cfset var a_str_rb_path = GetDirectoryFromPath(expandpath( '/james/config/rb/' )) />
		<cfset var q_select_rb = 0 />
		<cfset var a_str_path = '' />
		<cfset var a_str_lang = '' />
		<cfset var a_str_base_file = a_str_rb_path & 'RB.properties' />
		
		<!--- get available resources --->
		<cfdirectory action="list" directory="#a_str_rb_path#" name="q_select_rb" filter="*.properties">
		
		<cflog application="false" file="tb_lang" log="Application" text="language files found count: #q_select_rb.recordcount#">

		<!--- loop over found lang data --->		
		<cflock scope="application" type="exclusive" timeout="30">
		
			<!--- re-create struct --->
			<cfset application.langdata = {} />
			
			<cfloop query="q_select_rb">

				<!--- extract language name --->				
				<cfset a_str_lang = ListFirst( q_select_rb.name, '.' ) />
				<cfset a_str_lang = ReplaceNoCase( a_str_lang, 'RB_', '' ) />
				
				<cflog application="false" file="tb_lang" log="Application" text="now loading language structure: #a_str_lang#">
				
				<!--- load language --->
				<cfset application.langdata[a_str_lang] = ReadResourceBundleFile( q_select_rb.directory &  '/' & q_select_rb.name ) />
			
			</cfloop>
		</cflock>
		
		<cfreturn this />
	</cffunction>
	
	<cffunction access="private" name="ReadResourceBundleFile" output="false" returntype="struct"
			hint="read the RB file">
		<cfargument name="rbFile" type="string" required="true">
		
		<cfset var stReturn = StructNew() />
		<cfset var cffile = 0 />
		<cfset var a_str_content = '' />
		<cfset var a_str_item = '' />
		<cfset var a_str_key = '' />
		<cfset var a_str_value = '' />
		<cfset var a_str_listlen = 0 />
		<cfset var oFileStream = 0 />
		<cfset var oInputStreamReader = 0 />
		<cfset var oProperties = createObject( 'java', 'java.util.Properties' ).init() />
		
		<cfscript>
		oProperties.put("input.encoding", "utf-8");
		oFileStream = createObject( 'java', 'java.io.FileInputStream').init( arguments.rbFile );
		oInputStreamReader = createObject( 'java', 'java.io.InputStreamReader').init (oFileStream, "UTF8");
		oProperties.load( oInputStreamReader);
		</cfscript>
		
		<cffile action="read" file="#arguments.rbFile#" charset="utf-8" variable="a_str_content" />
		
		<cfloop list="#a_str_content#" delimiters="#Chr(10)#" index="a_str_item">
			
			<cfset a_str_item = Trim( a_str_item ) />
			
			<!--- is a valid string and no comment --->
			<cfif Len( a_str_item ) GT 0 AND Left( a_str_item, 1 ) NEQ '##'>
			
				<cfset a_str_item = Trim( a_str_item ) />
				<cfset a_str_listlen = ListLen( a_str_item, '=' ) />
				
				<!--- set key / value and we're done --->
				<cfif a_str_listlen GTE 2>
					<cfset a_str_key = ListFirst( a_str_item, '=' ) />
					<cfset a_str_value = Mid( a_str_item, FindNoCase( '=', a_str_item) + 1, Len( a_str_item )) />
					
					<!--- use the java function --->
					<cfset stReturn[ a_str_key ] = oProperties.getProperty( a_str_key ) />
				</cfif>
			
			</cfif>
			
		</cfloop>
		
		<cfscript>
		oProperties = 0;
		oInputStreamReader.close();
		oFileStream.close();
		</cfscript>
		
		<cfreturn stReturn />

	</cffunction>
	
</cfcomponent>
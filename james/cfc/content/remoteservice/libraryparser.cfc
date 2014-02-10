<!--- //

	Module:		Handle media items of user (source = iTunes)
	Description:Parse libraries
	
// --->

<cfcomponent name="libraryparser" displayname="iTunes library handler component"output="false" extends="MachII.framework.Listener"
	hint="Handle media items from iTunes">
	
	<!--- include generic and custom scripts --->
	<cfinclude template="/common/scripts.cfm">

<cffunction name="init" access="public" output="false" returntype="james.cfc.content.remoteservice.libraryparser"> 
	<cfreturn this />
</cffunction> 

<cffunction access="public" name="ParseHashValueData" returntype="struct" hint="Parse an incoming hash data request and return statuscode based on
		existance of file" output="false">
	<cfargument name="filename" type="string" required="true"
		hint="filename of the XML file">
	<cfargument name="userkey" type="string" required="true"
		hint="userkey of the user requesting this action">
		
	<cfset var stReturn = application.udf.GenerateReturnStruct() />
	<cfset var FileReader = CreateObject("Java","java.io.FileReader") />
	<cfset var a_str_hash_value = '' />
	<cfset var tmp = 0 />
	<cfset var XMLStreamReader = 0 />
	<cfset var CFStAX = 0 />
	<cfset var a_int_index = 0 />
	<cfset var a_str_dao_path = '/tb_transfer_config/content/' />
	<cfset var q_select_hash_data = QueryNew('hashvalue,statuscode', 'VarChar,Integer') />	
	<cfset var XMLStreamConstantArray = 0 />
	<cfset var System = 0 />
	<cfset var File = 0 />
	<cfset var FileInputStream = 0 />
	<cfset var XMLInputFactory = 0 />
	<cfset var XMLStreamConstants = 0 />
	<cfset var Stream = 0 />
	<cfset var Transformer = 0 />
	<cfset var DOMSource = 0 />						
	<cfset var StreamResult = 0 />						
	<cfset var OutputKeys = 0 />						
	<cfset var event = 0 />									
	
	<!--- init SAX parser --->
	<cfscript>
	CFStAX 			= CreateObject('component','james.model.utils.CFStax').init();
	XMLStreamConstantArray  = CFStAX.getXMLStreamConstants() ;  
	System 			= CreateObject("java", "java.lang.System");
	File			= CreateObject("java", "java.io.File");
	FileInputStream = CreateObject("java", "java.io.FileInputStream");
	
	// StAX imports
	XMLInputFactory 	= CreateObject( "java", "org.codehaus.stax2.XMLInputFactory2").newInstance();
	XMLStreamConstants 	= CreateObject( "java", "javax.xml.stream.XMLStreamConstants");
	XMLStreamReader		= CreateObject( "java",	"org.codehaus.stax2.XMLStreamReader2");
		
	// Stuff to write output
	Stream 			= CreateObject( "java", "java.io.ByteArrayOutputStream").init(); 
	Transformer 	= CreateObject( "java", "javax.xml.transform.TransformerFactory").newInstance().newTransformer(); 
	DOMSource 		= CreateObject( "java", "javax.xml.transform.dom.DOMSource"); 
	StreamResult 	= CreateObject( "java", "javax.xml.transform.stream.StreamResult"); 
	OutputKeys 		= CreateObject( "java", "javax.xml.transform.OutputKeys");
	</cfscript>
 	
	<cfset fileReader.init(arguments.filename) />
	
	<cfset XMLStreamReader	= XMLInputFactory.createXMLStreamReader(fileReader) /> 
	
	<cfscript>
	// loop now through iTunes file
	for (event = XmlStreamReader.next(); event NEQ XMLStreamConstants.END_DOCUMENT; event = XmlStreamReader.next()) {
		  if (event IS XMLStreamConstants.START_ELEMENT)  //1
	      {
	      	if (CompareNoCase(XmlStreamReader.getLocalName(), 'HashValue') IS 0) {
	      		a_int_index = a_int_index + 1;
	      		}
	       } 
	      else if (event IS XMLStreamConstants.CHARACTERS) //4
	      {
	     	
	     	if (XmlStreamReader.hasText()) {
				// set hash value	     		
	     		a_str_hash_value = Trim(XmlStreamReader.getText());
	     		
	     		// set the default status code ... 404, not found  		
	     		QueryAddRow(q_select_hash_data);
	     		QuerySetCell(q_select_hash_data, 'hashvalue', lcase( a_str_hash_value ), q_select_hash_data.recordcount);
	     		QuerySetCell(q_select_hash_data, 'statuscode', 404, q_select_hash_data.recordcount);
	   
	     		}
	       }
	       else{
	       	// WriteOutput("Event: " & XMLStreamConstantArray[event] & "<br />");
	      }
	       
	      }
	</cfscript>
	
	<!--- return query --->
	<cfset stReturn.q_select_hash_data = q_select_hash_data />
	<cfreturn application.udf.SetReturnStructSuccessCode(stReturn) />
</cffunction>

<!--- <cffunction name="ParseLibrary" access="public" output="false" returntype="struct" hint="Parse a library and return uniformed format (We convert everything to a new pseudo style)">
	<cfargument name="filename" type="string" required="true"
		hint="name of the file containing the lib (e.g. XML of itunes)">
	<cfargument name="format" type="string" required="true"
		hint="format (currently itunes only)">
		
	<cfset var stReturn = application.udf.GenerateReturnStruct() />
	<cfset var a_cmp_parser = 0 />
	
	<cfif NOT FileExists(arguments.filename)>
		<cfreturn application.udf.SetReturnStructErrorCode(stReturn, 999) />
	</cfif>
	
	<cfswitch expression="#arguments.format#">
		<cfcase value="itunes">
			<!--- important: always create as own instance --->
			<cfset a_cmp_parser = CreateObject('component', 'james.model.content.libraryparser_itunes').init(filename = arguments.filename) />
			<cfreturn a_cmp_parser.InternalItunesLibraryParser() />
		</cfcase>
	</cfswitch>
	
</cffunction> --->


<cffunction access="public" name="CreateDefaultLibraryFormatXML" output="false" returntype="struct">
	<cfargument name="data" type="array" required="true">
	<cfset var stReturn = application.udf.GenerateReturnStruct() />
	
	<cfset stReturn.xml = arrayToXML(data = arguments.data, rootelement = 'data', itemelement = 'item') />
	
	<cfreturn stReturn />
	
</cffunction>

<cffunction name="arrayToXML" returnType="string" access="public" output="false" hint="Converts an array into XML">
	<cfargument name="data" type="array" required="true">
	<cfargument name="rootelement" type="string" required="true">
	<cfargument name="itemelement" type="string" required="true">
	<cfargument name="includeheader" type="boolean" required="false" default="true">

	<cfset var s = createObject('java','java.lang.StringBuffer').init() />
	<cfset var x = 0 />
	<cfset var a_str_key = '' />

	<cfif arguments.includeheader>
		<cfset s.append("<?xml version=""1.0"" encoding=""UTF-8""?>")>
	</cfif>

	<cfset s.append("<#arguments.rootelement#>") />

	<cfloop index="x" from="1" to="#arrayLen(arguments.data)#">
		
		<cfset s.append('<item>') />
		
		<cfloop list="#StructKeyList(arguments.data[x])#" index="a_str_key">
			<cfset a_str_key = lCase(a_str_key) />
			<cfset s.append("<#a_str_key#>#XMLFormat(arguments.data[x][a_str_key])#</#a_str_key#>")>
		</cfloop>
		
		<cfset s.append('</item>') />
		
	</cfloop>
	
	<cfset s.append("</#arguments.rootelement#>")>

	<cfreturn s.toString() />

</cffunction>

<!--- 

<!--- Fix damn smart quotes. Thank you Microsoft! --->

<!--- This line taken from Nathan Dintenfas' SafeText UDF --->

<!--- www.cflib.org/udf.cfm/safetext --->

<!--- I wrapped up both xmlFormat and this code together. --->

<cffunction name="safeText" returnType="string" access="private" output="false">

	<cfargument name="txt" type="string" required="true">

	<cfset arguments.txt = unicodeWin1252(arguments.txt)>

	<cfreturn xmlFormat(arguments.txt)>

</cffunction>



<!--- This method written by Ben Garret (http://www.civbox.com/) --->

<cffunction name="UnicodeWin1252" hint="Converts MS-Windows superset characters (Windows-1252) into their XML friendly unicode counterparts" returntype="string">

	<cfargument name="value" type="string" required="yes">

	<cfscript>

		var string = value;

		string = replaceNoCase(string,chr(8218),'&##8218;','all');	

		string = replaceNoCase(string,chr(402),'&##402;','all');		

		string = replaceNoCase(string,chr(8222),'&##8222;','all');	

		string = replaceNoCase(string,chr(8230),'&##8230;','all');	

		string = replaceNoCase(string,chr(8224),'&##8224;','all');	

		string = replaceNoCase(string,chr(8225),'&##8225;','all');	

		string = replaceNoCase(string,chr(710),'&##710;','all');		

		string = replaceNoCase(string,chr(8240),'&##8240;','all');	

		string = replaceNoCase(string,chr(352),'&##352;','all');		

		string = replaceNoCase(string,chr(8249),'&##8249;','all');	

		string = replaceNoCase(string,chr(338),'&##338;','all');		

		string = replaceNoCase(string,chr(8216),'&##8216;','all');	

		string = replaceNoCase(string,chr(8217),'&##8217;','all');

		string = replaceNoCase(string,chr(8220),'&##8220;','all');	

		string = replaceNoCase(string,chr(8221),'&##8221;','all');

		string = replaceNoCase(string,chr(8226),'&##8226;','all');	

		string = replaceNoCase(string,chr(8211),'&##8211;','all');	

		string = replaceNoCase(string,chr(8212),'&##8212;','all');	

		string = replaceNoCase(string,chr(732),'&##732;','all');		

		string = replaceNoCase(string,chr(8482),'&##8482;','all');	

		string = replaceNoCase(string,chr(353),'&##353;','all');	

		string = replaceNoCase(string,chr(8250),'&##8250;','all');	

		string = replaceNoCase(string,chr(339),'&##339;','all');		

		string = replaceNoCase(string,chr(376),'&##376;','all');		

		string = replaceNoCase(string,chr(376),'&##376;','all');		

		string = replaceNoCase(string,chr(8364),'&##8364','all');		

	</cfscript>
	
	<cfreturn string />

</cffunction> --->

</cfcomponent>
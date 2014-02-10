<!--- //

	Module:		iTunes library parsing engine
	Action:		
	Description:
// --->

<cfcomponent displayname="iTunes library parser">

<!--- filename of .xml --->
<cfset variables.a_str_filename = '' />
<!--- current item --->
<cfset variables.a_struct_item = StructNew() />
<!--- all items --->
<cfset variables.a_arr_items = ArrayNew(1) />

<cfinclude template="/common/scripts.cfm">

<cffunction access="public" name="init" returntype="libraryparser_itunes" output="false">
	<cfargument name="filename" type="string" required="true">
	
	<cfset variables.a_str_filename = arguments.filename />
	
	<cfreturn this />
</cffunction>

<cffunction access="public" name="InternalItunesLibraryParser" returntype="struct" hint="Parse the itunes lib file (XML)">
	
	<cfset var stReturn = application.udf.GenerateReturnStruct() />
	<cfset var FileReader = CreateObject("Java","java.io.FileReader") />
	<cfset var a_str_current_content = '' />
	<cfset var a_str_previous_content = '' />
	<cfset var XMLStreamReader = 0 />
	<cfset var CFStAX = 0 />
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
 	
	<cfset fileReader.init(a_str_filename) />
	
	<cfset XMLStreamReader	= XMLInputFactory.createXMLStreamReader(fileReader) /> 
	
	<cfscript>
	// loop now through iTunes file
	for (event = XmlStreamReader.next(); event NEQ XMLStreamConstants.END_DOCUMENT; event = XmlStreamReader.next()) {
	      if(event IS XMLStreamConstants.START_DOCUMENT) 
	      {
			// WriteOutput("Event: " & XMLStreamConstantArray[event] & "<br />");
			//WriteOutput("Start document: " & XmlStreamReader.getLocalName() & "<br />");
	      }
	      else if (event IS XMLStreamConstants.START_ELEMENT)  //1
	      {
	      	iTunesLibAnalyzeTag(XmlStreamReader.getLocalName());
	       } 
	      else if (event IS XMLStreamConstants.END_ELEMENT)  //2
			{
	       }
	      else if (event IS XMLStreamConstants.CHARACTERS) //4
	      {
	     	
	     	if (XmlStreamReader.hasText()) {
	     		// set currently active content to false
	     		a_str_previous_content = a_str_current_content;
	     		
	     		a_str_current_content = Urldecode(XmlStreamReader.getText());
	     		
	     		iTunesCheckContentTagElement(a_str_current_content, a_str_previous_content);
	     	}
	       }
	       else{
	       	// WriteOutput("Event: " & XMLStreamConstantArray[event] & "<br />");
	      }
	       
	      }
	</cfscript>
	
	<cfset stReturn.data = a_arr_items />
	<cfreturn application.udf.SetReturnStructSuccessCode(stReturn) />
</cffunction>

<!--- add an item to the lib --->
<cffunction access="private" name="iTunesAddItemToArray" output="false" returntype="void">
	<cfset var a_struct_add = Duplicate(variables.a_struct_item) />
	<cfset var a_new_index = (ArrayLen(a_arr_items) + 1) />
	<cfset var a_str_hash_value = '' />
	
	<cfif StructCount(a_struct_add) LT 3>
		<cfreturn />
	</cfif>
		
	<cfset a_str_hash_value = CalculateHashValueForItem(a_struct_item) />
	
	<!--- calculate HASH value ... --->
	<cfset variables.a_arr_items[a_new_index] = a_struct_add />
	
	<!--- use this filename for uploading ... --->
	<cfset variables.a_arr_items[a_new_index].md5 = a_str_hash_value />
	
</cffunction>


<cffunction access="public" name="CalculateHashValueForItem" output="false" returntype="string"
		hint="Calculate the MD5 value for a certain lib item">
	<cfargument name="item" type="struct" required="true"
		hint="structure holding the data">

	<cfset var a_str_md5 = '' />
	<cfset var a_str_text = '' />
	<cfset var a_bol_artist_exists = StructKeyExists(arguments.item, 'ar') />
	<cfset var a_bol_album_exists = StructKeyExists(arguments.item, 'al') />
	<cfset var a_bol_title_exists = StructKeyExists(arguments.item, 'tit') />
	<cfset var a_bol_year_exists = StructKeyExists(arguments.item, 'y') />
	<cfset var a_bol_size_exists = StructKeyExists(arguments.item, 's') />
	
	<!--- Format: Hash ( Lowercase ( Artist + Album + Title + Year + Filesize)) --->
	
	<cfif a_bol_artist_exists>
		<cfset a_str_text = arguments.item.ar />
	</cfif>
	
	<cfif a_bol_album_exists>
		<cfset a_str_text = a_str_text & arguments.item.al />
	</cfif>
	
	<cfif a_bol_title_exists>
		<cfset a_str_text = a_str_text & arguments.item.tit />
	</cfif>
	
	<cfif a_bol_year_exists>
		<cfset a_str_text = a_str_text & arguments.item.y />
	</cfif>
	
	<cfif a_bol_size_exists>
		<cfset a_str_text = a_str_text & arguments.item.s />
	</cfif>
	
	<cfset a_str_text = Lcase(a_str_text) />
	
	<cfreturn Hash(a_str_text) />

</cffunction>

<!--- analyze the current tag ... find out if it is an new item --->
<cffunction access="private" name="iTunesLibAnalyzeTag" output="false" returntype="void">
	<cfargument name="tag_name" type="string" required="true">
	
	<cfset var tmp = 0 />
	
	<cfif (CompareNoCase(arguments.tag_name, 'dict') IS 0)>
		<cfset tmp = iTunesAddItemToArray(a_struct_item) />
		<cfset tmp = StructClear(a_struct_item) />
	</cfif>
	
</cffunction>

<cffunction access="private" name="iTunesCheckContentTagElement" output="false" returntype="void"
	hint="check name of last key element and if match, set data to current value">
	<cfargument name="current_data" type="string" required="true">
	<cfargument name="previous_data" type="string" required="true">
	
	<cfscript>
	switch(arguments.previous_data) {
		case "Track ID": {
			// track ID
			variables.a_struct_item.tid = Trim(arguments.current_data);
			break;
			}
		case "Name": {
			// title
			a_struct_item.tit = Trim(current_data);
			break;
			}
		case "Artist": {
			// artist
			a_struct_item.ar = Trim(current_data);
			break;
			}		
		case "Album": {
			// album
			a_struct_item.al = Trim(current_data);
			break;
			}	
		case "Year": {
			// year
			a_struct_item.y = Trim(current_data);
			break;
			}			
		//case "Kind": {
			// a_struct_item.Kind = Trim(current_data);
		//	break;
		//	}		
		case "Size": {
			// size
			a_struct_item.s = Trim(current_data);
			break;
			}		
		case "Location": {
			a_struct_item.L_loc = Trim(current_data);
			break;
			}	
		case "Total Time": {
			// total time
			a_struct_item.tt = Trim(current_data);
			break;
			}
		case "Play Count": {
			// playcount
			a_struct_item.pc = Trim(current_data);
			break;
			}		
		case "Play Date UTC": {
			// last played
			a_struct_item.pd = Trim(current_data);
			break;
			}	
			
		case "Persistent ID": {
			// set persistent ID ... using LOCAL keyword to mark proprietary things
			a_struct_item.L_pid = Trim(current_data);
			break;
			}														
	}
	</cfscript>
	
</cffunction>

</cfcomponent>
<!---
Copyright: 2006 James C. Collins 

Please contact me at jimcollins@gmail.com if you wish to make other licensing arrangements
than those stated below. 

Licensing: 

For commercial use, please contact me for a version licensed under "", which allows commercial use and 
does not require ....

Licensed under the The GNU General Public License (GPL) Version 2, June 1991
http://www.opensource.org/licenses/gpl-license.php

This program is free software; you can redistribute it and/or modify it under the terms of the GNU 
General Public License as published by the Free Software Foundation; either version 2 of the License, 
or (at your option) any later version.

This program is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; 
without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. 
See the GNU General Public License for more details.

You should have received a copy of the GNU General Public License along with this program; 
if not, write to the Free Software Foundation, Inc., 59 Temple Place, 
Suite 330, Boston, MA 02111-1307 USA

Woodstox is included under the Free Software Foundation's LGPL 2.1
http://www.opensource.org/licenses/lgpl-license.php

CFStAX Version : 0.1 Beta 

Changelog:
02/20/06 v 0.1 

About:
CFStAX is a ColdFusion wrapper for Woodstox (http://woodstox.codehaus.org/). 
Woodstox is a "fast fully-validating StAX-compliant (JSR-173) Open Source XML-processor written in Java". 

Latest version: 
This file is posted on the following repositories:
SourceForge http://sourceforge.net/projects/cfsynergy

If you know of another repository that you would like to suggest,
please email me at jimcollins@gmail.com
Announcements and the latest version will be found at http://sourceforge.net/projects/cfsynergy
and my blog: http://www.cfsynergy.com

Credits:
Thanks to Tatu Saloranta <cowtowncoder@yahoo.com> for his work in developing Woodstox 
and his assistance in developing CFStAX. 

Bug Reports and Code suggestions: 
jimcollins@gmail.com

Usage: 
put the jar files on the classpath ie:
C:\JRun4\servers\cfusion\cfusion-ear\cfusion-war\WEB-INF\lib

<cfset CFStAX = CreateObject('component','CFStAX') />
<cfset CFStAX.init() />
--->
 
<cfcomponent displayname="CFStAX" hint="I am a CFC wrapper for the Woodstox StAX parser." 
			 name="CFStAX">

	<cffunction name="init">
		<cfscript>
		v	= variables; 
		// standard imports
		v.currentPath 		= replace(getCurrentTemplatePath(),getFileFromPath(getCurrentTemplatePath()),'');
		v.URL 				= CreateObject('java', 'java.net.URL'); 
		v.System			= CreateObject("java", "java.lang.System");
		v.File				= CreateObject("java", "java.io.File");
		v.FileInputStream 	= CreateObject("java", "java.io.FileInputStream");
		
		// StAX imports
		// requires that wstx-lgpl-2.9.1.jar and stax2.jar be on the classpath
		v.XMLInputFactory 		= CreateObject( "java", "org.codehaus.stax2.XMLInputFactory2").newInstance();
		v.XMLStreamReader		= CreateObject( "java",	"javax.xml.stream.XMLStreamReader");
		
		// cursor methods
		// event methods 
			
		// Objects to write output
		v.Stream 			= CreateObject( "java", "java.io.ByteArrayOutputStream").init(); 
		v.Transformer 		= CreateObject( "java", "javax.xml.transform.TransformerFactory").newInstance().newTransformer(); 
		v.DOMSource 		= CreateObject( "java", "javax.xml.transform.dom.DOMSource"); 
		v.StreamResult 		= CreateObject( "java", "javax.xml.transform.stream.StreamResult"); 
		v.OutputKeys 		= CreateObject( "java", "javax.xml.transform.OutputKeys");
		v.XMLOutputFactory 	= CreateObject( "java", "javax.xml.stream.XMLOutputFactory").newInstance();		
		return this;
		</cfscript>
	</cffunction>
		
	
	<cffunction name="getXMLStreamConstants" access="public" output="false" returntype="array">
	<!--- <cfscript>
		//Create Stream Constants 
		//Conversion from Java Object to Structure to keep CF happy 
		XMLStreamConstants = StructNew(); 
		XMLStreamConstantsObject 			= CreateObject( "java", "javax.xml.stream.XMLStreamConstants");
	    XMLStreamConstants.START_DOCUMENT	=	XMLStreamConstantsObject.START_DOCUMENT;
	    XMLStreamConstants.END_DOCUMENT		=	XMLStreamConstantsObject.END_DOCUMENT;
	    XMLStreamConstants.START_ELEMENT	=	XMLStreamConstantsObject.START_ELEMENT;
	    XMLStreamConstants.END_ELEMENT		=	XMLStreamConstantsObject.END_ELEMENT;
	    XMLStreamConstants.ATTRIBUTE		=	XMLStreamConstantsObject.ATTRIBUTE;
	    XMLStreamConstants.CHARACTERS		=	XMLStreamConstantsObject.CHARACTERS;
	    XMLStreamConstants.CDATA			=	XMLStreamConstantsObject.CDATA;
	    XMLStreamConstants.SPACE			=	XMLStreamConstantsObject.SPACE;
	    XMLStreamConstants.COMMENT			=	XMLStreamConstantsObject.COMMENT;
	    XMLStreamConstants.DTD				=	XMLStreamConstantsObject.DTD;
	   // XMLStreamConstants.START_ENTITY		=	XMLStreamConstantsObject.START_ENTITY;
	   // XMLStreamConstants.END_ENTITY		=	XMLStreamConstantsObject.END_ENTITY;
	    XMLStreamConstants.ENTITY_DECLARATION	=	XMLStreamConstantsObject.ENTITY_DECLARATION;
	    XMLStreamConstants.ENTITY_REFERENCE		=	XMLStreamConstantsObject.ENTITY_REFERENCE;
	    XMLStreamConstants.NAMESPACE			=	XMLStreamConstantsObject.NAMESPACE;
	    XMLStreamConstants.NOTATION_DECLARATION	=	XMLStreamConstantsObject.NOTATION_DECLARATION;
	    XMLStreamConstants.PROCESSING_INSTRUCTION	=	XMLStreamConstantsObject.PROCESSING_INSTRUCTION;
		return XMLStreamConstants;
	   </cfscript>  --->
	  <!--- <cfreturn CreateObject( "java", "javax.xml.stream.XMLStreamConstants") /> ---> 
	  
		<cfscript>
		v.XMLStreamConstantsObject = CreateObject( "java", "javax.xml.stream.XMLStreamConstants");
		XMLStreamConstants = ArrayNew(1);
		XMLStreamConstants[XMLStreamConstantsObject.START_DOCUMENT] 		= "START_DOCUMENT"; 
		XMLStreamConstants[XMLStreamConstantsObject.END_DOCUMENT] 			= "END_DOCUMENT";
		// XMLStreamConstants[XMLStreamConstantsObject.START_ENTITY] 		= "START_ENTITY";
		// XMLStreamConstants[XMLStreamConstantsObject.END_ENTITY] 			= "END_ENTITY";
		XMLStreamConstants[XMLStreamConstantsObject.START_ELEMENT] 			= "START_ELEMENT";
		XMLStreamConstants[XMLStreamConstantsObject.END_ELEMENT] 			= "END_ELEMENT";
		XMLStreamConstants[XMLStreamConstantsObject.ATTRIBUTE]				= "ATTRIBUTE";
		XMLStreamConstants[XMLStreamConstantsObject.CHARACTERS] 			= "CHARACTERS";
		XMLStreamConstants[XMLStreamConstantsObject.CDATA] 					= "CDATA";
		XMLStreamConstants[XMLStreamConstantsObject.SPACE]					= "SPACE";	
		XMLStreamConstants[XMLStreamConstantsObject.PROCESSING_INSTRUCTION] = "PROCESSING_INSTRUCTION";
		XMLStreamConstants[XMLStreamConstantsObject.COMMENT]				= "COMMENT"; 
		XMLStreamConstants[XMLStreamConstantsObject.ENTITY_REFERENCE] 		= "ENTITY_REFERENCE";
		XMLStreamConstants[XMLStreamConstantsObject.NOTATION_DECLARATION] 	= "NOTATION_DECLARATION";
		XMLStreamConstants[XMLStreamConstantsObject.ENTITY_DECLARATION] 	= "ENTITY_DECLARATION";
		XMLStreamConstants[XMLStreamConstantsObject.NAMESPACE] 				= "NAMESPACE";
		XMLStreamConstants[XMLStreamConstantsObject.DTD]					= "DTD"; 
		return XMLStreamConstants;
		</cfscript> 
	</cffunction>
	
	<cffunction name="getXMLStreamReader" access="public" output="false" returntype="any">
		<cfargument name="XMLfile" required="true" type="string" />
		<cfset var FileStream 			= "" />
		<cfset var staxXmlStreamReader	= "" />
		<!--- <cftry> --->
			<!--- make sure filepath is valid ---->
			<cfset FileStream 			= v.FileInputStream.init(xmlfile) />
			<cfset staxXmlStreamReader 		= v.XMLInputFactory.createXMLStreamReader(FileStream) />
			<cfreturn staxXMLStreamReader />
		<!--- <cfcatch>
			<cfreturn "ERROR">
		</cfcatch>
		</cftry> --->
	</cffunction>	
	
	<cffunction name="getXMLEventReader" access="public" output="false" returntype="">
		<cfargument name="XMLfile" required="true" type="string" />
		<!--- make sure filepath is valid ---->
		<cfset var FileStream 			= FileInputStream.init(xmlFile) />
		<cfset var staxXMLEventReader 	= XMLInputFactory.createXMLEventReader(FileStream) />
		<cfreturn staxXMLEventReader />
	</cffunction>	
	
	<cffunction name="getXMLStreamConstantValue" access="public" output="false" returntype="any">
		<cfargument name="ConstantName" required="true" type="string" />
		<cfset constantVal = "XMLStreamConstantsObject." & #UCase(arguments.ConstantName)# />
		<cfreturn Evaluate(constantVal)>
	</cffunction>	
	
	<cffunction name="getXMLOutputFactory" access="public" output="false" returntype="any">
		<cfreturn v.XMLOutputFactory>
	</cffunction>	
	
	<!--- Implement various StAX functions  --->
	
	<cffunction name="setXMLValidation" access="public" output="false" returntype="">
	<!--- This is used to force the parser to check if the XLM document is valid  --->
	<!--- This must be implemented by the StAX parser. Woodstox is fully validating  --->
	<!--- 	factory.setProperty("javax.xml.stream.isValidating", Boolean.TRUE); --->
	</cffunction>	
	
	<!--- Set the reporter if something screws up  --->
	<!--- factory.setXMLReporter(new XMLReporter() {
	  public void report(String message, String errorType,
    	Object relatedInformation, Location location) {
      	System.err.println("Problem in " + location.getLocationURI());
      	System.err.println("at line " + location.getLineNumber()
        + ", column " + location.getColumnNumber());
      	System.err.println(message);
  			}
		}); --->
	
	<!----- implement StAX getter methods ---->
	<!--- 
	public String  	getName()
	public String   getLocalName()
	public String   getNamespaceURI()
	public String   getText()
	public String   getElementText()
	public int      getEventType()
	public Location getLocation()
	public int      getAttributeCount()
	public QName    getAttributeName(int index)
	public String   getAttributeValue(String namespaceURI, String localName) 
	--->

	<cffunction name="getName" access="public" output="false" returntype="">
		<!--- check for the correct event type ----->
		<cftry>
			<cfreturn staxXmlReader.getName() />
		<cfcatch>
			<cfreturn "" />
		</cfcatch>
		</cftry>
	</cffunction>	

	<cffunction name="getLocalName" access="public" output="false" returntype="">
		<cftry>
			<cfreturn staxXmlReader.getLocalName() />
		<cfcatch>
			<cfreturn "" />
		</cfcatch>
		</cftry>
	</cffunction>

	<cffunction name="getNamespaceURI" access="public" output="false" returntype="">
		<cftry>
			<cfreturn staxXmlReader.getNamespaceURI() />
		<cfcatch>
			<cfreturn "" />
		</cfcatch>
		</cftry>
	</cffunction>	
	
	<cffunction name="getText" access="public" output="false" returntype="">
		<cftry>
			<cfreturn staxXmlReader.getText() />
		<cfcatch>
			<cfreturn "" />
		</cfcatch>
		</cftry>
	</cffunction>
	
	<cffunction name="getElementText" access="public" output="false" returntype="">
		<cftry>
			<cfreturn staxXmlReader.getElementText() />
		<cfcatch>
			<cfreturn "" />
		</cfcatch>
		</cftry>
	</cffunction>
	
	<cffunction name="getEventType" access="public" output="false" returntype="">
		<cftry>
			<cfreturn staxXmlReader.getEventType() />
		<cfcatch>
			<cfreturn "" />
		</cfcatch>
		</cftry>
	</cffunction>
	
	<cffunction name="getLocation" access="public" output="false" returntype="">
		<cftry>
			<cfreturn staxXmlReader.getLocation() />
		<cfcatch>
			<cfreturn "" />
		</cfcatch>
		</cftry>
	</cffunction>
	
	<cffunction name="getAttributeCount" access="public" output="false" returntype="">
		<cftry>
		<cfreturn staxXmlReader.getAttributeCount() />
		<cfcatch>
			<cfreturn "" />
		</cfcatch>
		</cftry>
	</cffunction>
	
	<cffunction name="getAttributeName" access="public" output="false" returntype="">
		<cfargument name="index" required="true" type="numeric" />
		<cftry>
		<cfreturn staxXmlReader.getAttributeName(index) />
		<cfcatch>
			<cfreturn "" />
		</cfcatch>
		</cftry>
	</cffunction>
	
	<cffunction name="getAttributeValue" access="public" output="false" returntype="string">
		<cfargument name="namespaceURI" required="true" type="string" />
		<cfargument name="localName" required="true" type="string" />
		<cftry>
			<cfreturn staxXmlReader.getAttributeValue(namespaceURI,localName) />
		<cfcatch>
			<cfreturn "" />
		</cfcatch>
		</cftry>
	</cffunction>
	
	<cffunction name="hasText" access="public" output="false" returntype="boolean">
		<cftry>
			<cfreturn staxXmlReader.hasText() />
		<cfcatch>
			<cfreturn FALSE />
		</cfcatch>
		</cftry>
	</cffunction>
	
	<cffunction name="hasNext" access="public" output="false" returntype="boolean">
		<cftry>
			<cfreturn staxXmlReader.hasNext() />
		<cfcatch>
			<cfreturn FALSE />
		</cfcatch>
		</cftry>
	</cffunction>
	
	<cffunction name="isCharacters" access="public" output="false" returntype="boolean">
		<cftry>
			<cfreturn staxXmlReader.isCharacters() />
		<cfcatch>
			<cfreturn FALSE />
		</cfcatch>
		</cftry>
	</cffunction>
	
	<cffunction name="isWhiteSpace" access="public" output="false" returntype="boolean">
		<cftry>
			<cfreturn staxXmlReader.isWhiteSpace() />
		<cfcatch>
			<cfreturn FALSE />
		</cfcatch>
		</cftry>
	</cffunction>
	
	
	<!--- Writer functions  --->
	
	<!--- 
		  
	OutputStream out = new FileOutputStream("data.xml");
	XMLOutputFactory factory = XMLOutputFactory.newInstance();
	XMLStreamWriter writer = factory.createXMLStreamWriter(out);
	
	You write data onto the stream by using various writeFOO methods: writeStartDocument, writeStartElement, writeEndElement, writeCharacters, writeComment, writeCDATA, etc. For example, these lines of code write a simple hello world document:
	
	writer.writeStartDocument("ISO-8859-1", "1.0");
	writer.writeStartElement("greeting");
	writer.writeAttribute("id", "g1");
	writer.writeCharacters("Hello StAX");
	writer.writeEndDocument();
	
	When you've finished creating the document, you want to flush and close the writer. This does not close the underlying output stream, so you'll need to close that too:
	
	writer.flush();
	writer.close();
	out.close(); 
	
	Example 2:
	File file = new File("atomoutput.xml");
	FileOutputStream out = new FileOutputStream(file);
	String now = new SimpleDateFormat().format(new Date(System.currentTimeMillis()));
	XMLOutputFactory factory = XMLOutputFactory.newInstance();
	XMLStreamWriter staxWriter = factory.createXMLStreamWriter(out);
	
	staxWriter.writeStartDocument("UTF-8", "1.0");
	// feed
	staxWriter.writeStartElement("feed");
	staxWriter.writeNamespace("", "http://www.w3.org/2005/Atom");
	
	// title
	StaxUtil.writeElement(staxWriter,"title","Simple Atom Feed File");
	// subtitle
	StaxUtil.writeElement(staxWriter,"subtitle","Using StAX to read feed files");
	// link
	staxWriter.writeStartElement("link");
	staxWriter.writeAttribute("href","http://example.org/");
	staxWriter.writeEndElement();
	// updated
	StaxUtil.writeElement(staxWriter,"updated",now);
	// author
	...
	// entry
	.. 
	staxWriter.writeEndElement(); // end feed
	staxWriter.writeEndDocument();
	staxWriter.flush();
	staxWriter.close();
	
	
	--->
</cfcomponent>
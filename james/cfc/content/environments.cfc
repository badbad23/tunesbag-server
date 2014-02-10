<!--- 
	
	environment management component
	
	provide several routines in order to allow custom branding of parts of the site
	
	the environment information is stored in an XML file

 --->

<cfcomponent output="false" hint="environment / branding component">
	
	<cfset variables.xEnvironmentXML = '' />
	<cfset variables.sCurrentEnvironment = '' />
	<cfset variables.stProperties = {} />

	<cffunction access="public" name="init" returntype="any" output="false"
			hint="constructor">
		<cfargument name="sXMLEnvironmentsFile" type="string" required="true"
			hint="The XML environment file (skin)" />
		
		<cfset var stCGI = Duplicate( cgi ) />
		<cfset var local = {} />
		
		<cfset variables.sXMLEnvironmentsFile = arguments.sXMLEnvironmentsFile />
		
		<cfif NOT FileExists( variables.sXMLEnvironmentsFile ) >
			
			<cfset variables.sXMLEnvironmentsFile = ExpandPath( arguments.sXMLEnvironmentsFile ) />
			
			<cfif NOT FileExists( variables.sXMLEnvironmentsFile )>
				
				<cfmail from="office@tunesbag.com" to="office@tunesBag.com" subject="sXMLEnvironmentsFile does not exist" type="html">
				<cfdump var="#variables.sXMLEnvironmentsFile#">
				</cfmail>
				<cfthrow message="environment file does not exist">
			</cfif>
		</cfif>
		
		<!--- parse the environment file --->
		<cfset setEnvironmentXMLContent( parseEnvironmentFile( sXMLEnvironmentsFile = variables.sXMLEnvironmentsFile )) />
		
		<!--- setup environment --->
		<cfset setupEnvironment( stCGI = stCGI ) />
		
		<cfreturn this />		
	</cffunction>
	
	<cffunction access="public" name="parseEnvironmentFile" output="false" returntype="xml">
		<cfargument name="sXMLEnvironmentsFile" type="string" required="true"
			hint="The XML environment file (skin)" />
		
		<cfset var local = {} />
		
		<cffile action="read" charset="utf-8" file="#arguments.sXMLEnvironmentsFile#" variable="local.sXMLEnvironment" />
		
		<cfif NOT IsXML( local.sXMLEnvironment )>
			<cfthrow message="invalid environment xml file" />
		</cfif>
		
		<cfreturn XMLParse( local.sXMLEnvironment ) />
		
	</cffunction>
	
	<cffunction access="private" name="applyDefaultPropertiesSets" output="false" returntype="struct"
			hint="Apply the items of a given default properties set to the return structure">
		<cfargument name="stDefaultPropertiesSets" type="struct" required="true"
			hint="The structure holding all properties of the default sets" />
		<cfargument name="stProperties" type="struct" required="true"
			hint="The properties structure to modify" />
		<cfargument name="xItemNode" type="XML" required="true"
			hint="the item node to parse for sets to apply" />
			
		<cfset var stReturn = arguments.stProperties />
		<cfset var local = {} />

		<cfif NOT StructKeyExists( arguments.xItemNode.XMLAttributes, 'importsets')>
			<cfreturn stReturn />		
		</cfif>
		
		<cfloop list="#arguments.xItemNode.XMLAttributes.importsets#" index="local.sSet">
			
			<cfif StructKeyExists( arguments.stDefaultPropertiesSets, local.sSet )>
				<cfset StructAppend( stReturn, arguments.stDefaultPropertiesSets[ local.sSet ], true ) />
			</cfif>
			
		</cfloop>

		<cfreturn stReturn />

	</cffunction>
	
	<cffunction access="public" name="setupEnvironment" output="false" returntype="struct">
		<cfargument name="stCGI" type="struct" required="true"
			hint="CGI environment variables" />
			
		<cfset var stReturn = {} />
		<cfset var local = {} />
		
		<cfset local.xDoc = getEnvironmentXMLContent() />
			
		<!--- store raw XML doc --->
		<cfset setEnvironmentXMLContent( local.xDoc ) />
		
		<!--- load the default properties sets --->
		<cfset local.aPropertiesSets = XMLSearch( local.xDoc, '//environments/propertiessets/set') />
		
		<cfset local.stPropertiesSets = {} />
		
		<cfloop from="1" to="#ArrayLen( local.aPropertiesSets )#" index="local.ii">
			<cfset local.stPropertiesSets[ local.aPropertiesSets[ local.ii ].XmlAttributes.name ] = parseProperties( local.aPropertiesSets[ local.ii ].xmlchildren ) />
		</cfloop>
		
		<!--- define the default properties struct --->
		<cfset local.stProperties = {} />
		
		<!--- load the default environment --->
		<cfset local.aDefault = XMLSearch( local.xDoc, '//environments/item[ @default = ''true'' ]') />
		
		<cfif ArrayLen( local.aDefault ) GT 0>
			
			<cfset local.stProperties = applyDefaultPropertiesSets( stDefaultPropertiesSets = local.stPropertiesSets,
							stProperties = local.stProperties,
							xItemNode = local.aDefault[1] ) />

			<!--- own properties defined? --->
			<cfif StructKeyExists( local.aDefault[1], 'properties' )>
				
				<!--- overwrite any previously set properties --->
				<cfset StructAppend( local.stProperties, parseProperties( local.aDefault[1].properties.XmlChildren ), true ) />
				
			</cfif>
			
			<!--- set the name --->
			<cfset setCurEnvironment( local.aDefault[ 1 ].XmlAttributes.name ) />

		</cfif>
				
		<!--- find out which environment we have --->
		<cfset local.xEnvironment = XMLSearch( local.xDoc, '//environments/item/applyto/cgi_server_name[ @value = ''' & arguments.stCGI.server_name & ''' ]/../..' ) />
		
		<!--- a custom environment has been found? --->
		<cfif ArrayLen( local.xEnvironment ) GT 0>
			
			<!--- apply default parameters? overwrite previous items! --->
			<cfset local.stProperties = applyDefaultPropertiesSets( stDefaultPropertiesSets = local.stPropertiesSets,
							stProperties = local.stProperties,
							xItemNode = local.xEnvironment[1] ) />
			
			<cfif StructKeyExists( local.xEnvironment[1], 'properties' )>
			
				<!--- overwrite any previously set properties --->
				<cfset StructAppend( local.stProperties, parseProperties( local.xEnvironment[1].properties.XmlChildren ), true ) />
								
			</cfif>
			
			<!--- set the name --->
			<cfset setCurEnvironment( local.xEnvironment[ 1 ].XmlAttributes.name ) />
		</cfif>
		
		<!--- environmentkey given? --->
		<cfif StructKeyExists( arguments.stCGI, 'environmentkey' ) AND Len( arguments.stCGI.environmentkey ) GT 0>
			
			<cfset local.xEnvironment = XMLSearch( local.xDoc, '//environments/item/applyto/cgi_environmentkey[ @value = ''' & arguments.stCGI.environmentkey & ''' ]/../..' ) />
			
			<!--- hit? --->
			<cfif ArrayLen( local.xEnvironment ) GT 0>
			
				<!--- apply further default parameters? --->
				<cfset local.stProperties = applyDefaultPropertiesSets( stDefaultPropertiesSets = local.stPropertiesSets,
						stProperties = local.stProperties,
						xItemNode = local.xEnvironment[1] ) />
				
				<cfif StructKeyExists( local.xEnvironment[1], 'properties')>
				
					<!--- overwrite any previously set properties --->
					<cfset StructAppend( local.stProperties, parseProperties( local.xEnvironment[1].properties.XmlChildren ), true ) />
						
				</cfif>
				
				<!--- set the name --->
				<cfset setCurEnvironment( local.xEnvironment[ 1 ].XmlAttributes.name ) />
				
			</cfif>
			
		</cfif>
		
		<!--- set variables --->
		<cfset setCustomVariables( local.stProperties ) />
		
		<!--- set simple version of properties --->
		<cfset setSimplePropertiesStruct( local.stProperties ) />
		
		<cfreturn stReturn />
		
	</cffunction>
	
	<cffunction access="private" name="setSimplePropertiesStruct" output="false" returntype="void"
			hint="store a simple version of the provided variables">
		<cfargument name="stProperties" type="struct" required="true" />
		
		<cfset var local = {} />
		
		<cfset StructClear( variables.stProperties ) />
		
		<cfloop list="#StructKeyList( arguments.stProperties )#" index="local.sKey">
			<cfset variables.stProperties[ arguments.stProperties[ local.sKey ].name ] = Duplicate( arguments.stProperties[ local.sKey ].value ) />
		</cfloop>
		
	</cffunction>
	
	<cffunction access="private" name="setCustomVariables" output="false" returntype="void"
			hint="set the vars stated in the environment file">
		<cfargument name="stProperties" type="struct" required="true" />
		
		<cfset var local = {} />
		
		<cfloop list="#StructKeyList( arguments.stProperties )#" index="local.sKey">
			
			<cfset local.stItem = arguments.stProperties[ local.sKey ] />
			
			<!--- set the variable? --->
			<cfif local.stItem.set>
				
				<cfswitch expression="#local.stItem.scope#">
					<cfcase value="server">
						<cfset local.stScope = server />
					</cfcase>
					<cfcase value="session">
						<cfset local.stScope = session />
					</cfcase>
					<cfcase value="client">
						<cfset local.stScope = client />
					</cfcase>
					<cfcase value="cluster">
						<cfset local.stScope = cluster />
					</cfcase>
					<cfcase value="request">
						<cfset local.stScope = request />
					</cfcase>
					<cfcase value="url">
						<cfset local.stScope = url />
					</cfcase>
					<cfcase value="attributes">
						<cfset local.stScope = attributes />
					</cfcase>
					<cfdefaultcase>
						<!--- variables scope --->
						<cfset local.stScope = variables />
					</cfdefaultcase>
				</cfswitch>
				
				<!--- set? yes, check the overwrite flag next --->
				<cfset local.bSet = true />
				
				<!--- do not overwrite? --->			
				<cfif NOT local.stItem.overwrite AND StructKeyExists( local.stScope, local.stItem.name )>
					<cfset local.bSet = false />
				</cfif>
				
				<cfif local.bSet>
					
					<cfswitch expression="#local.stItem.scope#">
						<cfcase value="session">
								<cfset session[ local.stItem.name ] = local.stItem.value />			
						</cfcase>
						<cfcase value="application">
							<cflock scope="application" timeout="5" type="exclusive">
								<cfset application[ local.stItem.name ] = local.stItem.value />			
							</cflock>
						</cfcase>
						<cfdefaultcase>
							<cfset local.stScope[ local.stItem.name ] = local.stItem.value />						
						</cfdefaultcase>
					</cfswitch>
					

				</cfif>
				
			</cfif>
			
		</cfloop>
		
	</cffunction>
	
	<!--- 
		parse the properties
		
		set the default structure for the properties and check for additional parameters
		like set, scope or overwrite
		
	 --->
	<cffunction access="private" name="parseProperties" output="false" returntype="struct"
			hint="parse the xml file for properties">
		<cfargument name="xProperties" type="XML" required="true" />
		
		<cfset var stReturn = {} />
		<cfset var local = {} />
		
		<cfloop from="1" to="#ArrayLen( arguments.xProperties )#" index="local.ii">
			
			<cfset local.stProperty = arguments.xProperties[ local.ii ].xmlattributes />

			<cfset stReturn[ local.stProperty.name ] = {
						name = local.stProperty.name,
						value = '',
						scope = '',
						set = false,
						type = 'simple',
						overwrite = false } />
						
			<!--- value to set (in the first release, we only support simple values) --->
			<cfif StructkeyExists( local.stProperty, 'value' )>
				<cfset stReturn[ local.stProperty.name ][ 'value' ] = local.stProperty.value />
			<cfelse>
				<cfset stReturn[ local.stProperty.name ][ 'type' ] = 'struct' />
				<cfset stReturn[ local.stProperty.name ][ 'value' ] = ConvertXmlToStruct( arguments.xProperties[ local.ii ], {} ) />
				
			</cfif>
			
			<!--- scope to write variable --->
			<cfif StructkeyExists( local.stProperty, 'scope' )>
				<cfset stReturn[ local.stProperty.name ][ 'scope' ] = local.stProperty.scope />
			</cfif>
			
			<!--- overwrite? --->
			<cfif StructkeyExists( local.stProperty, 'overwrite' )>
				<cfset stReturn[ local.stProperty.name ][ 'overwrite' ] = local.stProperty.overwrite />
			</cfif>
			
			<!--- set custom variable --->
			<cfif StructkeyExists( local.stProperty, 'set' )>
				<cfset stReturn[ local.stProperty.name ][ 'set' ] = local.stProperty.set />
			</cfif>
						
						
		</cfloop>
		
		<cfreturn stReturn />
		
	</cffunction>
	
	<cffunction access="private" name="setCurEnvironment" output="false" returntype="void">
		<cfargument name="sEnvironment" type="string" required="true" />
		
		<cfset variables.sCurrentEnvironment = arguments.sEnvironment />
	</cffunction>
	
	<cffunction access="public" name="getCurEnvironment" output="false" returntype="string"
			hint="Return the currently used branding / environment">
		<cfreturn variables.sCurrentEnvironment />
	</cffunction>
	
	<cffunction access="private" name="setEnvironmentXMLContent" output="false" returntype="void">
		<cfargument name="xDoc" type="xml" required="true" />
		
		<cfset variables.xEnvironmentXML = arguments.xDoc />
		
	</cffunction>
	
	<cffunction access="public" name="getProperties" output="false" returntype="struct">
		<cfreturn variables.stProperties />
	</cffunction>
	
	<cffunction access="public" name="getEnvironmentXMLContent" output="false" returntype="xml">
		<cfreturn variables.xEnvironmentXML />
	</cffunction>
	
	<!--- 
		return a certain property
	 --->
	<cffunction access="public" name="getProperty" output="false" returntype="any"
			hint="return a certain property">
		<cfargument name="sKey" type="string" required="true"
			hint="key of item" />
		<cfargument name="sDefault" type="any" required="false"
			hint="default value, when not set and property does not exist will return empty string" />
			
		<cfif StructKeyExists( variables.stProperties, arguments.sKey )>
			<cfreturn variables.stProperties[ arguments.sKey ] />
		<cfelseif StructKeyExists( arguments, 'sDefault' )>
			<cfreturn arguments.sDefault />	
		</cfif>
		
	</cffunction>
	
	<cffunction access="public" name="includeTemplate" returntype="string">
		<cfargument name="template" type="string" required="true" />
		
		<cfreturn arguments.template>
	</cffunction>

<!---

Author: Anuj Gakhar (All RIAForge projects by this author)
Last Updated: March 12, 2008 11:04 AM
Version: 1.0
Views: 9,696
Downloads: 1,842
Demo URL: http://www.anujgakhar.com/2007/11/05/coldfusion-xml-to-struct/
License: GPL (GNU General Public License)


 http://xml2struct.riaforge.org/ --->
<cffunction name="ConvertXmlToStruct" access="public" returntype="struct" output="true"
				hint="Parse raw XML response body into ColdFusion structs and arrays and return it.">
	<cfargument name="xmlNode" type="string" required="true" />
	<cfargument name="str" type="struct" required="true" />
	<!---Setup local variables for recurse: --->
	<cfset var i = 0 />
	<cfset var axml = arguments.xmlNode />
	<cfset var astr = arguments.str />
	<cfset var n = "" />
	<cfset var tmpContainer = "" />
	<cfset var atr = '' />
	<cfset var attrib = '' />

	<cfset axml = XmlSearch(XmlParse(arguments.xmlNode),"/node()")>
	<cfset axml = axml[1] />
	<!--- For each children of context node: --->
	<cfloop from="1" to="#arrayLen(axml.XmlChildren)#" index="i">
		<!--- Read XML node name without namespace: --->
		<cfset n = replace(axml.XmlChildren[i].XmlName, axml.XmlChildren[i].XmlNsPrefix&":", "") />
		<!--- If key with that name exists within output struct ... --->
		<cfif structKeyExists(astr, n)>
			<!--- ... and is not an array... --->
			<cfif not isArray(astr[n])>
				<!--- ... get this item into temp variable, ... --->
				<cfset tmpContainer = astr[n] />
				<!--- ... setup array for this item beacuse we have multiple items with same name, ... --->
				<cfset astr[n] = arrayNew(1) />
				<!--- ... and reassing temp item as a first element of new array: --->
				<cfset astr[n][1] = tmpContainer />
			<cfelse>
				<!--- Item is already an array: --->
				
			</cfif>
			<cfif arrayLen(axml.XmlChildren[i].XmlChildren) gt 0>
					<!--- recurse call: get complex item: --->
					<cfset astr[n][arrayLen(astr[n])+1] = ConvertXmlToStruct(axml.XmlChildren[i], structNew()) />
			<cfelse>
					<!--- else: assign node value as last element of array: --->
					<cfset astr[n][arrayLen(astr[n])+1] = axml.XmlChildren[i].XmlText />
			</cfif>
		<cfelse>
			<!---
				This is not a struct. This may be first tag with some name.
				This may also be one and only tag with this name.
			--->
			<!---
					If context child node has child nodes (which means it will be complex type): --->
			<cfif arrayLen(axml.XmlChildren[i].XmlChildren) gt 0>
				<!--- recurse call: get complex item: --->
				<cfset astr[n] = ConvertXmlToStruct(axml.XmlChildren[i], structNew()) />
			<cfelse>
				<cfif IsStruct(aXml.XmlAttributes) AND StructCount(aXml.XmlAttributes)>
					<cfset local.at_list = StructKeyList(aXml.XmlAttributes)>
					<cfloop from="1" to="#listLen(local.at_list)#" index="atr">
						 <cfif ListgetAt(local.at_list,atr) CONTAINS "xmlns:">
							 <!--- remove any namespace attributes--->
							<cfset Structdelete(axml.XmlAttributes, listgetAt(local.at_list,atr))>
						 </cfif>
					 </cfloop>
					 <!--- if there are any atributes left, append them to the response--->
					 <cfif StructCount(axml.XmlAttributes) GT 0>
						 <cfset astr['_attributes'] = axml.XmlAttributes />
					</cfif>
				</cfif>
				<!--- else: assign node value as last element of array: --->
				<!--- if there are any attributes on this element--->
				<cfif IsStruct(aXml.XmlChildren[i].XmlAttributes) AND StructCount(aXml.XmlChildren[i].XmlAttributes) GT 0>
					<!--- assign the text --->
					<cfset astr[n] = axml.XmlChildren[i].XmlText />
						<!--- check if there are no attributes with xmlns: , we dont want namespaces to be in the response--->
					 <cfset local.attrib_list = StructKeylist(axml.XmlChildren[i].XmlAttributes) />
					 <cfloop from="1" to="#listLen(local.attrib_list)#" index="attrib">
						 <cfif ListgetAt(local.attrib_list,attrib) CONTAINS "xmlns:">
							 <!--- remove any namespace attributes--->
							<cfset Structdelete(axml.XmlChildren[i].XmlAttributes, listgetAt(local.attrib_list,attrib))>
						 </cfif>
					 </cfloop>
					 <!--- if there are any atributes left, append them to the response--->
					 <cfif StructCount(axml.XmlChildren[i].XmlAttributes) GT 0>
						 <cfset astr[n&'_attributes'] = axml.XmlChildren[i].XmlAttributes />
					</cfif>
				<cfelse>
					 <cfset astr[n] = axml.XmlChildren[i].XmlText />
				</cfif>
			</cfif>
		</cfif>
	</cfloop>
	<!--- return struct: --->
	<cfreturn astr />
</cffunction>

</cfcomponent>
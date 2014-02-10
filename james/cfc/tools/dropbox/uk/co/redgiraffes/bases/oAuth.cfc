<cfcomponent displayname="oAuthBase" hint="oAuth Base Function" output="false">
	<cfscript>
		instance 						= {};
		instance.apiEndPoints			= {};
		//There are some objects that need to be created in order to use the oAuth Correctly
		instance.obj					= {};
		instance.obj.reqSigMethodSHA	= CreateObject("component", "james.cfc.tools.dropbox.org.riaforge.oauth.oauthsignaturemethod_hmac_sha1");
	</cfscript>
	
	<cffunction name="init"			displayName="init Function"	description="The Inital Funciton to load the CFC" access="public"	output="false" returntype="oAuth">
		<cfscript>
			//Lets create our consumer token which will be used throughout our calls
			instance.obj.consumerToken				= CreateObject("component", "james.cfc.tools.dropbox.org.riaforge.oauth.oauthconsumer").init(
																	  sKey 		= getInstanceValue('consumerKey')
																	, sSecret 	= getInstanceValue('consumerToken')
																	);
			return this;
		</cfscript>
	</cffunction>

	<!--- Public Functions --->	
	<cffunction name="getAuthorisation" displayname="getAuthorisation" description="Make the call to the Service for Authorisation to access the users account" access="public" output="false" returntype="struct">
		<cfargument name="callBackURL"	type="string" displayname="callBackURL" hint="The URL to hit on call back from authorisation" required="false" default="">
		<cfscript>
			var returnStruct					= {};
			var requestToken					= {};
			var oAuthKeys						= {};
			var callBackURLEncoded				= '';
			var AuthURL							= '';
			
			var requestabc							= oAuthAccessObject(  token		: ''
																	, secret	: ''
																	, httpurl	: getInstanceValue ('requestToken','apiEndPoints')
																	);

			requestToken						= rgudf_http(requestabc.getString(),'get');
			returnStruct['success']				= false;
			
			//If there is a string for auth token
			if (findNoCase("oauth_token",requestToken.filecontent)) {
				oAuthKeys	= rgudf_queryString2struct(requestToken.fileContent);
							
				if (arguments.callBackURL NEQ '') {
					arguments.callBackURL	= URLSessionFormat(arguments.callBackURL);
					callBackURLEncoded		= '&oauth_callback=' & URLEncodedFormat(arguments.callBackURL);
				}
				
				//Should get back oauth_token & oauth_token_secret
				AuthURL =  getInstanceValue ('authorization','apiEndPoints') & "?oauth_token=" & oAuthKeys.oauth_token & callBackURLEncoded;
				
				returnStruct['authURL']			= AuthURL;
				returnStruct['token']			= oAuthKeys.oauth_token;
				returnStruct['token_secret']	= oAuthKeys.oauth_token_secret;
				returnStruct['success']			= true;
			}
			else {
				structAppend (returnStruct,requestToken,false);
			}
			
			return returnStruct;
		</cfscript>
	</cffunction>

	<cffunction name="getAccessToken" displayname="getAccessToken" description="Gets an Access Token which can be stored and used for future access" access="public" output="false" returntype="Struct" >
		<cfargument name="requestToken"		type="string" required="true" displayname="requestToken"	hint="Request Token needed to get Access Token" />
		<cfargument name="requestSecret"	type="string" required="true" displayname="requestSecret"	hint="Request Token Secret needed to get Access Token" />
		
		<cfscript>
			var returnStruct		= {};
			var accessToken			= {};
			var oAuthKeys			= {};
			
			var requestabc				= oAuthAccessObject(  token		: arguments.requestToken
														, secret	: arguments.requestSecret
														, httpurl	: getInstanceValue ('accessToken','apiEndPoints')
														);
			
			returnStruct['success']	= false;
			accessToken				= rgudf_http(requestabc.toURL(),'get');
			
			//If there is a string for auth token
			if (findNoCase("oauth_token",accessToken.filecontent)) {
				oAuthKeys						= rgudf_queryString2struct(accessToken.fileContent);
				returnStruct['token']			= oAuthKeys.oauth_token;
				returnStruct['token_secret']	= oAuthKeys.oauth_token_secret;
				returnStruct['success']			= true;
			}
			return returnStruct;
		</cfscript>
	</cffunction>
	<!--- Private Functions --->
	<cffunction name="setInstanceValue" displayname="setInstanceValue" description="A function to set instance values pairs" access="private" output="false" returntype="void">
		<cfargument name="key" 		type="string" 	required="true" 	displayname="structKey" 	hint="Key in the instance scope to set"/>
		<cfargument name="value" 	type="string" 	required="true" 	displayname="structValue" 	hint="Value to set in the key"/>
		<cfargument name="subkey" 	type="string" 	required="false" 	displayname="subKey" 		hint="The name of a sub key in the instance scope" default=""/>
		
		<cfscript>
			var refInstance	= instance;
			if (arguments.subkey NEQ '') {
				refInstance	= instance[arguments.subkey];
			}
			refInstance[arguments.key]	= arguments.value;
					
		</cfscript>
	</cffunction>
	
	<cffunction name="getInstanceValue" displayname="getInstanceValue" description="A function to get instance values" access="private" output="false" returntype="any">
		<cfargument name="key" 		type="string" 	required="true" 	displayname="structKey" 	hint="Key in the instance scope to set"/>
		<cfargument name="subkey" 	type="string" 	required="false" 	displayname="subKey" 		hint="The name of a sub key in the instance scope" default=""/>
		
		<cfscript>
			var refInstance	= instance;
			if (arguments.subkey NEQ '') {
				refInstance	= instance[arguments.subkey];
			}
			return refInstance[arguments.key];
		</cfscript>
	</cffunction>
	
	<!--- A Function to call CFHTTP in CFSCRIPT for pre  CF9 support prefixed with RGUDF_ (Red Giragges User Defined Function) T0 stop clashes --->
	<cffunction name="rgudf_http" displayname="cfhttp" description="Allows Scripting of CFHTTP" access="private" output="false" returntype="Struct" >
		<cfargument name="url" 			type="string" 	displayname="url" 		hint="URL to request" 		required="true" />
		<cfargument name="method" 		type="string" 	displayname="method" 	hint="Method of HTTP Call" 	required="true" />
		<cfargument name="parameters" 	type="struct" 	displayname="method" 	hint="HTTP parameters" 		required="false" default="#structNew()#" />
		<cfset var returnStruct = {} />
		
		<cfhttp url="#arguments.url#" method="#arguments.method#" result="returnStruct">
			<cfif structKeyExists (arguments.parameters,'file') and arguments.method is 'post'>
				<cfhttpparam type="file" name="file" file="#arguments.parameters.file#" >
			</cfif>
		</cfhttp>
		<cfreturn returnStruct />
	</cffunction>
	
	<cffunction name="rgudf_queryString2struct" displayname="queryString2Struct" description="Turns a query stirng into a struct" access="private" output="false" returntype="Struct" >
		<cfargument name="queryString"	type="string" displayname="queryString" hint="Query String to Decihper" required="true" />
		<cfscript>
			var returnStruct 	= {};
			var localPair		= '';
			var localKey		= '';
			var localValue		= '';
			var	i				= 0;
			for(i=1; i LTE listLen(arguments.queryString,'&');i=i+1) {
				localPair	= listGetAt(arguments.queryString,i,'&');
				localKey	= listGetAt(localPair,1,'=');
				if (listlen(localPair,'=') EQ 2) {
					localValue	= listGetAt(localPair,2,'=');
				}
				returnStruct[localKey]	= localValue;
			}
			
			return returnStruct;
		</cfscript>
	</cffunction>
	
	<cffunction name="oAuthAccessObject" displayname="oAuthAccessObject" description="Generates an oAuth access object" access="private" output="false" returntype="Any" >
		<cfargument name="token"			type="string"	required="false"	displayname="accessToken"		hint="Access Token needed to get access to the users account"								default="" />
		<cfargument name="secret"			type="string"	required="false"	displayname="accessSecret"		hint="Access Token Secret needed to get access to the users account"	default="" />		
		<cfargument name="httpurl"			type="string"	required="false"	displayname="httpurl"			hint="Parameters for the url to the service"	default="#structNew()#" />
		<cfargument name="httpmethod"		type="string"	required="false"	displayname="httpmethod"		hint="HTTP Method"	default="GET" />
		<cfargument name="parameters"		type="struct"	required="false"	displayname="parameters"		hint="Parameters for the url to the service"	default="#structNew()#" />
		<cfscript>
			var returnStruct	= {};
			var authToken 		= '';
			var	requestabc		= 0;
			var request			= '';
			if (arguments.token neq '') {
				authToken		= CreateObject("component", "james.cfc.tools.dropbox.org.riaforge.oauth.oauthtoken").init(
																								  sKey 		= arguments.token
																								, sSecret 	= arguments.secret);
			}
			else {
				authToken		= CreateObject("component", "james.cfc.tools.dropbox.org.riaforge.oauth.oauthtoken").createEmptyToken();
			}
			
			
			requestabc				= CreateObject("component", "james.cfc.tools.dropbox.org.riaforge.oauth.oauthrequest").fromConsumerAndToken(
												  oConsumer 	= instance.obj.consumerToken
												, oToken 		= authToken
												, sHttpMethod 	= arguments.httpmethod
												, sHttpURL 		= arguments.httpurl
												, stParameters	= arguments.parameters
												);
			requestabc.signRequest(
							  oSignatureMethod 	= instance.obj.reqSigMethodSHA
							, oConsumer 		= instance.obj.consumerToken
							, oToken 			= authToken
							);
			return requestabc;
		</cfscript>
	</cffunction>
</cfcomponent>
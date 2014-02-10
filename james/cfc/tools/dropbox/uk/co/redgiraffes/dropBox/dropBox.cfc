<cfcomponent displayname="dropBoxCFC" hint="Interacts with the dropBox API Version 0" output="false" extends="james.cfc.tools.dropbox.uk.co.redgiraffes.bases.oAuth" >
	
	<cffunction name="init"			displayName="init Function"	description="The Inital Funciton to load the CFC" access="public"	output="false" returntype="dropBox">
		<cfargument name="consumerKey" 		type="string" 	required="true" 	displayname="consumerKey" 	hint="Your Consumer API key from the provider" />
		<cfargument name="consumerToken" 	type="string" 	required="true" 	displayname="consumerToken" 	hint="Your Consumer API token from the provider" />
		
		<cfscript>
			//Lets store the Consumer Key and Token for Later Reference
			setInstanceValue('consumerKey',			arguments.consumerKey);
			setInstanceValue('consumerToken',		arguments.consumerToken);
			//We have some API EndPoints to use so we'll set them here
			setInstanceValue('requestToken',		'http://api.dropbox.com/0/oauth/request_token',		'apiEndPoints');
			setInstanceValue('authorization',		'http://api.dropbox.com/0/oauth/authorize',			'apiEndPoints');
			setInstanceValue('accessToken',			'http://api.dropbox.com/0/oauth/access_token',		'apiEndPoints');
			setInstanceValue('accountInfo',			'http://api.dropbox.com/0/account/info',			'apiEndPoints');
			setInstanceValue('metadata',			'http://api.dropbox.com/0/metadata',				'apiEndPoints');
			setInstanceValue('search',				'https://api.dropbox.com/1/search',					'apiEndPoints');			
			setInstanceValue('files',				'http://api-content.dropbox.com/0/files/dropbox',	'apiEndPoints');
			setInstanceValue('thumbnails',			'http://api-content.dropbox.com/0/thumbnails/',		'apiEndPoints');
			setInstanceValue('fileopsCreateFolder',	'http://api.dropbox.com/0/fileops/create_folder',	'apiEndPoints');
			setInstanceValue('fileopsCopy',			'http://api.dropbox.com/0/fileops/copy',			'apiEndPoints');
			setInstanceValue('fileopsMove',			'http://api.dropbox.com/0/fileops/move',			'apiEndPoints');
			setInstanceValue('fileopsDelete',		'http://api.dropbox.com/0/fileops/delete',			'apiEndPoints');
			setInstanceValue('createAccount',		'http://api.dropbox.com/0/account',					'apiEndPoints');
			setInstanceValue('token',				'http://api.dropbox.com/0/token',					'apiEndPoints');
			super.init();
			return this;
		</cfscript>
	</cffunction>

	<!--- Public Functions --->	
	<cffunction name="createAccount" displayname="createAccount" description="Create a Users DropBox Account" access="public" output="false" returntype="Struct" >
		<cfargument name="email"			type="string" required="true" displayname="email"			hint="The email account of the user" />
		<cfargument name="password"			type="string" required="true" displayname="password"		hint="The password for the user" />
		<cfargument name="first_name"		type="string" required="true" displayname="first_name"		hint="The user's first name" />
		<cfargument name="last_name"		type="string" required="true" displayname="last_name"		hint="The user's last name" />
		
		
		<cfscript>
			var returnStruct	= {};
			var httpParameters	= {email=arguments.email,password=arguments.password,first_name=arguments.first_name,last_name=arguments.last_name};
			var requestabc			= oAuthAccessObject(  token		: ''
													, secret	: ''
													, httpurl	: getInstanceValue ('createAccount','apiEndPoints')
													, parameters: httpParameters
													);
			
			var accountInfo			= rgudf_http(requestabc.toURL(),'get');
			
			if (isJson(accountInfo.fileContent)) {
				returnStruct		= deserializeJSON(accountInfo.fileContent,true);
			}
			else {
				returnStruct		= accountInfo;
			}
			return returnStruct;
		</cfscript>
	</cffunction>

	<cffunction name="token" displayname="token" description="Gets the Users token Info" access="public" output="false" returntype="Struct" >
		<cfargument name="email"			type="string" required="true" displayname="email"			hint="The email account of the user" />
		<cfargument name="password"			type="string" required="true" displayname="password"		hint="The password for the user" />
		
		<cfscript>
			var returnStruct	= {};
			var httpParameters	= {email=arguments.email,password=arguments.password};
			var requestabc			= oAuthAccessObject(  token		: ''
													, secret	: ''
													, httpurl	: getInstanceValue ('token','apiEndPoints')
													, parameters: httpParameters
													);
			
			var accountInfo			= rgudf_http(requestabc.toURL(),'get');
			
			if (isJson(accountInfo.fileContent)) {
				returnStruct		= deserializeJSON(accountInfo.fileContent,true);
			}
			else {
				returnStruct		= accountInfo;
			}
			return returnStruct;
		</cfscript>
	</cffunction>
	
	<cffunction name="getAccountInfo" displayname="getAccountInfo" description="Gets the Users DropBox Account Info" access="public" output="false" returntype="Struct" >
		<cfargument name="accessToken"		type="string" required="true" displayname="accessToken"		hint="Access Token needed to get access to the users account" />
		<cfargument name="accessSecret"		type="string" required="true" displayname="accessSecret"	hint="Access Token Secret needed to get access to the users account" />
		<cfscript>
			var returnStruct	= {};
			var requestabc			= oAuthAccessObject(  token		: arguments.accessToken
													, secret	: arguments.accessSecret
													, httpurl	: getInstanceValue ('accountInfo','apiEndPoints')
													);
			
			var accountInfo			= rgudf_http(requestabc.toURL(),'get');
			
			returnStruct		= deserializeJSON(accountInfo.fileContent,true);
			
			return returnStruct;
		</cfscript>
	</cffunction>
	
	<cffunction name="getDBMetaData" displayname="getDBMetaData" description="The getDBMetaData API location provides the ability to retrieve file and folder metadata and manipulate the directory structure by moving or deleting files and folders." access="public" output="false" returntype="Struct" >
		<cfargument name="accessToken"		type="string" required="true"	displayname="accessToken"		hint="Access Token needed to get access to the users account" />
		<cfargument name="accessSecret"		type="string" required="true"	displayname="accessSecret"		hint="Access Token Secret needed to get access to the users account" />
		<cfargument name="path"				type="string" required="true"	displayname="path"				hint="Path for Folder to create"/>
		<cfscript>
			var returnStruct	= {};
			var httpParameters	= {root='dropbox',path=arguments.path};
			var requestabc			= oAuthAccessObject(  token		: arguments.accessToken
													, secret	: arguments.accessSecret
													, httpurl	: getInstanceValue ('metadata','apiEndPoints')
													, httpMethod: 'get'
													, parameters: httpParameters
													);
			
			var accountInfo			= rgudf_http(requestabc.toURL(),'get');
			
			returnStruct		= deserializeJSON(accountInfo.fileContent,true);
			
			return returnStruct;
		</cfscript>	
	</cffunction>	
	
	<cffunction name="getDBSearchResult" displayname="getDBSearchResult" description="Search the dropbox account for the given query string" access="public" output="false" returntype="array" >
		<cfargument name="accessToken"		type="string" required="true"	displayname="accessToken"		hint="Access Token needed to get access to the users account" />
		<cfargument name="accessSecret"		type="string" required="true"	displayname="accessSecret"		hint="Access Token Secret needed to get access to the users account" />
		<cfargument name="path"				type="string" required="true"	displayname="path"				hint="Root folder for search"/>
		<cfargument name="query"			type="string" required="true"	displayname="path"				hint="Search query"/>		
		<cfargument name="file_limit"		type="numeric" required="false" default="3000" />
		<cfscript>
			var returnStruct	= {};
			var httpParameters	= {root='dropbox',path=arguments.path,query=arguments.query};
			var requestabc			= oAuthAccessObject(  token		: arguments.accessToken
													, secret	: arguments.accessSecret
													, httpurl	: getInstanceValue ('search','apiEndPoints')
													, httpMethod: 'get'
													, parameters: httpParameters
													);
			
			var accountInfo			= rgudf_http(requestabc.toURL(),'get');
			
			returnStruct		= deserializeJSON(accountInfo.fileContent,true);
			
			return returnStruct;
		</cfscript>	
	</cffunction>	
	
	<cffunction name="getDBFile" displayname="getDBFile" description="The getDBFile Gets a File" access="public" output="false" returntype="Struct" >
		<cfargument name="accessToken"		type="string" required="true"	displayname="accessToken"		hint="Access Token needed to get access to the users account" />
		<cfargument name="accessSecret"		type="string" required="true"	displayname="accessSecret"		hint="Access Token Secret needed to get access to the users account" />
		<cfargument name="path"				type="string" required="true"	displayname="path"				hint="Path for Folder to create"/>
		<cfscript>
			var returnStruct	= {};
			var httpParameters	= {root='dropbox',path=arguments.path};
			var requestabc			= oAuthAccessObject(  token		: arguments.accessToken
													, secret	: arguments.accessSecret
													, httpurl	: getInstanceValue ('files','apiEndPoints')
													, httpMethod: 'get'
													, parameters: httpParameters
													);
			
			//accountInfo			= rgudf_http(requestabc.toURL(),'get');
			
			//returnStruct		= accountInfo;
			
			return { url = requestabc.toURL() };
		</cfscript>	
	</cffunction>	
	
	<cffunction name="postDBFile" displayname="postDBFile" description="The postDBFile API Uploads a file." access="public" output="false" returntype="Struct" >
		<cfargument name="accessToken"		type="string" 	required="true"	displayname="accessToken"		hint="Access Token needed to get access to the users account" />
		<cfargument name="accessSecret"		type="string" 	required="true"	displayname="accessSecret"		hint="Access Token Secret needed to get access to the users account" />
		<cfargument name="path"				type="string" 	required="true"	displayname="path"				hint="Path for Folder to create" />
		<cfargument name="file"				type="any" 		required="true"	displayname="file"				hint="The File to Upload" />
		<cfscript>
			var returnStruct	= {};
			var httpParameters	= {root='dropbox',path=arguments.path,file=arguments.file};
			var requestabc			= oAuthAccessObject(  token		: arguments.accessToken
													, secret	: arguments.accessSecret
													, httpurl	: getInstanceValue ('files','apiEndPoints')
													, httpMethod: 'post'
													, parameters: httpParameters
													);
			var accountInfo			= rgudf_http(requestabc.toURL(),'post',httpParameters);
			
			returnStruct		= accountInfo;
			
			return returnStruct;
		</cfscript>	
	</cffunction>
	
	<cffunction name="getDBThumbnail" displayname="getDBThumbnail" description="The getDBThumbnail Gets the thumbnail of a photo." access="public" output="false" returntype="Struct" >
		<cfargument name="accessToken"		type="string" required="true"	displayname="accessToken"		hint="Access Token needed to get access to the users account" />
		<cfargument name="accessSecret"		type="string" required="true"	displayname="accessSecret"		hint="Access Token Secret needed to get access to the users account" />
		<cfargument name="path"				type="string" required="true"	displayname="path"				hint="Path for Folder to create"/>
		<cfargument name="size"				type="string" required="true"	displayname="size"				hint="Size of the thumbnail to return"/>
		<cfscript>
			var returnStruct	= {};
			var httpParameters	= {root='dropbox',path=arguments.path,size=arguments.size};
			var requestabc			= oAuthAccessObject(  token		: arguments.accessToken
													, secret	: arguments.accessSecret
													, httpurl	: getInstanceValue ('thumbnails','apiEndPoints')
													, httpMethod: 'get'
													, parameters: httpParameters
													);
			
			var accountInfo			= rgudf_http(requestabc.toURL(),'get');
			
			returnStruct		= accountInfo;
			
			return returnStruct;
		</cfscript>	
	</cffunction>	
	
	<cffunction name="dbcreateFolder" displayname="dbcreateFolder" description="Create a Folder in your dropbox" access="public" output="false" returntype="Struct" >
		<cfargument name="accessToken"		type="string" required="true"	displayname="accessToken"		hint="Access Token needed to get access to the users account" />
		<cfargument name="accessSecret"		type="string" required="true"	displayname="accessSecret"		hint="Access Token Secret needed to get access to the users account" />
		<cfargument name="path"				type="string" required="true"	displayname="path"				hint="Path for Folder to create"/>
		<cfscript>
			var returnStruct	= {};
			var httpParameters	= {root='dropbox',path=arguments.path};
			var requesta			= oAuthAccessObject(  token		: arguments.accessToken
													, secret	: arguments.accessSecret
													, httpurl	: getInstanceValue ('fileopsCreateFolder','apiEndPoints')
													, httpMethod: 'get'
													, parameters: httpParameters
													);
			
			var accountInfo			= rgudf_http(requesta.toURL(),'get');
			
			returnStruct		= deserializeJSON(accountInfo.fileContent,true);
			
			return returnStruct;
		</cfscript>	
	</cffunction>
	
	<cffunction name="dbCopy" displayname="createFolder" description="Copy a File/Folder in your dropbox" access="public" output="false" returntype="Struct" >
		<cfargument name="accessToken"		type="string" required="true"	displayname="accessToken"		hint="Access Token needed to get access to the users account" />
		<cfargument name="accessSecret"		type="string" required="true"	displayname="accessSecret"		hint="Access Token Secret needed to get access to the users account" />
		<cfargument name="from_path"		type="string" required="true"	displayname="from_pat"			hint="Path for File/Folder to copy"/>
		<cfargument name="to_path"			type="string" required="true"	displayname="to_path"			hint="Path for File/Folder to copy to"/>
		<cfscript>
			var returnStruct	= {};
			var httpParameters	= {root='dropbox',from_path=arguments.from_path,to_path=arguments.to_path};
			var requesta			= oAuthAccessObject(  token		: arguments.accessToken
													, secret	: arguments.accessSecret
													, httpurl	: getInstanceValue ('fileopsCopy','apiEndPoints')
													, httpMethod: 'get'
													, parameters: httpParameters
													);
			
			var accountInfo			= rgudf_http(requesta.toURL(),'get');
			
			returnStruct		= deserializeJSON(accountInfo.fileContent,true);
			
			return returnStruct;
		</cfscript>	
	</cffunction>
	
	<cffunction name="dbMove" displayname="dbMove" description="Move a File/Folder in your dropbox" access="public" output="false" returntype="Struct" >
		<cfargument name="accessToken"		type="string" required="true"	displayname="accessToken"		hint="Access Token needed to get access to the users account" />
		<cfargument name="accessSecret"		type="string" required="true"	displayname="accessSecret"		hint="Access Token Secret needed to get access to the users account" />
		<cfargument name="from_path"		type="string" required="true"	displayname="from_pat"			hint="Path for File/Folder to copy"/>
		<cfargument name="to_path"			type="string" required="true"	displayname="to_path"			hint="Path for File/Folder to copy to"/>
		<cfscript>
			var returnStruct	= {};
			var httpParameters	= {root='dropbox',from_path=arguments.from_path,to_path=arguments.to_path};
			var requesta			= oAuthAccessObject(  token		: arguments.accessToken
													, secret	: arguments.accessSecret
													, httpurl	: getInstanceValue ('fileopsMove','apiEndPoints')
													, httpMethod: 'get'
													, parameters: httpParameters
													);
			
			var accountInfo			= rgudf_http(requesta.toURL(),'get');
			
			returnStruct		= deserializeJSON(accountInfo.fileContent,true);
			
			return returnStruct;
		</cfscript>	
	</cffunction>
	
	<cffunction name="dbDelete" displayname="dbDelete" description="Delete a File/Folder in your dropbox" access="public" output="false" returntype="Struct" >
		<cfargument name="accessToken"		type="string" required="true"	displayname="accessToken"		hint="Access Token needed to get access to the users account" />
		<cfargument name="accessSecret"		type="string" required="true"	displayname="accessSecret"		hint="Access Token Secret needed to get access to the users account" />
		<cfargument name="path"		type="string" required="true"	displayname="from_pat"			hint="Path for File/Folder to copy"/>
		<cfscript>
			var returnStruct	= {};
			var httpParameters	= {root='dropbox',path=arguments.path};
			var requesta			= oAuthAccessObject(  token		: arguments.accessToken
													, secret	: arguments.accessSecret
													, httpurl	: getInstanceValue ('fileopsDelete','apiEndPoints')
													, httpMethod: 'get'
													, parameters: httpParameters
													);
			
			var accountInfo			= rgudf_http(requesta.toURL(),'get');
			
			returnStruct		= deserializeJSON(accountInfo.fileContent,true);
			
			return returnStruct;
		</cfscript>	
	</cffunction>
	
	
</cfcomponent>
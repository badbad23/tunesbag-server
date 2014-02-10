<!--- //

	Module:		Logger compnent
	Description: 
	
// --->

<cfcomponent name="storage" displayname="Storage component"output="false" extends="MachII.framework.Listener" hint="Storage handler">
	
<cfinclude template="/common/scripts.cfm">

<cffunction name="configure" access="public" output="false" returntype="void" hint="Configures this listener as part of the Mach-II  framework"> 
	<!--- do nothing --->
</cffunction> 

<cffunction name="CheckStorageLimit" access="public" output="false" returntype="void" hint="Check if the storage of this user is full or not">
	<cfargument name="event" type="MachII.framework.Event" required="true" />
	
	<cfset event.setArg( 'a_struct_check_quota', getProperty( 'beanFactory' ).getBean( 'StorageComponent' ).GetQuotaDataOfUser( userkey = application.udf.GetCurrentSecurityContext().entrykey )) />
	
</cffunction>

<cffunction access="public" name="getDownloadTicketInfo" returntype="void" output="false"
		hint="return the download ticket info">
	<cfargument name="event" type="MachII.framework.Event" required="true" />
	
	<cfset var a_entrykey = event.getArg( 'entrykey' ) />
	<cfset var a_transfer = getProperty( 'beanFactory' ).getBean( 'LogTransfer' ).getTransfer() />
	<cfset var a_info = a_transfer.readByProperty( 'api.downloadtickets', 'entrykey', a_entrykey ) />
	
	<cfset event.setArg( 'a_info', a_info ) />

</cffunction>

<cffunction access="public" name="ImageCache" output="false" returntype="void"
		hint="Check if we should cache a requested image">
	<cfargument name="event" type="MachII.framework.Event" required="true" />
	
	<cfset var a_str_img = event.getArg( 'url' ) />
	<cfset var a_cmp_cache = getProperty( 'beanFactory' ).getBean( 'CacheComponent' ) />
	<cfset var a_str_hash_value = 0 /> 
	<cfset var a_struct_cache = 0 />
	<cfset var cfhttp = 0 />
	<cfset var a_str_temp_file = '' />
	
	<cfif Len( a_str_img ) IS 0>
		<cfreturn />
	</cfif>
	
	<!--- internal image ... --->
	<cfif FindNoCase( '/res/images/', a_str_img) IS 1>
		<cfreturn />
	</cfif>
	
	<!--- add amazon default host --->
	<cfif FindNoCase( 'http://', a_str_img ) IS 0>
		<cfset a_str_img = 'http://ec1.images-amazon.com/' & a_str_img />
	</cfif>
	
	<!--- calc hash value --->
	<cfset a_str_hash_value = Hash( a_str_img ) />
	
	<cfset a_str_temp_file = application.udf.GetTBTempDirectory() & 'imgcache/' & Left( a_str_hash_value, 2 ) & '/' & a_str_hash_value & '.jpg' />

	<!--- cache cmp --->	
	<cfset a_struct_cache = a_cmp_cache.CheckAndGetStoredElement( hashvalue = a_str_hash_value ) />
	
	<cfif a_struct_cache.result AND FileExists( a_struct_cache.data )>
		<cfset event.setArg( 'filename', a_struct_cache.data ) >
		<cfreturn />
	</cfif>
	
	<cfif NOT a_struct_cache.result>
		
		<!--- try to load image --->
		<cftry>
		<cflock name="#CreateUUID()#" type="exclusive" timeout="10">
			<cfhttp method="get" charset="utf-8" getasbinary="auto" redirect="false" useragent="Mozilla/4.0 (compatible; MSIE 6.0; Windows NT 5.1)" url="#a_str_img#" timeout="5"></cfhttp>
		</cflock>
		
		<cfcatch type="any">
			<cfreturn />
		</cfcatch>		
		</cftry>
	
		<!--- store information in cache --->	
		<cfset a_cmp_cache.StoreCacheElement( hashvalue = a_str_hash_value,
							description = 'img_cache_' & a_str_img,
							system = 'imgcache',
							data = a_str_temp_file ) />
							
		<cfif NOT DirectoryExists( GetDirectoryFromPath ( a_str_temp_file ))>
			<cfdirectory action="create" directory="#GetDirectoryFromPath( a_str_temp_file )#">
		</cfif>
		
		<cffile action="write" file="#a_str_temp_file#" output="#cfhttp.FileContent#">
		
	</cfif>
	
</cffunction>

</cfcomponent>
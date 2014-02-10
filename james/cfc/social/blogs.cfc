<!---

	blogs handling

--->


<cfcomponent output="false" displayname="blog handling">

	<cfinclude template="/common/scripts.cfm">
	
	<cffunction name="init" access="public" returntype="james.cfc.social.blogs" output="false">
		<cfreturn this />
	</cffunction>
	
	<cffunction access="public" name="GetBlogPosts" output="false" returntype="struct"
			hint="return blog posts (and cache the result for a while)">
		<cfargument name="blogkey" type="string" required="true"
			hint="entrykey of the blog">
		<cfset var stReturn = application.udf.GenerateReturnStruct() />
		<cfset var a_str_item_hash = Hash( arguments.blogkey ) />
		<cfset var q_select_items = 0 />
		<cfset var cfhttp = 0 />
		<cfset var a_cmp_cache = application.beanFactory.getBean( 'CacheComponent' ) />
		<cfset var a_struct_cache = a_cmp_cache.CheckAndGetStoredElement( hashvalue = a_str_item_hash ) />
		<cfset var a_str_url = 'http://blog.tunesbag.com/feeds/posts/default' />
		
		<!--- feedback items --->
		<cfif arguments.blogkey IS 'FEEDBACKITEMS'>
			<cfset a_str_url = 'http://feedback.tunesbag.com/index.atom' />
		</cfif>
		
		<!--- use cache result? --->
		<cfif a_struct_cache.result>
			<cfset stReturn.cached = true />
			<cfset stReturn.q_select_items = a_struct_cache.data />
			<cfreturn application.udf.SetReturnStructSuccessCode( stReturn ) />
		</cfif>
		
		<!--- TODO: load blog --->
		<!--- <cfreturn application.udf.SetReturnStructErrorCode(stReturn, 999) /> --->
		<cftry>
			

		<cflock name="lck_load_feed_#Hash( a_str_url )#" timeout="10" throwontimeout="true">
			<cffeed action="read" source="#a_str_url#" query="q_select_items">
		</cflock>
		
		<cfcatch type="any">
			<!--- <cfrethrow> --->
			<cfreturn application.udf.SetReturnStructErrorCode(stReturn, 999) />
		</cfcatch>
		</cftry>
		
		<cfset stReturn.q_select_items = q_select_items />
		
		<cfset stReturn.cached = false />
						
		<!--- store in cache ... reload every hour if needed --->
		<cfset a_cmp_cache.StoreCacheElement( hashvalue = a_str_item_hash,
								system = 'blogs',
								description = 'blog ' & a_str_url,
								data = q_select_items,
								expiresmin = '45' ) />	
		
		<cfreturn application.udf.SetReturnStructSuccessCode( stReturn ) />
		
	</cffunction>
	
</cfcomponent>
<!--- 

	flickr component
	
--->

<cfcomponent output="false" hint="component responsible for handling stuff with flickr">
	
	<cfinclude template="/common/scripts.cfm">
	
	<!--- set the apikey and secret --->
	<cfset variables.sFlickrAPIKEy = application.udf.GetSettingsProperty( 'FlickrAPIKey', '8ab7b6f356e6099bf9cd3f0b8108905b' ) />
	<cfset variables.sFlickrSecret = application.udf.GetSettingsProperty( 'FlickrSecret', '259609a927d984d8' ) />
	
	<cfset variables.oFlickr = 0 />
	<cfset variables.oIntif = 0 />
	<cfset variables.oPplif = 0 />
	<cfset variables.oTagif = 0 />
	<cfset variables.oPif = 0 />
	
	<cffunction access="public" name="init" returntype="any" hint="constructor">
		
		<!--- create basic flickr component --->		
		<cfset variables.oFlickr = createObject( "component", "CFlickr.Flickr" ).init( variables.sFlickrAPIKEy, variables.sFlickrSecret ) />
		
		<!--- <cfset variables.oIntif = variables.oFlickr.getInterestingnessInterface() /> --->
		<cfset variables.oPplif = variables.oFlickr.getPeopleInterface() />
		<!--- <cfset variables.oTagif = variables.oFlickr.getTagsInterface() /> --->
		<cfset variables.oPif = variables.oFlickr.getPhotosInterface() />
		
		<cfreturn this />
	</cffunction>
	
	<cffunction access="public" name="searchForImages" output="false" returntype="struct"
			hint="search for images, handle caching etc">
		<cfargument name="sSearch" type="string" required="true" />
		<cfargument name="sLicences" type="string" required="false" default="4,5,7"
			hint="list of licences requested" />
		<cfargument name="sSort" type="string" required="false" default="relevance" />
		<cfargument name="sPrivacy_filter" type="string" required="false" default="1"
			hint="only public images" />
		<cfargument name="sContent_type" type="string" required="false" default="1"
			hint="1 = images only, no screenshots" />
		<cfargument name="iHits" type="numeric" default="25" required="false"
			hint="number of hits to return" />
		<cfargument name="sExtras" type="string" default="license,owner_name" required="false"
			hint="default values" />
		<cfargument name="sLoadResolutions" type="string" required="false" default="SIZE_SMALL_SQUARE,size_medium"
			hint="sizes to load" />
			
		<!--- 0 All Rights Reserved
			  4 Attribution License http://creativecommons.org/licenses/by/2.0/
			  6 Attribution-NoDerivs License http://creativecommons.org/licenses/by-nd/2.0/
			  3 Attribution-NonCommercial-NoDerivs License http://creativecommons.org/licenses/by-nc-nd/2.0/
			  2 Attribution-NonCommercial License http://creativecommons.org/licenses/by-nc/2.0/
			  1 Attribution-NonCommercial-ShareAlike License http://creativecommons.org/licenses/by-nc-sa/2.0/
			  5 Attribution-ShareAlike License http://creativecommons.org/licenses/by-sa/2.0/
			  7 No known copyright restrictions http://www.flickr.com/commons/usage/
			  8 United States Government Work http://www.usa.gov/copyright.shtml --->
		
		<cfset var stReturn = application.udf.GenerateReturnStruct() />
		<cfset var ii = 0 />
		<cfset var qResult = QueryNew( 'title,username,id,size_medium,size_medium_square,size_large,license,userid', 'VarChar,Varchar,Varchar,Varchar,Varchar,Varchar,Varchar,Varchar' ) />
		<cfset var sItemHash = Hash( 'flickr_search' & arguments.sSearch & arguments.sLicences & arguments.sLoadResolutions & arguments.sSort & arguments.sPrivacy_filter & arguments.sContent_type & arguments.iHits & arguments.sExtras ) />
		<cfset var oCache = application.beanFactory.getBean( 'CacheComponent' ) />
		<cfset var stCache = oCache.CheckAndGetStoredElement( hashvalue = sItemHash ) />		
		
		<cfif Len( arguments.sSearch ) IS 0>
			<cfreturn application.udf.SetReturnStructErrorCode(stReturn, 500, 'Empty search string') />
		</cfif>
		
		<!--- stored in cache? --->
		<cfif stCache.result>
			<cfset stReturn.qResult = stCache.data />
			<cfreturn application.udf.SetReturnStructSuccessCode(stReturn) />
		</cfif>		
		
		<cftry>
			<cfset var oSearch = variables.oPif.search( text = arguments.sSearch,
						per_page = arguments.iHits,
						privacy_filter = arguments.sPrivacy_filter,
						content_type = arguments.sContent_type,
						license = arguments.sLicences,
						sort = arguments.sSort,
						extras = sExtras ) />
						
		<cfcatch type="any">
			<cfreturn application.udf.SetReturnStructErrorCode(stReturn, 500, 'Error on Flickr API request') />
		</cfcatch>		
		</cftry>
		
		<cfif oSearch.GETTOTAL() IS 0>
			<cfreturn application.udf.SetReturnStructErrorCode(stReturn, 404, 'No hits') />
		</cfif>
		
		<!--- get photos --->
		<cfset var aPhotos = oSearch.getPhotos() />
		
		<cfset QueryAddRow( qResult, ArrayLen( aPhotos )) />
		
		<!--- loop over images --->
		<cfloop from="1" to="#ArrayLen( aPhotos )#" index="ii">
			
			<cfset var stPhoto = aPhotos[ ii ] />
			
			<cfset var oOwner = variables.oPplif.getInfo(stPhoto.getOwner().getId()) />
			
			<cfset QuerySetCell( qResult, 'id', stPhoto.getId(), ii ) />
			<cfset QuerySetCell( qResult, 'title', stPhoto.gettitle(), ii ) />
			<cfset QuerySetCell( qResult, 'username', stPhoto.getOwner().getUsername(), ii ) />
			<cfset QuerySetCell( qResult, 'userid', stPhoto.getOwner().getId(), ii ) />
			
			<!--- load medium version --->
			<cfif ListFindNoCase( arguments.sLoadResolutions, 'size_medium')>
				<cfset QuerySetCell( qResult, 'size_medium', stPhoto.getPhotoUrl(stPhoto.size_medium), ii ) />
			</cfif>
		
			<!--- medium square version --->		
			<cfif ListFindNoCase( arguments.sLoadResolutions, 'size_medium_square')>
				<cfset QuerySetCell( qResult, 'size_medium_square', stPhoto.getPhotoUrl(stPhoto.SIZE_SMALL_SQUARE), ii ) />
			</cfif>
			
			<!--- large --->
			<cfif ListFindNoCase( arguments.sLoadResolutions, 'size_large')>
				<cfset QuerySetCell( qResult, 'size_large', stPhoto.getPhotoUrl(stPhoto.size_large), ii ) />
			</cfif>
			
			<cfset QuerySetCell( qResult, 'license', stPhoto.getlicense(), ii ) />
			
		</cfloop>
		
		<cfset stReturn.qResult = qResult />
		
		<!--- cache the generated structure to save IO --->
		<cfset oCache.StoreCacheElement( hashvalue = sItemHash,
							system = 'flickr',
							description = 'Flickr Search for ' & arguments.sSearch,
							data = qResult,
							expiresmin = 20 ) />		
		
		<cfreturn application.udf.SetReturnStructSuccessCode(stReturn) />

	</cffunction>
	
</cfcomponent>
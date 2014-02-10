<!--- 
	UDF
 --->

<cfif StructKeyExists( application, 'udf' ) AND NOT StructKeyExists( url, 'reinit')>
	<cfexit method="exittemplate" />
</cfif>

<cflock type="exclusive" name="lock_init_udf" timeout="30">

<!--- include scripts and store them as application.udf --->
<cfinclude template="/common/scripts.cfm" />


<cfset application.udf = {} />
<cfset application.udf.checkAddGACode = variables.checkAddGACode />
<cfset application.udf.GenerateReturnStruct = variables.GenerateReturnStruct />
<cfset application.udf.getHTTPDate = variables.getHTTPDate />
<cfset application.udf.getQCacheTimeSpan = variables.getQCacheTimeSpan />
<cfset application.udf.generatePublicPageHashKey = variables.generatePublicPageHashKey />
<cfset application.udf.writeDefaultImageContainer = variables.writeDefaultImageContainer />
<cfset application.udf.generatePseudoSecurityContext = variables.generatePseudoSecurityContext />
<cfset application.udf.generateGAURLParams = variables.generateGAURLParams />
<cfset application.udf.checkIsFriend = variables.checkIsFriend />
<cfset application.udf.GetEpochTime = variables.GetEpochTime />
<cfset application.udf.getCurrentServerURI = variables.getCurrentServerURI />
<cfset application.udf.getMBds = variables.getMBds />
<cfset application.udf.getRecordsetDefaultLicencePermissionStructure = variables.getRecordsetDefaultLicencePermissionStructure />
<cfset application.udf.FormatSecToHMS = variables.FormatSecToHMS />
<cfset application.udf.GetTBTempDirectory = variables.GetTBTempDirectory />
<cfset application.udf.GetJavaPath = variables.GetJavaPath />
<cfset application.udf.IsVirtualPlaylist = variables.IsVirtualPlaylist />
<cfset application.udf.GetLocalContentDirectory = variables.GetLocalContentDirectory />
<cfset application.udf.IsLoggedIn = variables.IsLoggedIn />
<cfset application.udf.GetCurrentSecurityContext = variables.GetCurrentSecurityContext />
<cfset application.udf.GetCurrentUserkey = variables.GetCurrentUserkey />
<cfset application.udf.GenerateS3PathInformation = variables.GenerateS3PathInformation />
<cfset application.udf.SetReturnStructErrorCode = variables.SetReturnStructErrorCode />
<cfset application.udf.SetReturnStructSuccessCode = variables.SetReturnStructSuccessCode />
<cfset application.udf.GenerateWSXML = variables.GenerateWSXML />
<cfset application.udf.ReturnJSUUID = variables.ReturnJSUUID />
<cfset application.udf.CheckZeroString = variables.CheckZeroString />
<cfset application.udf.ExtractEmailAdr = variables.ExtractEmailAdr />
<cfset application.udf.GetCurrentLanguage = variables.GetCurrentLanguage />
<cfset application.udf.GetLangVal = variables.GetLangVal />
<cfset application.udf.GetLangValSec = variables.GetLangValSec />
<cfset application.udf.GetLangVal_ReplaceVariables = variables.GetLangVal_ReplaceVariables />
<cfset application.udf.ClientBrowserLocale = variables.ClientBrowserLocale />
<cfset application.udf.si_img = variables.si_img />
<cfset application.udf.WriteSectionHeader = variables.WriteSectionHeader />
<cfset application.udf.GetSettingsProperty = variables.GetSettingsProperty />
<cfset application.udf.ShortenString = variables.ShortenString />
<cfset application.udf.WriteCommonErrorMessage = variables.WriteCommonErrorMessage />
<cfset application.udf.byteConvert = variables.byteConvert />
<cfset application.udf.DynamicPlaylistCriteriaExists = variables.DynamicPlaylistCriteriaExists />
<cfset application.udf.returnMySQLVariableName = variables.returnMySQLVariableName />
<cfset application.udf.SimpleBuildOutput = variables.SimpleBuildOutput />
<cfset application.udf.fileSize = variables.fileSize />
<cfset application.udf.stripHTML = variables.stripHTML />
<cfset application.udf.WriteDefaultUserNameProfileLink = variables.WriteDefaultUserNameProfileLink />
<cfset application.udf.getPlistImageLink = variables.getPlistImageLink />
<cfset application.udf.getUserImageLink = variables.getUserImageLink />
<cfset application.udf.getArtistImageByID = variables.getArtistImageByID />
<cfset application.udf.getArtistStripImg = variables.getArtistStripImg />
<cfset application.udf.getCommonArtistImageFilePath = variables.getCommonArtistImageFilePath />
<cfset application.udf.getCommonAlbumImageFilePath = variables.getCommonAlbumImageFilePath />
<cfset application.udf.getCommonAlbumPlaylistFilePath = variables.getCommonAlbumPlaylistFilePath />
<cfset application.udf.getCommonArtistStripFilePath = variables.getCommonArtistStripFilePath />
<cfset application.udf.getStripFilename = variables.getStripFilename />
<cfset application.udf.getLocalArtistImagePath = variables.getLocalArtistImagePath />
<cfset application.udf.getLocalFlickrArtistImagePath = variables.getLocalFlickrArtistImagePath />
<cfset application.udf.SessionManagementEnabled = variables.SessionManagementEnabled />
<cfset application.udf.IsDevelopmentServer = variables.IsDevelopmentServer />
<cfset application.udf.generateArtistURL = variables.generateArtistURL />
<cfset application.udf.getAudioFormatByExt = variables.getAudioFormatByExt />

</cflock>
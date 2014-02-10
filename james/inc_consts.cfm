<!--- 
	consts
 --->

<cfif StructKeyExists( application, 'const' ) AND NOT StructKeyExists( url, 'reinit')>
	<cfexit method="exittemplate" />
</cfif>

<cflock type="exclusive" name="lock_init_consts" timeout="30">

<cfset application.const = {} />
<cfset application.const.S_REPORTING_INDICATOR_COMBINED = '' />
<cfset application.const.S_REPORTING_INDICATOR_ADDED = 'added' />
<cfset application.const.S_REPORTING_INDICATOR_PLAYED = 'played' />
<cfset application.const.S_REPORTING_INDICATOR_FANS = 'fans' />
<cfset application.const.S_REPORTING_INDICATOR_RATINGS = 'ratings' />
<cfset application.const.S_REPORTING_INDICATOR_INFOASSETSHITS = 'infoassetshits' />

<cfset application.const.I_IMG_STRIP_TYPE_DEFAULT = 0 />
<cfset application.const.I_IMG_STRIP_TYPE_INVALID = -1 />

<cfset application.const.S_GATEWAY_REMOTECONTROL = 'tbremotecontrol' />

<!--- supported file formats --->
<cfset application.const.L_SUPPORTED_FILE_FORMATS = 'mp3,wma,m4a,ogg,flac' />

<!--- user types --->
<cfset application.const.I_USER_STATUS_CONFIRMED = 1 />
<cfset application.const.I_USER_STATUS_UNCONFIRMED = 0 />

<!--- app keys --->
<cfset application.const.S_APPKEY_IPHONE = 'ACD78BD2-CAAE-9AA4-3FB1EC5A52249D62' />
<cfset application.const.S_APPKEY_ANDROID = 'A6C60612-0197-496B-BB9124666128745F' />
<cfset application.const.S_APPKEY_DESKTOPRADIO = 'DDD78BD2-CAAE-9AA4-3FB1EC5A52249D88' />
<cfset application.const.S_APPKEY_SQUEEZENETWORK = 'DDA79BD2-CAAE-9AA4-3FB1EC7A52249D88' />
<cfset application.const.S_APPKEY_BOXEE = '7706ECA1-F205-9A74-1C41F00931943688' />

<!--- sync source status --->
<cfset application.const.I_SYNC_SOURCE_STATUS_DEFAULT = 0 />
<cfset application.const.I_SYNC_SOURCE_STATUS_IN_SYNC = 10 />
<cfset application.const.I_SYNC_SOURCE_STATUS_ERROR = 999 />

<!--- service names --->
<cfset application.const.S_SERVICE_DROPBOX = 'dropbox' />

<!--- play context --->
<cfset application.const.I_PLAY_CONTEXT_DEFAULT = 0 />
<cfset application.const.I_PLAY_CONTEXT_AUTOSELECTED = 1 />
<cfset application.const.I_PLAY_CONTEXT_USER_PLIST = 3 />
<cfset application.const.I_PLAY_CONTEXT_RECOMMENDATION = 4 />

<!--- default plists --->
<cfset application.const.I_DEFAULT_PLIST_TOPRATED = -1 />
<cfset application.const.I_DEFAULT_PLIST_RECENTLYPLAYED = -2 />
<cfset application.const.I_DEFAULT_PLIST_FOLLOWSTREAM = -3 />
<cfset application.const.I_DEFAULT_PLIST_RECENTLYADDED = -4 />
<cfset application.const.I_DEFAULT_PLIST_RECOMMENDATIONS = -5 />

<!--- Play parameters --->
<cfset application.const.S_PLAY_PARAM_FORCE_RETURN_FILESIZE = 'returnfilesize' />

<!--- Preference keys --->
<cfset application.const.S_PREF_SQBN_STREAMING_BITRATE = 'sqbn_streaming_bitrate' />
<cfset application.const.S_PREF_DROPBOX_INTRO_SENT = 'dropboxintrosent' />

<!--- default images --->
<cfset application.const.S_DEFAULT_COVERART = 'http://cdn.tunesBag.com/images/skins/default/coverDefault.png' />

<!--- audio formats --->
<cfset application.const.I_AUDIO_FORMAT_UNKNOWN = 0 />
<cfset application.const.I_AUDIO_FORMAT_MP3 = 1 />
<cfset application.const.I_AUDIO_FORMAT_WMA = 5 />

<cfset application.const.I_AUDIO_FORMAT_M4A = 10 />

<!--- special formats --->
<cfset application.const.I_AUDIO_FORMAT_OGG = 20 />
<cfset application.const.I_AUDIO_FORMAT_SWF = 50 />
<cfset application.const.I_AUDIO_FORMAT_FLAC = 60 />

<!--- dropbox --->
<cfset application.const.I_DROPBOX_ITEM_FILE = 1 />
<cfset application.const.I_DROPBOX_ITEM_DIRECTORY = 2 />

<!--- total number of directories to scan per user --->
<cfset application.const.I_DROPBOX_MAX_DIRECTORIES_TO_SCAN = 2000 />
<cfset application.const.I_DROPBOX_MAX_FILES_TO_HOLD = 5000 />
<cfset application.const.I_DROPBOX_MAX_DIRECTORY_LEVEL = 5 />

<cfset application.const.I_DROPBOX_FILE_STATUS_NEW = 1 />
<cfset application.const.I_DROPBOX_FILE_STATUS_ANALYZED = 2 />
<cfset application.const.I_DROPBOX_FILE_STATUS_PUBLISHED = 3 />
<cfset application.const.I_DROPBOX_FILE_STATUS_ANALYZE_IN_PROGRESS = 50 />

<!--- in the queue for analysis --->
<cfset application.const.I_DROPBOX_FILE_STATUS_ANALYZING = 20 />

<cfset application.const.I_DROPBOX_FILE_STATUS_FAILED_READING = -99 />

<!--- where is the file originally stored? a file can be availble from multiple sources --->
<cfset application.const.I_STORAGE_TYPE_TB_CLOUD = 0 />
<cfset application.const.I_STORAGE_TYPE_HTTP_RAW = 2 />

<cfset application.const.I_STORAGE_TYPE_DROPBOX = 75 />
<cfset application.const.I_STORAGE_TYPE_MP3TUNES = 100 />
<cfset application.const.I_STORAGE_TYPE_MSPOT = 115 />
<cfset application.const.I_STORAGE_TYPE_8TRACKS = 150 />
<cfset application.const.I_STORAGE_TYPE_SOUNDCLOUD = 155 />

<!--- FB data --->
<cfset application.const.S_FB_GRAPH_TYPE_ARTIST = 'Musician/band' />
<cfset application.const.S_FB_GRAPH_TYPE_ARTIST_ID = 1 />
<cfset application.const.S_FB_GRAPH_TYPE_GENRE = 'Musical genre' />
<cfset application.const.S_FB_GRAPH_TYPE_GENRE_ID = 2 />

<!--- errors --->
<cfset application.err.AUDIO_UNABLE_TO_PARSE_FILE = 4101 />

</cflock>
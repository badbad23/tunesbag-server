<!---

	select popular playlist tags

--->

<cfset a_struct_tags = StructNew() />

<cfquery name="q_select_popular_playlist_tags" datasource="mytunesbutleruserdata">
SELECT
	DISTINCT( playlists.tags )
FROM
	playlists
;
</cfquery>

<cfloop query="q_select_popular_playlist_tags">
	
	<cfif Len( q_select_popular_playlist_tags.tags ) GT 0>
		
		<cfloop list="#q_select_popular_playlist_tags.tags#" index="a_str_tag" delimiters=" ">
		
			<cfif StructKeyExists( a_struct_tags, a_str_tag )>
				<cfset a_struct_tags[ a_str_tag ] = a_struct_tags[ a_str_tag ] + 1 />
			<cfelse>
				<cfset a_struct_tags[ a_str_tag ] = 1 />			
			</cfif>
		
		</cfloop>
		
	</cfif>
	
</cfloop>

<cfset q_select_tags = QueryNew( 'tag,number,image', 'VarChar,Integer,VarChar' ) />

<cfloop collection="#a_struct_tags#" item="a_str_tag">
	<cfset QueryAddRow( q_select_tags, 1 ) />
	<cfset QuerySetCell( q_select_tags, 'tag', a_str_tag, q_select_tags.recordcount ) />
	<cfset QuerySetCell( q_select_tags, 'number', a_struct_tags[ a_str_tag ], q_select_tags.recordcount ) />	
</cfloop>

<cfset QueryAddRow( q_select_tags, 1 ) />
<cfset QuerySetCell( q_select_tags, 'tag', 'sad', q_select_tags.recordcount ) />
<cfset QuerySetCell( q_select_tags, 'number', 999, q_select_tags.recordcount ) />
<cfset QuerySetCell( q_select_tags, 'image', 'emoticon_unhappy', q_select_tags.recordcount ) />


<cfset QueryAddRow( q_select_tags, 1 ) />
<cfset QuerySetCell( q_select_tags, 'tag', 'melancholic', q_select_tags.recordcount ) />
<cfset QuerySetCell( q_select_tags, 'number', 999, q_select_tags.recordcount ) />
<cfset QuerySetCell( q_select_tags, 'image', 'emoticon_waii', q_select_tags.recordcount ) />

<cfset QueryAddRow( q_select_tags, 1 ) />
<cfset QuerySetCell( q_select_tags, 'tag', 'goodvibrations', q_select_tags.recordcount ) />
<cfset QuerySetCell( q_select_tags, 'number', 999, q_select_tags.recordcount ) />
<cfset QuerySetCell( q_select_tags, 'image', 'emoticon_smile', q_select_tags.recordcount ) />

<cfset QueryAddRow( q_select_tags, 1 ) />
<cfset QuerySetCell( q_select_tags, 'tag', 'happy', q_select_tags.recordcount ) />
<cfset QuerySetCell( q_select_tags, 'number', 999, q_select_tags.recordcount ) />
<cfset QuerySetCell( q_select_tags, 'image', 'emoticon_happy', q_select_tags.recordcount ) />


<cfset QueryAddRow( q_select_tags, 1 ) />
<cfset QuerySetCell( q_select_tags, 'tag', 'party', q_select_tags.recordcount ) />
<cfset QuerySetCell( q_select_tags, 'number', 999, q_select_tags.recordcount ) />
<cfset QuerySetCell( q_select_tags, 'image', 'emoticon_grin', q_select_tags.recordcount ) />

<cfquery name="q_select_tags" dbtype="query">
SELECT
	*
FROM
	q_select_tags
ORDER BY
	number DESC
;
</cfquery>
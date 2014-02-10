<!--- search --->
<cfif NOT a_bol_exact_match AND Len( a_search_string ) GT 0>
	<cfquery name="q_select_possible_alias_items" datasource="#application.udf.getMBds()#">
	SELECT
		artistalias.ref
	FROM
		artistalias
	WHERE
		artistalias.name #a_sql_op# <cfqueryparam cfsqltype="cf_sql_varchar" value="#a_search_string#" />
	;
	</cfquery>
</cfif>

<cfquery name="q_select_search_artists" datasource="#application.udf.getMBds()#">
/* search operator: #searchmode# */
	(
	SELECT
		artist.name,
		artist.id,
		artist.quality,
		artist.gid,
		artist.begindate,
		artist.enddate,
		artist.sortname,
		STRCMP( SOUNDEX( artist.name ), SOUNDEX( <cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.artist#"> ) ) AS compare_name,
		
		<cfif arguments.bLoadBio>
			commoninfo.bio_en,
		</cfif>
		
		/* image revision */
		IFNULL( commoninfo.img_revision, 0 ) AS img_revision,
		/* strip revision ... -1 = does not exist */
		IFNULL( strips.img_revision, -1 ) AS strip_img_revision,
		strips.imgheight AS strip_img_height,
		strips.imgwidth AS strip_img_width,
		strips.copyrighthints AS strips_copyrighthints
		
		<!--- tags? --->
		<cfif arguments.gettags>
			,REPLACE( GROUP_CONCAT( DISTINCT tag_info_artist.name SEPARATOR ', '), 'and', '') AS tags_artist
		</cfif>
		
	FROM
		artist
	
		<!--- load tags for this artist? --->
		<cfif arguments.gettags>
			LEFT JOIN
				artist_tag ON (artist_tag.artist = artist.id)
			LEFT JOIN
				tag AS tag_info_artist ON (tag_info_artist.id = artist_tag.tag)	
		</cfif>
		
		LEFT JOIN
			mytunesbutlercontent.common_artist_information AS commoninfo ON (commoninfo.artistid = artist.id)
		LEFT JOIN
			/* join default strip image */
			mytunesbutlercontent.image_strips AS strips ON (strips.mbtype = 2 AND strips.mbid = artist.id AND strips.img_type = 0)
		
	WHERE
	
		<!--- read by IDs, GID or search for data? --->
		<cfif arguments.mbids NEQ -1>
			artist.id IN (<cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.mbids#" list="true">)
		<cfelseif arguments.mbgids NEQ "">
			artist.gid IN (<cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.mbgids#" list="true">)
		<cfelse>
		
			<!--- exact hit or keep on searching? --->
			<cfif a_bol_exact_match>
				artist.id = <cfqueryparam cfsqltype="cf_sql_integer" value="#q_select_test_exact_match.id#">
			<cfelse>
			
				<!--- perform lookups ... --->
				artist.name #a_sql_op# <cfqueryparam cfsqltype="cf_sql_varchar" value="#a_search_string#">
				
				<!--- special case ... in case the name of the artist is X AND y, check for X & Y as well --->
				<cfif FindNoCase( ' and ', a_search_string ) GT 0>
					OR
					artist.name #a_sql_op# <cfqueryparam cfsqltype="cf_sql_varchar" value="#ReplaceNoCase( a_search_string, ' and ', ' & ')#">
				</cfif>
				
				OR
				artist.sortname #a_sql_op# <cfqueryparam cfsqltype="cf_sql_varchar" value="#a_search_string#">
				OR
				artist.namesimple #a_sql_op# <cfqueryparam cfsqltype="cf_sql_varchar" value="#a_search_simple_string#">
				
				<!--- list possible alias --->
				<cfif IsQuery( q_select_possible_alias_items ) AND q_select_possible_alias_items.recordcount GT 0>
					OR
					artist.id IN
					(				
					<cfqueryparam cfsqltype="cf_sql_integer" value="#ValueList( q_select_possible_alias_items.ref )#" list="true">
					)	
				</cfif>
			
			
			</cfif>
			
		</cfif>
		
	<cfif arguments.gettags>
		GROUP BY artist.id
	</cfif>
		
	)
<!--- <cfif NOT a_bol_exact_match>
UNION ALL
	(
	SELECT
		artistcust.name,
		artistcust.id,
		/* always select with a very low quality */
		- 999 AS quality,
		artistcust.gid,
		artistcust.begindate,
		artistcust.enddate,
		artistcust.sortname,
		STRCMP( SOUNDEX( artistcust.name ), SOUNDEX( <cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.artist#"> ) ) AS compare_name,
		
		/* load dummy bio */
		<cfif arguments.bLoadBio>
			'' AS bio_en,
		</cfif>
		
		-1 AS strip_img_revision,
		0 AS strip_img_height,
		0 AS strip_img_width,
		'' AS strips_copyrighthints,
		-1 AS img_revision /* always select an invalid image revision */
		
		<!--- tags? not available for this artist! --->
		<cfif arguments.gettags>
			, '' AS tags_artist
		</cfif>
	FROM
		mytunesbutlercontent.artistcust
	WHERE
		<!--- ID, GID or name? --->
		<cfif arguments.mbids NEQ -1>
			artistcust.id IN (<cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.mbids#" list="true">)
		<cfelseif arguments.mbgids NEQ "">
			artistcust.gid IN (<cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.mbgids#" list="true">)			
		<cfelse>
			<!--- search! --->
			artistcust.name #a_sql_op# <cfqueryparam cfsqltype="cf_sql_varchar" value="#a_search_string#">
			OR
			artistcust.sortname #a_sql_op# <cfqueryparam cfsqltype="cf_sql_varchar" value="#a_search_string#">
			OR
			artistcust.namesimple #a_sql_op# <cfqueryparam cfsqltype="cf_sql_varchar" value="#a_search_simple_string#">
		</cfif>		
	)
ORDER BY
	quality DESC,
	id
LIMIT
	#arguments.maxrows#
</cfif> --->
</cfquery>
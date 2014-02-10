<!---

	get friend list
	
	get
	
	where I am the host ...
	
	cache for ten seconds

--->

<cfquery name="q_select_friend_list" datasource="mytunesbutleruserdata">
SELECT
	friend.entrykey,
	friend.user1_ID,
	friend.user2_ID,
	friend.userkey,
	/* seen from user */
	friend.accesslibrary,
	/* seen from friend */
	friends_seen_from_friend.accesslibrary AS accesslibrary_seen_from_friend,
	friend.otheruserkey,
	friend.dt_created,
	friend.taste,
	friend.source,
	friend.displayname,
	UPPER( friend.displayname ) AS upper_displayname,
	user2.online,
	friend.photourl AS photourl,
	user2.about_me,
	user2.pic AS photourl2,
	user2.music_preferences,
	user2.firstname,
	user2.surname,
	user2.city,
	user2.fb_uid,
	user2.libraryitemscount,
	user2.playlistscount,
	user2.photoindex,
	/* include the librarykey */
	libraries.entrykey AS librarykey,
	libraries.id AS libraryid
FROM
	friends AS friend
LEFT JOIN friends AS friends_seen_from_friend ON
	/* include how the friend seens the accessibility of this library */
	(friends_seen_from_friend.user2_ID = friend.user1_ID AND friends_seen_from_friend.user1_ID = friend.user2_ID)
LEFT JOIN users AS user2 ON
	(user2.id = friend.user2_ID)
LEFT JOIN libraries ON
	(libraries.userkey = friend.otheruserkey)
WHERE
	(
		(friend.user1_id = <cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.securitycontext.userid#">)
	)
	AND
	(
		(1 = 1)
		
		<!--- filtrs ... real users only (where the user exists on the local system, certain entrykeys or users who can access my lib --->
		<!--- <cfif arguments.realusers_only> --->
			AND
			(NOT ISNULL(user2.id))
		<!--- </cfif> --->
	
		<cfif Len( arguments.filter_entrykeys ) GT 0>
			AND
				(friend.entrykey IN (<cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.filter_entrykeys#" list="true">))
		</cfif>
		<cfif arguments.filter_accesslibrary_only>
			AND
				(friend.accesslibrary = 1)
		</cfif>

	)

</cfquery>

<!--- TODO: merge this part with the query above --->
<cfquery name="q_select_friend_list" dbtype="query">
SELECT
	*
FROM
	q_select_friend_list
ORDER BY
	upper_displayname
;
</cfquery>

<!--- loop over friends and set photo url to the pic the user has set in case the picture in the friend table is empty --->
<cfloop query="q_select_friend_list">
	<cfif Len( q_select_friend_list.photourl ) IS 0 AND Len( q_select_friend_list.photourl2 ) GT 0>
		<cfset QuerySetCell( q_select_friend_list, 'photourl', q_select_friend_list.photourl2, q_select_friend_list.currentrow ) />
	</cfif>
</cfloop>
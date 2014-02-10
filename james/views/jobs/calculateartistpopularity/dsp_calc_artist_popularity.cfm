<!--- 

	calculate the artist popularity for yeasterday
	
	a) tracks added
	
	b) tracks played
	
	c) tracks rated

 --->

<cfloop from="0" to="3" index="ii">
	<cfset GenerateStatForDate( DateAdd( 'd', -ii, Now() ) ) />
</cfloop>

<cffunction access="private" name="LoopData" returntype="void" output="false">
	<cfargument name="q" type="query" required="true" />
	<cfargument name="indicator" type="string" required="true" />
	<cfargument name="date" type="date" required="true" />
	
	<cfset var stLocal = {} />
	
	<cfloop query="arguments.q">
		
		<cfset InsertPopularityData( mb_artistid = arguments.q.mb_artistid, indicator = arguments.indicator, date = arguments.date, value = arguments.q.itemcount ) />
	
	</cfloop>
	
	<!--- total immer mit artistid 0 mitspeichern --->
	<cfquery name="stLocal.qSelectTotal" dbtype="query">
	SELECT
		SUM(itemcount) AS sum_total
	FROM
		arguments.q
	;
	</cfquery>
	
	<cfset InsertPopularityData( mb_artistid = 0, indicator = arguments.indicator, date = arguments.date, value = Val( stLocal.qSelectTotal.sum_total ) ) />
	
</cffunction>

<cffunction access="private" name="GenerateStatForDate" returntype="void" output="true">
	<cfargument name="date" type="date" required="true">
	
	<cfset var stLocal = {} />
	
	<cfquery name="stLocal.qSelectAdded" datasource="mytunesbutleruserdata">
	SELECT
		COUNT(id) AS itemcount,
		mb_artistid
	FROM
		mediaitems
	WHERE
		DATE(dt_created) = <cfqueryparam cfsqltype="cf_sql_date" value="#arguments.date#">
		AND NOT
		source = 'prefill'
		AND
		mb_artistid > 0
		AND
		mb_artistid < 100000000
	GROUP BY
		mb_artistid
	;
	</cfquery>
	
	<cfset LoopData( q = stLocal.qSelectAdded, indicator = application.const.S_REPORTING_INDICATOR_ADDED, date = arguments.date ) />
	
	<cfquery name="stLocal.qSelectPlayed" datasource="mytunesbutlerlogging">
	SELECT
		COUNT(id) AS itemcount,
		mb_artistid
	FROM
		playeditems
	WHERE
		DATE(dt_created) = <cfqueryparam cfsqltype="cf_sql_date" value="#arguments.date#">
		AND
		mb_artistid > 0
		AND
		mb_artistid < 100000000
		AND
		secondsplayed > 30
	GROUP BY
		mb_artistid
	;
	</cfquery>
	
	<cfset LoopData( q = stLocal.qSelectPlayed, indicator = application.const.S_REPORTING_INDICATOR_PLAYED, date = arguments.date ) />
		
	<cfquery name="stLocal.qSelectNewFans" datasource="mytunesbutleruserdata">
	SELECT
		COUNT(id) AS itemcount,
		mbid AS mb_artistid
	FROM
		ratings
	WHERE
		DATE(dt_created) = <cfqueryparam cfsqltype="cf_sql_date" value="#arguments.date#">
		AND
		mediaitemtype = 2
		AND
		mbid > 0
	GROUP BY
		mbid
	;
	</cfquery>
	
	<cfset LoopData( q = stLocal.qSelectNewFans, indicator = application.const.S_REPORTING_INDICATOR_FANS, date = arguments.date ) />
	
	<!--- ratings --->
	
	<cfquery name="stLocal.qSelectRatings" datasource="mytunesbutleruserdata">
	SELECT
		COUNT(ratings.id) AS itemcount,
		track.artist AS mb_artistid
	FROM
		ratings
	LEFT JOIN
		mytunesbutler_mb.track AS track ON (track.id = ratings.mbid)
	WHERE
		DATE(dt_created) = <cfqueryparam cfsqltype="cf_sql_date" value="#arguments.date#">
		AND
		mediaitemtype = 0
		AND
		mbid > 0
		AND
		mbid < 100000000
	GROUP BY
		track.artist
	;
	</cfquery>
	
	<cfset LoopData( q = stLocal.qSelectRatings, indicator = application.const.S_REPORTING_INDICATOR_RATINGS, date = arguments.date ) />
	
	<!--- added to plists --->
	
	
	<!--- public plists --->
	<cfquery name="stLocal.qSelectArtistAssetsHits" datasource="mytunesbutlerlogging">
	SELECT
		COUNT(id) AS itemcount,
		mbartistid AS mb_artistid
	FROM
		artist_visit_log
	WHERE
		DATE(dt_created) = <cfqueryparam cfsqltype="cf_sql_date" value="#arguments.date#">
	GROUP BY
		mbartistid
	;
	</cfquery>
	
	<cfset LoopData( q = stLocal.qSelectArtistAssetsHits, indicator = application.const.S_REPORTING_INDICATOR_INFOASSETSHITS, date = arguments.date ) />	
	
</cffunction>


<cffunction access="private" name="InsertPopularityData" output="false" returntype="void">
	<cfargument name="mb_artistid" type="numeric" required="true" />
	<cfargument name="indicator" type="string" required="true">
	<cfargument name="date" type="date" required="true">
	<cfargument name="value" type="numeric" required="true">
	
	<cfset var local = {} />
	
	<cfquery name="local.q_delete_old_value" datasource="mytunesbutlerlogging">
	DELETE FROM
		artistpopularityreporting
	WHERE
		(mb_artistid = <cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.mb_artistid#">)
		AND
		(indicator = <cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.indicator#">)
		AND
		(date_report = <cfqueryparam cfsqltype="cf_sql_date" value="#arguments.date#">)
	;
	</cfquery>
	
	<cfquery name="local.q_insert_new_value" datasource="mytunesbutlerlogging">
	INSERT INTO
		artistpopularityreporting
		(
		mb_artistid,
		indicator,
		date_report,
		val)
	VALUES
		(
		<cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.mb_artistid#">,
		<cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.indicator#">,
		<cfqueryparam cfsqltype="cf_sql_date" value="#arguments.date#">,
		<cfqueryparam cfsqltype="cf_sql_integer" value="#Val( arguments.value )#">
		)
	;
	</cfquery>
	

</cffunction>

<!--- //

	Module:		UI test
	Action:		
	Description:	
	Modified:	$Date$

	$Id$
	
// ---><script src="/res/js/package/jquery-1.3.min.js" type="text/javascript"></script>

<cfinclude template="/common/scripts.cfm">

<cfset q_select_items = event.getargs( 'q_select_items' ).q_select_items />

<!--- <cfquery name="q_select_items_2" dbtype="query" maxrows="10">
SELECT
	*
FROM
	q_select_items
;
</cfquery> --->

<cfset json_data = SerializeJSON(q_select_items) />

<!--- <cfoutput>#json_data#</cfoutput> --->

<script language="javascript">
	console.time('test');
	mydata = eval(<cfoutput>#json_data#</cfoutput>);
	
	mycols = mydata.COLUMNS;
	
	var a_album_index = mycols.indexOf('AL');
	var a_artist_index = mycols.indexOf('AR');
	var a_entrykey_index = mycols.indexOf('AR');
	
	// console.log(_data);
	$(mydata.DATA).each(function(index) {
		var a_album = _data[index][a_album_index];
		var a_artist = _data[index][a_artist_index];
		
	});
	
	console.timeEnd('test');
</script>

<!--- //
$Log$
//--->
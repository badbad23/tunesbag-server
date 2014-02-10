<!--- //

	Module:		Webservice helper routine
	Action:		
	Description:	
	Modified:	$Date$

	$Id$
	
// --->

<cfcomponent output="false" displayname="Webservice">
	
	<cfscript>
	// handle a query
	function HandleQuery(q)
		{
		var a_str_return = '';
		var a_str_record = '';
		var i = 0;
		var j = 0;
		var a_arr_rows = ArrayNew(1);
		var a_arr_record = ArrayNew(1);
		var a_str_columnlist = q.columnlist;
		var a_int_listlen = ListLen(a_str_columnlist);  
		var a_struct_record = StructNew();
		var a_col_name = '';
  
  		for (i = 1; i LTE q.recordcount; i = i + 1)
    		{
			// array holding the record
			// ArrayClear(a_arr_record);
			
			a_str_record = '<item>';
			
			for (j = 1; j LTE a_int_listlen; j = j + 1)
				{
				
				a_col_name = lcase(ListGetAt(a_str_columnlist, j));
				
				// a_arr_record[j] = '<' & a_col_name & '>' & xmlFormat(q[a_col_name][i]) & '</' & a_col_name & '>';				
				
				a_str_record = a_str_record & '<' & a_col_name & '>' & xmlFormat(q[a_col_name][i]) & '</' & a_col_name & '>';	
				}
				
				
			// compose the record xml
			// a_str_record = '<item>' & a_str_record & ArrayToList(a_arr_record, '') & '</item>';			
			a_str_record = a_str_record & '</item>';			
				
			a_arr_rows[i] = a_str_record;
    		}		
			
		a_str_return = a_str_return & ArrayToList(a_arr_rows, '');
		
		return a_str_return;
		}
		
	function HandleSubArray(a, item_name)
		{
		var a_str_return = '';
		var a_str_item = '';
		
		for (y = 1; y LTE ArrayLen(a); y=y+1)
			{
			
			// after the first item, always open a new tag ...
			if (y GT 1)
				{
				a_str_return = a_str_return & '<' & item_name & '>';
				}			
			
			if (IsSimpleValue(a[y]))
				{
				a_str_return = a_str_return & xmlformat(a[y]);
				}
				
			if (IsStruct(a[y]))
				{
				a_str_return = a_str_return & HandleSubStructure(a[y]);
				}
				
			if (IsArray(a[y]))
				{
				a_str_return = a_str_return & HandleSubArray(a[y]);
				}				
				
			// if not the last item, close the tag ...
			if (y LT ArrayLen(a))
				{
				a_str_return = a_str_return & '</' & item_name & '>';
				}
			
			}
			
		
		return a_str_return;
		}
		
	function HandleSubStructure(s)
		{
		var a_str_return = '';
		var a_str_item = '';
		var a_str_keylist = StructKeyList(s);
		
		for (x = 1; x LTE ListLen(a_str_keylist); x=x+1)
			{
			
			a_str_item = ListGetAt(a_str_keylist, x);
			
			a_str_item = LCase(a_str_item);
			
			a_str_return = a_str_return & '<' & a_str_item & '>';
			
			// simple value ...
			if (IsSimpleValue(s[a_str_item]))
				{
				a_str_return = a_str_return & xmlformat(s[a_str_item]);
				}
				
			// sub structure
			if (IsStruct(s[a_str_item]))
				{
				a_str_return = a_str_return & HandleSubStructure(s[a_str_item]);
				}
				
			// array ...
			if (IsArray(s[a_str_item]))
				{
				a_str_return = a_str_return & HandleSubArray(s[a_str_item], a_str_item);
				}
				
			// query
			if (IsQuery(s[a_str_item]))
				{
				a_str_return = a_str_return & HandleQuery(s[a_str_item]);
				}
				
			a_str_return = a_str_return & '</' & a_str_item & '>';				
			
			}		
			
		return a_str_return;
		
		}

	</cfscript>

	<cffunction access="public" name="DoGenerateXMLStringFromReturnStruct" output="false" returntype="string"
			hint="return the XML string of the converted structure">
		<cfargument name="return_struct" type="struct" required="true"
			hint="the return structure">
			
		<cfset var a_str_xml = '' />
		<cfset var a_str_whole_xml = '' />

		<cfsavecontent variable="a_str_whole_xml">
			<result>			
				<cfoutput>#HandleSubStructure(arguments.return_struct)#</cfoutput>
			</result>
		</cfsavecontent>
		
		<cftry>
		<cfxml variable="a_str_xml">
		<cfoutput>#a_str_whole_xml#</cfoutput>
		</cfxml>
		<cfcatch type="any">
		</cfcatch>
		</cftry>
		
		<cfreturn tostring(a_str_xml)>

	</cffunction>

</cfcomponent>

<!--- //
$Log$
//--->
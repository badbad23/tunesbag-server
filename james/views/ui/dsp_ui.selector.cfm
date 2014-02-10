<!---

	Selector
	
	display output

--->

<cfset a_struct_selector = event.getArg( 'a_struct_selector' ) />

<cfif NOT IsStruct( a_struct_selector )>
	<cfreturn />
</cfif>

<cfif NOT a_struct_selector.result>
	<cfreturn />
</cfif>

<cfoutput>#a_struct_selector.a_str_content#</cfoutput>
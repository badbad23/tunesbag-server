<!--- //

	Module:		Main layout header
	Description: 
	
// --->


<cfoutput>
<div class="container-narrow">

	<div style="background-color:white;padding: 8px;">

	     <div class="masthead">
	       <ul class="nav nav-pills pull-right">
	         <li class="active"><a href="/">Home</a></li>
	         <!--- <li><a href="#">About</a></li>
	         <li><a href="#">Contact</a></li> --->
	       </ul>
	       <h3 class="muted">#htmleditformat( event.getArg( 'PageTitle' ))#</h3>
	     </div>
		
		<cfset sTopContent = event.getArg( 'top_content', '' ) />
		
		<cfif Len( sTopContent )>
			<div>#sTopContent#</div>
		</cfif>
	
	     <hr />

</cfoutput>
<!---

	application uploader info page

--->

<cfinclude template="/common/scripts.cfm">

<!--- get the bg color of the windows system ... --->
<cfset a_str_bg_color = event.getArg( 'bgcolor', 'white' ) />

<cfset a_struct_blog = getProperty( 'beanFactory' ).getBean( 'BlogsComponent' ).GetBlogPosts( blogkey = 'INTERNALBLOG' ) />

<cfsavecontent variable="request.content.final">
	
<style type="text/css">
	body.body_iframe {
		border:none;
		background-color:<cfoutput>#htmleditformat( a_str_bg_color )#</cfoutput>;
		padding:0px;
		}
	a {color:blue;}
</style>

<div class="div_container">

	<table class="table_details">
		<tr>
			<td width="40%" valign="top">
				<div class="div_left_nav_header">
					
				<cfoutput>Version</cfoutput>
				</div>
				Your version of the uploader is up to date.
				<br /><br />
				<a href="/rd/feedback/?keyword=uploader" target="_blank"><cfoutput>#application.udf.GetLangValSec( 'cm_ph_bug_reports_long' )#</cfoutput></a>
			
			</td>
			<td width="60%" valign="top">
			
			<cfif a_struct_blog.result>
				<div class="div_left_nav_header">
					
					<cfoutput>Blog</cfoutput>
				</div>
				
				<ul>
				<cfoutput query="a_struct_blog.q_select_items" startrow="1" maxrows="5">
					<li>
						#application.udf.si_img( 'bullet_orange' )# <a href="#a_struct_blog.q_select_items.RSSLINK#" target="_blank">#htmleditformat(a_struct_blog.q_select_items.title)#</a>
					</li>
				</cfoutput>
				</ul> 
			</cfif>
			
			</td>
		</tr>
	</table>
	
	
	
</div>
</cfsavecontent>
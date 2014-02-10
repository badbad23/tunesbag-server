<!--- //

	Module:		Main layout
	Description: 
	
// --->








<cfprocessingdirective pageencoding="utf-8" />

<cfheader name="Content-Language" value="en" />

<cfset a_str_page_title = event.getArg('PageTitle', '') />
<cfset a_str_page_description = event.getArg( 'PageDescription', 'tunesBag - Listen to your music anywhere! Upload your music and share it with friends. Free signup.' ) />

<!--- dev server? --->
<cfset bDevServer = application.udf.IsDevelopmentServer() />

<cfsavecontent variable="request.content.final">
<!DOCTYPE html>
<html lang="en"
	xmlns:og="http://ogp.me/ns#"
	xmlns:fb="http://www.facebook.com/2008/fbml">
  <head>
    <meta charset="utf-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <meta name="description" content="">
    <meta name="author" content="">
	
	<title><cfif Len(a_str_page_title) GT 0><cfoutput>#htmleditformat(a_str_page_title)#</cfoutput></cfif><cfif FindNoCase( 'tunesBag', a_str_page_title ) IS 0> - tunesBag</cfif></title>
	
	<link href="/assets/css/bootstrap.min.css" rel="stylesheet" />
	<style type="text/css">
      body {
        padding-top: 20px;
        padding-bottom: 40px;
		background-color:#fafafa;
      }

      /* Custom container */
      .container-narrow {
        margin: 0 auto;
        max-width: 780px;
      }
      .container-narrow > hr {
        margin: 30px 0;
      }

      /* Main marketing message and sign up button */
      .jumbotron {
        margin: 60px 0;
        text-align: center;
      }
      .jumbotron h1 {
        font-size: 42px;
        line-height: 1;
      }
      .jumbotron .btn {
        font-size: 21px;
        padding: 14px 24px;
      }

      /* Supporting marketing content */
      .marketing {
        margin: 60px 0;
      }
      .marketing p + h4 {
        margin-top: 28px;
      }
	div.boxContainer {
		float: left;
		margin: 12px;
	}
	div.boxContainer div.header {
		text-align: center;
		}
	div.ad {
		padding-top:18px;
		padding-bottom: 18px;
		}
    </style>
	<link href="/assets/css/bootstrap-responsive.min.css" rel="stylesheet" />
	
	<link rel="shortcut icon" href="http://deliver.tunesbagcdn.com/images/favicon.ico" type="image/x-icon" />		
	<link rel="icon" type="image/png" href="http://deliver.tunesbagcdn.com/images/favicon-32px.png" />
	<link rel="image_src" type="image/png" href="http://cdn.tunesbag.com/images/skins/default/bgLogoLeftTop.png" />

	
<!--- 	<cfset arJSFiles = [ 'james/james.basic.js' ] /> --->
	
	<script src="http://ajax.googleapis.com/ajax/libs/jquery/1.9.1/jquery.min.js"></script>
	
<!--- 	<cfloop from="1" to="#ArrayLen( arJSFiles )#" index="ii">
		<script type="text/javascript" src="/res/js/<cfoutput>#arJSFiles[ ii ]#</cfoutput>"></script>
	</cfloop> --->
			
	<meta name="author" content="(c) by tunesBag.com" />
	<meta name="keywords" content="music, mp3, player, directory, sharing, browser-based, streaming, upload, friends, spotify, youtube, deezer" />
	<meta name="description" content="<cfoutput>#htmleditformat( a_str_page_description )#</cfoutput>" />
	
	<meta http-equiv="Content-type" content="text/html;charset=UTF-8" />
	
	<!--- opengraph / facebook --->
	<meta property="og:title" content="tunesBag"/>
	<meta property="og:type" content="product" />
	<meta property="og:url" content="http://www.tunesBag.com/"/>
	<meta property="og:site_name" content="tunesBag" />
	<meta property="og:image" content="http://deliver.tunesbagcdn.com/images/skins/default/bgLogoLeftTop.png" />
	<meta property="og:description" content="Cloud Music Service for your own collection" />
	<!--- <meta property="fb:app_id" content="39900567213"/> --->
	<meta property="fb:app_id" content="216032921780058"/>
	<meta property="fb:admins" content="523658434"/>
	
	<!-- TradeDoubler site verification 1565356 --> 
	
	<cfinclude template="inc_tracking.cfm">
</head>
<body>

<cfinclude template="layout.main.header.cfm">

<cfoutput>#request.content.final#</cfoutput>

<cfinclude template="layout.main.footer.cfm">

</body>
</html>
</cfsavecontent>
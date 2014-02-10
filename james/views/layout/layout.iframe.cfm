<!--- //

	Module:		Inpage Popup layout
	Description: 
	
// --->

<cfset a_str_window_title = event.getArg( 'WindowTitle' , 'Dialog' ) />

<cfsavecontent variable="request.content.final">
<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html xmlns="http://www.w3.org/1999/xhtml">
<head>
<!--- CSS --->
<link rel="stylesheet" href="/res/css/default.css" />
<!--- JS --->

<cfset arJSFiles = [ 'jquery-1.4.min.js', 'ui/jquery-ui-1.7.0.js', 'jquery.form.js', 'plugins/jquery.bgiframe.min.js',
		'plugins/jquery.autocomplete.pack.js',
		'tweaks.js','james/james.basic.js', 'james/james.interface.js', 'james/james.data.js' ] />

<cfloop from="1" to="#ArrayLen( arJSFiles )#" index="ii">
	<script type="text/javascript" src="/res/js/<cfoutput>#arJSFiles[ ii ]#?#CreateUUID()#</cfoutput>"></script>
</cfloop>
	
<meta http-equiv="Content-Type" content="text/html; charset=utf-8" />
<meta http-equiv="Content-Language" content="en-us" />
<meta name="description" content="tunesBag is your music hub on the net.">

<script type="text/javascript" src="/res/js/swfobject.js"></script>

<title><cfoutput>#htmleditformat(a_str_window_title)#</cfoutput></title>

<script type="text/javascript">
	recSet = parent.recSet;
</script>

<!--- google logging --->
<cfset request.bSubscribers = true />
<cfinclude template="inc_tracking.cfm">

</head>
<body class="body_iframe">
<cfoutput>#request.content.final#</cfoutput>


</body>
</html>
</cfsavecontent>
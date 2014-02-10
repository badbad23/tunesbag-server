<cfset q_select_playlists = event.getArg( 'q_select_items' ) />

<cfsavecontent variable="request.content.final">


<!--- <cfdump var="#q_select_playlists#"> --->

<html>
	<head>
		<title>tunesBag</title>	

		<script language="javascript" src="/res/js/jquery-1.2.6.min.js"></script>
		<script language="javascript" src="/res/js/ui/ui.core.js"></script>
		<script language="javascript" src="/res/js/ui/ui.draggable.js"></script>
		
		<script type="text/javascript">
			
			jQuery.easing.bounceout = function(p, n, firstNum, delta, duration) {
					if ((n/=duration) < (1/2.75)) {
						return delta*(7.5625*n*n) + firstNum;
					} else if (n < (2/2.75)) {
						return delta*(7.5625*(n-=(1.5/2.75))*n + .75) + firstNum;
					} else if (n < (2.5/2.75)) {
						return delta*(7.5625*(n-=(2.25/2.75))*n + .9375) + firstNum;
					} else {
						return delta*(7.5625*(n-=(2.625/2.75))*n + .984375) + firstNum;
					}
				};
							
			jQuery.easing.bouncein = function(x, t, b, c, d) {
					return c - jQuery.easing['bounceout'](x, d-t, 0, c, d) + b;
				};
			
			
			function AddEventHandlers() {
		
			$('.box').click(function() {
				
				//alert('123');
				
				var a_left = $(this).offset().left;
				
				console.log( a_left);
				
				// $(window)[0].scrollX = 100;
				
				// console.log( $(window)[0].document );
				
				//$('#id_body').scrollLeft = 18;
				
				$("body").animate({
					scrollLeft : 200 },
					"slow").animate({ scrollLeft: 260 }, 1000, "bounceout")
					;
				

				});
				
			}
		
		</script>
		
		<style type="text/css" media="all">
			div.box {
				-moz-border-radius: 12px;
				background-color: lightblue;
				float: left;
				padding: 12px;
				width: 600px;
				height: 560px;
				margin: 20px;
				}
			div.boxartist {
				background-color: lightgreen;
				}
			div.boxuser {
				background-color: lightyellow;
				}
			div.boxsearch {
				background-color: #EEEEEE;
				}
		</style>
		
	</head>
<body style="" onload="AddEventHandlers()" id="id_body">

<div style="width:2800px;" id="id_container">
<div class="box">
	Artists
</div>

<div class="box boxartist">
	Artists
</div>

<div class="box boxuser">
	User
</div>

<div class="box boxsearch">
	Search
</div>
</div>

</body>
</html>
</cfsavecontent>
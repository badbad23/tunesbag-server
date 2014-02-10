
<cfcomponent
	output="false"
	hint="Image utility functions that abstract out complex ColdFusion image manipulation processes.">
	
	
	<cffunction
		name="Init"
		access="public"
		returntype="any"
		output="false"
		hint="Returns an initialized component.">
		
		<!--- Return This reference. --->
		<cfreturn THIS />
	</cffunction>
	

	<!---
		Function: aspectCrop
		Author: Emmet McGovern
		http://www.illequipped.com/blog
		emmet@fullcitymedia.com
		2/29/2008 - Leap Day!
	--->
	<cffunction name="aspectCrop" access="public" returntype="any" output="false" hint="">
		
		<!--- Define arguments. --->
		<cfargument name="image" type="any" required="true" hint="The ColdFusion image object or path to an image file." />
		<cfargument name="cropwidth" type="numeric" required="true" hint="The pixel width of the final cropped image" />
		<cfargument name="cropheight" type="numeric" required="true" hint="The pixel height of the final cropped image" />
		<cfargument name="position" type="string" required="true" default="center" hint="The y origin of the crop area." />
		
		<!--- Define local variables. --->
		<cfset var nPercent = "" />
		<cfset var wPercent = "" />
		<cfset var hPercent = "" />
		<cfset var px = "" />
		<cfset var ycrop = "" />
		<cfset var xcrop = "" />

		<!--- If not image, assume path. --->
		<cfif (
			(NOT isImage(arguments.image)) AND
			(NOT isImageFile(arguments.image))
			)>
			<cfthrow message="The value passed to aspectCrop was not an image." />
		</cfif>
		
		<!--- If we were given a path to an image, read the image into a ColdFusion image object. --->
		<cfif isImageFile(arguments.image)>
			<cfset arguments.image = imageRead(arguments.image) />
		</cfif>

		<!--- Resize image without going over crop dimensions--->
		<cfset wPercent = arguments.cropwidth / arguments.image.width>
		<cfset hPercent = arguments.cropheight / arguments.image.height>
		
		<cfif  wPercent gt hPercent>
			<cfset nPercent = wPercent>
    		<cfset px = arguments.image.width * nPercent + 1>
			<cfset ycrop = ((arguments.image.height - arguments.cropheight)/2)>
			<cfset imageResize(arguments.image,px,"") />
		<cfelse>
    		<cfset nPercent = hPercent>
    		<cfset px = arguments.image.height * nPercent + 1>
			<cfset xcrop = ((arguments.image.width - arguments.cropwidth)/2)>
			<cfset imageResize(arguments.image,"",px) />
		</cfif>

		<!--- Set the xy offset for cropping, if not provided defaults to center --->
		<cfif listfindnocase("topleft,left,bottomleft", arguments.position)>
			<cfset xcrop = 0>
		<cfelseif listfindnocase("topcenter,center,bottomcenter", arguments.position)>
			<cfset xcrop = (arguments.image.width - arguments.cropwidth)/2>
		<cfelseif listfindnocase("topright,right,bottomright", arguments.position)>
			<cfset xcrop = arguments.image.width - arguments.cropwidth>
		<cfelse>
			<cfset xcrop = (arguments.image.width - arguments.cropwidth)/2>
		</cfif>
		
		<cfif listfindnocase("topleft,topcenter,topright", arguments.position)>
			<cfset ycrop = 0>
		<cfelseif listfindnocase("left,center,right", arguments.position)>
			<cfset ycrop = (arguments.image.height - arguments.cropheight)/2>
		<cfelseif listfindnocase("bottomleft,bottomcenter,bottomright", arguments.position)>
			<cfset ycrop = arguments.image.height - arguments.cropheight>
		<cfelse>
			<cfset ycrop = (arguments.image.height - arguments.cropheight)/2>	
		</cfif>	

		<!--- Return new cropped image. --->
		<cfset ImageCrop(arguments.image,xcrop,ycrop,arguments.cropwidth,arguments.cropheight)>
		
		<cfreturn arguments.image>
	</cffunction>	
	
	<cffunction
		name="CalculateGradient"
		access="public"
		returntype="array"
		output="false"
		hint="Given a From and To normalized color structure (as defined by the NormalizeColor() function) that contain Red, Green, Blue, and Alpha keys, it will return the equivalent structs for each step of the gradient.">
		
		<!--- Define arguments. --->
		<cfargument
			name="FromColor"
			type="struct"
			required="true"
			hint="A normalized color struct."
			/>
			
		<cfargument
			name="ToColor"
			type="struct"
			required="true"
			hint="A normalized color struct."
			/>
			
		<cfargument
			name="Steps"
			type="numeric"
			required="true"
			hint="The number of steps overwhich to calculate the gradient."
			/>
			
		<!--- Define the local scope. --->
		<cfset var LOCAL = {} />
		
		<!--- 
			Find the differences between the two and from colors. 
			We will getting this by finding the difference of each 
			color chanel in RGB format. 
		--->
		<cfset LOCAL.RedDelta = (ARGUMENTS.ToColor.Red - ARGUMENTS.FromColor.Red) />
		<cfset LOCAL.GreenDelta = (ARGUMENTS.ToColor.Green - ARGUMENTS.FromColor.Green) />
		<cfset LOCAL.BlueDelta = (ARGUMENTS.ToColor.Blue - ARGUMENTS.FromColor.Blue) />
		<cfset LOCAL.AlphaDelta = (ARGUMENTS.ToColor.Alpha - ARGUMENTS.FromColor.Alpha) />
		
		<!--- 
			Based on the number of steps that we want to define the 
			gradient, find the step for each color delta.
		--->
		<cfset LOCAL.RedStep = (LOCAL.RedDelta / ARGUMENTS.Steps) />
		<cfset LOCAL.GreenStep = (LOCAL.GreenDelta / ARGUMENTS.Steps) />
		<cfset LOCAL.BlueStep = (LOCAL.BlueDelta / ARGUMENTS.Steps) />
		<cfset LOCAL.AlphaStep = (LOCAL.AlphaDelta / ARGUMENTS.Steps) />
		
		
		<!--- Create an array to hold the color steps. --->
		<cfset LOCAL.Gradient = [] />
		
		<!--- Create a start color. --->
		<cfset LOCAL.Color = StructCopy( ARGUMENTS.FromColor ) />
		
		<!--- Loop over color differences to calculate. --->
		<cfloop
			index="LOCAL.StepIndex"
			from="1"
			to="#ARGUMENTS.Steps#"
			step="1">
			
			<!--- Store the gradient step. --->
			<cfset ArrayAppend(
				LOCAL.Gradient,
				StructCopy( LOCAL.Color )
				) />
			
			<!--- 
				Increment color. In order to make sure that the 
				gradient steps get used appropriatly, add the steps 
				directly the FROM color rather than to the previous 
				color index. This will prevent the Fix() function 
				from stopping our gradient if the increment is too 
				small.
			--->
			<cfset LOCAL.Color.Red = Fix( ARGUMENTS.FromColor.Red + (LOCAL.RedStep * LOCAL.StepIndex) ) />
			<cfset LOCAL.Color.Green = Fix( ARGUMENTS.FromColor.Green + (LOCAL.GreenStep * LOCAL.StepIndex) ) />
			<cfset LOCAL.Color.Blue = Fix( ARGUMENTS.FromColor.Blue + (LOCAL.BlueStep * LOCAL.StepIndex) ) />
			<cfset LOCAL.Color.Alpha = Fix( ARGUMENTS.FromColor.Alpha + (LOCAL.AlphaStep * LOCAL.StepIndex) ) />
			
		</cfloop>
		
		
		<!--- Return gradient array. --->
		<cfreturn LOCAL.Gradient />
	</cffunction>
	
	
	<cffunction
		name="ColorsAreEqual"
		access="public"
		returntype="boolean"
		output="false"
		hint="Determines if the given two *normalized* colors (as defined by NormalizeColor() function) are equal in color given the tolerance. By default, all transparent pixels are equal.">
		
		<!--- Define arguments. --->
		<cfargument
			name="ColorOne"
			type="struct"
			required="true"
			hint="A normalized color struct."
			/>
			
		<cfargument
			name="ColorTwo"
			type="struct"
			required="true"
			hint="A normalized color struct."
			/>
			
		<cfargument
			name="Tolerance"
			type="numeric"
			required="false"
			default="0"
			hint="The tolerance between the color channels when determining if the colors are equal (max possible delta in channel value)."
			/>
			
		<cfargument
			name="AlphaPrecedence"
			type="boolean"
			required="false"
			default="true"
			hint="Flags whether or not the alpha channel takes precedence over the color channels."
			/>
			
		<!--- Define the local scope. --->
		<cfset var LOCAL = {} />
		
		<!--- Check to see if alpha has precedence and both pixels are transparent. --->
		<cfif (
			ARGUMENTS.AlphaPrecedence AND
			(ARGUMENTS.ColorOne.Alpha LTE ARGUMENTS.Tolerance) AND
			(ARGUMENTS.ColorTwo.Alpha LTE ARGUMENTS.Tolerance)
			)>
			
			<!--- Both pixels are transparent and we have defined those as being equal. --->
			<cfreturn true />
			
		</cfif>
		
		<!--- 
			Check to see if these pixles are within the tolerance of 
			each other. 
		--->
		<cfreturn (
			(Abs( ARGUMENTS.ColorOne.Red - ARGUMENTS.ColorTwo.Red ) LTE ARGUMENTS.Tolerance) AND
			(Abs( ARGUMENTS.ColorOne.Green - ARGUMENTS.ColorTwo.Green ) LTE ARGUMENTS.Tolerance) AND
			(Abs( ARGUMENTS.ColorOne.Blue - ARGUMENTS.ColorTwo.Blue ) LTE ARGUMENTS.Tolerance) AND
			(Abs( ARGUMENTS.ColorOne.Alpha - ARGUMENTS.ColorTwo.Alpha ) LTE ARGUMENTS.Tolerance)
			) />
	</cffunction>
	
	
	<cffunction
		name="CreateGradient"
		access="public"
		returntype="any"
		output="false"
		hint="Creates a gradient rectangle to be used with other graphics.">
		
		<!--- Define arguments. --->
		<cfargument
			name="FromColor"
			type="struct"
			required="true"
			hint="The normalized color struct from which to start our gradient."
			/>
			
		<cfargument
			name="ToColor"
			type="struct"
			required="true"
			hint="The normalized color struct at which to end our gradient."
			/>
		
		<cfargument
			name="GradientDirection"
			type="string"
			required="true"
			hint="The direction in which to darw the gradient. Possible values are TopBottom, BottomTop, LeftRight, and RightLeft."
			/>
			
		<cfargument
			name="Width"
			type="numeric"
			required="true"
			hint="The width of the desired rectangle."
			/>
			
		<cfargument
			name="Height"
			type="numeric"
			required="true"
			hint="The height of the desired rectangle."
			/>
			
		<!--- Define the local scope. --->
		<cfset var LOCAL = {} />
		
		
		<!--- Make sure that we have a valid direciton. --->
		<cfif NOT ListFindNoCase( 
			"TopBottom,BottomTop,LeftRight,RightLeft",
			ARGUMENTS.GradientDirection
			)>
			
			<!--- Inavlid gardient, default to TopBottom. --->
			<cfset ARGUMENTS.GradientDirection = "TopBottom" />
			
		</cfif>
		
		
		<!--- 
			Create a new transparent gradient. It is important 
			that it is transparent since the gradient utilizes 
			an alpha channel. 
		--->
		<cfset LOCAL.Gradient = ImageNew(
			"",
			ARGUMENTS.Width,
			ARGUMENTS.Height,
			"argb",
			""
			) />
			
			
		<!--- 
			In order to figure out what steps that we need to 
			create, we need to figure out which direction the 
			gradient is going in.
		--->
		<cfswitch expression="#ARGUMENTS.GradientDirection#">
			
			<!--- 
				For vertical gradients, use the height to 
				define the number of steps. 
			--->
			<cfcase value="TopBottom,BottomTop" delimiters=",">
				<cfset LOCAL.StepCount = ARGUMENTS.Height />
			</cfcase>
		
			<!--- 
				For horizontal gradients, use the width to 
				define the number of steps. 
			--->
			<cfcase value="LeftRight,RightLeft" delimiters=",">
				<cfset LOCAL.StepCount = ARGUMENTS.Width />
			</cfcase>
			
		</cfswitch>
		
			
		<!--- 
			Calculate the gradient using our From and To colors. 
			This will give us all the colors in the gradient.
		--->
		<cfset LOCAL.GradientSteps = THIS.CalculateGradient(
			THIS.NormalizeColor( ARGUMENTS.FromColor ),
			THIS.NormalizeColor( ARGUMENTS.ToColor ),
			LOCAL.StepCount
			) />
			
		
		<!--- 
			Now that we have our gradient steps, we can start to 
			apply our individual color steps to the blank canvas 
			in order to create the gradient rectangle. 
		--->
		
		<!--- 
			We don't want there to be too much fuziness, so turn 
			off antialiasing. 
		--->
		<cfset ImageSetAntialiasing( LOCAL.Gradient, "off" ) />
		
		<!--- Loop over the steps in the gradient. --->
		<cfloop
			index="LOCAL.StepIndex"
			from="1"
			to="#LOCAL.StepCount#"
			step="1">
			
			<!--- Set the current drawing color. --->
			<cfset ImageSetDrawingColor( 
				LOCAL.Gradient, 
				(
					LOCAL.GradientSteps[ LOCAL.StepIndex ].Red & "," &
					LOCAL.GradientSteps[ LOCAL.StepIndex ].Green & "," &
					LOCAL.GradientSteps[ LOCAL.StepIndex ].Blue
				)) />
				
			<!--- 
				Set the drawing transparency. When doing this, 
				we have to be careful as we are not setting the 
				opacity, which is actually the opposite value. An 
				alpha channel of 255 is totally opaque, but requires 
				a tranparency of zero. 
			--->
			<cfset ImageSetDrawingTransparency(
				LOCAL.Gradient,
				(100 - (LOCAL.GradientSteps[ LOCAL.StepIndex ].Alpha / 255 * 100))
				) />
				
			<!--- 
				When we actually draw the rectangle, we have to take
				into account the direction of the gradient to figure 
				out where the individual step gradient will be applied. 
			--->
			<cfswitch expression="#ARGUMENTS.GradientDirection#">
				<cfcase value="TopBottom">
					
					<cfset ImageDrawRect(
						LOCAL.Gradient,
						0,
						(LOCAL.StepIndex - 1),
						ARGUMENTS.Width,
						1,
						true
						) />
						
				</cfcase>
				<cfcase value="BottomTop">
					
					<cfset ImageDrawRect(
						LOCAL.Gradient,
						0,
						(ARGUMENTS.Height - LOCAL.StepIndex),
						ARGUMENTS.Width,
						1,
						true
						) />
					
				</cfcase>
				<cfcase value="LeftRight">
				
					<cfset ImageDrawRect(
						LOCAL.Gradient,
						(LOCAL.StepIndex - 1),
						0,
						1,
						ARGUMENTS.Height,
						true
						) />
				
				</cfcase>
				<cfcase value="RightLeft">
					
					<cfset ImageDrawRect(
						LOCAL.Gradient,
						(ARGUMENTS.Width - LOCAL.StepIndex),
						0,
						1,
						ARGUMENTS.Height,
						true
						) />
						
				</cfcase>
			</cfswitch>
			
		</cfloop>
		
		
		<!--- Return gradient rectangle. --->
		<cfreturn LOCAL.Gradient />
	</cffunction>
	
	
	<cffunction
		name="DrawGradientRect"
		access="public"
		returntype="any"
		output="false"
		hint="Takes an image and draws the given gradient rectangle on it.">
		
		<!--- Define arguments. --->
		<cfargument
			name="Image"
			type="any"
			required="true"
			hint="The ColdFusion image object onto which we are drawing the gradient."
			/>
			
		<cfargument
			name="X"
			type="numeric"
			required="true"
			hint="The X coordinate at which to start drawing the rectangle."
			/>
			
		<cfargument
			name="Y"
			type="numeric"
			required="true"
			hint="The Y coordinate at which to start drawing the rectangle."
			/>
			
		<cfargument
			name="Width"
			type="numeric"
			required="true"
			hint="The width of the desired rectangle."
			/>
			
		<cfargument
			name="Height"
			type="numeric"
			required="true"
			hint="The height of the desired rectangle."
			/>
			
		<cfargument
			name="FromColor"
			type="struct"
			required="true"
			hint="The HEX, R,G,B,A list, or color struct for the start color of our gradient."
			/>
			
		<cfargument
			name="ToColor"
			type="struct"
			required="true"
			hint="TheHEX, R,G,B,A list, or color struct for the end color of our gradient."
			/>
			
		<cfargument
			name="GradientDirection"
			type="string"
			required="true"
			hint="The direction in which to darw the gradient. Possible values are TopBottom, BottomTop, LeftRight, and RightLeft."
			/>
		
		<!--- Define the local scope. --->
		<cfset var LOCAL = {} />
		
		<!--- Create the gradient rectangle. --->
		<cfset LOCAL.Gradient = THIS.CreateGradient(
			THIS.NormalizeColor( ARGUMENTS.FromColor ),
			THIS.NormalizeColor( ARGUMENTS.ToColor ),
			ARGUMENTS.GradientDirection,
			ARGUMENTS.Width,
			ARGUMENTS.Height
			) />
			
		<!--- Paste the gradient onto the image. --->
		<cfset ImagePaste(
			ARGUMENTS.Image,
			LOCAL.Gradient,
			ARGUMENTS.X,
			ARGUMENTS.Y
			) />
		
		<!--- Return the updated image. --->
		<cfreturn ARGUMENTS.Image />	
	</cffunction>

	
	<!---
		Author: Ben Nadel
		Taken from: http://www.bennadel.com/blog/977-ColdFusion-8-ImageDrawTextArea-Inspired-By-Barney-Boisvert.htm
	--->
	<cffunction
		name="DrawTextArea"
		access="public"
		returntype="void"
		output="true"
		hint="Draws a text area on the given canvas.">
		
		<cfargument 
			name="Source" 
			type="any"
			required="true"
			hint="The image on which we are going to write the text."
			/>
			
		<cfargument 
			name="Text" 
			type="string"
			required="true"
			hint="The text value that we are going to write."
			/>
			
		<cfargument 
			name="X" 
			type="numeric"
			required="true"
			hint="The X coordinate of the start of the text."
			/>
			
		<cfargument 
			name="Y" 
			type="numeric"
			required="true"
			hint="The Y coordinate of the baseline of the start of the text."
			/>
			
		<cfargument 
			name="Width" 
			type="numeric" 
			required="true"
			hint="The width of the text area in which the text should fit."
			/>
			
		<cfargument 
			name="Attributes" 
			type="struct"
			required="false"
			default="#StructNew()#"
			hint="The attributes of the font (including TextAlign and LineHeight)."
			/>
		
		
		<!--- Define the local scope. --->
		<cfset var LOCAL = {} />
		
		
		<!--- 
			In additional the standard attributes defined above, 
			this function allows for a few additional font 
			attributes. Let's give them some default values.
		--->	
		<cfparam 
			name="ARGUMENTS.Attributes.LineHeight" 
			type="numeric" 
			default="#(1.4 * ARGUMENTS.Attributes.Size)#" 
			/>
			
		<cfparam 
			name="ARGUMENTS.Attributes.TextAlign" 
			type="string" 
			default="left" 
			/>
			
		
		<!--- 
			Now, that we have our font-testing environment set up, 
			it's time to start figuring out how we are gonna layout
			the text. To begin, we are going to take the user's text
			and split it up into an array of word tokens (based on
			single spaces).
		--->
		<cfset LOCAL.Words = ARGUMENTS.Text.Split(
			JavaCast( "string", " " )
			) />
		
		<!--- 
			As we loop through the words, we are going to keep 
			track of which words fit onto each line and the 
			dimensions that that line occupies. To store this, we 
			will use an array of Line structures.
		--->
		<cfset LOCAL.Lines = [] />
		
		<!--- 
			Create the first line item. Here, the Text is the 
			string data for the line and the Width / Height are 
			the physical dimensions of the text.
		--->
		<cfset LOCAL.Lines[ 1 ] = {
			Text = "",
			Width = 0,
			Height = 0
			} />
		
		
		<!--- Loop over all the words. --->
		<cfloop
			index="LOCAL.WordIndex"
			from="1"
			to="#ArrayLen( LOCAL.Words )#"
			step="1">
			
			<!--- Get a short hand to the current word. --->
			<cfset LOCAL.Word = LOCAL.Words[ LOCAL.WordIndex ] />
			
			<!--- Get a short hand to the current line. --->
			<cfset LOCAL.Line = LOCAL.Lines[ ArrayLen( LOCAL.Lines ) ] />
			
			
			<!---
				Get the text dimensions of the current line with 
				the addition of the next word.
			--->
			<cfset LOCAL.Dimensions = THIS.GetTextDimensions(
				Trim( LOCAL.Line.Text & " " & LOCAL.Word ),
				StructCopy( ARGUMENTS.Attributes )
				) />
				
			<!--- 
				Now that we have the physical dimensions, we need to
				check to see if new line would be too wide for the
				text area. If it is too wide and there is not text 
				on the line yet, then add it anyway as it simply is 
				too wide for the text area.
			--->
			<cfif (
				(LOCAL.Dimensions.Width LTE ARGUMENTS.Width) OR
				(NOT Len( LOCAL.Line.Text ))			
				)>
			
				<!--- 
					The current word will fit on the current line 
					so add it to the string data of the line. If 
					this is NOT the first word, be sure to add a 
					preceeding space.
				--->
				<cfset LOCAL.Line.Text &= (
					IIF(
						Len( LOCAL.Line.Text ), 
						DE( " " ), 
						DE( "" ) 
						) & 
					LOCAL.Word
					) />
				
				<!--- 
					Since the text data of this line has been 
					updated, we need to get the updated dimensions 
					of the line. When it comes go getting the width,
					we have to be careful about lines that are too
					wide for the text area. We never want to record
					any width that is larger than the text area.
				--->
				<cfset LOCAL.Line.Width = Min( 
					LOCAL.Dimensions.Width, 
					ARGUMENTS.Width 
					) />
					
				<!--- Get height. --->
				<cfset LOCAL.Line.Height = LOCAL.Dimensions.Height />
				
			<cfelse>
			
				<!---
					Due to the dimensions of the potential line, we 
					are going to have to move the current word to a 
					new line. For this we must create a new line 
					object and insert the word.
				--->
				
				<!--- 
					Get the bounds of the new line (which will be 
					the same as the bounds of the current word).
				--->
				<cfset LOCAL.Dimensions = THIS.GetTextDimensions(
					LOCAL.Word,
					StructCopy( ARGUMENTS.Attributes )
					) />
					
				<!--- Create a new line object. --->
				<cfset LOCAL.Line = {
					Text = LOCAL.Word,
					Width = LOCAL.Dimensions.Width,
					Height = LOCAL.Dimensions.Height
					} />			
			
				<!--- Append the new line object to our array. --->
				<cfset ArrayAppend(
					LOCAL.Lines,
					LOCAL.Line
					) />
			
			</cfif>
			
		</cfloop>
		
		
		<!--- 
			ASSERT: At this point, we have determined which text 
			will go on which lines of our rendered text area. We
			also know the dimensions of each line of text.
		--->
			
		
		<!--- 
			Now, it's time to actually draw the text on the passed 
			in image object. Loop over the lines array. 
		--->
		<cfloop
			index="LOCAL.LineIndex"
			from="1"
			to="#ArrayLen( LOCAL.Lines )#"
			step="1">
			
			<!--- Get a shorthand to the current line object. --->
			<cfset LOCAL.Line = LOCAL.Lines[ LOCAL.LineIndex ] />
			
			
			<!--- 
				Let's determine the X-coordinate of this line of 
				text. This will depend on the alignment of the text
				(left, center, right).
			--->
			<cfswitch expression="#ARGUMENTS.Attributes.TextAlign#">
			
				<!--- Right aligned text. --->
				<cfcase value="right">
				
					<cfset LOCAL.X = (
						ARGUMENTS.X + 
						ARGUMENTS.Width - 
						LOCAL.Line.Width
						) />
					
				</cfcase>
				
				<!--- Center align text. --->
				<cfcase value="center">
				
					<cfset LOCAL.X = (
						ARGUMENTS.X + 
						Fix( 
							(ARGUMENTS.Width - LOCAL.Line.Width) /
							2
						)) />
				
				</cfcase>
			
				<!--- Left aligned text. --->
				<cfdefaultcase>
					
					<cfset LOCAL.X = ARGUMENTS.X />
					
				</cfdefaultcase>
			</cfswitch>
			
			
			<!--- 
				When getting the Y value of the line, we have to 
				take into account line height and count of the 
				current line. This is for the baseline of the text,
				NOT the top-left-most corner.
			--->
			<cfset LOCAL.Y = (
				ARGUMENTS.Y + 
				(
					(LOCAL.LineIndex - 1) * 
					ARGUMENTS.Attributes.LineHeight
				)) />
			
			
			
			<!--- 
				Draw the text at the given coordinates. Pass in 
				the structure that we got. This Attributes structure
				will contain extraneous information (TextAlign, 
				LineHeight), but this will not throw an error.
			--->
			<cfset ImageDrawText(
				ARGUMENTS.Source,
				LOCAL.Line.Text,
				LOCAL.X,
				LOCAL.Y,
				ARGUMENTS.Attributes
				) />
			
		</cfloop>
		
			
		<!--- Return out. --->
		<cfreturn />
	</cffunction>
	
	
	<cffunction 
		name="EasyCaptcha"
		access="public"
		returntype="array"
		output="true"
		hint="Outputs a CAPTCHA problem using a series of images rather than one image.">
		
		<!--- Define arguments. --->
		<cfargument
			name="Text"
			type="string"
			required="true"
			hint="The text that will be output in the CAPTCHA."
			/>
			
		<cfargument
			name="FontSize"
			type="string"
			required="false"
			default="20"
			hint="The font size to use for the CAPTCHA."
			/>
			
		<cfargument
			name="BackgroundColor"
			type="string"
			required="false"
			default="##FAFAFA"
			hint="The canvas color."
			/>
			
		<cfargument 
			name="Color"
			type="string"
			required="false"
			default="##333333"
			hint="The drawing (Text) color."
			/>
			
		<!--- Define the local scope. --->
		<cfset var LOCAL = {} />
		
		<!--- Set the font properties. --->
		<cfset LOCAL.FontProperties =  {
			Font = "Courier New",
			Size = ToString( ARGUMENTS.FontSize ),
			Style = "normal"
			} />
	
		
		<!--- 
			Create the array in which we are going to store the 
			individual images. Each image will represent a single
			characer in the CAPTCHA.
		--->
		<cfset LOCAL.Images = [] />
		
		
		<!--- Loop over the characters in the given text. --->
		<cfloop
			index="LOCAL.CharacterIndex"
			from="1"
			to="#Len( ARGUMENTS.Text )#"
			step="1">
			
			<!--- Get character. --->
			<cfset LOCAL.Character = Mid( 
				ARGUMENTS.Text, 
				LOCAL.CharacterIndex, 
				1 
				) />
				
			<!--- Get character dimensions. --->
			<cfset LOCAL.Dimensions = THIS.GetTextDimensions(
				LOCAL.Character, 
				LOCAL.FontProperties
				) />
			
			<!--- Create a new image. --->
			<cfset LOCAL.Image = ImageNew(
				"",
				(LOCAL.Dimensions.Width + 6),
				Ceiling( LOCAL.Dimensions.Height * 1.5 ),
				"rgb",
				ARGUMENTS.BackgroundColor
				) />
			
			<!--- Set the drawing color. --->
			<cfset ImageSetDrawingColor(
				LOCAL.Image,
				ARGUMENTS.Color
				) />
			
			<!--- Draw character on canvas. --->
			<cfset ImageDrawText(
				LOCAL.Image,
				LOCAL.Character,
				3,
				Ceiling( LOCAL.Dimensions.Height * 1.1 ),
				LOCAL.FontProperties
				) />
			
			<!--- Add the image to the return array. --->
			<cfset ArrayAppend(
				LOCAL.Images,
				LOCAL.Image
				) />
			
		</cfloop>
		
		
		<!--- 
			Create a local buffer to which to save the images. We 
			are doing this so that we can strip out the white space 
			between the individual images to make a cleaner output. 
		--->
		<cfsavecontent variable="LOCAL.Buffer">
		
			<!--- Loop over images array. --->
			<cfloop
				index="LOCAL.Image"
				array="#LOCAL.Images#">
				
				
				<!--- Write character to response buffer. --->
				<cfimage
					action="writetobrowser"
					source="#LOCAL.Image#"
					format="gif"
					/>
							
			</cfloop>
		
		</cfsavecontent>
		
		<!--- Strip out all white space that is not in a tag. --->
		<cfset LOCAL.Buffer = Trim(
			REReplace(
				LOCAL.Buffer,
				"\s+(?=<)",
				"",
				"all"
				) 
			) />
			
		<!--- Write the buffer out to the repsonse. --->
		<cfset WriteOutput( LOCAL.Buffer ) />	
		
		
		<!--- Return image array. --->
		<cfreturn LOCAL.Images />
	</cffunction>
	

	<!---
	This code is credited to Ben Nadel, Barney Boisvert, and a user named C S
	--->
	<cffunction name="getCenteredTextPosition" access="public" returnType="struct" output="false">
		<cfargument name="image" type="any" required="true">
		<cfargument name="text" type="string" required="true">
		<cfargument name="fontname" type="any" required="true" hint="This can either be the name of a font, or a structure containing style,size,font, like you would use for imageDrawText">
		<cfargument name="fonttype" type="string" required="false" hint="Must be ITALIC, PLAIN, or BOLD">
		<cfargument name="fontsize" type="string" required="false">
		
		<cfset var buffered = imageGetBufferedImage(arguments.image)>
		<cfset var context = buffered.getGraphics().getFontRenderContext()>
		<cfset var font = createObject("java", "java.awt.Font")>
		<cfset var textFont = "">
		<cfset var textLayout = "">
		<cfset var textBounds = "">
		<cfset var result = structNew()>
		<cfset var fp = "">
		<cfset var width = "">
		<cfset var height = "">
		
		<!--- Handle arguments.fontName possibly being a structure. --->
		<cfif isStruct(arguments.fontname)>
			<cfset arguments.fonttype = arguments.fontname.style>
			<cfset arguments.fontsize = arguments.fontname.size>
			<cfset arguments.fontname = arguments.fontname.font>
		</cfif>
		
		<!--- possibly refactor --->	
		<cfif arguments.fonttype is "plain">
			<cfset fp = font.PLAIN>
		<cfelseif arguments.fonttype is "bold">
			<cfset fp = font.BOLD>
		<cfelse>
			<cfset fp = font.ITALIC>
		</cfif>
	
		<cfset textFont = font.init(arguments.fontname, fp, javacast("int", arguments.fontsize))>
		<cfset textLayout = createObject("java", "java.awt.font.TextLayout").init( arguments.text, textFont, context)>
		<cfset textBounds = textLayout.getBounds()>
		<cfset width = textBounds.getWidth()>
		<cfset height = textBounds.getHeight()>
		
		<cfset result.x = (arguments.image.width/2 - width/2)>
		<cfset result.y = (arguments.image.height/2 + height/2)>
	
		<cfreturn result>
	</cffunction>
	
	<cffunction
		name="GetPixel"
		access="public"
		returntype="struct"
		output="false"
		hint="Returns a struct containing the given pixel RGBA data.">
		
		<!--- Define arguments. --->
		<cfargument
			name="Image"
			type="any"
			required="true"
			hint="The ColdFusion image object whose pixel data map we are returning."
			/>
			
		<cfargument
			name="X"
			type="numeric"
			required="true"
			hint="The X coordinate of the pixel that we are returning."
			/>
			
		<cfargument
			name="Y"
			type="numeric"
			required="true"
			hint="The Y coordinate of the pixel that we are returning."
			/>
			
		<!--- Define the local scope. --->
		<cfset var LOCAL = {} />
		
		<!--- Get the pixels array for a 1x1 area. --->
		<cfset LOCAL.Pixels = GetPixels(
			ARGUMENTS.Image,
			ARGUMENTS.X,
			ARGUMENTS.Y,
			1,
			1
			) />
			
		<!--- Return the first returned pixel. --->
		<cfreturn LOCAL.Pixels[ 1 ][ 1 ] />
	</cffunction>
	
	
	<cffunction
		name="GetPixels"
		access="public"
		returntype="array"
		output="false"
		hint="Returns a two dimensional array of RGBA values for the image. Array will be in the form of Pixels[ Y ][ X ] where Y is along the height axis and X is along the width axis.">
		
		<!--- Define arguments. --->
		<cfargument
			name="Image"
			type="any"
			required="true"
			hint="The ColdFusion image object whose pixel map we are returning."
			/>
			
		<cfargument
			name="X"
			type="numeric"
			required="false"
			default="1"
			hint="The default X point where we will start getting our pixels (will be translated to 0-based system for Java interaction)."
			/>
			
		<cfargument
			name="Y"
			type="numeric"
			required="false"
			default="1"
			hint="The default Ypoint where we will start getting our pixels (will be translated to 0-based system for Java interaction)."
			/>
			
		<cfargument
			name="Width"
			type="numeric"
			required="false"
			default="#ImageGetWidth( ARGUMENTS.Image )#"
			hint="The width of the area from which we will be sampling pixels."
			/>
			
		<cfargument
			name="Height"
			type="numeric"
			required="false"
			default="#ImageGetHeight( ARGUMENTS.Image )#"
			hint="The height of the area from which we will be sampling pixels."
			/>
			
		<!--- Define the local scope. --->
		<cfset var LOCAL = {} />
		
		<!--- Define the pixels array. --->
		<cfset LOCAL.Pixels = [] />
		
		<!--- 
			Get the image data raster. This holds all the data 
			for the buffered image and will give us access to the
			individual pixel data.
		--->
		<cfset LOCAL.Raster = ImageGetBufferedImage( ARGUMENTS.Image ).GetRaster() />
		
		
		<!--- 
			Now, starting at our Y position, we want to move down 
			each column (Y-direction) and gather the pixel values
			for each row along the Y-axis. 
		--->
		<cfloop
			index="LOCAL.Y"
			from="#ARGUMENTS.Y#"
			to="#(ARGUMENTS.Y + ARGUMENTS.Height - 1)#"
			step="1">
			
			<!--- 
				Create a nested array for this row of pixels. 
				Remember, the data will be in the Pixel[ Y ][ X ] 
				array format.
			--->
			<cfset ArrayAppend(
				LOCAL.Pixels,
				ArrayNew( 1 )
				) />
				
			<!--- 
				Loop over this row of pixels at this given Y-axis
				position.
			--->
			<cfloop
				index="LOCAL.X"
				from="#ARGUMENTS.X#"
				to="#(ARGUMENTS.X + ARGUMENTS.Width - 1)#"
				step="1">
				
				<!--- 
					Create an In-array to be used to retreive the 
					color data. Each element will be used for the
					Red, Green, Blue, and Alpha channels respectively.
					Be sure to use the JavaCast() here rather than 
					when we pass in the array to the GetPixel() 
					method. This way, we don't lose the reference
					to the array value.
				--->
				<cfset LOCAL.PixelArray = JavaCast( 
					"int[]", 
					ListToArray( "0,0,0,0" ) 
					) />
			
				<!--- Get the pixel data array. --->
				<cfset LOCAL.Raster.GetPixel(
					JavaCast( "int", LOCAL.X ),
					JavaCast( "int", LOCAL.Y ),
					LOCAL.PixelArray
					) />
					
				<!--- 
					Now that we have an index-based pixel data 
					array, let's convert the the data into a keyed 
					struct that will be more user friendly.
				--->
				<cfset LOCAL.Pixel = THIS.NormalizeColor(
					"#LOCAL.PixelArray[ 1 ]#,#LOCAL.PixelArray[ 2 ]#,#LOCAL.PixelArray[ 3 ]#,#LOCAL.PixelArray[ 4 ]#"
					) />
					
				<!--- Add this pixel data to curren row. --->
				<cfset ArrayAppend(
					LOCAL.Pixels[ ArrayLen( LOCAL.Pixels ) ],
					LOCAL.Pixel
					) />
				
			</cfloop>
			
		</cfloop>	
		
		
		<!--- Return pixels. --->
		<cfreturn LOCAL.Pixels />
	</cffunction>
	
	
	<cffunction
		name="GetTextDimensions"
		access="public"
		returntype="struct"
		output="false"
		hint="Give the string and the font properties, the width and height of the text is calculated. If the font properties struct is missing any values, ColdFusion's default values will be used.">
		
		<!--- Define arguments. --->
		<cfargument
			name="Text"
			type="string"
			required="true"
			hint="The text whose dimensions we are going to calculate."
			/>
			
		<cfargument
			name="FontProperties"
			type="struct"
			required="true"
			hint="The font properties used to calculate the text dimensions."
			/>
			
		<!--- Define the local scope. --->
		<cfset var LOCAL = {} />
		
		<!--- 
			Create an canvas to work with. We won't actually need 
			to draw on this, we just need it to get access to some 
			of the default values that ColdFusion uses plus we can 
			get access to some of the utility methods. 
		--->
		<cfset LOCAL.Image = ImageNew( "", 1, 1, "rgb" ) />
		
		<!---
			From our temporary ColdFusion image, get the underlying 
			Java AWT object. This will allow us access to properties 
			that we will need to space and style the font.
		--->
		<cfset LOCAL.Graphics = ImageGetBufferedImage( LOCAL.Image )
			.GetGraphics() 
			/>
	 
		<!---
			Get the font that is currently set in the image. From
			this, we will be able to default the properties of our
			text attributes (any that were not set explicitly).
		--->
		<cfset LOCAL.CurrentFont = LOCAL.Graphics.GetFont() />
	 
	 
		<!---
			Now, we are going to check to see if the passed in
			font properties has all the properties that we need to
			properly render the new font. If it does not, then we
			are going to use the ColdFusion default values that are
			supplied with our temporary canvas.
		---> 
	 
		<!--- Check for a defined size.--->
		<cfif NOT StructKeyExists( ARGUMENTS.FontProperties, "Size" )>
	 
			<!--- Get size from current font. --->
			<cfset ARGUMENTS.FontProperties.Size = LOCAL.CurrentFont.GetSize() />
	 
		</cfif>
	 
	 
		<!--- Check for a defined font. --->
		<cfif NOT StructKeyExists( ARGUMENTS.FontProperties, "Font" )>
	 
	 		<!--- Get font name from current font. --->
			<cfset ARGUMENTS.FontProperties.Font = LOCAL.CurrentFont.GetFontName() />
	 
		</cfif>
	 
	 
		<!--- Check for a defined style. --->
		<cfif NOT StructKeyExists( ARGUMENTS.FontProperties, "Style" )>
	 
			<!---
				When it comes to defaulting the style, we need to
				build not only the font attributes, but also the
				font style argument for creating our new font (for
				the Font Metrics). Because of that, we will be
				building a bit-mask for the style.
	 
				Because the Styles are just constants, we can pull
				them out of our Current Font object.
			--->
			<cfif (
				LOCAL.CurrentFont.IsBold() AND
				LOCAL.CurrentFont.IsItalic()
				)>
	 
				<!--- Set the style. --->
				<cfset ARGUMENTS.FontProperties.Style = "bolditalic" />
	 
				<!--- Set the bit mask. --->
				<cfset LOCAL.FontStyleMask = BitOR(
					LOCAL.CurrentFont.BOLD,
					LOCAL.CurrentFont.ITALIC
					) />
	 
			<cfelseif LOCAL.CurrentFont.IsBold()>
	 
				<!--- Set the style. --->
				<cfset ARGUMENTS.FontProperties.Style = "bold" />
	 
				<!--- Set the bit mask. --->
				<cfset LOCAL.FontStyleMask = LOCAL.CurrentFont.BOLD />
	 
			<cfelseif LOCAL.CurrentFont.IsItalic()>
	 
				<!--- Set the style. --->
				<cfset ARGUMENTS.FontProperties.Style = "italic" />
	 
				<!--- Set the bit mask. --->
				<cfset LOCAL.FontStyleMask = LOCAL.CurrentFont.ITALIC />
	 
			<cfelse>
	 
				<!--- Set the style. --->
				<cfset ARGUMENTS.FontProperties.Style = "plain" />
	 
				<!--- Set the bit mask. --->
				<cfset LOCAL.FontStyleMask = LOCAL.CurrentFont.PLAIN />
	 
			</cfif>
	 
		<cfelse>
	 
			<!--- Set the plain font mask. --->
			<cfset LOCAL.FontStyleMask = LOCAL.CurrentFont.PLAIN />
	 
		</cfif>
	 
	 
	 	<!--- 
			ASSERT: At this point, we have fully set up our font 
			properties struct (filling in any gaps that the user 
			missed), as well as create a style bit-mask based on 
			those properties. We  now have enough information to 
			create a new Java Font object.
		--->
	 
	 
		<!---
			Now that we have our Font attributes all paramed, we
			need to create a new Font object (that will be used to
			get the Font Metrics for the passed-in text).
		--->
		<cfset LOCAL.NewFont = CreateObject(
			"java",
			"java.awt.Font"
			).Init(
				JavaCast( "string", ARGUMENTS.FontProperties.Font ),
				JavaCast( "int", LOCAL.FontStyleMask ),
				JavaCast( "int", ARGUMENTS.FontProperties.Size )
				)
			/>
	 
		<!---
			Now that we have our new Font set up, get the
			Font Metrics for our graphic in the context of
			the new Font.
		--->
		<cfset LOCAL.FontMetrics = LOCAL.Graphics.GetFontMetrics(
			LOCAL.NewFont
			) />
	 
		<!---
			Using the Font Metrics, get the bounds of the
			current text line with the addition of the next
			word.
		--->
		<cfset LOCAL.TextBounds = LOCAL.FontMetrics.GetStringBounds(
			JavaCast( "string", ARGUMENTS.Text ),
			LOCAL.Graphics
			) />
			
			
		<!--- Now that we have the font metrics, let's create the dimensions return value. --->
		<cfset LOCAL.Return = {
			Width = Ceiling( LOCAL.TextBounds.GetWidth() ),
			Height = Ceiling( LOCAL.TextBounds.GetHeight() )
			} />
	
		<!--- Return text dimensions. --->
		<cfreturn LOCAL.Return />
	</cffunction>
	
	<!---
		Author: Todd Sharp
	--->
	<cffunction name="getThumbnail" returnType="any" output="false" hint="Returns binary data, not a CF Image">
		<cfargument name="url" type="string" required="false" default="" />
		<cfargument name="content" type="string" required="false" hint="pass a string of formatted content (instead of a url)" default="" />
		<cfargument name="scale" type="numeric" required="false" default="25">
		
		<cfset var pdfdata = "">
		<cfset var prefix = replace(createUUID(),"-","_","all")>
		<cfset var myimage = "">
		
		<!--- make the pdf --->
		<cfif len(arguments.url)>
			<cfdocument src="#arguments.url#" name="pdfdata" format="pdf" />
		<cfelseif len(arguments.content)>
			<cfdocument name="pdfdata" format="pdf"><cfoutput>#arguments.content#</cfoutput></cfdocument>
		<cfelse>
			<cfthrow type="getThumbnail.invalidCall" message="You must pass a url or content into this function." />
		</cfif>
		
		<!--- write out the image --->
		<cfpdf source="pdfdata" pages="1" action="thumbnail" destination="#expandPath('./')#" format="jpg" overwrite="true" resolution="high" scale="#arguments.scale#" imagePrefix="#prefix#">
		
		<!--- read it in --->
		<cffile action="readbinary" file="#expandPath('./#prefix#_page_1.jpg')#" variable="myimage">
		
		<!--- clean it up --->
		<cffile action="delete" file="#expandPath('./#prefix#_page_1.jpg')#">
		<cfreturn myimage>

	</cffunction>
	
	<!---
		Author: Ben Nadel
		Taken from: http://www.bennadel.com/blog/1028-Getting-The-URL-Of-ColdFusion-8-s-Temporary-Images.htm
	--->
	<cffunction
		name="GetUrl"
		access="public"
		returntype="string"
		output="false"
		hint="Returns the URL of the temporary image generated from the passed in ColdFusion image object.">
		
		<!--- Define arguments. --->
		<cfargument
			name="Source"
			type="any"
			required="true"
			hint="The ColdFusion image object who's URL we want to get."
			/>
		
		<cfargument
			name="Format"
			type="string"
			required="false"
			default="png"
			hint="The file type of the image we want to use."
			/>
			
		<!--- Define the local scope. --->
		<cfset var LOCAL = {} />
		
		
		<!--- Store the output of the image. --->
		<cfsavecontent variable="LOCAL.Output">
		
			<!--- Write the image the output buffer. --->
			<cfimage
				action="writetobrowser"
				source="#ARGUMENTS.Source#"
				format="#ARGUMENTS.Format#"
				/>
		
		</cfsavecontent>
		
		
		<!--- 
			Extract the URL of the temporary image. This will give 
			us an array of the matches, which should only be one.
		--->
		<cfset LOCAL.URL = REMatch(
			"(?i)src\s*=\s*""[^""]+",
			LOCAL.Output
			) />
			
		<!--- 
			Clean up the SRC that we extracted. We can think of the 
			value a double-quote delimited list in which our true 
			SRC value is the last item.
		--->
		<cfset LOCAL.URL = ListLast( LOCAL.URL[ 1 ], """" ) />
		
		<!--- Return the URL. --->
		<cfreturn LOCAL.URL />	
	</cffunction>
	
	
	<cffunction 
		name="HexToRGB"
		access="public"
		returntype="struct"
		output="false"
		hint="Takes a 6 digit hex value and returns a struct with Red, Green, and Blue keys.">
		
		<!--- Define arguments. --->
		<cfargument
			name="Hex"
			type="string"
			required="true"
			hint="The 6 digit hex color value."
			/>
			
		<!--- Define the local scope. --->
		<cfset var LOCAL = {} />
		
		<!--- Remove any non-hex values. --->
		<cfset ARGUMENTS.Hex = REReplace(
			ARGUMENTS.Hex,
			"(?i)[^0-9A-F]+",
			"",
			"all"
			) />
			
		<!--- Get the decimal value of this hex. --->
		<cfset LOCAL.DecimalColor = InputBaseN( ARGUMENTS.Hex, "16" ) />
		
		<!--- Create the RGB struct. --->
		<cfset LOCAL.Return = {
			Red = BitSHRN(
				BitAnd( LOCAL.DecimalColor, InputBaseN( "FF0000", 16 ) ),
				16
				),
			Green = BitSHRN(
				BitAnd( LOCAL.DecimalColor, InputBaseN( "00FF00", 16 ) ),
				8
				),
			Blue = BitAnd( LOCAL.DecimalColor, InputBaseN( "0000FF", 16 ) ),
			Alpha = 255
			} />
			
		<!--- Return RGB color. --->
		<cfreturn LOCAL.Return />	
	</cffunction>
	
	<!---
	Author: Daniel Budde II
	--->
	<cffunction name="IsMultiTiff" access="public" returntype="boolean" output="false" hint="Determines if the file is a multi-page TIFF format.">
		<cfargument name="TIFF" type="string" required="yes" hint="Path to source TIFF file." />

		<cfset var LOCAL = {} />

		<cfif not FileExists(arguments.TIFF)>
			<cfthrow message="Missing input file." detail="Could not locate Tiff file (#arguments.TIFF#)." />
		</cfif>

		<cfset LOCAL.isMultiTIFF = false />
		<cfset LOCAL.totalPages = TiffPageCount(arguments.TIFF) />

		<cfif LOCAL.totalPages gt 1>
			<cfset LOCAL.isMultiTIFF = true />
		</cfif>

		<cfreturn LOCAL.isMultiTIFF />
	</cffunction>
	

	<!---
		Author		: Daniel Budde
	--->
	<cffunction name="IsTiff" access="public" returntype="boolean" output="false" hint="Determines if the file is a TIFF format.">
		<cfargument name="TIFF" type="string" required="yes" hint="Path to source TIFF file." />

		<cfset var LOCAL = {} />

		<cfif not FileExists(arguments.TIFF)>
			<cfthrow message="Missing input file." detail="Could not locate Tiff file (#arguments.TIFF#)." />
		</cfif>

		<cfset LOCAL.isTIFF = false />
		<cfset LOCAL.TIFFile = CreateObject("java", "java.io.File").init(arguments.TIFF) />
		<cfset LOCAL.FileSeekableStream = CreateObject("java", "com.sun.media.jai.codec.FileSeekableStream").init(LOCAL.TIFFile) />
		<cfset LOCAL.names = CreateObject("java", "com.sun.media.jai.codec.ImageCodec").getDecoderNames(LOCAL.FileSeekableStream) />

		<cfloop array="#LOCAL.names#" index="LOCAL.name">
			<cfif LOCAL.name eq "tiff">
				<cfset LOCAL.isTIFF = true />
				<cfbreak />
			</cfif>
		</cfloop>

		<cfreturn LOCAL.isTIFF />
	</cffunction>
	
	<!---
		Author: Ray Camden
		Taken from: http://www.coldfusionjedi.com/index.cfm/2007/10/10/Simple-ColdFusion-8-Drop-Shadow-Example
		Note: Ben Nadel has modified the formatting and added comments / hints.
	--->
	<cffunction 
		name="makeShadow" 
		access="public"
		returntype="any"
		output="false"
		hint="Adds a drop shadow with the given offset, blur, and color properties. The shadow increases the size of the image canvas.">
		
		<!--- Define arguments. --->
		<cfargument 
			name="image" 
			type="any" 
			required="true"
			hint="The ColdFusion image object or path to an image file."
			/>
			
		<cfargument 
			name="offset" 
			type="numeric" 
			required="true"
			hint="The pixel offset of the drop shadow (out and down)."
			/>
			
		<cfargument 
			name="blur" 
			type="numeric" 
			required="true"
			hint="The pixel amount by which the shadow should be blurred."
			/>
			
		<cfargument 
			name="shadowcol" 
			type="string" 
			required="false" 
			default="145,145,145"
			hint="The color of the drop shadow color (can be R,G,B, Hex, or named colors)."
			/>
			
		<cfargument 
			name="backgroundcol" 
			type="string" 
			required="false" 
			default="white"
			hint="The color of the canvas color that goes around shadow (can be R,G,B, Hex, or named colors)."
			/>
	
		<!--- Define local variables. --->
		<cfset var newwidth = "" />
		<cfset var newheight = "" />
		<cfset var shadow = "" />
		
	
		<!--- If not image, assume path. --->
		<cfif (
			(NOT isImage(arguments.image)) AND
			(NOT isImageFile(arguments.image))
			)>
			<cfthrow message="The value passed to makeShadow was not an image." />
		</cfif>
		
		<!--- If we were given a path to an image, read the image into a ColdFusion image object. --->
		<cfif isImageFile(arguments.image)>
			<cfset arguments.image = imageRead(arguments.image) />
		</cfif>
		
		<!--- Calculate the dimensions of the new canvas. --->
		<cfset newwidth = arguments.image.width + (2*offset) />
		<cfset newheight = arguments.image.height + (2*offset) />
		
		<!--- Make a blank image the same size as original. --->
		<cfset shadow = imageNew("", newwidth, newheight, "rgb", arguments.backgroundcol)>
		<cfset imageResize(shadow, newwidth, newheight) />
		<cfset imageSetDrawingColor(shadow,arguments.shadowcol) />
		<cfset imageDrawRect(shadow, arguments.offset, arguments.offset, arguments.image.width, arguments.image.height, true) />
		
		<!--- Blur the image. --->
		<cfset imageBlur(shadow, arguments.blur)>
		
		<!--- Paste the original image over the blurred shaddow image. --->
		<cfset imagePaste(shadow,arguments.image,0,0) />
		
		<!--- Return new image with drop shadow. --->
		<cfreturn shadow>
	</cffunction>
		
		
	<cffunction
		name="NormalizeColor"
		access="public"
		returntype="struct"
		output="false"
		hint="Take a HEX value or R,G,B[,A] list and creates a normalized color structure that can be safely used by the other functions of this utility component.">
		
		<!--- Define arguments. --->
		<cfargument 
			name="Color"
			type="any"
			required="true"
			hint="A HEX or R,G,B[,A] color list or struct."
			/>
			
		<!--- Define the local scope. --->
		<cfset var LOCAL = {} />
		
		<!--- 
			Create the default color object. This will get returned if the 
			passed-in color cannot be normalized.
		--->
		<cfset LOCAL.Return = {
			Red = 255,
			Green = 255,
			Blue = 255,
			Alpha = 255,
			Hex = "##FFFFFF"
			} />
		
		
		<!--- Check to see if the passed in value is a struct. --->
		<cfif IsStruct( ARGUMENTS.Color )>
		
			<!--- The passed in color was a struct. Let's see if we can copy over the R,G,B,A values. --->
			<cfloop
				index="LOCAL.Key"
				list="Red,Green,Blue,Alpha"
				delimiters=",">
					
				<cfif StructKeyExists( ARGUMENTS.Color, LOCAL.Key )>
				
					<!--- Copy this key to return color. --->
					<cfset LOCAL.Return[ LOCAL.Key ] = ARGUMENTS.Color[ LOCAL.Key ] />
				
				</cfif>
				
			</cfloop>		
		
		<!--- Check to see if we are dealing with a HEX value or an R,G,B list. --->
		<cfelseif REFind( "(?i)^##?[0-9A-F]{6}$", ARGUMENTS.Color )>
		
			<!--- Strip out the non-hex characters values. --->
			<cfset ARGUMENTS.Color = REReplace(
				ARGUMENTS.Color,
				"(?i)[^0-9A-F]+",
				"",
				"all"
				) />
				
			<!--- Get the decimal value of this hex. --->
			<cfset LOCAL.DecimalColor = InputBaseN( ARGUMENTS.Color, "16" ) />
			
			<!--- Set the red channel. --->
			<cfset LOCAL.Return.Red = BitSHRN(
					BitAnd( LOCAL.DecimalColor, InputBaseN( "FF0000", 16 ) ),
					16
					) />
					
			<!--- Set the green channel. --->
			<cfset LOCAL.Return.Green = BitSHRN(
					BitAnd( LOCAL.DecimalColor, InputBaseN( "00FF00", 16 ) ),
					8
					) />
				
			<!--- Set the blue channel. --->
			<cfset LOCAL.Return.Blue = BitAnd( LOCAL.DecimalColor, InputBaseN( "0000FF", 16 ) ) />
				
		<!--- Check to see if we are dealing with a list of R,G,B colors. --->
		<cfelseif REFind( "^\d+,\d+,\d+$", ARGUMENTS.Color )>
		
			<!--- Store the channels. --->
			<cfset LOCAL.Return.Red = ListGetAt( ARGUMENTS.Color, 1 ) />
			<cfset LOCAL.Return.Green = ListGetAt( ARGUMENTS.Color, 2 ) />
			<cfset LOCAL.Return.Blue = ListGetAt( ARGUMENTS.Color, 3 ) />
			
		<!--- Check to see if we are dealing with a list of R,G,B,A colors. --->
		<cfelseif REFind( "^\d+,\d+,\d+,\d+$", ARGUMENTS.Color )>
		
			<!--- Store the channels. --->
			<cfset LOCAL.Return.Red = ListGetAt( ARGUMENTS.Color, 1 ) />
			<cfset LOCAL.Return.Green = ListGetAt( ARGUMENTS.Color, 2 ) />
			<cfset LOCAL.Return.Blue = ListGetAt( ARGUMENTS.Color, 3 ) />
			<cfset LOCAL.Return.Alpha = ListGetAt( ARGUMENTS.Color, 4 ) />
		
		</cfif>
		
		
		<!--- Set the HEX value based on the RGB. --->
		<cfset LOCAL.Return.Hex = UCase(
			Right( "0#FormatBaseN( LOCAL.Return.Red, '16' )#", 2 ) &
			Right( "0#FormatBaseN( LOCAL.Return.Green, '16' )#", 2 ) &
			Right( "0#FormatBaseN( LOCAL.Return.Blue, '16' )#", 2 )
			) />
			
		<!--- Return RGB color. --->
		<cfreturn LOCAL.Return />	
		
	</cffunction>


	<!---
		Function: OpacityBlend
		Author: Emmet McGovern
		http://www.illequipped.com/blog
		emmet@fullcitymedia.com
		4/27/2008 - Macaroni Self-Portrait Day!
	--->
	<cffunction name="OpacityBlend" access="public" returntype="any" output="false" hint="">
		
		<!--- Define arguments. --->
		<cfargument name="foreground" type="any" required="true" hint="" />
		<cfargument name="background" type="any" required="true" hint="" />
		<cfargument name="opacity" type="numeric" required="true" hint="" />
		
		<!--- Define local variables. --->
		<cfset var fRGB = "" />
		<cfset var bRGB = "" />
		<cfset var blendRGB = {} />
		<cfset var blendHEX = "" />
		<cfset var transparency = "" />
		
		<cfset arguments.foreground = REReplace(arguments.foreground,"(?i)[^0-9A-F]+","","all") />
		<cfset arguments.background = REReplace(arguments.background,"(?i)[^0-9A-F]+","","all") />
		
		<cfif NOT reFindNoCase('^##?([a-f]|[A-F]|[0-9]){6}?$',arguments.foreground) OR NOT reFindNoCase('^##?([a-f]|[A-F]|[0-9]){3}(([a-f]|[A-F]|[0-9]){3})?$',arguments.background)>
			<cfthrow message="All colors passed must be in 6 character hexidecimal format." />
		</cfif>
		
		<cfif arguments.opacity GTE 100>
			<cfset blendHEX = arguments.foreground>
		<cfelseif arguments.opacity LTE 0>
			<cfset blendHEX = arguments.background>
		<cfelse>
		
		<cfset fRGB = HexToRGB(arguments.foreground)>
		<cfset bRGB = HexToRGB(arguments.background)>
		
		<cfset transparency = 100 - arguments.opacity>
		
		<cfset blendRGB.red =  ceiling((bRGB.red - fRGB.red) / 100 * transparency + fRGB.red)>
		<cfset blendRGB.green = ceiling((bRGB.green - fRGB.green) / 100 * transparency + fRGB.green)>
		<cfset blendRGB.blue = ceiling((bRGB.blue - fRGB.blue) / 100 * transparency + fRGB.blue)>

		<cfset blendHex = UCase(
			Right( "0#FormatBaseN( blendRGB.red, '16' )#", 2 ) &
			Right( "0#FormatBaseN( blendRGB.green, '16' )#", 2 ) &
			Right( "0#FormatBaseN( blendRGB.blue, '16' )#", 2 )
			) />	
		</cfif>	
		
	<cfreturn blendHex>
	</cffunction>	
		
	
	<cffunction
		name="ReflectImage"
		access="public"
		returntype="any"
		output="false"
		hint="Reflects image along the given side with the given properties.">
		
		<!--- Define arguments. --->
		<cfargument
			name="Image"
			type="any"
			required="true"
			hint="The ColdFusion image object that we are going to reflect."
			/>
			
		<cfargument
			name="Side"
			type="string"
			required="true"
			hint="The side of the image that we are going to reflect. Valid values include Top, Right, Bottom, and Left."
			/>
			
		<cfargument
			name="BackgroundColor"
			type="string"
			required="false"
			default="FFFFFF"
			hint="The HEX color of the canvas background color used in the reflection."
			/>
			
		<cfargument
			name="Offset"
			type="numeric"
			required="false"
			default="0"
			hint="The offset of the reflection from the image."
			/>
			
		<cfargument
			name="Size"
			type="numeric"
			required="false"
			default="100"
			hint="The height or width of the given reflection (depending on the side being reflected)."
			/>
			
		<cfargument
			name="StartingAlpha"
			type="numeric"
			required="false"
			default="25"
			hint="The starting alpha channel of the covering !!background color!! (between 0 and 255 where 0 is completely transparent)."
			/>
			
		<!--- Set up local scope. --->
		<cfset var LOCAL = {} />
		
		
		<!--- Check to make sure that we have a valid side. --->
		<cfif NOT ListFindNoCase( "Top,Right,Bottom,Left", ARGUMENTS.Side )>
			
			<!--- 
				An invalid side was passed in, so just default 
				to the most popular: bottom. 
			--->
			<cfset ARGUMENTS.Side = "Bottom" />
		
		</cfif>
		
		
		<!--- 
			Before we apply the reflection, we have to figure 
			out what the size of our resulting canvas will be. 
			This is going to be different depending on what side 
			we are refelcting. 
		--->
		<cfif ListFindNoCase( "Top,Bottom", ARGUMENTS.Side )>
		
			<!--- We are reflecting in the vertical plane. --->
			
			<!--- 
				Get the size of the resultant canvas. This will be 
				the same width, but will need to take into account 
				the size and offset of the reflection. 
			--->
			<cfset LOCAL.Width = ImageGetWidth( ARGUMENTS.Image ) />
			
			<cfset LOCAL.Height = (
				ImageGetHeight( ARGUMENTS.Image ) +
				ARGUMENTS.Offset + 
				ARGUMENTS.Size			
				) />
				
		<cfelse>
		
			<!--- We are reflecting in the horizontal plane. --->
			
			<!--- 
				Get the size of the resultant canvas. This will be 
				the same height, but will need to take into account 
				the size and offset of the reflection. 
			--->
			<cfset LOCAL.Height = ImageGetHeight( ARGUMENTS.Image ) />
			
			<cfset LOCAL.Width = (
				ImageGetWidth( ARGUMENTS.Image ) +
				ARGUMENTS.Offset + 
				ARGUMENTS.Size			
				) />
		
		</cfif>
		
		
		<!--- 
			Create the new canvas with the above calculated 
			dimensions. Leave the background transparent in 
			case the user wants to use the reflection over 
			something else.
		--->
		<cfset LOCAL.Result = ImageNew(
			"",
			LOCAL.Width,
			LOCAL.Height,
			"argb"
			) />
			
			
		<!--- 
			Create a copy of the passed in image. We are going 
			to be building our reflection gradient over this image.
		--->
		<cfset LOCAL.Reflection = ImageCopy(
			ARGUMENTS.Image,
			0, 
			0, 
			ImageGetWidth( ARGUMENTS.Image ),
			ImageGetHeight( ARGUMENTS.Image )
			) />
			
		<!--- 
			Now, we actually need to flip the image that we are 
			going to reflect. This will be either veritcal or
			horizontal depending on the side.
		--->
		<cfif ListFindNoCase( "Top,Bottom", ARGUMENTS.Side )>
		
			<!--- Flip vertical. --->
			<cfset ImageFlip( LOCAL.Reflection, "vertical" ) />
		
		<cfelse>
		
			<!--- Flip horizontal. --->
			<cfset ImageFlip( LOCAL.Reflection, "horizontal" ) />
		
		</cfif>
			
			
		<!--- 
			Get the colors that will be used in the gradient. 
			These will both be the same color, but with different 
			alpha channels.
		--->
		<cfset LOCAL.FromColor = THIS.NormalizeColor( ARGUMENTS.BackgroundColor ) />
		<cfset LOCAL.ToColor = StructCopy( LOCAL.FromColor ) />
		
		<!--- 
			The from color will have the given starting alpha and 
			the to color will always have an alpha of 255 which will
			give us a solid background. 
		--->
		<cfset LOCAL.FromColor.Alpha = ARGUMENTS.StartingAlpha />
		<cfset LOCAL.ToColor.Alpha = 255 />
		
			
		<!--- 
			Now that we have our reflection image, we have to figure 
			out how we want to build the fade-to-background color 
			gradient. This is going to be dependent on what side is 
			being reflected.
			
			Once we have that, let's create the new image by pasting
			both the original image and the reflection image onto 
			the new canvas.
		--->
		<cfswitch expression="#ARGUMENTS.Side#">
			
			<cfcase value="Top">
				
				<!--- Create reflection w/ Gradient. --->
				<cfset LOCAL.Reflection = THIS.DrawGradientRect(
					LOCAL.Reflection,
					0,
					(ImageGetHeight( LOCAL.Reflection ) - ARGUMENTS.Size),
					ImageGetWidth( LOCAL.Reflection ),
					ARGUMENTS.Size,
					LOCAL.FromColor,
					LOCAL.ToColor,
					"BottomTop"
					) />
									
				<!--- Paste original object onto canvas. --->
				<cfset ImagePaste(
					LOCAL.Result,
					ARGUMENTS.Image,
					0,
					(ImageGetHeight( LOCAL.Result ) - ImageGetHeight( ARGUMENTS.Image ))
					) />
					
				<!--- Paste reflection onto canvas. --->
				<cfset ImagePaste(
					LOCAL.Result,
					LOCAL.Reflection,
					0,
					(-ImageGetHeight( LOCAL.Reflection ) + ARGUMENTS.Size)
					) />
			
			</cfcase>
			
			<cfcase value="Bottom">
				
				<!--- Create reflection w/ Gradient. --->
				<cfset LOCAL.Reflection = THIS.DrawGradientRect(
					LOCAL.Reflection,
					0,
					0,
					ImageGetWidth( LOCAL.Reflection ),
					ARGUMENTS.Size,
					LOCAL.FromColor,
					LOCAL.ToColor,
					"TopBottom"
					) />
					
				<!--- Paste original object onto canvas. --->
				<cfset ImagePaste(
					LOCAL.Result,
					ARGUMENTS.Image,
					0,
					0
					) />
					
				<!--- Paste reflection onto canvas. --->
				<cfset ImagePaste(
					LOCAL.Result,
					LOCAL.Reflection,
					0,
					(ImageGetHeight( ARGUMENTS.Image ) + ARGUMENTS.Offset)
					) />
			
			</cfcase>
			
			<cfcase value="Left">
				
				<!--- Create reflection w/ Gradient. --->
				<cfset LOCAL.Reflection = THIS.DrawGradientRect(
					LOCAL.Reflection,
					(ImageGetWidth( LOCAL.Reflection ) - ARGUMENTS.Size),
					0,
					ARGUMENTS.Size,
					ImageGetHeight( LOCAL.Reflection ),
					LOCAL.FromColor,
					LOCAL.ToColor,
					"RightLeft"
					) />
					
				<!--- Paste original object onto canvas. --->
				<cfset ImagePaste(
					LOCAL.Result,
					ARGUMENTS.Image,
					(ImageGetWidth( LOCAL.Result ) - ImageGetWidth( ARGUMENTS.Image )),
					0
					) />
					
				<!--- Paste reflection onto canvas. --->
				<cfset ImagePaste(
					LOCAL.Result,
					LOCAL.Reflection,
					(-ImageGetWidth( LOCAL.Reflection ) + ARGUMENTS.Size),
					0
					) />
			
			</cfcase>
			
			<cfcase value="Right">
				
				<!--- Create reflection w/ Gradient. --->
				<cfset LOCAL.Reflection = THIS.DrawGradientRect(
					LOCAL.Reflection,
					0,
					0,
					ARGUMENTS.Size,
					ImageGetHeight( LOCAL.Reflection ),
					LOCAL.FromColor,
					LOCAL.ToColor,
					"LeftRight"
					) />
					
				<!--- Paste original object onto canvas. --->
				<cfset ImagePaste(
					LOCAL.Result,
					ARGUMENTS.Image,
					0,
					0
					) />
					
				<!--- Paste reflection onto canvas. --->
				<cfset ImagePaste(
					LOCAL.Result,
					LOCAL.Reflection,
					(ImageGetWidth( ARGUMENTS.Image ) + ARGUMENTS.Offset),
					0
					) />
			
			</cfcase>
			
		</cfswitch>
			
			
		<!--- 
			We have created the reflection. Now, return the 
			resulting canvas. 
		--->
		<cfreturn LOCAL.Result />
	</cffunction>

	<!---
		Author: 	Daniel Budde II
		E-mail:		dbudde [at] leadergraphics.com
		Purpose:	Can extract one or more tiff images from a multi-page tiff creating a new single or multi-page tiff document
					respectively.  This method is developed primarily for scanned/faxed documents that create multi-page tiffs.
					
					Please refer to method: TiffMergeSaveImage for an explanation of the compression types.
	--->
	<cffunction name="TiffExtract" access="public" returntype="void" output="false" hint="Extracts pages from a multi-page Tiff, creating either a single page Tiff or new multi-page Tiff.">
		<cfargument name="TIFF" type="string" required="yes" hint="Path to source TIFF file." />
		<cfargument 	name="destination" 
						type="string" 
						required="yes" 
						default="" 
						hint="Full path and file name to where the new file will be created." />
	
		<cfargument 	name="pages" 
						type="string" 
						required="yes" 
						default=""
						hint="Pages to be extracted. Valid Examples ('3' or '3,7,9' or '5-14' or '3,5-14,27-30,33')" />

		<cfargument 	name="overwrite" 
						type="boolean" 
						required="no" 
						default="true"
						hint="Overwrite files with the same existing name at the destination." />

		<cfargument 	name="compression" 
						type="numeric" 
						required="no" 
						default="1"
						hint="Sets the compression to be used when creating the resulting TIFF file." />


		<cfset var LOCAL = {} />
		<cfset LOCAL.destinationPath = GetDirectoryFromPath(arguments.destination) />
		<cfset LOCAL.destinationFile = GetFileFromPath(arguments.destination) />
	
	
		<cfif not FileExists(arguments.TIFF)>
			<cfthrow message="Missing input file." detail="Could not locate Tiff file (#arguments.TIFF#)." />
		</cfif>
	
	
		<cfif not DirectoryExists(LOCAL.destinationPath)>
			<cfthrow message="Missing destination directory." detail="Could not locate directory (#LOCAL.destinationPath#)." />
		</cfif>
	
	
		<!--- Used to guarantee file path format --->
		<cfif Find("/", LOCAL.destinationPath) gt 0>
			<cfset LOCAL.systemDelimiter = "/" />
		<cfelse>
			<cfset LOCAL.systemDelimiter = "\" />
		</cfif>
	
	
		<!--- Ensure that the 'destinationPath' ends in the system delimiter --->
		<cfif Right(LOCAL.destinationPath, 1) neq LOCAL.systemDelimiter>
			<cfset LOCAL.destinationPath &= LOCAL.systemDelimiter />
		</cfif>
	
	
		<cfset LOCAL.pageCount = TiffPageCount(arguments.TIFF) />
		<cfset LOCAL.extractList = "" />
	
	
		<!--- If it is a Multi-Page TIFF --->
		<cfif LOCAL.pageCount gt 1 and (not FileExists(arguments.destination) or arguments.overwrite)>
	
			<!--- Make sure pages attribute is valid --->
			<cfif ListLen(Trim(arguments.pages)) eq 0>
				<cfthrow message="Invalid page range." detail="The attribute 'pages' does not contain a valid page range." />
			</cfif>
	
	
			<!--- Loop through pages to extract --->
			<cfloop list="#arguments.pages#" index="LOCAL.pageRange">
				<cfif Find("-", LOCAL.pageRange) gt 0>
					<cfif not IsValid("integer", Trim(ListFirst(LOCAL.pageRange, "-"))) or not IsValid("integer", Trim(ListLast(LOCAL.pageRange, "-")))>
						<cfthrow message="Invalid page range." detail="The attribute 'pages' does not contain a valid page range." />
					</cfif>
	
	
					<cfif JavaCast("int", Trim(ListFirst(LOCAL.pageRange, "-"))) lte JavaCast("int", Trim(ListLast(LOCAL.pageRange, "-")))>
						<cfset LOCAL.lowNumber = JavaCast("int", Trim(ListFirst(LOCAL.pageRange, "-"))) />
						<cfset LOCAL.highNumber = JavaCast("int", Trim(ListLast(LOCAL.pageRange, "-"))) />
					<cfelse>
						<cfset LOCAL.lowNumber = JavaCast("int", Trim(ListFirst(LOCAL.pageRange, "-"))) />
						<cfset LOCAL.highNumber = JavaCast("int", Trim(ListLast(LOCAL.pageRange, "-"))) />
					</cfif>
	
	
					<cfif LOCAL.lowNumber gt LOCAL.pageCount>
						<cfthrow message="Invalid page range." detail="The page (#LOCAL.lowNumber#) is greater than the total number of pages (#LOCAL.pageCount#)." />
					</cfif>
	
					<cfif LOCAL.highNumber gt LOCAL.pageCount>
						<cfthrow message="Invalid page range." detail="The page (#LOCAL.highNumber#) is greater than the total number of pages (#LOCAL.pageCount#)." />
					</cfif>
	
	
					<cfloop from="#LOCAL.lowNumber#" to="#LOCAL.highNumber#" step="1" index="LOCAL.i">
						<cfif ListFind(LOCAL.extractList, LOCAL.i) eq 0>
							<cfset LOCAL.extractList = ListAppend(LOCAL.extractList, LOCAL.i) />
						</cfif>
					</cfloop>
				<cfelse>
					<cfif not IsValid("integer", Trim(LOCAL.pageRange))>
						<cfthrow message="Invalid page range." detail="The attribute 'pages' does not contain a valid page range." />
					</cfif>
	
					<cfif JavaCast("int", Trim(LOCAL.pageRange)) gt LOCAL.pageCount>
						<cfthrow message="Invalid page range." detail="The page (#Trim(LOCAL.pageRange)#) is greater than the total number of pages (#LOCAL.pageCount#)." />
					</cfif>
	
					<cfif ListFind(LOCAL.extractList, Trim(LOCAL.pageRange)) eq 0>
						<cfset LOCAL.extractList = ListAppend(LOCAL.extractList, Trim(LOCAL.pageRange)) />
					</cfif>
				</cfif>
			</cfloop>
	
	
			<cfset LOCAL.extractList = ListSort(LOCAL.extractList, "numeric") />
			<cfset LOCAL.tiffImageArray = ArrayNew(1) />
	
	
			<cfset LOCAL.TIFFile = CreateObject("java", "java.io.File").init(arguments.TIFF) />
			<cfset LOCAL.FileSeekableStream = CreateObject("java", "com.sun.media.jai.codec.FileSeekableStream").init(LOCAL.TIFFile) />
			<cfset LOCAL.decoder = CreateObject("java", "com.sun.media.jai.codec.ImageCodec").createImageDecoder("tiff", LOCAL.FileSeekableStream, JavaCast("null", "")) />
	
	
			<cfloop list="#LOCAL.extractList#" index="LOCAL.currentPage">
				<cfset LOCAL.renderedCurrentPage = JavaCast("int", Trim(LOCAL.currentPage)) - 1 />
				<cfset LOCAL.RenderedImage = LOCAL.decoder.decodeAsRenderedImage(LOCAL.renderedCurrentPage) />
				
				<cfset ArrayAppend(LOCAL.tiffImageArray, LOCAL.RenderedImage) />
			</cfloop>
	
	
			<cfset TiffMerge(arguments.destination, LOCAL.tiffImageArray, arguments.overwrite, arguments.compression) />
		</cfif>
	</cffunction>


	<!---
		Author: 	Daniel Budde II
		E-mail:		dbudde [at] leadergraphics.com
		Purpose:	This method should be able to merge any number and types of images into a multi-page tiff document.  It is 
					primarily best used with the tiff scanned document format and compression.  It can accept an array of paths to
					image files or an array of java RenderedImages (developed for use with TiffExtract).
					
					Please refer to method: TiffMergeSaveImage for an explanation of the compression types.
	--->
	<cffunction name="TiffMerge" access="public" returntype="void" output="false" hint="Merges an array of image paths or an array of RenderedImages into a multi-page Tiff document.">
		<cfargument 	name="destination" 
						type="string" 
						required="yes" 
						default="" 
						hint="Full path and file name to where the new file will be created." />
	
		<cfargument 	name="imageArray" 
						type="array" 
						required="yes" 
						default="true"
						hint="Must be an array of 'image paths (strings)' or an array of java type RenderedImage." />
	
		<cfargument 	name="overwrite" 
						type="boolean" 
						required="no" 
						default="true"
						hint="Overwrite files with the same existing name at the destination." />

		<cfargument 	name="compression" 
						type="numeric" 
						required="no" 
						default="1"
						hint="Sets the compression to be used when creating the resulting TIFF file." />
	
	
		<cfset var LOCAL = {} />
		<cfset LOCAL.destinationPath = GetDirectoryFromPath(arguments.destination) />
		<cfset LOCAL.destinationFile = GetFileFromPath(arguments.destination) />
		<cfset LOCAL.imageArray = [] />
	
	
		<cfif not DirectoryExists(LOCAL.destinationPath)>
			<cfthrow message="Missing destination directory." detail="Could not locate directory (#LOCAL.destinationPath#)." />
		</cfif>
	
	
		<!--- Cannot merge with empty  array --->
		<cfif ArrayLen(arguments.imageArray) eq 0>
			<cfthrow message="Invalid array size." detail="Cannot merge an empty array." />
		</cfif>
	
	
		<!--- Determine Array Type --->
		<cfif IsInstanceOf(arguments.imageArray[1], "java.awt.image.RenderedImage")>
	
			<cfloop array="#arguments.imageArray#" index="LOCAL.image">
				<cfif not IsInstanceOf(LOCAL.image, "java.awt.image.RenderedImage")>
					<cfthrow message="Invalid array." detail="First array element is of type [java.awt.image.RenderedImage], but not all the array elements are of this type." />
				</cfif>
			</cfloop>
			<cfset LOCAL.imageArrayType = "RenderedImage" />
	
		<cfelseif IsSimpleValue(arguments.imageArray[1])>
	
			<cfloop array="#arguments.imageArray#" index="LOCAL.image">
				<cfif not FileExists(LOCAL.image)>
					<cfthrow message="Invalid array." detail="File (#LOCAL.image#) does not exist." />
				</cfif>
			</cfloop>
			<cfset LOCAL.imageArrayType = "ImagePath" />
	
		<cfelse>
			<cfthrow message="Invalid array." detail="imageArray must be an array of type [java.awt.image.RenderedImage] or image file paths." />
		</cfif>
	
	
	
	
		<cfif not FileExists(arguments.destination) or arguments.overwrite>
			<cfif LOCAL.imageArrayType eq "ImagePath">
				
				<cfloop array="#arguments.imageArray#" index="LOCAL.image">
					<cfset LOCAL.File = CreateObject("java", "java.io.File").init(LOCAL.image) />
					<cfset LOCAL.FileSeekableStream = CreateObject("java", "com.sun.media.jai.codec.FileSeekableStream").init(LOCAL.File) />
					<cfset LOCAL.decoderNames = CreateObject("java", "com.sun.media.jai.codec.ImageCodec").getDecoderNames(LOCAL.FileSeekableStream) />
					<cfset LOCAL.decoder = CreateObject("java", "com.sun.media.jai.codec.ImageCodec").createImageDecoder(LOCAL.decoderNames[1], LOCAL.FileSeekableStream, JavaCast("null", "")) />
	
	
					<!---
						Fixes wierd issue with GIF images where 'getNumPages' does not work on the first try.
						I was not able to determine the cause, so if anyone can tell me a better fix, I am all
						ears.  Error produced: 'Error reading GIF image header.'
					--->
					<cftry>
						<cfset LOCAL.totalPages = LOCAL.decoder.getNumPages() />
						
						<cfcatch type="any">
							<cftry>
								<cfset LOCAL.totalPages = LOCAL.decoder.getNumPages() />
								
								<cfcatch type="any">
									<cfset LOCAL.totalPages = 1 />
								</cfcatch>
							</cftry>
						</cfcatch>
					</cftry>
		
		
					<cfif LOCAL.totalPages eq 1>
						<cfset LOCAL.RenderedImage = LOCAL.decoder.decodeAsRenderedImage() />
						<cfset ArrayAppend(LOCAL.imageArray, LOCAL.RenderedImage) />
					<cfelse>
		
						<cfloop from="1" to="#LOCAL.totalPages#" step="1" index="LOCAL.currentPage">
							<cfset LOCAL.actualPage = JavaCast("int", LOCAL.currentPage - 1) />
		
							<cfset LOCAL.RenderedImage = LOCAL.decoder.decodeAsRenderedImage(LOCAL.actualPage) />
		
							<cfset ArrayAppend(LOCAL.imageArray, LOCAL.RenderedImage) />
						</cfloop>
		
					</cfif>
				</cfloop>
	
			<cfelse>
				<cfset LOCAL.imageArray = arguments.imageArray />
			</cfif>
		
		
			<cfset LOCAL.firstRenderedImage = Duplicate(LOCAL.imageArray[1]) />
			<cfset ArrayDeleteAt(LOCAL.imageArray, 1) />

			<cfset TiffMergeSaveImage(arguments.destination, LOCAL.firstRenderedImage, LOCAL.imageArray, arguments.overwrite, arguments.compression) />
		</cfif>
	</cffunction>
	

	<!---
		Author: 	Daniel Budde II
		E-mail:		dbudde [at] leadergraphics.com
		Purpose:	Saves the RenderedImage array to a multi-page TIFF file.
		
		compression:
					I am taking a moment to explain the compression argument just a little further and leave some reference information.
					Below is a list of compression types, what they accomplish and any little tid bits I was able to pick up.  
					
					(1) COMPRESSION_NONE - 		No compression.
					(2) COMPRESSION_PACKBITS - 	Byte-oriented run-length encoding "PackBits" compression. (Seems to be the most generic
												accepted compression format)
					(3) COMPRESSION_GROUP3_1D - Modified Huffman Compression (CCITT Run Length Encoding (RLE))  (Never personnally 
												attempted this one)
					(4) COMPRESSION_GROUP3_2D - CCITT T.4 bilevel compression (Group 3 facsimile compression)  (-bilevel- can ONLY be 
												used with black & white images only, typically scanned/faxed documents - better to use GROUP4)
					(5) COMPRESSION_GROUP4 - 	CCITT T.6 bilevel compression (Group 4 facsimile compression)  (-bilevel- can ONLY be 
												used with black & white images only, typically scanned/faxed documents)
					(6) COMPRESSION_LZW - 		LZW compression - NOT SUPPORTED
					(7) COMPRESSION_JPEG_TTN2 - JPEG-in-TIFF compression
					(8) COMPRESSION_DEFLATE - 	DEFLATE lossless compression (also known as "Zip-in-TIFF")  (Seems like the best generic 
												compression for size, but not widely accepted - TIFF failed to open when I used this)
					
					I tend to use COMPRESSION_GROUP4 on scanned/faxed multi-page documents, but if the images include a grayscale or
					color image, I would use COMPRESSION_PACKBITS.  If you want lossless, then at this time I assume the only choice
					is COMPRESSION_NONE.  I will be looking to improve the compression component of this as time goes on.
					
					The reason for needing to manually set the compression type, is that when I tried to use a try/catch to recover from 
					a bilevel compression attempt on a color image, it would work fine on CF8/Win2003.  On a CF8/OSX machine the thrown 
					error would ignore all try/catch attempts and stop the process.  I will be working on a method to detect bilevel
					images, but this will come later.
	--->
	<cffunction name="TiffMergeSaveImage" access="private" returntype="void" output="false" hint="Takes the firstRenderedImage and RenderedImage array from TiffMerge and saves them to the destination with the proposed compression.">
		<cfargument 	name="destination" 
						type="string" 
						required="yes" 
						default="" 
						hint="Full path and file name to where the new file will be created." />
	
		<cfargument 	name="firstRenderedImage" 
						type="any" 
						required="yes" 
						default="true"
						hint="Must be the first RenderedImage." />
	
		<cfargument 	name="imageArray" 
						type="array" 
						required="yes" 
						default="true"
						hint="Must be an array of java type RenderedImage." />
	
		<cfargument 	name="overwrite" 
						type="boolean" 
						required="no" 
						default="true"
						hint="Overwrite files with the same existing name at the destination." />

		<cfargument 	name="compression" 
						type="numeric" 
						required="no" 
						default="1"
						hint="Sets the compression to be used when creating the resulting TIFF file." />

		<cfset var LOCAL = {} />


		<cfif arguments.overwrite and FileExists(arguments.destination)>
			<cffile action="delete" file="#arguments.destination#" />
		</cfif>
	
	
		<cfset LOCAL.TIFFFileOut = CreateObject("java", "java.io.FileOutputStream").init(arguments.destination) />


		<cfswitch expression="#arguments.compression#">
			<cfcase value="2">
				<cfset LOCAL.compression = "COMPRESSION_PACKBITS" />
			</cfcase>
			<cfcase value="3">
				<cfset LOCAL.compression = "COMPRESSION_GROUP3_1D" />
			</cfcase>
			<cfcase value="4">
				<cfset LOCAL.compression = "COMPRESSION_GROUP3_2D" />
			</cfcase>
			<cfcase value="5">
				<cfset LOCAL.compression = "COMPRESSION_GROUP4" />
			</cfcase>
			<cfcase value="6">
				<cfset LOCAL.compression = "COMPRESSION_LZW" />
			</cfcase>
			<cfcase value="7">
				<cfset LOCAL.compression = "COMPRESSION_JPEG_TTN2" />
			</cfcase>
			<cfcase value="8">
				<cfset LOCAL.compression = "COMPRESSION_DEFLATE" />
			</cfcase>
			<cfdefaultcase>
				<cfset LOCAL.compression = "COMPRESSION_NONE" />
			</cfdefaultcase>
		</cfswitch>


		<cftry>
			<cfset LOCAL.TIFFEncodeParam = CreateObject("java", "com.sun.media.jai.codec.TIFFEncodeParam").init() />
			<cfset LOCAL.TIFFEncodeParam.setCompression(Evaluate("LOCAL.TIFFEncodeParam." & LOCAL.compression)) />
		
			<cfset LOCAL.ImageCodec = CreateObject("java", "com.sun.media.jai.codec.ImageCodec") />
		
			<cfset LOCAL.imageEncoder = LOCAL.ImageCodec.createImageEncoder("tiff", LOCAL.TIFFFileOut, LOCAL.TIFFEncodeParam) />
		
			<cfset LOCAL.vector = CreateObject("java", "java.util.Vector").init() />
		
		
			<cfloop array="#arguments.imageArray#" index="LOCAL.RenderedImage">
				<cfset LOCAL.vector.add(LOCAL.RenderedImage) />
			</cfloop>
		
			<cfset LOCAL.TIFFEncodeParam.setExtraImages(LOCAL.vector.iterator()) />

			<cfset LOCAL.imageEncoder.encode(arguments.firstRenderedImage) />
			<cfset LOCAL.TIFFFileOut.close() />
	
	
			<cfcatch type="any">
				<cfset LOCAL.TIFFFileOut.close() />
				<cfrethrow />
			</cfcatch>
		</cftry>
	</cffunction>
	

	<!---
		Author		: Daniel Budde
	--->
	<cffunction name="TiffPageCount" access="public" returntype="numeric" output="false" hint="Gets the number of pages in the TIFF.">
		<cfargument name="TIFF" type="string" required="yes" hint="Path to source TIFF file." />

		<cfset var LOCAL = {} />

		<cfif not FileExists(arguments.TIFF)>
			<cfthrow message="Missing input file." detail="Could not locate Tiff file (#arguments.TIFF#)." />
		</cfif>

		<cfset LOCAL.totalPages = 0 />
		
		<cfif IsTiff(arguments.TIFF)>
			<cfset LOCAL.TIFFile = CreateObject("java", "java.io.File").init(arguments.TIFF) />
			<cfset LOCAL.FileSeekableStream = CreateObject("java", "com.sun.media.jai.codec.FileSeekableStream").init(LOCAL.TIFFile) />
			<cfset LOCAL.decoder = CreateObject("java", "com.sun.media.jai.codec.ImageCodec").createImageDecoder("tiff", LOCAL.FileSeekableStream, JavaCast("null", "")) />
			<cfset LOCAL.totalPages = LOCAL.decoder.getNumPages() />
		</cfif>

		<cfreturn LOCAL.totalPages />
	</cffunction>	

	<!---
		Author: 	Daniel Budde II
		E-mail:		dbudde [at] leadergraphics.com
		History:	Adapted to use TiffExtract function which handles and added the 'compression' argument.
					Before this method would fail if the image was NOT a bilevel image (black & white) (7/11/2008 DKB)

					Please refer to method: TiffMergeSaveImage for an explanation of the compression types.  Current 
					problem with this method is that it will output all split TIFF files with the same compression. 
					In the future this will hopefully be changed, but since this is primarily for use with scanned/faxed
					documents, this is not a terrible limitation.
	--->
	<cffunction name="TiffSplit" access="public" returntype="void" output="false" hint="Splits a multi-page TIFF image into multiple TIFF images.">
		<cfargument name="TIFF" type="string" required="yes" hint="Path to source TIFF file." />
		<cfargument 	name="destination" 
						type="string" 
						required="no" 
						default="" 
						hint="Directory where to store the single images. Defaults to the same location as the source." />
	
		<cfargument 	name="fileNamePrefix" 
						type="string" 
						required="no" 
						default=""
						hint="Prefix to be used when naming the saved single TIFF pages.  Defaults to using the original file name." />

		<cfargument 	name="overwrite" 
						type="boolean" 
						required="no" 
						default="true"
						hint="Overwrite files with the same existing name at the destination." />

		<cfargument 	name="compression" 
						type="numeric" 
						required="no" 
						default="1"
						hint="Sets the compression to be used when creating the resulting TIFF file." />

	
		<cfset var LOCAL = {} />
	
	
		<cfif not FileExists(arguments.TIFF)>
			<cfthrow message="Missing input file." detail="Could not locate Tiff file (#arguments.TIFF#)." />
		</cfif>
	
	
		<!--- Determine file prefix --->
		<cfif Len(arguments.fileNamePrefix) gt 0>
			<cfset LOCAL.fileNamePrefix = arguments.fileNamePrefix />
		<cfelse>
			<cfset LOCAL.fileNamePrefix = GetFileFromPath(arguments.TIFF) />
			<cfset LOCAL.fileNamePrefix = ListDeleteAt(LOCAL.fileNamePrefix, ListLen(LOCAL.fileNamePrefix, "."), ".") />
		</cfif>
	
	
		<!--- Determine file output destination --->
		<cfif Len(arguments.destination) gt 0>
			<cfif DirectoryExists(arguments.destination)>
				<cfset LOCAL.destination = arguments.destination />
			<cfelse>
				<cfthrow message="Missing destination directory." detail="Could not locate directory (#arguments.destination#)." />
			</cfif>
		<cfelse>
			<cfset LOCAL.destination = GetDirectoryFromPath(arguments.TIFF) />
		</cfif>
	
	
		<!--- Used to guarantee file path format --->
		<cfif Find("/", LOCAL.destination) gt 0>
			<cfset LOCAL.systemDelimiter = "/" />
		<cfelse>
			<cfset LOCAL.systemDelimiter = "\" />
		</cfif>
	
	
		<!--- Ensure that the 'destination' ends in the system delimiter --->
		<cfif Right(LOCAL.destination, 1) neq LOCAL.systemDelimiter>
			<cfset LOCAL.destination = LOCAL.destination & LOCAL.systemDelimiter />
		</cfif>
	
	
		<cfif IsTiff(arguments.TIFF)>
			<cfset LOCAL.TIFFile = CreateObject("java", "java.io.File").init(arguments.TIFF) />
			<cfset LOCAL.FileSeekableStream = CreateObject("java", "com.sun.media.jai.codec.FileSeekableStream").init(LOCAL.TIFFile) />
			<cfset LOCAL.decoder = CreateObject("java", "com.sun.media.jai.codec.ImageCodec").createImageDecoder("tiff", LOCAL.FileSeekableStream, JavaCast("null", "")) />
			<cfset LOCAL.totalPages = LOCAL.decoder.getNumPages() />
	
			<cfif LOCAL.totalPages gt 1>
				<cfset LOCAL.endPage = LOCAL.totalPages - 1 />
	
				<cfloop from="0" to="#LOCAL.endPage#" index="LOCAL.currentPage" step="1">
					<cfset LOCAL.actualPageNumber = LOCAL.currentPage + 1 />
	
					<cfif arguments.overwrite or not FileExists(LOCAL.destination & LOCAL.fileNamePrefix & "_" & LOCAL.actualPageNumber & ".tif")>
						<cfset TiffExtract(arguments.TIFF, LOCAL.destination & LOCAL.fileNamePrefix & "_" & LOCAL.actualPageNumber & ".tif", LOCAL.actualPageNumber, arguments.overwrite, arguments.compression) />
					</cfif>
				</cfloop>
			</cfif>
		</cfif>
	
	</cffunction>		

	<!---
		Author		: Daniel Budde
	--->
	<cffunction 	name="TiffToPDF" access="public" returntype="void" output="false"
					hint=	"
							Converts a TIFF image into a PDF document.  Essentially places a scaled image of
					  		a TIFF in a page of a PDF.  Automatically handles multi-paged TIFF images.
							Meant for 8.5 x 11 faxed or scanned documents.
							">
		<cfargument name="TIFF" type="string" required="yes" hint="Path to source TIFF file." />
		<cfargument name="PDF" type="string" required="no" default="" hint="Path to PDF file." />

		<cfset var LOCAL = {} />

		<cfif not FileExists(arguments.TIFF)>
			<cfthrow message="Missing input file." detail="Could not locate Tiff file (#arguments.TIFF#)." />
		</cfif>

		<cfif Len(arguments.PDF) gt 0>
			<cfset LOCAL.PDF = arguments.PDF />
		<cfelse>
			<cfset LOCAL.PDFFileName = GetFileFromPath(arguments.TIFF) />
			<cfset LOCAL.PDFFileName = ListDeleteAt(LOCAL.PDFFileName, ListLen(LOCAL.PDFFileName, "."), ".") & ".pdf" />
			<cfset LOCAL.PDF = GetDirectoryFromPath(arguments.TIFF) />
			<cfset LOCAL.PDF = LOCAL.PDF & LOCAL.PDFFileName />
		</cfif>

		<cfset LOCAL.PDFDocument = CreateObject("java", "com.lowagie.text.Document").init() />
		<cfset LOCAL.PDFFile = CreateObject("java", "java.io.FileOutputStream").init(LOCAL.PDF) />
		<cfset LOCAL.PDFWriter = CreateObject("java", "com.lowagie.text.pdf.PdfWriter").getInstance(LOCAL.PDFDocument, LOCAL.PDFFile) />
		<cfset LOCAL.PageSize = CreateObject("java", "com.lowagie.text.PageSize").init() />

		<cfset LOCAL.TIFFile = CreateObject("java", "java.io.File").init(arguments.TIFF) />
		<cfset LOCAL.FileSeekableStream = CreateObject("java", "com.sun.media.jai.codec.FileSeekableStream").init(LOCAL.TIFFile) />

		<cfset LOCAL.TIFDirectory = CreateObject("java", "com.sun.media.jai.codec.TIFFDirectory").init(LOCAL.FileSeekableStream, JavaCast("int", 0)) />
		<cfset LOCAL.names = CreateObject("java", "com.sun.media.jai.codec.ImageCodec").getDecoderNames(LOCAL.FileSeekableStream) />

		<cfset LOCAL.decoder = CreateObject("java", "com.sun.media.jai.codec.ImageCodec").createImageDecoder(LOCAL.names[1], LOCAL.FileSeekableStream, JavaCast("null", "")) />

		<cfset LOCAL.totalPages = LOCAL.decoder.getNumPages() - 1 />

		<cfset LOCAL.PDFDocument.open() />
		<cfset LOCAL.PDFContentByte = LOCAL.PDFWriter.getDirectContent() />


		<cfloop from="0" to="#LOCAL.totalPages#" index="LOCAL.pageIndex" step="1">
			<cfset LOCAL.PDFDocument.setPageSize(LOCAL.PageSize.LETTER) />

			<cfset LOCAL.renderedImg = LOCAL.decoder.decodeAsRenderedImage(LOCAL.pageIndex) />
			<cfset LOCAL.colorModel = LOCAL.renderedImg.getColorModel() />
			<cfset LOCAL.raster = LOCAL.renderedImg.getData() />
			<cfset LOCAL.writableRaster = CreateObject("java", "java.awt.image.Raster").createWritableRaster(LOCAL.renderedImg.getSampleModel(), LOCAL.raster.getDataBuffer(), JavaCast("null", "")) />

			<cfset LOCAL.bufferedImg = CreateObject("java", "java.awt.image.BufferedImage").init(LOCAL.colorModel, LOCAL.writableRaster, false, CreateObject("java", "java.util.Hashtable")) />
			<cfset LOCAL.img = CreateObject("java", "com.lowagie.text.Image").getInstance(LOCAL.bufferedImg, JavaCast("null", ""), true) />


			<cfset LOCAL.IFDOffset = JavaCast("long", LOCAL.TIFDirectory.getIFDOffset()) />
			<cfset LOCAL.width = JavaCast("long", 0) />
			<cfset LOCAL.height = JavaCast("long", 0) />


			<cfloop condition="LOCAL.IFDOffset neq JavaCast('long', 0)">
				<cfset LOCAL.TIFDirectory = CreateObject("java", "com.sun.media.jai.codec.TIFFDirectory").init(LOCAL.FileSeekableStream, LOCAL.IFDOffset, JavaCast("int", 0)) />
				<cfset LOCAL.IFDOffset = JavaCast("long", LOCAL.TIFDirectory.getNextIFDOffset()) />
				<cfset LOCAL.width = LOCAL.TIFDirectory.getFieldAsLong(LOCAL.decoder.TIFF_IMAGE_WIDTH) />
				<cfset LOCAL.height = LOCAL.TIFDirectory.getFieldAsLong(LOCAL.decoder.TIFF_IMAGE_LENGTH) />
			</cfloop>


			<cfset LOCAL.img.scaleToFit(LOCAL.PageSize.LETTER.width(), LOCAL.PageSize.LETTER.height()) />
			<cfset LOCAL.img.setAbsolutePosition(0, 0) />
			<cfset LOCAL.PDFContentByte.addImage(LOCAL.img) />
			<cfset LOCAL.PDFDocument.newPage() />

		</cfloop>

		<cfset LOCAL.PDFDocument.close() />
	</cffunction>	
	
	<cffunction
		name="TileImage"
		access="public"
		returntype="any"
		output="false"
		hint="Takes your ColdFusion image object and tiles the given image over it.">
		
		<!--- Define arguments. --->
		<cfargument
			name="Image"
			type="any"
			required="true"
			hint="The ColdFusion image onto which we are going to tile our graphic."
			/>
			
		<cfargument
			name="TileImage"
			type="any"
			required="true"
			hint="The image that we are going to tile onto our ColdFusion image."
			/>
			
		<cfargument
			name="X"
			type="numeric"
			required="false"
			default="0"
			hint="The X point at which we are going to start our tiling."
			/>
			
		<cfargument
			name="Y"
			type="numeric"
			required="false"
			default="0"
			hint="The Y point at which we are going to start our tiling."
			/>
			
		<!--- Define the local scope. --->
		<cfset var LOCAL =  {} />
		
		
		<!--- 
			Check to see what kind of value the tile image is. 
			If it is not an image, then we have to create an 
			image with it such that we can more easily get the
			height and width dimensions.
		--->
		<cfif NOT IsImage( ARGUMENTS.TileImage )>
			
			<!--- Read in the image file. --->
			<cfimage
				action="read"
				source="#ARGUMENTS.TileImage#"
				name="ARGUMENTS.TileImage"
				/>
		
		</cfif>
		
		
		<!--- Get the image dimensions. --->
		<cfset LOCAL.ImageDimensions = {
			Width = ImageGetWidth( ARGUMENTS.Image ),
			Height = ImageGetHeight( ARGUMENTS.Image )
			} />
			
		<!--- Get the tile image dimensions. --->
		<cfset LOCAL.TileDimensions = {
			Width = ImageGetWidth( ARGUMENTS.TileImage ),
			Height = ImageGetHeight( ARGUMENTS.TileImage )
			} />
			
			
		<!--- 
			Now that we have our dimensions, we need to figure 
			out where we need to start tiling. We need to make 
			sure that we start at or before ZERO in both of 
			the axis.
		--->
		<cfset LOCAL.StartCoord = {
			X = ARGUMENTS.X,
			Y = ARGUMENTS.Y 
			} />
			
		<!--- Find the starting X coord. --->
		<cfloop condition="(LOCAL.StartCoord.X GT 0)">
			
			<!--- Subtract the width of the tiled image. --->
			<cfset LOCAL.StartCoord.X -= LOCAL.TileDimensions.Width />
			
		</cfloop>
		
		<!--- Find the starting Y coord. --->
		<cfloop condition="(LOCAL.StartCoord.Y GT 0)">
			
			<!--- Subtract the width of the tiled image. --->
			<cfset LOCAL.StartCoord.Y -= LOCAL.TileDimensions.Height />
			
		</cfloop>
		
		
		<!--- 
			ASSERT: At this point, our StartCoord has the {X,Y} 
			point at which we need to begin our tiling. 
		--->
		
		
		<!--- 
			Set the current coordindate of pasting to be the 
			start point that we calcualted above. We will be
			updating this value as we tile the image.
		--->
		<cfset LOCAL.PasteCoord = StructCopy( LOCAL.StartCoord ) />
		
		<!--- 
			Now, we want to keep looping until the Y coord 
			of our pasting is greater than the heigh of our 
			target ColdFusion image. 
		--->
		<cfloop 
			index="LOCAL.PasteCoord.Y"
			from="#LOCAL.StartCoord.Y#"
			to="#LOCAL.ImageDimensions.Height#"
			step="#LOCAL.TileDimensions.Height#">
			
			<!--- 
				As we loop over the Y coordinate, we want to 
				also keep looping until our X pasting coordinate 
				goes beyond the width of the target ColdFusion 
				image.
			--->
			<cfloop 
				index="LOCAL.PasteCoord.X"
				from="#LOCAL.StartCoord.X#"
				to="#LOCAL.ImageDimensions.Width#"
				step="#LOCAL.TileDimensions.Width#">
			
				<!--- 
					Paste the tile image onto the target 
					ColdFusion image at the given X,Y 
					coordinate. 
				--->
				<cfset ImagePaste(
					ARGUMENTS.Image,
					ARGUMENTS.TileImage,
					LOCAL.PasteCoord.X,
					LOCAL.PasteCoord.Y
					) />
			
			</cfloop>
		
		</cfloop>
			
			
		<!--- Return the updated image. --->
		<cfreturn ARGUMENTS.Image />
	</cffunction>
	
	
	<cffunction
		name="TrimCanvas"
		access="public"
		returntype="any"
		output="false"
		hint="Trims the canvas to the smallest possible rectangle using the given background color.">
		
		<!--- Define arguments. --->
		<cfargument
			name="Image"
			type="any"
			required="true"
			hint="The image that we are trimming."
			/>
			
		<cfargument
			name="BackgroundColor"
			type="string"
			required="true"
			hint="The HEX, R,G,B or normalized background color that will be used to trim the canvas."
			/>
			
		<cfargument
			name="Tolerance"
			type="numeric"
			required="false"
			default="10"
			hint="The tolerance of difference in any given color channel between the background color and the current pixel whereby the pixels can still be considered equal"
			/>
		
		<!--- Define the local scope. --->
		<cfset var LOCAL = {} />
		
		<!--- Trim canvas top. --->
		<cfset LOCAL.Return = THIS.TrimCanvasSide( 
			ARGUMENTS.Image, 
			"Top", 
			ARGUMENTS.BackgroundColor,
			ARGUMENTS.Tolerance 
			) />
			
		<!--- Trim canvas bottom. --->
		<cfset LOCAL.Return = THIS.TrimCanvasSide( 
			LOCAL.Return, 
			"Bottom", 
			ARGUMENTS.BackgroundColor,
			ARGUMENTS.Tolerance 
			) />
			
		<!--- Trim canvas left. --->
		<cfset LOCAL.Return = THIS.TrimCanvasSide( 
			LOCAL.Return, 
			"Left", 
			ARGUMENTS.BackgroundColor,
			ARGUMENTS.Tolerance 
			) />
			
		<!--- Trim canvas right. --->
		<cfset LOCAL.Return = THIS.TrimCanvasSide( 
			LOCAL.Return, 
			"Right", 
			ARGUMENTS.BackgroundColor,
			ARGUMENTS.Tolerance 
			) />		
		
		<!--- Return trimmed canvas. --->
		<cfreturn LOCAL.Return />		
	</cffunction>
	
	
	<cffunction
		name="TrimCanvasSide"
		access="public"
		returntype="any"
		output="false"
		hint="Trims the given side of a canvas using the given background color.">
		
		<!--- Define arguments. --->
		<cfargument
			name="Image"
			type="any"
			required="true"
			hint="The image that we are trimming."
			/>
			
		<cfargument
			name="Side"
			type="string"
			required="true"
			hint="The side of the canvas that we are trimming. Possible value are Top, Bottom, Left, Right."
			/>
			
		<cfargument
			name="BackgroundColor"
			type="string"
			required="true"
			hint="The HEX background color that will be used to trim the canvas."
			/>
			
		<cfargument
			name="Tolerance"
			type="numeric"
			required="false"
			default="10"
			hint="The tolerance of difference in any given color channel between the background color and the current pixel whereby the pixels can still be considered equal"
			/>
		
		<!--- Define the local scope. --->
		<cfset var LOCAL = {} />
		
		
		<!--- Check to make sure that we have a valid side. --->
		<cfif NOT ListFindNoCase( "Top,Right,Bottom,Left", ARGUMENTS.Side )>
			
			<!--- 
				An invalid side was passed in. There is no way to 
				properly recover from this, so just throw an error.
			--->
			<cfthrow
				type="InvalideSideValue"
				message="The Side value you passed-in, which is currently #UCase( ARGUMENTS.Side )# is not valid. The valid values are Top, Bottom, Left, Right."
				/>
		
		</cfif>
		
		
		<!--- 
			We want our method to be non-destructive, so make a 
			copy of the image that has been passed-in. 
		--->
		<cfset LOCAL.Image = ImageCopy(
			ARGUMENTS.Image,
			0, 
			0, 
			ImageGetWidth( ARGUMENTS.Image ),
			ImageGetHeight( ARGUMENTS.Image )
			) />
			
			
		<!--- 
			Convert the hex background color to a normalized color struct
			so that we can compare it's color to the pixels we sample from 
			the target image. 
		--->
		<cfset LOCAL.Color = THIS.NormalizeColor( ARGUMENTS.BackgroundColor ) />
		
		
		<!--- 
			We are going to keep looping over the canvas until we 
			run out of pixels to trim. Set a flag so that we know
			when to stopp trimming.
		--->
		<cfset LOCAL.KeepTrimming = true />
		
		<!--- Loop while we should keep trimming. --->
		<cfloop condition="#LOCAL.KeepTrimming#">
		
			<!--- Check what side we are going to be trimming. --->
			<cfswitch expression="#ARGUMENTS.Side#">
			
				<cfcase value="Top">
					
					<!--- 
						Sample the top row of pixels. This gives us a two 
						dimensional array (rows x columns). 
					--->
					<cfset LOCAL.Pixels = THIS.GetPixels(
						LOCAL.Image,
						0,
						0,
						ImageGetWidth( LOCAL.Image ),
						1
						) />
					
					<!--- Get the top row from our sample. --->
					<cfset LOCAL.Pixels = LOCAL.Pixels[ 1 ] />
					
					
					<!--- 
						Loop over the pixels to see if there are 
						any colors that are not the same as the 
						background color. 
					--->
					<cfloop
						index="LOCAL.Pixel"
						array="#LOCAL.Pixels#">
						
						<!--- 
							Check to see if the colors are NOT the same. This 
							will be true of their color channels match OR if 
							they are both transparent.
						--->
						<cfif NOT THIS.ColorsAreEqual(
							LOCAL.Pixel,
							LOCAL.Color,
							ARGUMENTS.Tolerance
							)>
							
							<!--- 
								We found non-matching colors. We 
								cannot keep trimming this side. Set 
								the flag to stop the looping. 
							--->
							<cfset LOCAL.KeepTrimming = false />
							
							<!--- Break out of the current pixel loop. --->
							<cfbreak />
							
						</cfif>
							
					</cfloop>
					
					
					<!--- 
						At this point, we have either looped over the entire row of 
						pixels or found one that does not match. Check to see if we 
						should crop the canvase. We should to this we our keep trimming 
						flag is true AND, there are any pixels left to crop. 
					--->
					<cfif LOCAL.KeepTrimming>
					
						<cfset ImageCrop(
							LOCAL.Image,
							0,
							1,
							ImageGetWidth( LOCAL.Image ),
							(ImageGetHeight( LOCAL.Image ) - 1)
							) />
							
					</cfif>
				
				</cfcase>
				
				
				<cfcase value="Bottom">
					
					<!--- 
						Sample the bottom row of pixels. This gives us a two 
						dimensional array (rows x columns). 
					--->
					<cfset LOCAL.Pixels = THIS.GetPixels(
						LOCAL.Image,
						0,
						(ImageGetHeight( LOCAL.Image ) - 1),
						ImageGetWidth( LOCAL.Image ),
						1
						) />
					
					<!--- Get the top row from our sample. --->
					<cfset LOCAL.Pixels = LOCAL.Pixels[ 1 ] />
					
					
					<!--- 
						Loop over the pixels to see if there are 
						any colors that are not the same as the 
						background color. 
					--->
					<cfloop
						index="LOCAL.Pixel"
						array="#LOCAL.Pixels#">
						
						<!--- 
							Check to see if the colors are NOT the same. This 
							will be true of their color channels match OR if 
							they are both transparent.
						--->
						<cfif NOT THIS.ColorsAreEqual(
							LOCAL.Pixel,
							LOCAL.Color,
							ARGUMENTS.Tolerance
							)>
							
							<!--- 
								We found non-matching colors. We 
								cannot keep trimming this side. Set 
								the flag to stop the looping. 
							--->
							<cfset LOCAL.KeepTrimming = false />
							
							<!--- Break out of the current pixel loop. --->
							<cfbreak />
							
						</cfif>
							
					</cfloop>
					
					
					<!--- 
						At this point, we have either looped over the entire row of 
						pixels or found one that does not match. Check to see if we 
						should crop the canvase. We should to this we our keep trimming 
						flag is true AND, there are any pixels left to crop. 
					--->
					<cfif LOCAL.KeepTrimming>
					
						<cfset ImageCrop(
							LOCAL.Image,
							0,
							0,
							ImageGetWidth( LOCAL.Image ),
							(ImageGetHeight( LOCAL.Image ) - 1)
							) />
							
					</cfif>
				
				</cfcase>
				
				
				<cfcase value="Left">
					
					<!--- 
						Sample the left column of pixels. This gives us a two 
						dimensional array (rows x columns). 
					--->
					<cfset LOCAL.Pixels = THIS.GetPixels(
						LOCAL.Image,
						0,
						0,
						1,
						ImageGetHeight( LOCAL.Image )
						) />
					
					<!--- 
						Loop over the pixels to see if there are 
						any colors that are not the same as the 
						background color. 
					--->
					<cfloop
						index="LOCAL.RowIndex"
						from="1"
						to="#ArrayLen( LOCAL.Pixels )#"
						step="1">
						
						<!--- Get the current pixel. --->
						<cfset LOCAL.Pixel = LOCAL.Pixels[ LOCAL.RowIndex ][ 1 ] />
						
						<!--- 
							Check to see if the colors are NOT the same. This 
							will be true of their color channels match OR if 
							they are both transparent.
						--->
						<cfif NOT THIS.ColorsAreEqual(
							LOCAL.Pixel,
							LOCAL.Color,
							ARGUMENTS.Tolerance
							)>
							
							<!--- 
								We found non-matching colors. We 
								cannot keep trimming this side. Set 
								the flag to stop the looping. 
							--->
							<cfset LOCAL.KeepTrimming = false />
							
							<!--- Break out of the current pixel loop. --->
							<cfbreak />
							
						</cfif>
							
					</cfloop>
					
					
					<!--- 
						At this point, we have either looped over the entire column of 
						pixels or found one that does not match. Check to see if we 
						should crop the canvase. We should to this we our keep trimming 
						flag is true AND, there are any pixels left to crop. 
					--->
					<cfif LOCAL.KeepTrimming>
					
						<cfset ImageCrop(
							LOCAL.Image,
							1,
							0,
							(ImageGetWidth( LOCAL.Image ) - 1),
							ImageGetHeight( LOCAL.Image )
							) />
							
					</cfif>
				
				</cfcase>
				
				
				<cfcase value="Right">
					
					<!--- 
						Sample the right column of pixels. This gives us a two 
						dimensional array (rows x columns). 
					--->
					<cfset LOCAL.Pixels = THIS.GetPixels(
						LOCAL.Image,
						(ImageGetWidth( LOCAL.Image ) - 1),
						0,
						1,
						ImageGetHeight( LOCAL.Image )
						) />
					
					<!--- 
						Loop over the pixels to see if there are 
						any colors that are not the same as the 
						background color. 
					--->
					<cfloop
						index="LOCAL.RowIndex"
						from="1"
						to="#ArrayLen( LOCAL.Pixels )#"
						step="1">
						
						<!--- Get the current pixel. --->
						<cfset LOCAL.Pixel = LOCAL.Pixels[ LOCAL.RowIndex ][ 1 ] />
						
						<!--- 
							Check to see if the colors are NOT the same. This 
							will be true of their color channels match OR if 
							they are both transparent.
						--->
						<cfif NOT THIS.ColorsAreEqual(
							LOCAL.Pixel,
							LOCAL.Color,
							ARGUMENTS.Tolerance
							)>
							
							<!--- 
								We found non-matching colors. We 
								cannot keep trimming this side. Set 
								the flag to stop the looping. 
							--->
							<cfset LOCAL.KeepTrimming = false />
							
							<!--- Break out of the current pixel loop. --->
							<cfbreak />
							
						</cfif>
							
					</cfloop>
					
					
					<!--- 
						At this point, we have either looped over the entire column of 
						pixels or found one that does not match. Check to see if we 
						should crop the canvase. We should to this we our keep trimming 
						flag is true AND, there are any pixels left to crop. 
					--->
					<cfif LOCAL.KeepTrimming>
					
						<cfset ImageCrop(
							LOCAL.Image,
							0,
							0,
							(ImageGetWidth( LOCAL.Image ) - 1),
							ImageGetHeight( LOCAL.Image )
							) />
							
					</cfif>
				
				</cfcase>
			
			</cfswitch>
			
		</cfloop>
		
		
		<!--- Return the trimmed image. --->
		<cfreturn LOCAL.Image />	
	</cffunction>
	
	
	<!---
		Author: Ben Nadel
		Taken from: http://www.bennadel.com/blog/846-Styling-The-ColdFusion-8-WriteToBrowser-CFImage-Output.htm
	--->
	<cffunction
		name="WriteToBrowser"
		access="public"
		returntype="void"
		output="true"
		hint="Writes the image to the browser with additional attributes such as ALT tag and CSS/Style values.">
	 
		<!--- Define arguments. --->
		<cfargument
			name="Image"
			type="any"
			required="true"
			hint="The ColdFusion image object that you are writing to browser."
			/>
	 
		<cfargument
			name="Alt"
			type="string"
			required="false"
			default=""
			hint="The ALT attribute value to apply to the image."
			/>
	 
		<cfargument
			name="Class"
			type="string"
			required="false"
			default=""
			hint="The CSS class to apply to the image."
			/>
	 
		<cfargument
			name="Style"
			type="string"
			required="false"
			default=""
			hint="The STYLE attribute value to apply to the image."
			/>
	 
		<cfargument
			name="Height"
			type="string"
			required="false"
			default=""
			hint="The HEIGHT attribute value to apply to the image."
			/>
	 
		<cfargument
			name="Width"
			type="string"
			required="false"
			default=""
			hint="The WIDTH attribute value to apply to the image."
			/>
	 
		<cfargument
			name="Border"
			type="string"
			required="false"
			default=""
			hint="The BORDER attribute value to apply to the image."
			/>
	 
	 
		<!--- Define the local scope. --->
		<cfset var LOCAL = {} />
	 
	 
		<!---
			Write the image to the browser. This is really just
			creating the image and then writing to the buffer.
			All we have to do is intercept the buffer write.
		--->
		<cfsavecontent variable="LOCAL.Output">
			<cfoutput>
	 
				<!--- Write image tag. --->
				<cfimage
					action="writetobrowser"
					source="#ARGUMENTS.Image#"
					/>
	 
			</cfoutput>
		</cfsavecontent>
	 
		<!---
			First, delete any existing attributes that we might
			be using (so that we can just add new ones).
		--->
		<cfset LOCAL.Output = LOCAL.Output.ReplaceAll(
			"(?i) (alt|class|style|height|width|border)=""[^""]*""",
			""
			) />
	 
		<!---
			Now that we have an image with Just the SRC
			attribute, we can go about adding our attributes.
			First, chop off the trailing slash.
		--->
		<cfset LOCAL.Output = LOCAL.Output.ReplaceFirst(
			"\s*/?>\s*$",
			""
			) />
	 
		<!---
			Loop over the arguments to see if we need to
			add them to the tag.
		--->
		<cfloop
			index="LOCAL.Key"
			list="alt,class,style,height,width,border"
			delimiters=",">
	 
			<!--- Check for a passed-in value. --->
			<cfif Len( ARGUMENTS[ LOCAL.Key ] )>
	 
				<!---
					Append this argument to the output and a
					key-value attribute.
				--->
				<cfset LOCAL.Output &= (
					" " &
					LOCAL.Key &
					"=""" &
					ARGUMENTS[ LOCAL.Key ] &
					""""
					) />
	 
			</cfif>
	 
		</cfloop>
	 
		<!--- Write the image tag to the output. --->
		<cfset WriteOutput( LOCAL.Output & " />" ) />
	 
		<!--- Return out. --->
		<cfreturn />
	</cffunction>
	
</cfcomponent>
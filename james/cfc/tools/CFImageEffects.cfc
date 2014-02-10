<cfcomponent hint="Image Effects for the CFImage Tag and Image Functions." displayname="CFImage Effects" output="false">
	
	<!---
		NAME: CFImage Effects
		Copyright: Copyright 2007 Foundeo Inc. All Rights Reserved
		
		LICENSE:
			One License required for each server instance that invokes the CFC
			By downloading and placing the software on your computer you hereby accept the terms of the license set forth. If you do not agree with this license you must delete the software.
			This license grants you a permission to use the software provided the following conditions are met:
			You agree to the terms of this license
			You agree NOT to distribute the software to any third party.
			You understand and agree to the following:			
			THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE. 
	
	--->
	
	<cffunction name="init" hint="Returns a reference to this object" output="false" returntype="component"> 
		<cfreturn this>
	</cffunction>
	
	<cffunction name="drawGradientFilledRect" hint="Draws a rectangle with a gradient fade from a start color to and end color. Returns a reference to the image" returntype="any" output="false">
		<cfargument name="imageObj">
		<cfargument name="x" type="numeric" default="0">
		<cfargument name="y" type="numeric" default="0">
		<cfargument name="width" type="numeric" default="0">
		<cfargument name="height" type="numeric" default="0">
		<cfargument name="startColor" type="string" default="black">
		<cfargument name="endColor" type="string" default="white">
		<cfargument name="gradientDirection" type="variablename" hint="horizontal or vertical" default="vertical">
		<cfset var chunkSize = 0>
		<cfset var currentTransparency = 0>
		<cfset var iterations = 0>
		<cfset var isHorizontal = LCase(arguments.gradientDirection) IS "horizontal">
		<cfset var i = 0>
		<cfset var x1 = 0>
		<cfset var x2 = 0>
		<cfset var y1 = 0>
		<cfset var y2 = 0>
		<cfset ImageSetBackgroundColor(arguments.imageObj, arguments.endColor)>
		<cfset ImageClearRect(arguments.imageObj, arguments.x, arguments.y, arguments.width, arguments.height)>
		<cfset ImageSetDrawingColor(arguments.imageObj, arguments.startColor)>
		<cfif isHorizontal>
			<cfset chunkSize = 100 / arguments.width>
			<cfset y1 = arguments.y>
			<cfset y2 = arguments.y + arguments.height>
			<cfset iterations = arguments.width>
		<cfelse>
			<cfset chunkSize = 100 / arguments.height>
			<cfset x1 = arguments.x>
			<cfset x2 = arguments.x + arguments.width>
			<cfset iterations = arguments.height>
		</cfif>
		<cfloop from="1" to="#iterations#" index="i">
				<cfif isHorizontal>
					<cfset x1 = arguments.x + (i-1)>
					<cfset x2 = x1>
				<cfelse>
					<cfset y1 = arguments.y + (i-1)>
					<cfset y2 = y1>
				</cfif>
				<cfif currentTransparency LT 100>
					<cfset ImageSetDrawingTransparency(arguments.imageObj, currentTransparency)>
				</cfif>
				<cfset ImageDrawLine(arguments.imageObj, x1, y1, x2, y2)>
				<cfset currentTransparency = currentTransparency + chunkSize>
		</cfloop>
		<cfreturn arguments.imageObj>
	</cffunction>
	
	<cffunction name="applyReflectionEffect" hint="adds a mirrored look or reflection look, as if the image were on a glass or shiny surface. Returns a new image." returntype="any" output="false">
		<cfargument name="imageObj">
		<cfargument name="backgroundColor" default="white" type="string">
		<cfargument name="mirrorHeight" default="40" type="numeric" hint="Number of pixels high the mirror will be, this will increase the overall image height by this amount.">
		<cfargument name="startOpacity" default="60" type="numeric" hint="must be between 0 and 100, controls the opacity at the top of the mirror">
		<cfset var imageInfo = ImageInfo(arguments.imageObj)>
		<cfset var flippedImage = "">
		<cfset var flippedImageHeight = arguments.mirrorHeight>
		<cfset var newImage = ImageNew("", imageInfo.width, imageInfo.height+arguments.mirrorHeight)>
		<cfset var i = 0>
		<cfset var opacityStep = 1>
		<cfset ImageSetBackgroundColor(newImage, arguments.backgroundColor)>
		<cfset ImageClearRect(newImage, 0, 0, imageInfo.width, imageInfo.height+arguments.mirrorHeight)>
		<cfif imageInfo.height GT arguments.mirrorHeight>
			<cfset flippedImage = ImageCopy(arguments.imageObj, 0, imageInfo.height-arguments.mirrorHeight, imageInfo.width, arguments.mirrorHeight)>
		<cfelse>
			<cfset flippedImageHeight = imageInfo.height>
			<cfset flippedImage = ImageCopy(arguments.imageObj, 0, 0, imageInfo.width, imageInfo.height)>
		</cfif>
		<cfset ImageFlip(flippedImage, "vertical")>
		<cfset ImagePaste(newImage, arguments.imageObj, 0, 0)>
		<cfif flippedImageHeight GT (100-arguments.startOpacity)>
			<cfset opacityStep = (100-arguments.startOpacity) / flippedImageHeight>
		</cfif>
		<cfloop from="1" to="#flippedImageHeight#" index="i">
			<cfif arguments.startOpacity LTE 100>
				<cfset ImageSetDrawingTransparency(newImage, arguments.startOpacity)>
				<cfset imageLine = ImageCopy(flippedImage, 0, i-1, imageInfo.width, 1)>
				<cfset ImagePaste(newImage, imageLine, 0, imageInfo.height+(i-1))>
			</cfif>
			<cfset arguments.startOpacity = arguments.startOpacity+opacityStep>
		</cfloop>
		<cfreturn newImage>
	</cffunction>
	
	<cffunction name="applyPlasticEffect" hint="Adds a plastic look to the image. Returns a new Image" returntype="any" output="false">
		<cfargument name="imageObj">
		<cfargument name="backgroundColor" default="white" type="string">
		<cfargument name="startOpacity" default="60" type="numeric" hint="must be between 0 and 100, controls the opacity at the top of the mirror">
		<cfargument name="endOpacity" default="20" type="numeric" hint="must be between 0 and 100">
		<cfset var imageInfo = ImageInfo(arguments.imageObj)>
		<cfset var newImage = "">
		<cfset var i = 0>
		<cfset var opacityStep = 1>
		<cfset var bottomY = Int(imageInfo.height / 2)>
		<cfset newImage = ImageNew("", imageInfo.width, imageInfo.height)>
		<cfset ImagePaste(newImage, arguments.imageObj, 0, 0)>
		<cfset ImageSetBackgroundColor(newImage, arguments.backgroundColor)>
		<cfset ImageClearRect(newImage, 0, 0, imageInfo.width, bottomY)>
		
		<cfset opacityStep = (arguments.startOpacity-arguments.endOpacity) / bottomY>
		
		<cfloop from="1" to="#bottomY#" index="i">
			<cfif arguments.startOpacity GTE arguments.endOpacity>
				<cfset ImageSetDrawingTransparency(newImage, arguments.startOpacity)>
				<cfset imageLine = ImageCopy(arguments.imageObj, 0, i-1, imageInfo.width, 1)>
				<cfset ImagePaste(newImage, imageLine, 0, (i-1))>
			</cfif>
			<cfset arguments.startOpacity = arguments.startOpacity-opacityStep>
		</cfloop>
		<cfreturn newImage>
	</cffunction>
	
	<cffunction name="applyRoundedCornersEffect" hint="Takes an image and returns a new image with rounded corners." returntype="any" output="false">
		<cfargument name="imageObj">
		<cfargument name="backgroundColor" default="white" type="string">
		<cfargument name="cornerSize" type="numeric" default="20">
		<cfset var imageInfo = ImageInfo(arguments.imageObj)>
		<cfset var i = 0>
		<cfset ImageSetAntialiasing(arguments.imageObj, "on")>
		<cfset ImageSetDrawingColor(arguments.imageObj, arguments.backgroundColor)>
		<cfloop to="#arguments.cornerSize#" from="1" index="i">
			<cfset ImageDrawRoundRect(arguments.imageObj, 0, 0, imageInfo.width, imageInfo.height, i, i, false)>
		</cfloop>
		<cfreturn arguments.imageObj>
	</cffunction>
	
	<cffunction name="applyDropShadowEffect" output="false" hint="Returns a new image with a dropshadow, increased height and width by shadowWidth+shadowDistance">
		<cfargument name="imageObj" hint="A ColdFusion Image Object you wish to add a drop shadow to.">
		<cfargument name="backgroundColor" default="white" type="string" hint="background color the image will be displayed on."> 
		<cfargument name="shadowColor" default="##A19FA4" type="string" hint="the color of the drop shadow, you typically want a grayish color">
		<cfargument name="shadowWidth" default="3" type="numeric">
		<cfargument name="shadowDistance" default="4">
		<cfset var imageInfo = ImageInfo(arguments.imageObj)>
		<cfset var strokeAttribs = StructNew()>
		<cfset var offset = 20>
		<cfset var newWidth = imageInfo.width+arguments.shadowWidth+arguments.shadowDistance + (offset * 2)>
		<cfset var newHeight = imageInfo.height+arguments.shadowWidth+arguments.shadowDistance + (offset * 2)>
		
		<cfset newImage = ImageNew("", newWidth, newHeight)>
		<cfset ImageSetBackgroundColor(newImage, arguments.backgroundColor)>
		<cfset ImageSetDrawingColor(newImage, arguments.backgroundColor)>
		<cfset ImageDrawRect(newImage, 0, 0, newWidth, newHeight, true)>
		<cfset strokeAttribs.width = arguments.shadowWidth>
		<cfset ImageSetDrawingStroke(newImage, strokeAttribs)>	
		<cfset ImageSetDrawingColor(newImage, arguments.shadowColor)>
		<cfset ImageDrawLine(newImage, imageInfo.width+offset, arguments.shadowDistance+offset, imageInfo.width+offset, imageInfo.height+offset)>
		<cfset ImageDrawLine(newImage, arguments.shadowDistance+offset, imageInfo.height+offset, imageInfo.width-Fix(arguments.shadowWidth/2)+offset, imageInfo.height+offset)>
		<cfset ImageSetBackgroundColor(newImage, arguments.backgroundColor)>
		<cfset ImageSetDrawingColor(newImage, arguments.backgroundColor)>
		<cfset ImageBlur(newImage, 9)>
		<cfset ImageBlur(newImage, 5)>
		<cfset ImageBlur(newImage, 4)>
		<cfset ImagePaste(newImage, arguments.imageObj, offset, offset)>
		<cfset ImageCrop(newImage, offset, offset, newWidth-(offset*2), newHeight-(offset*2))>
		<cfreturn newImage>
	</cffunction>
	
	<cffunction name="sepiaTone" output="false" returntype="any" hint="Adds a Sepia Tone to the given image">
		<cfargument name="imageObj" hint="The image object">
		<cfset var bufImg =  ImageGetBufferedImage(arguments.imageObj)>
		<cfset var w = bufImg.getWidth()>
		<cfset var h = bufImg.getHeight()>
		<cfset var x = 0>
		<cfset var y = 0>
		<cfset var r = 0>
		<cfset var g = 0>
		<cfset var b = 0>
		<cfset var old_r = 0>
		<cfset var old_g = 0>
		<cfset var old_b = 0>
		<cfset var old_color = "">
		<cfset var new_color = "">
		<cfset var rgbArray = bufImg.getRGB(0,0,w,h,JavaCast("null", ""),0,w)>
		<cfloop from="1" to="#w#" index="x">
			<cfloop from="1" to="#h#" index="y">
				<cfset old_color = rgbArray[((y-1)*w)+(x-1)+1]>
				<cfset old_r = BitAnd(BitSHRN(old_color, 16),255) / 255>
				<cfset old_g = BitAnd(BitSHRN(old_color, 8),255) / 255>
				<cfset old_b = BitAnd(old_color,255) / 255>
				<cfset r = Int( ((old_r * 0.393) + (old_g * 0.769) + (old_b * 0.189)) * 255)>
				<cfset g = Int( ((old_r * 0.349) + (old_g * 0.686) + (old_b * 0.168)) * 255)>
				<cfset b = Int( ((old_r * 0.272) + (old_g * 0.534) + (old_b * 0.131)) * 255)>
				<cfif r GT 255><cfset r=255></cfif>
				<cfif g GT 255><cfset g=255></cfif>
				<cfif b GT 255><cfset b=255></cfif>
				<cfset new_color = BitOr( BitSHLN(BitAnd(r,255), 16), BitOr(BitSHLN(BitAnd(g,255),8), BitAnd(b,255) ) )>
				<cfset bufImg.setRGB(x-1,y-1,new_color)>
			</cfloop>
		</cfloop>
		<cfreturn arguments.imageObj>
	</cffunction>
	
	<cffunction name="darkenImage" output="false" returntype="any" hint="Darkens the given image.">
		<cfargument name="imageObj" hint="The CFImage Object.">
		<cfset var bufImg =  ImageGetBufferedImage(arguments.imageObj)>
		<cfset var w = bufImg.getWidth()>
		<cfset var h = bufImg.getHeight()>
		<cfset var x = 0>
		<cfset var y = 0>
		<cfset var r = 0>
		<cfset var g = 0>
		<cfset var b = 0>
		<cfset var factor = 0.7>
		<cfset var rgb = "">
		<cfset var new_color = "">
		<cfset var rgbArray = bufImg.getRGB(0,0,w,h,JavaCast("null", ""),0,w)>
		<cfloop from="1" to="#w#" index="x">
			<cfloop from="1" to="#h#" index="y">
				<cfset rgb = rgbArray[((y-1)*w)+(x-1)+1]>
				<cfset r = BitAnd(BitSHRN(rgb, 16),255) * factor>
				<cfset g = BitAnd(BitSHRN(rgb, 8),255) * factor>
				<cfset b = BitAnd(rgb,255) * factor>
				<cfif r LT 0><cfset r=0></cfif>
				<cfif g LT 0><cfset g=0></cfif>
				<cfif b LT 0><cfset b=0></cfif>
				<cfset rgb = BitOr( BitSHLN(BitAnd(r,255), 16), BitOr(BitSHLN(BitAnd(g,255),8), BitAnd(b,255) ) )>
				<cfset bufImg.setRGB(x-1,y-1,rgb)>
			</cfloop>
		</cfloop>
		<cfreturn arguments.imageObj>
	</cffunction>
	
	<cffunction name="brightenImage" output="false" returntype="any" hint="Brightens the given image.">
		<cfargument name="imageObj" hint="The CFImage Object.">
		<cfset var bufImg =  ImageGetBufferedImage(arguments.imageObj)>
		<cfset var w = bufImg.getWidth()>
		<cfset var h = bufImg.getHeight()>
		<cfset var x = 0>
		<cfset var y = 0>
		<cfset var r = 0>
		<cfset var g = 0>
		<cfset var b = 0>
		<cfset var rgb = "">
		<cfset var rgbArray = bufImg.getRGB(0,0,w,h,JavaCast("null", ""),0,w)>
		<cfloop from="1" to="#w#" index="x">
			<cfloop from="1" to="#h#" index="y">
				<cfset rgb = rgbArray[((y-1)*w)+(x-1)+1]>
				<cfset r = BitAnd(BitSHRN(rgb, 16),255)>
				<cfset g = BitAnd(BitSHRN(rgb, 8),255)>
				<cfset b = BitAnd(rgb,255)>
				<cfif r EQ 0><cfset r = 3></cfif>
				<cfif g EQ 0><cfset g = 3></cfif>
				<cfif b EQ 0><cfset b = 3></cfif>
				<cfset r= r/0.7>
				<cfset g= g/0.7>
				<cfset b= b/0.7>
				<cfif r GT 255><cfset r=255></cfif>
				<cfif g GT 255><cfset g=255></cfif>
				<cfif b GT 255><cfset b=255></cfif>
				<cfset rgb = BitOr( BitSHLN(BitAnd(r,255), 16), BitOr(BitSHLN(BitAnd(g,255),8), BitAnd(b,255) ) )>
				<cfset bufImg.setRGB(x-1,y-1,rgb)>
			</cfloop>
		</cfloop>
		<cfreturn arguments.imageObj>
	</cffunction>
	
	
</cfcomponent>
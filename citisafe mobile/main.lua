-----------------------------------------------------------------------------------------
--
-- main.lua
--
-----------------------------------------------------------------------------------------

-- hide status bar
display.setStatusBar( display.HiddenStatusBar )

-- Get the screen metrics (use the entire device screen area)
local WIDTH = display.actualContentWidth
local HEIGHT = display.actualContentHeight
local xMin = display.screenOriginX
local yMin = display.screenOriginY
local xMax = xMin + WIDTH
local yMax = yMin + HEIGHT
local xCenter = (xMin + xMax) / 2
local yCenter = (yMin + yMax) / 2

-- import widget module
local widget = require( "widget" )

-- drawing area
local board = display.newRect( xCenter, yCenter, WIDTH * 0.9, HEIGHT * 0.9 )
local canvas = display.newGroup( )

-- frame around drawing area, needed to be defined after so overhanging "brushstrokes" would be masked
local frame = display.newGroup( )

local borderL = display.newRect( frame, xMin + 10, yCenter, 20, HEIGHT )
local borderR = display.newRect( frame, xMax - 10, yCenter, 20, HEIGHT)
local borderT = display.newRect( frame, xCenter, yMin + 15, WIDTH, 30 )
local borderB = display.newRect( frame, xCenter, yMax - 75, WIDTH, 150 )

-- save a whole line of code using a loop to set color
for i = 1, frame.numChildren do
	frame[i]:setFillColor(0.8,0.8,0.8)
end

-- paintbrush preview area
local brushBox = display.newRect(xMin + 30, yMax - 100, 50, 50)
brushBox:setStrokeColor(0,0,0)
brushBox.strokeWidth = 2
brushBox:setFillColor(1,1,1)

-- default paint brush, circle
local circle = display.newCircle(xMin + 30,yMax - 100, 12)
circle:setStrokeColor(1,1,1)
circle:setFillColor(1,0,0)
circle.fillColor = {1,0,0} -- store color value for access during drawing

-- alternate paintbrush, square (not an improvement, but I ran out of time)
local square = display.newRect(xMin + 30,yMax - 100, 24, 24)
square:setFillColor(1,0,0) -- gotta keep the square the same color as the circle, even if hidden
square.alpha = 0 -- hide by default

brush = "Circle" -- flag for current brush selection

-- brush value labels
local brushSize = display.newText(2 * circle.path.radius .. " pt", xMin + 30, yMax - 35, "Helvetica", 10)
brushSize:setFillColor(0, 0, 0)
local brushLabel = display.newText("Paintbrush", xMin + 30, yMax - 135, "Helvetica", 10)
brushLabel:setFillColor(0,0,0)
local colorLabel = display.newText("Color", xMin + 200, yMax - 135, "Helvetica", 10)
colorLabel:setFillColor(0,0,0)
local brushShape = display.newText("Shape", xMin + 95, yMax - 20, "Helvetica", 10)
brushShape:setFillColor(0,0,0)
local brushWeight = display.newText("Transparency", xMin + 150, yMax - 20, "Helvetica", 10)
brushWeight:setFillColor(0,0,0)

-- brush stroke transparency
brushWeight.opacity = 1

-- change brushsize based on slider widget value
function sliderListener( event )
	-- update both size of both brush previews 
   	circle.path.radius = 2 + 20 * event.value / 100
   	square.width, square.height = 4 + 40 * event.value / 100, 4 + 40 * event.value / 100

   	-- output text displaying brush size
   	brushSize.text = math.ceil(2 * circle.path.radius) .. " pt"
end

-- set paint color based on segmented widget selected value
function onSegmentPress ( event )
	local target = event.target
	
	-- set color based on Lobel value... maybe there was a good way to store the RGB as a table, but didn't find it
	if target.segmentLabel == "Red" then
		circle:setFillColor(1,0,0) -- set circle color
		circle.fillColor = {1,0,0} -- store color value for reference during drawing
		square:setFillColor(1,0,0) -- set square color
		brushBox:setFillColor(1,1,1) -- white background for all non-White colors
	elseif target.segmentLabel =="Yellow" then -- same for the rest
		circle:setFillColor(1,1,0)
		circle.fillColor = {1,1,0}
		square:setFillColor(1,1,0)
		brushBox:setFillColor(1,1,1)  
	elseif target.segmentLabel =="Green" then
		circle:setFillColor(0,1,0)
		circle.fillColor = {0,1,0}
		square:setFillColor(0,1,0)
		brushBox:setFillColor(1,1,1) 
	elseif target.segmentLabel =="Blue" then
		circle:setFillColor(0,0,1)
		circle.fillColor = {0,0,1}
		square:setFillColor(0,0,1)
		brushBox:setFillColor(1,1,1)
	elseif target.segmentLabel =="White" then
		circle:setFillColor(1,1,1)
		circle.fillColor = {1,1,1}
		square:setFillColor(1,1,1)
		brushBox:setFillColor(0,0,0) -- black background to show White brush
	elseif target.segmentLabel =="Black" then
		circle:setFillColor(0,0,0)
		circle.fillColor = {0,0,0}
		square:setFillColor(0,0,0)
		brushBox:setFillColor(1,1,1)
	end
end


-- Create paintbrush size selector with a slider widget
local slider = widget.newSlider(
    {
        x = xMin + 30,
        top = yMax - 80,
        width = 50,
        listener = sliderListener,
        orientation = "horizontal",
    }
)

-- Create the paint color selector, default value red
local colorPicker = widget.newSegmentedControl(
	{
		left = xMin + 65,
		top = yMax - 120,
		segmentWidth = 40,
		segments = {"Red","Yellow","Green", "Blue", "White", "Black"},
		onPress = onSegmentPress,
	}
)

-- Listener event for picker wheel widget; NOTE: can't use picker wheel methods here, lame
function pickValues( event )
	if event.column == 1 then
		if event.row == 1 then
			-- select Circle brush, hide Square brush
			brush = "Circle"
			circle.alpha = 1
			square.alpha = 0
		else
			-- select Square brush, hide Circle brush
			brush = "Square"
			circle.alpha = 0
			square.alpha = 1
		end
	elseif event.column == 2 then
		if event.row == 1 then
			brushWeight.opacity = 1 -- make brushstroke fully opaque
		else
			brushWeight.opacity = 0.3 -- make brushstroke semi transparent
		end
	end
	
end


-- Set up the picker wheel columns
local columnData = 
{ 
    {
        align = "left",
        width = 45,
        labelPadding = 10,
        startIndex = 1,
        labels = { "Circle", "Square"}
    },
    {
        align = "left",
        width = 55,
        labelPadding = 5,
        startIndex = 1,
        labels = { "Opaque", "Translucent"}
    }
}
 
-- Create the picker wheel widget
local pickerWheel = widget.newPickerWheel(
{
    left = xMin + 70,
    top = colorPicker.y + 30,
    columns = columnData,
    style = "resizable",
    width = 110,
    rowHeight = 10,
    fontSize = 10,
    onValueSelected = pickValues, -- listener event for new selections
})
 

-- Reset drawing app to initial state
function clearDrawing ( event )
	
	while canvas.numChildren > 0 do
		canvas[1]:removeSelf() -- deletes first object in group table, Corona reindexes table (?), new first element
	end

	-- for comparison, since the group is a "smart array" (per lecture), deletion should proceed in reverse
	-- for i = canvas.numChildren, 1, -1 do
 	-- 		canvas[i]:removeSelf()
 	-- end

 	-- return brush controls to default values 
  	slider:setValue(50) -- brush size to middle value
  	circle.path.radius = 2 + 20 * slider.value / 100 -- calculate brush based on slider value
  	brushSize.text = math.ceil(2 * circle.path.radius) .. " pt" -- update brush size display
  	colorPicker:setActiveSegment(1) -- select "Red" on color picker
  	
  	-- reset circle brush in preview area
  	circle:setFillColor(1,0,0) -- set to Red as default
  	circle.fillColor = {1,0,0} -- store color value for reference when drawing
  	circle.alpha = 1 -- visible as default brush shape selection

  	-- reset square brush in preview area
  	square:setFillColor(1,0,0) -- set to Red even though it won't be visible
  	square.alpha = 0 -- hidden by default

  	brushBox:setFillColor(1,1,1) -- white background to go with Red brush
  	
  	brushWeight.opacity = 1 -- set default brush 
  	pickerWheel:selectValue( 1, 1 )
  	pickerWheel:selectValue( 2, 1 )

end

local newDrawing = widget.newButton(
	{	
		id = reset,
		x = xMax - 55,
		y = yMax - 25,
		label = "New Drawing",
		fontSize = 12,
		defaultFile = "",
		overFile = "",
		shape = "roundedRect",
		width = 100,
		height = 30,
		onEvent = clearDrawing,
	}
)

-- drawing function, using the touch event
function myTouchListener( event )
 	local dot

    if ( event.phase == "began" ) then
        -- Start drawing as soon as the screen is touched
       	
        if brush == "Circle" then -- apply currently selected brush shape
        	dot = display.newCircle(event.x, event.y, circle.path.radius )
        else
        	dot = display.newRect(event.x,event.y,circle.path.radius * 2, circle.path.radius * 2)
        end
        
		dot:setFillColor( unpack(circle.fillColor) ) -- set brush to selected color value
        dot.alpha = brushWeight.opacity -- set brush to selected transparency value
        
        canvas:insert(dot) -- add drawing to canvas group (organized for deletion)
        
        
    elseif ( event.phase == "moved" ) then
        -- Code executed when the touch is moved over the object
        
        if brush == "Circle" then
        	dot = display.newCircle(event.x, event.y, circle.path.radius )
        else
        	dot = display.newRect(event.x,event.y,circle.path.radius * 2, circle.path.radius * 2)
        end

        dot:setFillColor( unpack(circle.fillColor) ) -- set brush to selected color value
        dot.alpha = brushWeight.opacity -- set brush to selected transparency value
        
        canvas:insert(dot) -- add drawing to canvas group
        
        -- connect the dots with lines to fill gaps
        if lastX ~= nil then
         	local connect = display.newLine( lastX, lastY, event.x, event.y )
        	connect.strokeWidth = circle.path.radius * 2 -- match radius for a smooth line
        	connect:setStrokeColor( unpack(circle.fillColor) ) -- set line to current color selection
        	connect.alpha = brushWeight.opacity -- set brush to selected transparency value
        	canvas:insert(connect) -- add line to group
        end

        -- set new end point for connecting next connector if needed
        lastX = event.x 
        lastY = event.y

    elseif ( event.phase == "ended" ) then
      
      	-- clear end points so next touch doesn't connect the dots
        lastX, lastY = nil, nil
    end
end

board:addEventListener( "touch", myTouchListener )  -- Add a "touch" listener to the object
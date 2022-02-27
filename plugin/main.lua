-- README.md

--[[

AUTHOR: R0bl0x10501050

IMPORTANT:	THIS IS A PROOF-OF-CONCEPT, BUILT SOLELY FOR EXPERIMENTAL PURPOSES AND NOT MEANT 
			TO BE USED IN ANY ROBLOX EXPERIENCE!

			THIS WILL BE POSTED ON THE OFFICIAL ROBLOX DEVELOPER FORUM (https://devforum.roblox.com)
			
]]

local ChangeHistoryService = game:GetService("ChangeHistoryService")
local HTTP = game:GetService("HttpService")

local toolbar = plugin:CreateToolbar("Thingy")

local NewButton = toolbar:CreateButton("Thingy", "Thingy", "rbxassetid://4458901886")

local Widget
local widgetInfo = DockWidgetPluginGuiInfo.new(
	Enum.InitialDockState.Float,  -- Widget will be initialized in floating panel
	true,   -- Widget will be initially enabled
	false,  -- Don't override the previous enabled state
	300,    -- Default width of the floating window
	500,    -- Default height of the floating window
	300,    -- Minimum width of the floating window
	500     -- Minimum height of the floating window
)
local gui

Widget = plugin:CreateDockWidgetPluginGui("Thingy", widgetInfo)
Widget.Title = "Thingy"
Widget.Enabled = true

NewButton.Click:Connect(function()
	Widget.Enabled = not Widget.Enabled
end)

script.Parent:WaitForChild('ScreenGui'):WaitForChild('Frame').Parent = Widget

Widget.Frame.TextButton.MouseButton1Click:Connect(function()
	gui = game.Selection:Get()[1]
end)

Widget.Frame.Submit.MouseButton1Click:Connect(function()
	local id = Widget.Frame.TextBox.Text
	local data = HTTP:GetAsync("http://localhost:8080/" .. id)
	local decoded = HTTP:JSONDecode(data)
	
	local h = decoded.height
	local w = decoded.width
	local zIndex = 1
	local scale = tonumber(Widget.Frame.Scale.Text) or 1
	
	local function addPixel(color, transparency, cw, ch, zIndex)
		local pixel = Instance.new("Frame", gui)
		pixel.Position = UDim2.fromOffset((cw * scale) - scale, (ch * scale) - scale)
		pixel.Size = UDim2.fromOffset(scale, scale)
		pixel.BorderSizePixel = 0
		pixel.BackgroundColor3 = color
		pixel.BackgroundTransparency = transparency
		pixel.ZIndex = zIndex
	end
	
	for y = 1, h, 1 do
		for x = 1, w, 1 do
			local d = decoded.pixels[zIndex]
			local split = d:split("|")
			local color = Color3.fromRGB(tonumber(split[1]), tonumber(split[2]), tonumber(split[3]))
			local transparency = 1 - (tonumber(split[4]) / 255)
			addPixel(color, transparency, x, y, zIndex)
			zIndex += 1
		end
	end
	
	print("Completed!")
end)

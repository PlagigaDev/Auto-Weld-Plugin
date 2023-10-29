local ChangeHistoryService = game:GetService("ChangeHistoryService")
local Selection = game:GetService("Selection")
local Roact = require(script.Parent:WaitForChild("Roact"))

local toolbar = plugin:CreateToolbar("Auto Weld")

local pluginButton = toolbar:CreateButton(
"Auto Weld", --Text that will appear below button
"Weld all parts to the Handle/ Primary part", --Text that will appear if you hover your mouse on button
"rbxassetid://12432317029") --Button icon

local info = DockWidgetPluginGuiInfo.new(
	Enum.InitialDockState.Right, --From what side gui appears
	false, --Widget will be initially enabled
	false, --Don't overdrive previouse enabled state
	300, --default weight
	500, --default height
	200, --minimum weight (optional)
	300 --minimum height (optional)
)

local widget = plugin:CreateDockWidgetPluginGui(
"Auto Weld", --A unique and consistent identifier used to storing the widget’s dock state and other internal details
info --dock widget info
)

local theme = settings():GetService("Studio").Theme

function weld()
	local currentElement = Selection:Get()
	if #currentElement > 1 then
		warn("Please only select one Model/ Accessory that you want to weld together")
		return
	end
	currentElement = currentElement[1]
	local isModel = currentElement:IsA("Model")
	if not (isModel or currentElement:IsA("Accessory")) then
		error("Only Models and Accessories can be Auto welded")
		return
	end
	local mainPart: BasePart
	if isModel then
		mainPart = currentElement.PrimaryPart
	else
		mainPart = currentElement:FindFirstChild("Handle")
	end

	if mainPart == nil then
		error(string.format(isModel and "%s has no PrimaryPart" or "%s has no Handle", currentElement.Name))
		return
	end
	for _, part: BasePart in pairs(currentElement:GetDescendants()) do
		if not part:IsA("BasePart") or part == mainPart then
			continue
		end
		local weld = Instance.new("WeldConstraint")
		weld.Part0 = part
		weld.Part1 = mainPart
		weld.Name = string.format("ConnectionTo%s",mainPart.Name)
		weld.Parent = part

		part.Anchored = false
	end


	ChangeHistoryService:SetWaypoint(string.format("Welded %s to %s", currentElement.Name, isModel and "PrimaryPart" or "Handle"))
end

Roact.mount(Roact.createElement("TextButton", {
	Text = "Weld",
	Position = UDim2.fromScale(.5,.5),
	AnchorPoint = Vector2.new(.5,.5),
	Size = UDim2.fromScale(.75,.5),
	TextScaled = true,
	BackgroundColor3 = theme:GetColor(Enum.StudioStyleGuideColor.MainButton),
	TextColor3 = theme:GetColor(Enum.StudioStyleGuideColor.MainText),
	[Roact.Event.MouseButton1Click] = weld
}), widget, "Auto Weld UI" )



local isOpen = plugin:GetSetting("on") or false

if isOpen then
    widget.Enabled = isOpen
	pluginButton:SetActive(isOpen)
end

pluginButton.Click:Connect(function()
	isOpen = not widget.Enabled
    plugin:SetSetting("on", isOpen)
    widget.Enabled = isOpen
	pluginButton:SetActive(isOpen)
end)
local cameraFunctions = {}

local TweenService = game:GetService('TweenService')
local cameraTween = TweenInfo.new(
	0.375,
	Enum.EasingStyle.Linear,
	Enum.EasingDirection.In,
	0,
	false,
	0
)
local previousCameraTilt = 0

function cameraFunctions.CameraTilt(camera,cameraTilt)
    TweenService:Create(camera,cameraTween, { CFrame = camera.CFrame * CFrame.Angles(0,0,math.rad(cameraTilt - previousCameraTilt))}):Play()
    previousCameraTilt = cameraTilt
end

function cameraFunctions.UpdateFOV(camera,base,excess_speed)
    camera.FieldOfView = base + excess_speed
end

return cameraFunctions
local CameraFunctions = {}

local TweenService = game:GetService('TweenService')
local cameraTween = TweenInfo.new(
	0.375,
	Enum.EasingStyle.Linear,
	Enum.EasingDirection.In,
	0,
	false,
	0
)

function CameraFunctions.UpdateFOV(camera,base,speed)
	camera.FieldOfView = base + speed
end

local previousCameraTilt = 0
function CameraFunctions.CameraTilt(camera,cameraTilt)
    TweenService:Create(camera,cameraTween, { CFrame = camera.CFrame * CFrame.Angles(0,0,math.rad(cameraTilt - previousCameraTilt))}):Play()
    previousCameraTilt = cameraTilt
end

return CameraFunctions

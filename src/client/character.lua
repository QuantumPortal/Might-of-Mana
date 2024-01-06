local characterFunctions = {}


local TweenService = game:GetService('TweenService')
local torsoTween = TweenInfo.new(
	0.2,
	Enum.EasingStyle.Linear,
	Enum.EasingDirection.Out,
	0,
	false,
	0
)

function characterFunctions.DirectionalTilt(player)
    local character = player.Character
    local humanoid = character.Humanoid
    local rootPart = character.HumanoidRootPart
    local waist = character.UpperTorso.Waist

    local moveAngle = rootPart.CFrame.LookVector:Angle(humanoid.MoveDirection,rootPart.CFrame.LookVector)

	if moveAngle > math.pi/2 then
		moveAngle = math.pi - moveAngle
	end

    local x = (
        math.cos(moveAngle)
        * math.sign(((CFrame.fromEulerAnglesXYZ(0,math.pi/2,0) * rootPart.CFrame).LookVector:Cross(humanoid.MoveDirection)).Y)
        * (CFrame.fromEulerAnglesXYZ(0,math.pi/2,0) * rootPart.CFrame).LookVector:Angle(humanoid.MoveDirection,rootPart.CFrame.LookVector)
        / 4
    )

    local z = (
        math.sin(moveAngle)
        * math.sign((rootPart.CFrame.LookVector:Cross(humanoid.MoveDirection)).Y) 
        * rootPart.CFrame.LookVector:Angle(humanoid.MoveDirection,rootPart.CFrame.LookVector)
        / 5
    )
        local targetWaist = waist.C0 * CFrame.fromEulerAnglesXYZ(x,0,z)

    TweenService:Create(waist,torsoTween, {C0 = targetWaist}):Play()
end

function characterFunctions.LookToMouse(player)
    local mouse = player:GetMouse()
    local character = player.Character
    local rootPart = character.HumanoidRootPart
    local waist = character.UpperTorso.Waist
    local neck = character.Head.Neck
    local x, y, z = CFrame.lookAt(
        rootPart.CFrame.Position, 
        Vector3.new(mouse.Hit.Position.X,mouse.Hit.Position.Y,mouse.Hit.Position.Z)
    ):ToOrientation()
	
    rootPart.CFrame = rootPart.CFrame:Lerp(CFrame.new(rootPart.CFrame.Position) * CFrame.fromEulerAnglesXYZ(0,y,0),0.2)
	
	waist.C0 = waist.C0:Lerp(CFrame.new(waist.C0.Position) * CFrame.fromEulerAnglesXYZ(0.45*x,0,0.45*z),0.35)
	neck.C0 = neck.C0:Lerp(CFrame.new(neck.C0.Position) * CFrame.fromEulerAnglesXYZ(0.55*x,0,0.55*z), 0.35)
	
end

return characterFunctions
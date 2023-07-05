local enabled = true
local thickness = 100
function onCreate()
    makeLuaSprite("bar_upper", nil, 0, -thickness)
	makeGraphic("bar_upper", 1280, thickness, "000000")
	setObjectCamera("bar_upper", "hud")
	addLuaSprite("bar_upper", false)
			
	makeLuaSprite("bar_lower", nil, 0, 720)
	makeGraphic("bar_lower", 1280, thickness, "000000")
	setObjectCamera("bar_lower", "hud")
	addLuaSprite("bar_lower", false)
end
function onCreatePost()
	callScript("scripts/neocam", "set_target", {"intro", 1000, -400})
	callScript("scripts/neocam", "snap_target", {"intro"})
		
	callScript("scripts/neocam", "snap_zoom", {"game", 0.7})
end

function onSongStart()
	callScript("scripts/neocam", "focus", {"center", 5, "cubeinout", true})
	doTweenY("bar_upper", "bar_upper", 0, 2, "quintout")
	doTweenY("bar_lower", "bar_lower", 720 - thickness, 2, "quintout")
end
function onBeatHit()
	if curBeat == 48 then
		setGlobalFromScript("scripts/neocam", "locked_pos", false)
		callScript("scripts/neocam", "zoom", {"game", 1.025, 2, "easein"})
	end
end
function onUpdate() end
function onUpdatePost() end
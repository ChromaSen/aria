function onCreatePost()
	callScript("scripts/neocam", "set_target", {"intro", 1000, -400})
	callScript("scripts/neocam", "snap_target", {"intro"})
		
	callScript("scripts/neocam", "snap_zoom", {"game", 0.7})
end

function onSongStart()
	callScript("scripts/neocam", "focus", {"center", 5, "cubeinout", true})
end
function onBeatHit()
	if curBeat == 48 then
		setGlobalFromScript("scripts/neocam", "locked_pos", false)
		callScript("scripts/neocam", "zoom", {"game", 1.025, 2, "easein"})
	end
	if curBeat == 112 then
		callScript("scripts/neocam", "zoom", {"game", 0.9, 1, "quartout"})
	end
	if curBeat == 239 then
		callScript("scripts/neocam", "zoom", {"game", 0.7, 1, "quartout"})
	end
end
function onUpdate() end
function onUpdatePost() end
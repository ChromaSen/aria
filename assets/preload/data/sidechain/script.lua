local stop_countdown = true

function onCreatePost()
	if isStoryMode then
		callScript("scripts/neocam", "set_target", {"intro", 1500, 500})
		callScript("scripts/neocam", "snap_target", {"intro"})
		
		callScript("scripts/neocam", "snap_zoom", {"game", 1.6})
		
	else
		setGlobalFromScript("scripts/neocam", "position_locked", true)
	end
end

function onStartCountdown()
    if isStoryMode then
		callScript("scripts/neocam", "focus", {"center", 5, "cubeinout", true})
		callScript("scripts/neocam", "zoom", {"game", 0.9, 2, "easein"})
		setGlobalFromScript("scripts/neocam", "locked_pos", false)
    end
end
-- crash prevention
function onUpdate() end
function onUpdatePost() end

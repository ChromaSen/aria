function onBeatHit() --fuck events.json all my homies hate events.json
	if curBeat == 1 then
		callScript("scripts/neocam", "zoom", {"game", 1.1, 4, "sineinout"})
	end
end
function onUpdate() end
function onUpdatePost() end
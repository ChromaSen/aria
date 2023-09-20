function onBeatHit() --fuck events.json all my homies hate events.json
	if curBeat == 1 then
		callScript("scripts/neocam", "zoom", {"game", 1.1, 4, "sineinout"})
	end
	if curBeat == 36 then
		callScript("scripts/neocam", "zoom", {"game", 0.9, 1, "sineinout"})
	end
	if curBeat == 164 then
		callScript("scripts/neocam", "zoom", {"game", 1.1, 1, "sineinout"})
	end
	if curBeat == 256 then
		callScript("scripts/neocam", "zoom", {"game", 1.3, 4.5, "easein"})
	end
end
function onUpdate() end
function onUpdatePost() end
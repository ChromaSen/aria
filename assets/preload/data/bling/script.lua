function onBeatHit() --fuck events.json all my homies hate events.json
	if curBeat == 192 then
        cameraFlash('camHUD', 'ffffff', 1)
		callScript("scripts/neocam", "zoom", {"game", 1.1, 1, "sineinout"})
	end
end
function onUpdate() end
function onUpdatePost() end
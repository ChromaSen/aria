function onBeatHit() --fuck events.json all my homies hate events.json
	if curBeat == 192 then
        cameraFlash('camHUD', 'ffffff', 1)
		callScript("scripts/neocam", "zoom", {"game", 1.1, 1, "sineinout"})
	end
	if curBeat == 216 then
        cameraFlash('camHUD', 'ffffff', 1)
		callScript("scripts/neocam", "zoom", {"game", 0.9, 2, "sineinout"})
	end
	if curBeat == 236 then
		callScript("scripts/neocam", "zoom", {"game", 1.2, 2, "sineinout"})
	end
	if curBeat == 240 then
		cameraFlash('camHUD', 'ffffff', 1)
		callScript("scripts/neocam", "zoom", {"game", 1.2, 16, "sineinout"})
	end
end
function onUpdate() end
function onUpdatePost() end
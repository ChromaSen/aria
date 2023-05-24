function onCreatePost()
	setPropertyFromClass("GameOverSubstate", "characterName", "nim-dead")
	--setPropertyFromClass("GameOverSubstate", "deathSoundName", "zibidi_lose_sfx")
	
	if not lowQuality then
		addCharacterToList("nim-dead")
		--precacheSound("zibidi_lose_sfx")
	end
end

-- crash prevention
function onUpdate() end
function onUpdatePost() end

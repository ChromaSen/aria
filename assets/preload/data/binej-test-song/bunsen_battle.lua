local events = {
	[30] = {"binej", 2, "punch"},
	[62] = {"bf", 2, 16},
	[93] = {"bf", 2, 16},
	--[46] = {"bf", 1, 16}
}
local event_index = 0
local attacks_left = 5

local sin = math.sin
local pi = math.pi
local ceil = math.ceil
local floor = math.floor
local function lerp(start, goal, alpha)
	return start + (goal - start) * alpha
end

local health = {binej = 5, bf = 4, init = 4}
local active = false
local input = false
local hit = 0
local combo = 0
local player = false
local attack = nil
local beats = 0
local pre_event = 0

local window = {secret = {{{9, 54}, {-46, -6}}, {{24, 46}, {-39, -25}}}}
local bar_type = "normal"
local secret = false
local function arrow_angle() return 8.7 - (61 * sin(getSongPosition() * pi / getPropertyFromClass("Conductor", "crochet"))) end

local faked_out = false
local ko = false
local burn = false
local gameover = false
local restarted = false

function onCreatePost()
	difficultyName = difficultyName:lower()
	
	health.init = ({easy = 5, normal = 4, hard = 3})[difficultyName]
	health.bf = health.init
	
	bar_type = health.init == 5 and "easy" or "normal"
	window.def = health.init == 5 and {{{-44, 57}}, {{-26, 28.5}}} or {{{-37, 44}}, {{-18.5, 20}}}
	
	local dad_x, dad_y = getProperty("dad.x"), getProperty("dad.y")
	local bf_x, bf_y = getProperty("boyfriend.x"), getProperty("boyfriend.y")
	local gf_x, gf_y = getProperty("gf.x"), getProperty("gf.y")
	
	--[[makeAnimatedLuaSprite("bf_melted", "characters/bf_melted", bf_x - 20, bf_y - 20)
	addAnimationByPrefix("bf_melted", "default", "default", 24, false)
	setProperty("bf_melted.alpha", 0.00001)
	addLuaSprite("bf_melted", true)
	addCharacterToList("bf_kicked")]]
	
	makeAnimatedLuaSprite("binej", "battle/philly-fray/bunsenbattle_animations", dad_x - 0, dad_y - 0)
	scaleObject("binej", 0.9, 0.9)
	addAnimationByPrefix("binej", "punch_pre", "bunsenfleft", 24, false)
	addAnimationByPrefix("binej", "punch", "bunsenpunch", 24, false)
	addOffset("binej", "punch_pre", 158, -25)
	addOffset("binej", "punch", -44, -32)
	addAnimationByPrefix("binej", "burn_pre", "bunsen burn prepare", 24, false)
	addOffset("binej", "burn_pre", -41, -108)
	addAnimationByPrefix("binej", "burn", "bunsen burn", 24, false)
	addOffset("binej", "uppercut", -99, 417)
	addAnimationByPrefix("binej", "burn_end", "bunsen burn end", 24, false)
	--[[addOffset("binej", "kick_pre", -25, -82)
	addAnimationByPrefix("binej", "kick", "kick0", 24, false)
	addOffset("binej", "kick", -41, 59)]]
	addAnimationByPrefix("binej", "fakeout_pre", "fakeout_pre", 24, false)
	addOffset("binej", "fakeout_pre", -2, 1)
	addAnimationByPrefix("binej", "fakeout", "fakeout0", 24, false)
	addOffset("binej", "fakeout", -101, -80)
	addAnimationByPrefix("binej", "spit_pre", "spit_pre", 24, false)
	addOffset("binej", "spit_pre", -56, -35)
	addAnimationByPrefix("binej", "spit", "spit0", 24, false)
	addOffset("binej", "spit", -120, -72)
	addAnimationByPrefix("binej", "ko", "ko", 24, false)
	addOffset("binej", "ko", 1294, 105)
	setProperty("binej.alpha", 0.00001)
	addLuaSprite("binej", true)
	
	setObjectOrder("boinglight2", getObjectOrder("binej") + 1)
	
	makeAnimatedLuaSprite("blood_bf", "mouthman/blood", bf_x + 150, bf_y - 125)
	addAnimationByPrefix("blood_bf", "default", "bf", 24, true)
	setProperty("blood_bf.alpha", 0.00001)
	addLuaSprite("blood_bf", true)
	
	makeAnimatedLuaSprite("blood_binej", "mouthman/blood", dad_x + 40, dad_y - 300)
	addAnimationByPrefix("blood_binej", "default", "binej", 24, false)
	setProperty("blood_binej.alpha", 0.00001)
	setProperty("blood_binej.flipX", true)
	setProperty("blood_binej.colorTransform.greenOffset", 50)
	addLuaSprite("blood_binej", true)
	
	makeAnimatedLuaSprite("hit", "mouthman/hit", dad_x + 250, dad_y - 160)
	addAnimationByPrefix("hit", "hit", "hit", 24, false)
	setProperty("hit.alpha", 0.00001)
	addLuaSprite("hit", true)
	
	makeAnimatedLuaSprite("spit", "mouthman/spit", bf_x - 220, bf_y - 110)
	addAnimationByPrefix("spit", "hit", "hit", 24, false)
	addAnimationByPrefix("spit", "dodged", "dodged", 24, false)
	setProperty("spit.alpha", 0.00001)
	addLuaSprite("spit", true)
	
	makeLuaSprite("combo", "mouthman/texts/combo", gf_x + 75, gf_y - 75)
	setProperty("combo.alpha", 0.00001)
	addLuaSprite("combo", true)
	
	makeAnimatedLuaSprite("bar", "battle/ui/attackbar", bf_x - 112, bf_y - 112)
	addAnimationByPrefix("bar", "appear", "ATTACKBAR_APPEAR", 24, false)
	addAnimationByPrefix("bar", "bop", "ATTACKBAR_BUMP", 24, false)
	addAnimationByPrefix("bar", "hit", "ATTACKBAR_HIT", 24, false)
	addAnimationByPrefix("bar", "disappear", "ATTACKBAR_DISAPPEAR", 24, false)
	addOffset("bar", "disappear", 10, 25)
	addOffset("bar", "appear", 21, 153)
	addOffset("bar", "bop", 50, 20)
	--scaleObject("bar", 0.9, 0.9)
	addLuaSprite("bar", true)
	setProperty("bar.alpha", 0.00001)
	
	precacheImage("battle/ui/attackbar")
	--precacheImage("mouthman/ui/bar_secret")
	
	makeAnimatedLuaSprite("bar_hit", "battle/ui/attackbar_hit", bf_x - 127, bf_y - 155)
	addAnimationByPrefix("bar_hit", "perfect", "PERFECT", 24, false)
	addOffset("bar_hit", "perfect", 158, 55)
	addAnimationByPrefix("bar_hit", "good", "GOOD", 24, false)
	addOffset("bar_hit", "good", 0, 11)
	addAnimationByPrefix("bar_hit", "fail", "SHIT", 24, false)
	addOffset("bar_hit", "fail", -2, 5)
	scaleObject("bar_hit", 0.9, 0.9)
	addLuaSprite("bar_hit", true)
	setProperty("bar_hit.alpha", 0.00001)
	
	precacheImage("mouthman/ui/bar_hit_normal")
	precacheImage("mouthman/ui/bar_hit_secret")
	
	makeLuaSprite("arrow", "mouthman/ui/arrow", bf_x - 20, bf_y + 39)
	scaleObject("arrow", 0.9, 0.9)
	setProperty("arrow.origin.x", 101)
	setProperty("arrow.origin.y", 37)
	setProperty("arrow.alpha", 0.00001)
	addLuaSprite("arrow", true)
	
	makeAnimatedLuaSprite("arrow_hit", "mouthman/ui/arrow_hit", bf_x - 30, bf_y + 34)
	addAnimationByPrefix("arrow_hit", "hit", "hit", 24, false)
	scaleObject("arrow_hit", 0.94, 0.94)
	setProperty("arrow_hit.origin.x", 111)
	setProperty("arrow_hit.origin.y", 42)
	setProperty("arrow_hit.alpha", 0.00001)
	addLuaSprite("arrow_hit", true)
	
	makeAnimatedLuaSprite("space", "battle/ui/PRESS_SPACE", middlescroll and 508 or 825, downscroll and 105 or 165)
	addAnimationByPrefix("space", "bop", "press_bop", 24, false)
	addAnimationByPrefix("space", "appear", "press_appear", 24, false)
	addAnimationByPrefix("space", "pressed", "press_disappear", 24, false)
	addOffset("space", "bop", 7, 7)
	addOffset("space", "appear", 48, 101)
	addOffset("space", "pressed", -2, -2)
	scaleObject("space", 1.5, 1.5)
	setProperty("space.alpha", 0.00001)
	setObjectCamera("space", "hud")
	addLuaSprite("space", true)
	
	makeAnimatedLuaSprite("space_death", "battle/ui/HOLD_SPACE", middlescroll and 470 or 787, downscroll and 62 or 122)
	addAnimationByPrefix("space_death", "bop", "HOLD_SPACE", 24, false)
	setProperty("space_death.alpha", 0.00001)
	setObjectCamera("space_death", "hud")
	addLuaSprite("space_death", true)
	
	makeAnimatedLuaSprite("counter", "alphabet", middlescroll and 616 or 933, downscroll and 505 or 565)
	for i = 0, 9 do addAnimationByPrefix("counter", tostring(i), "bold" .. i, 32, true) end
	addOffset("counter", "1", -3, 0)
	setProperty("counter.alpha", 0.00001)
	setObjectCamera("counter", "hud")
	addLuaSprite("counter", true)
	
	makeAnimatedLuaSprite("early", "mouthman/texts/early", bf_x - 310, bf_y - 290)
	addAnimationByPrefix("early", "default", "default", 24, false)
	scaleObject("early", 0.9, 0.8)
	setProperty("early.alpha", 0.00001)
	addLuaSprite("early", true)
	
	makeAnimatedLuaSprite("faked_out", "mouthman/texts/faked_out", bf_x - 360, bf_y - 380)
	addAnimationByPrefix("faked_out", "default", "default", 24, false)
	scaleObject("faked_out", 0.9, 0.8)
	setProperty("faked_out.alpha", 0.00001)
	addLuaSprite("faked_out", true)
	
	makeAnimatedLuaSprite("fail", "mouthman/texts/fail", bf_x - 70, bf_y - 180)
	addAnimationByPrefix("fail", "default", "default", 24, false)
	scaleObject("fail", 0.94, 0.94)
	setProperty("fail.alpha", 0.00001)
	addLuaSprite("fail", true)
	
	makeAnimatedLuaSprite("good", "mouthman/texts/good", bf_x - 30, bf_y - 170)
	addAnimationByPrefix("good", "default", "default", 24, false)
	scaleObject("good", 0.94, 0.94)
	setProperty("good.alpha", 0.00001)
	addLuaSprite("good", true)
	
	makeAnimatedLuaSprite("perfect", "mouthman/texts/perfect", bf_x - 90, bf_y - 240)
	addAnimationByPrefix("perfect", "default", "default", 24, false)
	scaleObject("perfect", 0.94, 0.94)
	setProperty("perfect.alpha", 0.00001)
	addLuaSprite("perfect", true)
	
	--[[makeAnimatedLuaSprite("ko", "mouthman/texts/ko", -140, -343)
	addAnimationByPrefix("ko", "default", "default", 24, false)
	scaleObject("ko", 0.94, 0.94)
	setProperty("ko.alpha", 0.00001)
	setObjectCamera("ko", "other")
	addLuaSprite("ko", true)]]
	
	for i = 1, 5 do
		local heart = "binej_heart" .. i
		makeAnimatedLuaSprite(heart, "battle/ui/P2_HEARTS", -80, 100 * (i + 1) - (downscroll and 120 or 30))
		addAnimationByPrefix(heart, "bump", "heartcounter_enemy_scaled", 24, false)
		addAnimationByPrefix(heart, "half", "half", 24, false)
		addAnimationByPrefix(heart, "explode", "heartcounter_enemy_break", 24, false)
		addAnimationByPrefix(heart, "empty", "empty_enemy_heart", 12, true)
		addOffset(heart, "empty", -10, 7)
		addOffset(heart, "explode", 15, 55)
		setProperty(heart .. ".alpha", 0.00001)
		setObjectCamera(heart, "hud")
		addLuaSprite(heart, true)
	end
	
	for i = 1, health.init do
		local heart = "bf_heart" .. i
		makeAnimatedLuaSprite(heart, "battle/ui/P1_HEARTS", 1145, 100 * (i + 1) - (downscroll and 118 or 28))
		--addAnimationByPrefix(heart, "appear", "appear", 24, false)
		--addOffset(heart, "appear", 13, 16)
		addAnimationByPrefix(heart, "bump", "heartcounter_scaled", 24, false)
		addAnimationByPrefix(heart, "explode", "heartcounter_break", 24, false)
		addOffset(heart, "explode", 18, 53)
		addAnimationByPrefix(heart, "empty", "empty_heart", 12, true)
		addOffset(heart, "empty", -10, -6)
		setProperty(heart .. ".alpha", 0.00001)
		setObjectCamera(heart, "hud")
		addLuaSprite(heart, true)
	end
end

function onCountdownTick(tick)
	if tick == 2 then
		doTweenAlpha("binej_heart_appear1", "binej_heart1", 1, 0.4, "cubeinout")
		doTweenX("binej_heart_move1", "binej_heart1", 20, 0.75, "cubeout")
		runTimer("binej_heart_appear", 0.1, 4)
		
		setProperty("bf_heart1.alpha", 1)
		--playAnim("bf_heart1", "appear", true)
		doTweenX("bf_heart_move1", "bf_heart", 1165, 0.75, "cubeout")
		runTimer("bf_heart_appear", 0.1, 4)
	end
end

function onSongStart()
	for i = 1, 5 do
		playAnim("binej_heart" .. i, "bump", true)
	end
	
	for i = 1, health.init do
		playAnim("bf_heart" .. i, "bump", true)
	end
end

local timer_stuff = {
	reset_binej = function(remaining)
		if remaining == 0 then
			setProperty("dad.alpha", 1)
			setProperty("binej.alpha", 0.00001)
			
			if faked_out then
				faked_out = false
				
				playAnim("dad", "fuck_you", true)
				setProperty("dad.specialAnim", true)
			else
				characterDance("dad")
			end
			
			setGlobalFromScript("scripts/neocam", "position_locked", false)
		else
			playAnim("dad", "angry", true)
			setProperty("dad.specialAnim", true)
			runTimer("reset_binej", 14 / 24)
		end
	end,
	
	reset_bf = function()
		characterDance("bf")
		
		if ko then
			playAnim("boyfriend", "idle", true)
		else
			setGlobalFromScript("scripts/neocam", "position_locked", false)
		end
	end,
	
	hide_blood = function()
		setProperty("blood_binej.alpha", 0.00001)
		setProperty("blood_bf.alpha", 0.00001)
	end,
	
	hide_fx = function()
		setProperty("hit.alpha", 0.00001)
		setProperty("spit.alpha", 0.00001)
	end,
	
	hide_texts = function()
		setProperty("early.alpha", 0.00001)
		setProperty("faked_out.alpha", 0.00001)
		setProperty("fail.alpha", 0.00001)
		setProperty("good.alpha", 0.00001)
		setProperty("perfect.alpha", 0.00001)
	end,
	
	hide_ko = function()
		setProperty("ko.alpha", 0.00001)
	end,
	
	binej_heart_appear = function(remaining)
		local i = 5 - remaining
		
		doTweenAlpha("binej_heart_appear" .. i, "binej_heart" .. i, 1, 0.4, "cubeinout")
		doTweenX("binej_heart_move" .. i, "binej_heart" .. i, 20, 0.75, "cubeout")
	end,
	
	bf_heart_appear = function(remaining)
		local i = health.init - remaining
		
		local heart = "bf_heart" .. i
		doTweenAlpha("bf_heart_appear" .. i, "bf_heart" .. i, 1, 0.4, "cubeinout")
		doTweenX("bf_heart_move" .. i, "bf_heart" .. i, 1165, 0.75, "cubeout")
		--playAnim(heart, "appear", true)
	end,
	
	dead = function()
		setHealth(-1)
		
		if spit then
			cameraShake("other", 0.01, 0.3)
			
			cameraFlash("other", "00ff00", 0.5, true)
		end
	end,
	
	binej_fall = function()
		playSound("mouthman/ko_fall")
	end,
	
	pose = function()
		playAnim("gf", "cheer", true)
		
		playAnim("boyfriend", "hey", true)
		setProperty("bf.specialAnim", true)
	end,
	
	end_song = function()
		setSoundVolume("", 1)
		endSong()
	end,
	
	restart_song = function()
		restartSong(not restarted)
	end,
	
	spit_gameover = function()
		for _, sprite in pairs({"dad", "binej", "bf_melted", "spit"}) do
			doTweenX("spit_gameover" .. sprite .. "x", sprite, getProperty(sprite .. ".x") - 150, 10.921, "smootherstepin")
			doTweenY("spit_gameover" .. sprite .. "y", sprite, getProperty(sprite .. ".y") - 125, 10.921, "smootherstepin")
		end
		
		doTweenZoom("spit_gameover_cam", "camOther", 1.6, 10.921, "smootherstepin")
		
		setSoundVolume("", 0)
		
		playSound("mouthman/trolled", 1, "trolled")
		
		runTimer("restart_song", 10.971)
		
		playAnim("dad", "fuck_you", true)
		setProperty("dad.specialAnim", true)
		runTimer("binej_lol", 60 / 175, 999)
	end,
	
	bf_melted = function()
		playAnim("bf_melted", "default", true, false, 6)
	end,
	
	binej_lol = function()
		playAnim("dad", "fuck_you", true)
		setProperty("dad.specialAnim", true)
	end
}

function onTimerCompleted(tag, loops, remaining)
	if timer_stuff[tag] then
		timer_stuff[tag](remaining)
	end
end

function onUpdatePost()
	if gameover then
		setPropertyFromClass("flixel.FlxG", "sound.music.time", 0)
		setProperty("vocals.volume", 0)
		setPropertyFromClass("Conductor", "songPosition", 0)
		setProperty("songTime", 0)
	elseif ko then
		setProperty("vocals.volume", 1)
	elseif active then
		if player then
			local angle = arrow_angle()
			setProperty("arrow.angle", angle)
			
			if input and not botPlay then
				if getPropertyFromClass("flixel.FlxG", "keys.justPressed.SPACE") then
					input = false
					
					setProperty("bar.alpha", 0.00001)
					
					setProperty("bar_hit.alpha", 1)
					doTweenAlpha("bar_hit_fadeout", "bar_hit", 0, 1, "quartin")
					
					setProperty("arrow.alpha", 0.00001)
					
					setProperty("arrow_hit.angle", angle)
					setProperty("arrow_hit.alpha", 1)
					playAnim("arrow_hit", "hit", true)
					doTweenAlpha("arrow_hit_fadeout", "arrow_hit", 0, 1, "quartin")
					
					local cur_window = window[secret and "secret" or "def"]
					for _, range in pairs(cur_window[2]) do
						if angle >= range[1] and angle <= range[2] then
							hit = 2
							break
						end
					end
					
					if hit == 0 then
						for _, range in pairs(cur_window[1]) do
							if angle >= range[1] and angle <= range[2] then
								hit = 1
								break
							end
						end
					end
					
					if hit == 2 then
						playAnim("bar_hit", "perfect", true)
						
						setProperty("perfect.alpha", 1)
						playAnim("perfect", "default", true)
					elseif hit == 1 then
						playAnim("bar_hit", "good", true)
						
						setProperty("good.alpha", 1)
						playAnim("good", "default", true)
					else
						hit = 0
						
						playAnim("bar_hit", "fail", true)
						
						setProperty("fail.alpha", 1)
						playAnim("fail", "default", true)
						
						playSound("badnoise" .. getRandomInt(1, 3), 0.5)
					end
					
					runTimer("hide_texts", 21 / 24)
					
					playSound("clickText", 0.7)
				end
			end
		elseif input and not botPlay then
			if getPropertyFromClass("flixel.FlxG", "keys.justPressed.SPACE") then
				input = false
				
				if beats * crochet > crochet then
					setProperty("early.alpha", 1)
					playAnim("early", "default", true)
					runTimer("hide_texts", 1)
					
					setProperty("counter.color", getColorFromHex("ffaaaa"))
				else
					hit = 1
					
					setProperty("counter.color", getColorFromHex("aaffbb"))
				end
				
				playAnim("boyfriend", "dodge", true)
				setProperty("boyfriend.specialAnim", true)
				runTimer("reset_bf", crochet / 1000)
				
				setProperty("space.alpha", 1)
				playAnim("space", "pressed", true, false, (spit or health.bf == 1) and 2 or 0)
				doTweenAlpha("space_fadeout", "space", 0, 0.6, "circin")
				
				setProperty("space_death.alpha", 0.00001)
				
				scaleObject("counter", 1, 1)
				playAnim("counter", tostring(beats), true)
				--doTweenX("counter_zoom_out_x", "counter.scale", 0.75, 0.25, "backinout")
				--doTweenY("counter_zoom_out_y", "counter.scale", 0.75, 0.25, "backinout")
				doTweenAlpha("counter_fadeout", "counter", 0, 0.75, "quartin")
				
				playSound("clickText", 0.7)
			end
		end
	end
end

function onStepHit()
	if curStep % 8 == 0 then
		for i = 1, 5 do
			local heart = "binej_heart" .. i
			local anim = heart .. ".animation.curAnim"
			if not (getProperty(anim .. ".name") == "lose" and getProperty(anim .. ".curFrame") < 9) then
				playAnim(heart, i <= health.binej and "bump" or "empty", true)
				if i <= health.binej then
					playAnim(heart, "bump",true)
				elseif i == ceil(health.binej) then
					playAnim(heart, "half", true)
				end
			end
		end
		
		for i = 1, health.init do
			local heart = "bf_heart" .. i
			local anim = heart .. ".animation.curAnim"
			if not (getProperty(anim .. ".name") == "lose" and getProperty(anim .. ".curFrame") < 9) then
				playAnim(heart, i <= health.bf and "bump" or "empty", true)
			end
		end
	end
	
	local event = events[(curStep + 2) / 4]
	if event and not gameover then
		active = true
		hit = 0
		player = event[1] == "bf"
		
		if player then
			secret = getRandomInt(1, 10) == 1 and difficultyName == "hard"
			
			local texture = secret and "secret" or bar_type
			
			if texture == "secret" and botPlay then
				texture = "normal"
			end
			
			loadFrames("bar", "battle/ui/attackbar")
			loadFrames("bar_hit", "battle/ui/attackbar_hit")
			
			addAnimationByPrefix("bar", "appear", "ATTACKBAR_APPEAR", 48, false)
			addOffset("bar", "appear", 21, 153)
			addAnimationByPrefix("bar", "bop", "ATTACKBAR_BUMP", 24, false)
			
			setProperty("bar.alpha", 1)
			playAnim("bar", "appear", true)
			
			addAnimationByPrefix("bar_hit", "perfect", "PERFECT", 24, false)
			addAnimationByPrefix("bar_hit", "good", "GOOD", 24, false)
			addAnimationByPrefix("bar_hit", "fail", "SHIT", 24, false)
			
			doTweenAlpha("arrow_fadein", "arrow", 1, 0.25, "circin")
		else
		end
		
		attack = event[3]
		beats = event[2] + 1
		spit = attack == "spit"
		pre_event = -3
		
		event_index = (curStep + 2) / 4
	end
	
	pre_event = pre_event + 1
	if pre_event == 0 then
		input = true
		
		if player then
			cancelTween("arrow_hit_fadeout")
			cancelTween("bar_hit_fadeout")
		else
			setProperty("dad.alpha", 0.00001)
			
			setProperty("binej.alpha", 1)
			
			if spit or health.bf == 1 then
				setProperty("space_death.alpha", 1)
			else
				cancelTween("space_fadeout")
				
				setProperty("space.alpha", 1)
			end
			
			scaleObject("counter", 1, 1)
			setProperty("counter.alpha", 1)
			setProperty("counter.color", getColorFromHex("ffffff"))
		end
		
		callScript("scripts/neocam", "focus", {player and "bf_attack" or "binej_attack", 0.75, "circout", true})
		--callScript("scripts/neocam", "zoom", {"game", 0.85, 0})
	end
	
	if active and curStep % 4 == 0 then
		beats = beats - 1
		
		local fakeout = attack == "fakeout"
		
		if beats == 1 and botPlay then
			if player then
				hit = 2
				
				setProperty("bar.alpha", 0.00001)
				
				setProperty("bar_hit.alpha", 1)
				playAnim("bar_hit", "perfect", true)
				doTweenAlpha("bar_hit_fadeout", "bar_hit", 0, 1, "quartin")
				
				setProperty("arrow.alpha", 0.00001)
				
				setProperty("arrow_hit.angle", 0)
				setProperty("arrow_hit.alpha", 1)
				playAnim("arrow_hit", "hit", true)
				doTweenAlpha("arrow_hit_fadeout", "arrow_hit", 0, 1, "quartin")
				
				setProperty("perfect.alpha", 1)
				playAnim("perfect", "default", true)
				
				runTimer("hide_texts", 21 / 24)
			else
				hit = 1
				
				playAnim("boyfriend", "dodge", true)
				setProperty("boyfriend.specialAnim", true)
				runTimer("reset_bf", crochet / 1000)
				
				setProperty("space.alpha", 1)
				playAnim("space", "pressed", true, false, (spit or health.bf == 1) and 2 or 0)
				doTweenAlpha("space_fadeout", "space", 0, 0.6, "circin")
				
				setProperty("space_death.alpha", 0.00001)
				
				scaleObject("counter", 1, 1)
				setProperty("counter.color", getColorFromHex("aaffbb"))
				playAnim("counter", tostring(beats), true)
				doTweenX("counter_zoom_out_x", "counter.scale", 0.75, 0.25, "backinout")
				doTweenY("counter_zoom_out_y", "counter.scale", 0.75, 0.25, "backinout")
				doTweenAlpha("counter_fadeout", "counter", 0, 0.75, "quartin")
			end
			
			playSound("clickText", 0.7)
		end
		
		if beats <= 0 then
			if player then
				playAnim("boyfriend", "punch", true)
				setProperty("boyfriend.specialAnim", true)
				runTimer("reset_bf", crochet / 1000)
				
				if hit == 0 then
					combo = 0
					
					setProperty("binej.alpha", 0.00001)
					
					setProperty("dad.alpha", 1)
					playAnim("dad", "dodge")
					setProperty("dad.specialAnim", true)
					runTimer("reset_binej", 11 / 24)
					
					if input then
						input = false
						
						setProperty("bar.alpha", 0.00001)
						setProperty("bar_hit.alpha", 1)
						playAnim("bar_hit", "fail", true)
						doTweenAlpha("bar_hit_fadeout", "bar_hit", 0, 1, "quartin")
						
						setProperty("arrow.alpha", 0.00001)
						
						setProperty("arrow_hit.angle", arrow_angle())
						setProperty("arrow_hit.alpha", 1)
						playAnim("arrow_hit", "hit", true)
						doTweenAlpha("arrow_hit_fadeout", "arrow_hit", 0, 1, "quartin")
						
						setProperty("fail.alpha", 1)
						playAnim("fail", "default", true)
						runTimer("hide_ratings", 21 / 24)
						
						playSound("badnoise" .. getRandomInt(1, 3), 0.5)
					end
					
					addMisses(1)
					addScore(-50)
				else
					combo = combo + 1
					if combo <= 3 then playSound("zumachime"..combo, 0.4) else playSound("zumachime3", 0.4) end
					
					setProperty("blood_binej.alpha", 1)
					playAnim("blood_binej", "default", true)
					runTimer("hide_blood", 10 / 24)
					
					setProperty("hit.alpha", 1)
					playAnim("hit", "hit", true)
					runTimer("hide_fx", 6 / 24)
					
					local health_binej = health.binej
					if health_binej % 1 == 0.5 then
						local heart = "binej_heart" .. ceil(health_binej)
						playAnim(heart, "explode", true)
						
						if health_binej > 1 and hit == 2 then
							playAnim("binej_heart" .. floor(health_binej), "half", true)
						end
					elseif hit == 2 then
						playAnim("binej_heart" .. health_binej, "explode", true)
					elseif health_binej > 1 then
						playAnim("binej_heart" .. health_binej, "half", true)
					end
					
					setGlobalFromScript("scripts/neocam", "position_locked", false)
					
					health.binej = health_binej - hit / 2
					health_binej = health.binej
					if health_binej <= 0 then
						ko = true
						
						setProperty("gf.debugMode", true)
						setProperty("boyfriend.debugMode", true)
						
						setProperty("dad.alpha", 0.00001)
						
						setProperty("binej.alpha", 1)
						playAnim("binej", "ko", true)
						
						cancelTimer("reset_binej")
						
						runTimer("binej_fall", 42 / 24)
						runTimer("pose", 4.3)
						
						setProperty("ko.alpha", 1)
						playAnim("ko", "default", true)
						runTimer("hide_ko", 39 / 24)
						
						setHealth(2)
						
						playSound("mouthman/ko_spin")
						
						doTweenAlpha("ko_hide_hud", "camHUD", 0, 5, "quintout")
						
						--setGlobalFromScript("stages/7quid", "bopping", false)
						
						callScript("scripts/neocam", "focus", {"ko", 0.8, "quintout", true})
					else
						callScript("scripts/neocam", "focus", {"dad", 0.8, "quintout", true})
						
						playSound("bunsen_hit")
						
						playAnim("dad", "hurt", true)
						setProperty("dad.specialAnim", true)
						runTimer("reset_binej", 0.44, 2)
					end
					
					if combo >= 3 and health.bf < health.init then
						combo = 0
						health.bf = health.bf + 1
						
						playAnim("gf", "kiss", true)
						setProperty("gf.specialAnim", true)
						
						scaleObject("combo", 1, 1)
						setProperty("combo.y", getProperty("gf.y") - 75)
						setProperty("combo.alpha", 1)
						doTweenX("combo_backin_x", "combo.scale", 0.75, 1, "backin")
						doTweenY("combo_backin_y", "combo.scale", 0.75, 1, "backin")
						doTweenY("combo_fall", "combo", getProperty("gf.y"), 1, "backin")
						doTweenAlpha("combo_fadeout", "combo", 0, 1, "quartin")
						
						playAnim("bf_heart" .. health.bf, "appear", true)
					end
					
					addHealth(hit == 2 and 0.2 or 0.1)
					addHits(1)
					addScore(500)
					
					playSound("mouthman/" .. (hit == 2 and "punch" or "kick"), 0.7)
					
					cameraShake("game", 0.015, 0.2)
					cameraShake("hud", 0.005, 0.2)
				end
				
				if hit == 2 or (hit == 1 and attacks_left > health.binej + 0.5) then
					attacks_left = attacks_left - 1
				else
					triggerEvent("Reverse Time", events[event_index][3], 1)
				end
			else
				setProperty("dad.alpha", 0.0001)
				
				setProperty("binej.alpha", 1)
				playAnim("binej", fakeout and "uppercut" or attack, true)
				runTimer("reset_binej", 11 / 24)
				
				local sound = attack == "kick" and attack or "punch"
				if spit then
					setProperty("spit.alpha", 1)
				else
					playSound("mouthman/" .. sound .. "_whoosh_" .. getRandomInt(1, 4), 0.9)
				end
				
				if hit == 0 then
					playAnim("boyfriend", "hurt", true)
					setProperty("boyfriend.specialAnim", true)
					
					if spit then
						playAnim("gf", "scared", true)
						setProperty("gf.specialAnim", true)
						
						setProperty("space_death.alpha", 0.00001)
						
						playAnim("spit", "hit", true)
						runTimer("hide_spit", 22 / 24)
						
						setHealth(0.001)
						runTimer("dead", 0.08)
					else
						setProperty("blood_bf.alpha", 1)
						playAnim("blood_bf", "default", true)
						runTimer("hide_blood", 10 / 24)
						
						doTweenAlpha("space_fadeout", "space", 0, 0.6, "circin")
						
						if input then
							input = false
							
							scaleObject("counter", 1, 1)
							setProperty("counter.color", getColorFromHex("ffaaaa"))
							playAnim("counter", "0", true)
							doTweenX("counter_zoom_out_x", "counter.scale", 0.75, 0.25, "backinout")
							doTweenY("counter_zoom_out_y", "counter.scale", 0.75, 0.25, "backinout")
							doTweenAlpha("counter_fadeout", "counter", 0, 0.75, "quartin")
						elseif fakeout then
							faked_out = true
							
							setProperty("faked_out.alpha", 1)
							playAnim("faked_out", "default", true)
							runTimer("hide_texts", 17 / 24)
						end
						
						playAnim("bf_heart" .. health.bf, "explode", true)
						
						playSound("mouthman/" .. sound, 0.7)
						
						cameraShake("game", 0.015, 0.2)
						cameraShake("hud", 0.005, 0.2)
						
						addHealth(-0.3)
						health.bf = health.bf - 1
						
						if getHealth() <= 0 or health.bf <= 0 then
							setHealth(0.001)
							
							runTimer("dead", 0.03)
							
							if attack == "kick" or attack == "uppercut" or fakeout then
								setPropertyFromClass("GameOverSubstate", "characterName", "bf_kicked")
							end
							
							playAnim("gf", "scared", true)
						else
							playAnim("gf", "sad", true)
						end
						
						setProperty("gf.specialAnim", true)
					end
					
					setGlobalFromScript("scripts/neocam", "position_locked", false)
					callScript("scripts/neocam", "focus", {"bf", 0.8, "quintout", true})
				elseif spit then
					playAnim("spit", "dodged", true)
					runTimer("hide_spit", 9 / 24)
					
					playSound("mouthman/acid_dodged", 0.35)
				end
			end
			
			active = false
			
			--callScript("scripts/neocam", "zoom", {"game", 0.65, 0.25, "cubeinout"})
		elseif not player then
			local hide_attack = getProperty("dad.animation.name"):sub(1, 4) == "sing"
			setProperty("dad.alpha", hide_attack and 1 or 0.0001)
			setProperty("binej.alpha", hide_attack and 0.0001 or 1)
			
			if fakeout and beats <= 2 then
				if beats == 2 then
					playAnim("binej", attack, true)
					
					playSound("mouthman/fakeout_whoosh", 0.7)
				else
					playAnim("binej", "uppercut_pre", true)
				end
			else
				playAnim("binej", attack .. "_pre", true)
				cancelTimer("reset_binej")
			end
			
			if input then
				local count = beats
				if beats > 2 and fakeout then
					count = count - 2
					setProperty("counter.color", getColorFromHex("ffaaaa"))
				else
					setProperty("counter.color", getColorFromHex("ffffff"))
				end
				
				scaleObject("counter", 1, 1)
				playAnim("counter", tostring(count), true)
				doTweenX("counter_zoom_out_x", "counter.scale", 0.75, 0.25, "backinout")
				doTweenY("counter_zoom_out_y", "counter.scale", 0.75, 0.25, "backinout")
				
				playAnim("space" .. ((spit or health.bf == 1) and "_death" or ""), "bop", true)
			end
		elseif input then
			playAnim("bar", "bop", true)
			
			playAnim("boyfriend", "pre-attack", true)
			setProperty("boyfriend.specialAnim", true)
		end
	end
end

function onPause()
	return (ko or gameover) and Function_Stop or Function_Continue
end

function onGameOverStart()
	if getPropertyFromClass("GameOverSubstate", "characterName") == "bf_kicked" then
		playSound("mouthman/pop", 0.7)
		
		setProperty("camFollow.x", getProperty("boyfriend.x") + 475)
		setProperty("camFollow.y", getProperty("boyfriend.y") + 900)
	end
end

function onGameOver()
	if spit then
		if gameover then
			for _, key in pairs({"SPACE", "ENTER", "ESCAPE"}) do
				if getPropertyFromClass("flixel.FlxG", "keys.justPressed." .. key) then
					restarted = true
					
					soundFadeOut("acid_hit", 0.5)
					soundFadeOut("trolled", 0.5)
					
					runTimer("restart_song", 0.01)
					
					break
				end
			end
		else
			gameover = true
		
			setSoundVolume("", 0)
			
			playSound("mouthman/acid_hit", 0.75, "acid_hit")
			
			setProperty("camGame.alpha", 0.00001)
			setProperty("camHUD.alpha", 0.00001)
			
			setProperty("boyfriend.alpha", 0.00001)
			setProperty("bf_melted.alpha", 1)
			playAnim("bf_melted", "default", true, false, 2)
			
			for _, sprite in pairs({"dad", "binej", "bf_melted", "spit"}) do
				local sprite_x, sprite_y = getProperty(sprite .. ".x"), getProperty(sprite .. ".y")
				setProperty(sprite .. ".x", sprite_x - 125)
				setProperty(sprite .. ".y", sprite_y - 375)
				setObjectCamera(sprite, "other")
				doTweenX("spit_gameover" .. sprite .. "x_init", sprite, sprite_x - 250, 1.45, "cubeout")
				doTweenY("spit_gameover" .. sprite .. "y_init", sprite, sprite_y - 550, 1.45, "cubeout")
			end
			
			setProperty("camOther.zoom", 0.7)
			doTweenZoom("spit_gameover_cam_init", "camOther", 0.65, 1.45, "cubeout")
			
			runTimer("bf_melted", 0.2, 999)
			runTimer("spit_gameover", 1.5)
		end
		
		return Function_Stop
	else
		return Function_Continue
	end
end

-- crash prevention
function onUpdate() end
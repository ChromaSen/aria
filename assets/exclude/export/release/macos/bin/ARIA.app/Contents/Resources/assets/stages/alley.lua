
--How makeLuaSprite works:
--makeLuaSprite(<SPRITE VARIABLE>, <SPRITE IMAGE FILE NAME>, <X>, <Y>);
--"Sprite Variable" is how you refer to the sprite you just spawned in other methods like "setScrollFactor" and "scaleObject" for example

--so for example, i made the sprites "stagelight_left" and "stagelight_right", i can use "scaleObject('stagelight_left', 1.1, 1.1)"
--to adjust the scale of specifically the one stage light on left instead of both of them

function onCreate()
	-- background shit
	makeLuaSprite('background', 'alley/bg0002', 300, -300);
	setScrollFactor('background', 0.7, 0.7);
	
	makeLuaSprite('light', 'alley/trafficlight', 550, -200);

	makeLuaSprite('alley', 'alley/alley', 0, -500);

	makeLuaSprite('objects', 'alley/objects', 500, 250);

	addLuaSprite('background', false);
	addLuaSprite('light', false);
	addLuaSprite('alley', false);
	addLuaSprite('objects', false);


end
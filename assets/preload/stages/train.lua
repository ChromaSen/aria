local enabled = true
--How makeLuaSprite works:
--makeLuaSprite(<SPRITE VARIABLE>, <SPRITE IMAGE FILE NAME>, <X>, <Y>);
--"Sprite Variable" is how you refer to the sprite you just spawned in other methods like "setScrollFactor" and "scaleObject" for example

--so for example, i made the sprites "stagelight_left" and "stagelight_right", i can use "scaleObject('stagelight_left', 1.1, 1.1)"
--to adjust the scale of specifically the one stage light on left instead of both of them
local thickness = 100
function onCreate()
	--bars
	makeLuaSprite("bar_upper", nil, 0, -thickness)
	makeGraphic("bar_upper", 1280, thickness, "000000")
	setObjectCamera("bar_upper", "hud")
	addLuaSprite("bar_upper", false)
			
	makeLuaSprite("bar_lower", nil, 0, 720)
	makeGraphic("bar_lower", 1280, thickness, "000000")
	setObjectCamera("bar_lower", "hud")
	addLuaSprite("bar_lower", false)
	
	-- background shit
	makeLuaSprite('background', 'train/bg', 250, -330);
	makeLuaSprite('building1', 'train/buildings2', -300, 250);
	makeLuaSprite('bloom', 'train/bloom', -250, -330); --This object should scroll REEEEALLLY slowly, giving it a parallax effect
	makeLuaSprite('building2', 'train/newgrounds', -50, 250); --This one follows the previous one, but it should be a little faster.
	makeLuaSprite('igotarock', 'train/rock', -400, 630); --This should scroll infinitely.

	makeAnimatedLuaSprite('newgroundsdotcom', 'train/train', 270, 1000);
	scaleObject ('newgroundsdotcom', 1.2, 1.2)
	addAnimationByPrefix('newgroundsdotcom', 'move', 'train move', 24, true);
	playAnim('newgroundsdotcom', 'move');
	
	makeAnimatedLuaSprite('rain1', 'train/rainscaled', 420, 400);
	scaleObject ('rain1', 1.2, 1.2)
	addAnimationByPrefix('rain1', 'rainmove', 'rain smaller', 24, true);
	playAnim('rain1', 'rainmove', true);

	makeAnimatedLuaSprite('rain2', 'train/rainscaled', 270, -1050);
	scaleObject ('rain2', 1.2, 1.2)
	addAnimationByPrefix('rain2', 'rainmove', 'rain smaller', 24, true);
	playAnim('rain2', 'rainmove', true);

	makeAnimatedLuaSprite('rain3', 'train/rainscaled', -170, -720);
	scaleObject ('rain3', 1.2, 1.2)
	addAnimationByPrefix('rain3', 'rainmove', 'rain smaller', 24, true);
	playAnim('rain3', 'rainmove', true);

	makeAnimatedLuaSprite('rain4', 'train/rainscaled', -570, 720);
	scaleObject ('rain4', 1.2, 1.2)
	addAnimationByPrefix('rain4', 'rainmove', 'rain smaller', 24, true);
	playAnim('rain4', 'rainmove', true);
	

	addLuaSprite('background', false);
	addLuaSprite('building1', false);
	addLuaSprite('building2', false);
	addLuaSprite('newgroundsdotcom', false);
	addLuaSprite('igotarock', true);
	addLuaSprite('bloom', true);
	
	addLuaSprite('rain1', true);
	addLuaSprite('rain2', true);
	addLuaSprite('rain3', true);
	addLuaSprite('rain4', true);

end

function onSongStart()
	doTweenY("bar_upper", "bar_upper", 0, 2, "quintout")
	doTweenY("bar_lower", "bar_lower", 720 - thickness, 2, "quintout")
end
-- crash prevention
function onUpdate() end
function onUpdatePost() end
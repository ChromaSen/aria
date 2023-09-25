package;

import flixel.FlxG;
import flixel.FlxSprite;
import flixel.FlxSubState;
import flixel.text.FlxText;
import flixel.util.FlxColor;
import flixel.effects.FlxFlicker;
import lime.app.Application;
import flixel.addons.transition.FlxTransitionableState;
import flixel.tweens.FlxTween;
import flixel.util.FlxTimer;

class ExtrasState extends MusicBeatState
{
	public var gallery:Array<String>=[
	"Bunsen's original concept art, drawn by tinb.",
	"Burn attack concept.",
	"Original concept of 4R1A.",
	"Nim (old version)",
	"Sketch of Nim (forma de tinb).",
	"Original sketch of Orchid.",
	"Yamiku & Bo BG concept, done by VEP.",
	"Early spritework for her.",
	"Pause concepts.",
	"Story Mode concepts.",

	];

	public static var leftState:Bool = false;

	var warnText:FlxText;
	override function create()
	{
		super.create();

		var bg:FlxSprite = new FlxSprite().loadGraphic(Paths.image('menu'));
		add(bg);
		warnText = new FlxText(0, 0, FlxG.width,
			"You're a stupid motherfucker, \naren't you?
			There were meant to be gallery art and some other shit, but this section is unfinished. \nPress Enter to go to Credits menu, or press Escape to go back.",
			32);
		warnText.setFormat("VCR OSD Mono", 32, FlxColor.WHITE, CENTER);
		warnText.screenCenter(Y);
		add(warnText);
	}

	override function update(elapsed:Float)
	{
			if (controls.ACCEPT) {
				FlxG.sound.play(Paths.sound('confirmMenu'));
				FlxTween.tween(warnText, {alpha: 0}, 1, {
					onComplete: function (twn:FlxTween) {
						MusicBeatState.switchState(new CreditsState());
					}
				});
			}
			else if(controls.BACK) {
				FlxG.sound.play(Paths.sound('cancelMenu'));
				FlxTween.tween(warnText, {alpha: 0}, 1, {
					onComplete: function (twn:FlxTween) {
						MusicBeatState.switchState(new MainMenuState());
					}
				});
			}
		super.update(elapsed);
	}
}

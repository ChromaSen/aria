package;

import flixel.util.FlxTimer;
import Controls.Control;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.FlxSubState;
import flixel.addons.transition.FlxTransitionableState;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.input.keyboard.FlxKey;
import flixel.system.FlxSound;
import flixel.text.FlxText;
import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;
import flixel.util.FlxColor;
import flixel.FlxCamera;
import flixel.util.FlxStringUtil;
import haxe.ds.Option;
#if !flash 
import flixel.addons.display.FlxRuntimeShader;
import openfl.filters.ShaderFilter;
#end
#if sys
import sys.FileSystem;
import sys.io.File;
#end
class PauseSubState extends MusicBeatSubstate
{
	var grpMenuShit:FlxTypedGroup<FlxText>;
	public var VHS:FlxRuntimeShader;
	var menuItems:Array<String> = [];
	var menuItemsOG:Array<String> = ['Resume', 'Restart Song', 'Exit to menu'];
	var difficultyChoices = [];
	var curSelected:Int = 0;

	var pauseMusic:FlxSound;
	var practiceText:FlxText;
	var skipTimeText:FlxText;
	var skipTimeTracker:FlxText;
	var curTime:Float = Math.max(0, Conductor.songPosition);
	//var botplayText:FlxText;

	public static var songName:String = '';

	public var bg:FlxSprite;
	public var blacked:FlxSprite;	
	public var levelInfo:FlxText;
	public var levelDifficulty:FlxText;
	public var blueballedTxt:FlxText;
	public var item:FlxText;
	public var accepted:Bool;
	var pausePortrait:FlxSprite;
	public function new(x:Float, y:Float)
	{
		super();
		if(CoolUtil.difficulties.length < 2) menuItemsOG.remove('Change Difficulty'); //No need to change difficulty if there is only one!

		if(PlayState.chartingMode)
		{
			menuItemsOG.insert(2, 'Leave Charting Mode');
			
			var num:Int = 0;
			if(!PlayState.instance.startingSong)
			{
				num = 1;
				menuItemsOG.insert(3, 'Skip Time');
			}
			menuItemsOG.insert(3 + num, 'End Song');
			menuItemsOG.insert(4 + num, 'Toggle Practice Mode');
			menuItemsOG.insert(5 + num, 'Toggle Botplay');
		}
		menuItems = menuItemsOG;

		for (i in 0...CoolUtil.difficulties.length) {
			var diff:String = '' + CoolUtil.difficulties[i];
			difficultyChoices.push(diff);
		}
		difficultyChoices.push('BACK');

		pauseMusic = new FlxSound().loadEmbedded(Paths.music('pause'), true, true);
		pauseMusic.volume = 0;

		pauseMusic.play(false, FlxG.random.int(0, Std.int(pauseMusic.length / 2)));

		FlxG.sound.list.add(pauseMusic);

		var source:String=File.getContent(Paths.modsShaderFragment("vhs"));
		VHS=new FlxRuntimeShader(source);
		VHS.setFloat("iTime",0);

		FlxG.camera.setFilters([new ShaderFilter(VHS)]);
		bg = new FlxSprite().makeGraphic(FlxG.width, FlxG.height, FlxColor.BLACK);
		bg.alpha = 0.5;
		bg.scrollFactor.set();
		add(bg);
		blacked = new FlxSprite(-480).makeGraphic(480, 720, FlxColor.BLACK);
		blacked.screenCenter(Y);
		add(blacked);

		var portraitDistance:Float = 1000;
		pausePortrait = new FlxSprite(1280, 0);
		pausePortrait.frames = Paths.getSparrowAtlas('VS/portraits/ports');
		pausePortrait.antialiasing = ClientPrefs.globalAntialiasing;
		pausePortrait.scrollFactor.set();
		pausePortrait.animation.addByPrefix('bunsen', "bunsen", 24);
		pausePortrait.animation.addByPrefix('y2kuntz', "kuntz", 24);
		pausePortrait.animation.addByPrefix('bo', "bo", 24);

		/*This needs optimization. I can't be fucked to make this look cleaner but it works so whatever.*/
		if (PlayState.SONG.stage == 'alley')
			{
				pausePortrait.animation.play('bunsen');
				pausePortrait.y = 100;
			}
		if (PlayState.SONG.stage == 'train_bg')
			{
				pausePortrait.animation.play('y2kuntz');
				pausePortrait.y = 100;
			}
		if (PlayState.SONG.stage == 'jp-bg')
			{
				pausePortrait.animation.play('bo');
				pausePortrait.y = 100;		
			}
			add(pausePortrait);
		levelInfo = new FlxText(20, 15 + 20, 0, "You have been listening to: \n", 32);
		levelInfo.text += PlayState.SONG.song;
		levelInfo.scrollFactor.set();
		levelInfo.setFormat(Paths.font("helvetica.ttf"), 32);
		levelInfo.antialiasing = ClientPrefs.globalAntialiasing;
		levelInfo.updateHitbox();
		add(levelInfo);

		levelDifficulty= new FlxText(20, 15 + 72, 0, "", 32);
		levelDifficulty.text += CoolUtil.difficultyString();
		levelDifficulty.scrollFactor.set();
		levelDifficulty.setFormat(Paths.font('helvetica.ttf'), 32);
		levelDifficulty.antialiasing = ClientPrefs.globalAntialiasing;
		levelDifficulty.updateHitbox();
		add(levelDifficulty);

		blueballedTxt = new FlxText(20, 15 + 128, 0, "", 32);
		blueballedTxt.text = "Blueballed: " + PlayState.deathCounter;
		blueballedTxt.scrollFactor.set();
		blueballedTxt.setFormat(Paths.font('helvetica.ttf'), 32);
		blueballedTxt.antialiasing = ClientPrefs.globalAntialiasing;
		blueballedTxt.updateHitbox();
		add(blueballedTxt);

		practiceText = new FlxText(20, 15 + 101, 0, "PRACTICE MODE", 32);
		practiceText.scrollFactor.set();
		practiceText.setFormat(Paths.font('vcr.ttf'), 32);
		practiceText.x = FlxG.width - (practiceText.width + 20);
		practiceText.antialiasing = ClientPrefs.globalAntialiasing;
		practiceText.updateHitbox();
		practiceText.visible = PlayState.instance.practiceMode;
		add(practiceText);

		var chartingText:FlxText = new FlxText(20, 15 + 101, 0, "CHARTING MODE", 32);
		chartingText.scrollFactor.set();
		chartingText.setFormat(Paths.font('vcr.ttf'), 32);
		chartingText.antialiasing = ClientPrefs.globalAntialiasing;
		chartingText.updateHitbox();
		chartingText.visible = PlayState.chartingMode;
		add(chartingText);

		blueballedTxt.alpha = 0;
		levelDifficulty.alpha = 0;
		levelInfo.alpha = 0;

		practiceText.x = 460;
		chartingText.x = FlxG.width - (chartingText.width + 20);
		chartingText.y = FlxG.height - (chartingText.height + 20);
		levelInfo.x = 480;
		levelDifficulty.x = 480;
		blueballedTxt.x = 480;
		FlxTween.tween(blacked, {x:0}, {ease: FlxEase.quintOut});
		FlxTween.tween(pausePortrait, {x:700}, {ease: FlxEase.quartOut});
		if (PlayState.SONG.stage == 'jp-bg')
			{
				FlxTween.tween(pausePortrait, {x:900}, {ease: FlxEase.quartOut});
			}
		if (PlayState.SONG.stage == 'train_bg')
				{
					FlxTween.tween(pausePortrait, {x:700}, {ease: FlxEase.quartOut});
				}
		FlxTween.tween(levelInfo, {alpha: 1, y: 20}, 0.4, {ease: FlxEase.quintOut, startDelay: 0.3});
		FlxTween.tween(levelDifficulty, {alpha: 1, y: levelDifficulty.y + 5}, 0.4, {ease: FlxEase.quartInOut, startDelay: 0.5});
		FlxTween.tween(blueballedTxt, {alpha: 1, y: blueballedTxt.y + 5}, 0.4, {ease: FlxEase.quartInOut, startDelay: 0.7});


		grpMenuShit = new FlxTypedGroup<FlxText>();
		add(grpMenuShit);

		regenMenu();
		cameras = [FlxG.cameras.list[FlxG.cameras.list.length - 1]];
	}

	var holdTime:Float = 0;
	var cantUnpause:Float = 0.1;
	override function update(elapsed:Float)
	{
		VHS.setFloat("iTime",VHS.getFloat("iTime")+elapsed);
		cantUnpause -= elapsed;
		if (pauseMusic.volume < 0.5)
			pauseMusic.volume += 0.01 * elapsed;

		super.update(elapsed);
		updateSkipTextStuff();

		var upP = controls.UI_UP_P;
		var downP = controls.UI_DOWN_P;
		accepted = controls.ACCEPT;

		if (upP)
		{
			changeSelection(-1);
		}
		if (downP)
		{
			changeSelection(1);
		}

		var daSelected:String = menuItems[curSelected];
		switch (daSelected)
		{
			case 'Skip Time':
				if (controls.UI_LEFT_P)
				{
					FlxG.sound.play(Paths.sound('scrollMenu'), 0.4);
					curTime -= 1000;
					holdTime = 0;
				}
				if (controls.UI_RIGHT_P)
				{
					FlxG.sound.play(Paths.sound('scrollMenu'), 0.4);
					curTime += 1000;
					holdTime = 0;
				}

				if(controls.UI_LEFT || controls.UI_RIGHT)
				{
					holdTime += elapsed;
					if(holdTime > 0.5)
					{
						curTime += 45000 * elapsed * (controls.UI_LEFT ? -1 : 1);
					}

					if(curTime >= FlxG.sound.music.length) curTime -= FlxG.sound.music.length;
					else if(curTime < 0) curTime += FlxG.sound.music.length;
					updateSkipTimeText();
				}
		}

		if (accepted && (cantUnpause <= 0 || !ClientPrefs.controllerMode))
		{	
			//checks if the current selection isnt the ones that in array. if it's not, it will do the tweening
			//made it because if you wanna restart the song for example, the tweening will just look off lol
			//thank you chroma -razrs
			if(!check(daSelected,["Change Difficulty","Restart Song","Leave Charting Mode","End Song","Skip Time","Toggle Botplay","Exit to menu"])){
				FlxTween.tween(blacked,{x:-480},{ease:FlxEase.quintOut});
				FlxTween.tween(bg,{alpha:0},0.4,{ease:FlxEase.quartInOut});
				FlxTween.tween(levelInfo,{alpha:0,y:-480},0.4,{ease:FlxEase.quintOut});
				FlxTween.tween(levelDifficulty, {alpha: 0, y:levelDifficulty.y - 5}, 0.4, {ease: FlxEase.quartInOut});
				FlxTween.tween(blueballedTxt, {alpha: 0, y: blueballedTxt.y - 5}, 0.4, {ease: FlxEase.quartInOut});
				FlxTween.tween(item,{x:-120},0.5,{ease:FlxEase.quartInOut});
			}
			if (menuItems == difficultyChoices)
			{
				if(menuItems.length - 1 != curSelected && difficultyChoices.contains(daSelected)) {
					var name:String = PlayState.SONG.song;
					var poop = Highscore.formatSong(name, curSelected);
					PlayState.SONG = Song.loadFromJson(poop, name);
					PlayState.storyDifficulty = curSelected;
					MusicBeatState.resetState();
					FlxG.sound.music.volume = 0;
					PlayState.changedDifficulty = true;
					PlayState.chartingMode = false;
					return;
				}

				menuItems = menuItemsOG;
				regenMenu();
			}

			switch (daSelected)
			{
				case "Resume":
				FlxG.camera.setFilters([]);
				close();
				case 'Change Difficulty':
					menuItems = difficultyChoices;
					deleteSkipTimeText();
					regenMenu();
				case 'Toggle Practice Mode':
					PlayState.instance.practiceMode = !PlayState.instance.practiceMode;
					PlayState.changedDifficulty = true;
					practiceText.visible = PlayState.instance.practiceMode;
				case "Restart Song":
					restartSong();
				case "Leave Charting Mode":
					restartSong();
					PlayState.chartingMode = false;
				case 'Skip Time':
					if(curTime < Conductor.songPosition)
					{
						PlayState.startOnTime = curTime;
						restartSong(true);
					}
					else
					{
						if (curTime != Conductor.songPosition)
						{
							PlayState.instance.clearNotesBefore(curTime);
							PlayState.instance.setSongTime(curTime);
						}
						close();
					}
					FlxG.camera.setFilters([]);
				case "End Song":
					close();
					PlayState.instance.finishSong(true);
				case 'Toggle Botplay':
					PlayState.instance.cpuControlled = !PlayState.instance.cpuControlled;
					PlayState.changedDifficulty = true;
					PlayState.instance.botplayTxt.visible = PlayState.instance.cpuControlled;
					PlayState.instance.botplayTxt.alpha = 1;
					PlayState.instance.botplaySine = 0;
				case "Exit to menu":
					PlayState.deathCounter = 0;
					PlayState.seenCutscene = false;

					WeekData.loadTheFirstEnabledMod();
					if(PlayState.isStoryMode) {
						MusicBeatState.switchState(new MainMenuState()); //Takes player back to main menu instead.
					} else {
						MusicBeatState.switchState(new FreeplayState());
					}
					PlayState.cancelMusicFadeTween();
					FlxG.sound.playMusic(Paths.music('freakyMenu'));
					PlayState.changedDifficulty = false;
					PlayState.chartingMode = false;
			}
			curSelected=0;
			for (item in grpMenuShit.members){
				item.alpha=0.6;
			}
		}
	}
	function check(daselected:String,opt:Array<String>):Bool{
		return Lambda.exists(opt,function(option){
			return option==daselected;
		});
	}
	function deleteSkipTimeText()
	{
		if(skipTimeText != null)
		{
			skipTimeText.kill();
			remove(skipTimeText);
			skipTimeText.destroy();
		}
		skipTimeText = null;
		skipTimeTracker = null;
	}

	public static function restartSong(noTrans:Bool = false)
	{
		PlayState.instance.paused = true; // For lua
		FlxG.sound.music.volume = 0;
		PlayState.instance.vocals.volume = 0;

		if(noTrans)
		{
			FlxTransitionableState.skipNextTransOut = true;
			FlxG.resetState();
		}
		else
		{
			MusicBeatState.resetState();
		}
	}

	override function destroy()
	{
		pauseMusic.destroy();

		super.destroy();
	}

	function changeSelection(change:Int = 0):Void
	{
		curSelected += change;
	
		FlxG.sound.play(Paths.sound('scrollMenu'), 0.4);
	
		if (curSelected < 0) {
			curSelected = menuItems.length - 1;
		}
	
		if (curSelected >= menuItems.length) {
			curSelected = 0;
		}
	
		for (item in grpMenuShit.members) {
			item.alpha=0.6;
		}
	
		var itm=grpMenuShit.members[curSelected];
		itm.alpha=1;
	
	}

	function regenMenu():Void {
		for (i in 0...grpMenuShit.members.length) {
			var obj = grpMenuShit.members[0];
			obj.kill();
			grpMenuShit.remove(obj, true);
			obj.destroy();
		}
		for (i in 0...menuItems.length) {
			item=new FlxText(-480,190+i*110,0,menuItems[i]);
			item.setFormat(Paths.font("helvetica.ttf"),64,FlxColor.WHITE,FlxTextBorderStyle.OUTLINE,FlxColor.BLACK);
			item.antialiasing = ClientPrefs.globalAntialiasing;
			grpMenuShit.add(item);
			FlxTween.tween(item,{x:30},0.8,{ease:FlxEase.quartOut});
			if (menuItems[i] == 'Skip Time') {
				skipTimeText = new FlxText(0, 0, 0, '', 64);
				skipTimeText.setFormat(Paths.font("vcr.ttf"), 64, FlxColor.WHITE, CENTER, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
				skipTimeText.scrollFactor.set();
				skipTimeText.borderSize = 2;
				add(skipTimeText);
		
				updateSkipTextStuff();
				updateSkipTimeText();
			}
		}
		curSelected = 0;
		changeSelection();
	}
	
	function updateSkipTextStuff()
	{
		if(skipTimeText == null || skipTimeTracker == null) return;

		skipTimeText.x = skipTimeTracker.x + skipTimeTracker.width + 60;
		skipTimeText.y = skipTimeTracker.y;
		skipTimeText.visible = (skipTimeTracker.alpha >= 1);
	}

	function updateSkipTimeText()
	{
		skipTimeText.text = FlxStringUtil.formatTime(Math.max(0, Math.floor(curTime / 1000)), false) + ' / ' + FlxStringUtil.formatTime(Math.max(0, Math.floor(FlxG.sound.music.length / 1000)), false);
	}
}
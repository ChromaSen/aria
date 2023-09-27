package;

import flixel.addons.plugin.taskManager.FlxTask;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.FlxSubState;
import flixel.text.FlxText;
import flixel.util.FlxColor;
import flixel.effects.FlxFlicker;
import lime.app.Application;
import flixel.addons.transition.FlxTransitionableState;
import flixel.addons.display.FlxBackdrop;
import flixel.tweens.FlxTween;
import flixel.FlxCamera;
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

	public var credits:Array<String>=[
		"REDIALBEAT",
		"tinb",
		"seal",
		"VEP",
		"sacredrazrs"
	];

	public var creditLinks:Array<String>=[
        "https://twitter.com/RDBT_0",
        "https://thisisniceboy.newgrounds.com/",
        "https://twitter.com/seale2234",
        "https://voideyedpanda.newgrounds.com/",
        "https://twitter.com/sacredrazrs"
    ];

	public var description:Array<String>=[
		"Director, Musician",
		"Sprite & BG Artist",
		"Musician",
		"Sprite & UI Artist",
		"Coder, additional Composing"
	];

	/*public var icons:Array<String>=[
		"REDIALBEAT-icon",
		"tinb-icon",
		"seal-icon",
		"VEP-icon",
		"sacredrazrs-icon"
	]
	*/

	private var camAchievement:FlxCamera;


	public var creditstxt:Array<FlxText>;
	public var icons:Array<FlxSprite>;
	public var descriptiontxt:FlxText;
	public var creditstext:FlxText;
	public var curSelected:Int=0;
	var warnText:FlxText;
	var backdro:FlxBackdrop;
	var bar:FlxSprite;

	public var texttostream:String;
    public var streaming:Float;
	public var icon:FlxSprite;

	/*2do
	* eecans credits //ill do it later (no)
	* gallery?
	* streamable text //done
	*/ 
	override function create()
	{
		super.create();


		FlxG.camera.zoom=0.8;
		camAchievement = new FlxCamera();
		camAchievement.bgColor.alpha = 0;
		FlxG.cameras.add(camAchievement, false);

		creditstxt=new Array<FlxText>();
		icons=new Array<FlxSprite>();

        backdro = new FlxBackdrop(Paths.image('menu'), XY);
        backdro.spacing.x = -0.05;
		backdro.antialiasing = ClientPrefs.globalAntialiasing;    
		backdro.scale.set(0.5, 0.5); 
		backdro.alpha=0.8;
		add(backdro);

		for(i in 0...credits.length){
			creditstext=new FlxText(490,i*150,300,credits[i]);
			creditstext.setFormat(Paths.font("helvetica.ttf"),56,FlxColor.WHITE,CENTER,FlxTextBorderStyle.OUTLINE,FlxColor.BLACK);
            creditstext.alpha=(i==curSelected)?1:0.7; //
            creditstxt.push(creditstext);
            add(creditstext);
			icon=new FlxSprite(creditstext.x+creditstext.width-80,creditstext.y-15,Paths.image('credits/' + credits[i] + "-icon"));
            icon.scale.set(1.1,1.1);
            icon.alpha=(i==curSelected)?1:0.7;
            icons.push(icon);
            add(icon);
		}
		bar=new FlxSprite().loadGraphic(Paths.image('mainmenu/bars'));
		bar.screenCenter();
		bar.antialiasing=false;
		bar.cameras=[camAchievement];
		add(bar);

		descriptiontxt=new FlxText(10,FlxG.height-50,FlxG.width-15,"");
		descriptiontxt.setFormat(Paths.font("helvetica.ttf"),32,FlxColor.WHITE,CENTER,FlxTextBorderStyle.OUTLINE,FlxColor.BLACK);
	//	descriptiontxt.text=description[curSelected];
		descriptiontxt.cameras=[camAchievement];
		descriptiontxt.text="";
		add(descriptiontxt);

		FlxG.sound.playMusic(Paths.music('CogsSETTINGS'),0.75); //i really enjoy this small option song, props to a guy who made it 💪// REDIII I LUV YAAAAA THIS IS A BOP
        texttostream=description[curSelected];
/*
		switch(credits[curSelected]){
			case "tinb":
				icons[curSelected].x=720;
				icons[curSelected].y=100;
				trace("tinb eecan!!!");
				//FUCK
		}
		*/
	}

	override function update(elapsed:Float)
	{
		backdro.x += (90 * 2) * elapsed;
		if (controls.UI_DOWN_P){
            nextarr();
        }else if(controls.UI_UP_P){
            previousarr();
        }
		if (controls.ACCEPT){
			CoolUtil.browserLoad(creditLinks[curSelected]);
		}	
		else if(controls.BACK) {
			FlxG.sound.play(Paths.sound('cancelMenu'));
			MusicBeatState.switchState(new MainMenuState());
			FlxG.sound.playMusic(Paths.music('freakyMenu'));
		}

		streaming+=elapsed;
		if(streaming>=0.05){
			streaming=0;
			descriptiontxt.text+=texttostream.charAt(descriptiontxt.text.length);
		}
		
		super.update(elapsed);
	}
	public function nextarr(){
		//shit formatting, but if it works, IT WORKS
        curSelection(curSelected,false);
		curSelected++;
		if (curSelected>=credits.length){
			curSelected=0;
		}
    	curSelection(curSelected,true);
		texttostream=description[curSelected];
        descriptiontxt.text="";
    }

    public function previousarr() {
        if (curSelected>0){
            curSelection(curSelected,false);
            curSelected--;
            curSelection(curSelected,true);
        }
		texttostream=description[curSelected];
        descriptiontxt.text="";
    }

    public function curSelection(index:Int=0,curSelected:Bool){
        if (index<creditstxt.length){
            creditstxt[index].alpha=curSelected?1:0.7;
			icons[index].alpha=curSelected?1:0.7;
        }
    }

}

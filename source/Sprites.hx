import flixel.addons.display.FlxBackdrop;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.math.FlxPoint;
import Paths;
import ClientPrefs;
import flixel.addons.display.FlxBackdrop;

class Sprites{
    static public function sprite(path:String,x:Float,y:Float):FlxSprite{
        var spirte=new FlxSprite().loadGraphic(Paths.image(path));
        spirte.antialiasing=ClientPrefs.globalAntialiasing;
        spirte.updateHitbox();
        spirte.setPosition(x,y);
        FlxG.state.add(spirte);
        return spirte;
    }
    static public function animatedSprite(path:String,x:Null<Float>=null,y:Null<Float>=null,animName:String,loop:Bool=true):FlxSprite{
        var spirteanimated=new FlxSprite();
        spirteanimated.frames=Paths.getSparrowAtlas(path);
        spirteanimated.antialiasing=ClientPrefs.globalAntialiasing;
        spirteanimated.updateHitbox();
        if (x!=null&&y!=null){
            spirteanimated.setPosition(x,y);
        }
        spirteanimated.animation.addByPrefix("idle",animName,24,loop);
        spirteanimated.animation.play("idle");
        FlxG.state.add(spirteanimated);
        return spirteanimated;
    }
    static public function backdrop(path:String,x:Null<Float>=null,y:Null<Float>=null,velocityX:Float,velocityY:Float):FlxBackdrop{
        var backdrop=new FlxBackdrop(Paths.image(path),X);
        if(x!=null&&y!=null)
            {
                backdrop.setPosition(x,y);
            }
        backdrop.velocity.set(velocityX,velocityY);
        backdrop.antialiasing=ClientPrefs.globalAntialiasing;
        FlxG.state.add(backdrop);
        return backdrop;
    }
}

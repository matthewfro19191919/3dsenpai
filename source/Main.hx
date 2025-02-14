package;

import extensions.openfl.display.FPSExt;
import modding.PolymodHandler;
import flixel.system.scaleModes.RatioScaleMode;
import extensions.flixel.FlxUIStateExt;
import transition.data.*;
import flixel.FlxG;
import flixel.FlxGame;
import openfl.display.Sprite;
import debug.*;
import openfl.display.FPS;
#if mobile
import mobile.MobileUtil;
#end

class Main extends Sprite
{

	public static var fpsDisplay:FPSExt;

	public static var novid:Bool = false;
	public static var flippymode:Bool = false;

	public function new()
	{
		#if mobile
		#if android
		MobileUtil.requestPermsFromUser();
		#end
		Sys.setCwd(MobileUtil.getStorageDirectory());
		#end
		CrashHandler.init();

		super();

		PolymodHandler.init();

		#if (sys && !mobile)
		novid = Sys.args().contains("-novid");
		flippymode = Sys.args().contains("-flippymode");
		#end

		SaveManager.global();

		fpsDisplay = new FPSExt(3, 3, 0xFFFFFF);
		fpsDisplay.visible = true;

		FlxUIStateExt.defaultTransIn = ScreenWipeIn;
		FlxUIStateExt.defaultTransInArgs = [0.6];
                FlxUIStateExt.defaultTransOut = ScreenWipeOut;
                FlxUIStateExt.defaultTransOutArgs = [0.6];

		addChild(new FlxGame(#if mobile 1280, 720 #else 0, 0 #end, #if mobile !mobile.CopyState.checkExistingFiles() ? mobile.CopyState : #end Startup, 60, 60, true));
		addChild(fpsDisplay);

		//On web builds, video tends to lag quite a bit, so this just helps it run a bit faster.
		#if web
		VideoHandler.MAX_FPS = 30;
		#end

		#if mobile
		#if android FlxG.android.preventDefaultKeys = [BACK]; #end

		FlxG.signals.gameResized.add(function (w, h) {
			if(fpsDisplay != null)
				fpsDisplay.positionFPS(10, 3, Math.min(w / FlxG.width, h / FlxG.height));
		});
		#end

		#if (sys && !mobile)
		trace("-=Args=-");
		trace("novid: " + novid);
		trace("flippymode: " + flippymode);
		#end
	}
}

/*
 * Copyright (C) 2025 Mobile Porting Team
 *
 * Permission is hereby granted, free of charge, to any person obtaining a
 * copy of this software and associated documentation files (the "Software"),
 * to deal in the Software without restriction, including without limitation
 * the rights to use, copy, modify, merge, publish, distribute, sublicense,
 * and/or sell copies of the Software, and to permit persons to whom the
 * Software is furnished to do so, subject to the following conditions:
 *
 * The above copyright notice and this permission notice shall be included in
 * all copies or substantial portions of the Software.
 *
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 * IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 * FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 * AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 * LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING
 * FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER
 * DEALINGS IN THE SOFTWARE.
 */

package mobile;

import flixel.util.FlxColor;
import flixel.util.FlxDestroyUtil;
import flixel.FlxSprite;
import flixel.FlxG;
import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;
import openfl.display.BitmapData;
import openfl.display.Shape;
import flixel.graphics.FlxGraphic;
import openfl.geom.Matrix;
import mobile.input.MobileInputManager;
import mobile.input.MobileInputID;

/**
 * A zone with 4 hint's (A hitbox).
 * It's really easy to customize the layout.
 *
 * @author: Karim Akra and Lily Ross (mcagabe19)
 */
class Hitbox extends MobileInputManager
{
	public var buttonLeft:TouchButton = new TouchButton(0, 0, [MobileInputID.HITBOX_LEFT]);
	public var buttonDown:TouchButton = new TouchButton(0, 0, [MobileInputID.HITBOX_DOWN]);
	public var buttonUp:TouchButton = new TouchButton(0, 0, [MobileInputID.HITBOX_UP]);
	public var buttonRight:TouchButton = new TouchButton(0, 0, [MobileInputID.HITBOX_RIGHT]);

	public var instance:MobileInputManager;

	var storedButtonsIDs:Map<String, Array<MobileInputID>> = new Map<String, Array<MobileInputID>>();

	/**
	 * Create the zone.
	 */
	public function new()
	{
		super();

		for (button in Reflect.fields(this))
		{
			var field = Reflect.field(this, button);
			if (Std.isOfType(field, TouchButton))
				storedButtonsIDs.set(button, Reflect.getProperty(field, 'IDs'));
		}

		add(buttonLeft = createHint(0, 0, Std.int(FlxG.width / 4), FlxG.height, 0xFFC24B99));
		add(buttonDown = createHint(FlxG.width / 4, 0, Std.int(FlxG.width / 4), FlxG.height, 0xFF00FFFF));
		add(buttonUp = createHint(FlxG.width / 2, 0, Std.int(FlxG.width / 4), FlxG.height, 0xFF12FA05));
		add(buttonRight = createHint((FlxG.width / 2) + (FlxG.width / 4), 0, Std.int(FlxG.width / 4), FlxG.height, 0xFFF9393F));

		for (button in Reflect.fields(this))
		{
			if (Std.isOfType(Reflect.field(this, button), TouchButton))
				Reflect.setProperty(Reflect.getProperty(this, button), 'IDs', storedButtonsIDs.get(button));
		}

		storedButtonsIDs.clear();
		scrollFactor.set();
		updateTrackedButtons();

		instance = this;
	}

	/**
	 * Clean up memory.
	 */
	override function destroy()
	{
		super.destroy();

		for (fieldName in Reflect.fields(this))
		{
			var field = Reflect.field(this, fieldName);
			if (Std.isOfType(field, TouchButton))
				Reflect.setField(this, fieldName, FlxDestroyUtil.destroy(field));
		}
	}

	private function createHint(X:Float, Y:Float, Width:Int, Height:Int, Color:Int = 0xFFFFFF):TouchButton
	{
		var hint = new TouchButton(X, Y);
		hint.statusAlphas = [];
		hint.statusIndicatorType = NONE;
		hint.loadGraphic(createHintGraphic(Width, Height));

		hint.label = new FlxSprite();
		hint.labelStatusDiff = (config.Config.hitboxType != "Hidden") ? config.Config.mobileCAlpha : 0.00001;
		hint.label.loadGraphic(createHintGraphic(Width, Math.floor(Height * 0.035), true));
		hint.label.offset.y -= (hint.height - hint.label.height) / 2;

		if (config.Config.hitboxType != "Hidden")
		{
			var hintTween:FlxTween = null;
			var hintLaneTween:FlxTween = null;

			hint.onDown.callback = function()
			{
				if (hintTween != null)
					hintTween.cancel();

				if (hintLaneTween != null)
					hintLaneTween.cancel();

				hintTween = FlxTween.tween(hint, {alpha: config.Config.mobileCAlpha}, config.Config.mobileCAlpha / 100, {
					ease: FlxEase.circInOut,
					onComplete: (twn:FlxTween) -> hintTween = null
				});

				hintLaneTween = FlxTween.tween(hint.label, {alpha: 0.00001}, config.Config.mobileCAlpha / 10, {
					ease: FlxEase.circInOut,
					onComplete: (twn:FlxTween) -> hintTween = null
				});
			}

			hint.onOut.callback = hint.onUp.callback = function()
			{
				if (hintTween != null)
					hintTween.cancel();

				if (hintLaneTween != null)
					hintLaneTween.cancel();

				hintTween = FlxTween.tween(hint, {alpha: 0.00001}, config.Config.mobileCAlpha / 10, {
					ease: FlxEase.circInOut,
					onComplete: (twn:FlxTween) -> hintTween = null
				});

				hintLaneTween = FlxTween.tween(hint.label, {alpha: config.Config.mobileCAlpha}, config.Config.mobileCAlpha / 100, {
					ease: FlxEase.circInOut,
					onComplete: (twn:FlxTween) -> hintTween = null
				});
			}
		}

		hint.immovable = hint.multiTouch = true;
		hint.solid = hint.moves = false;
		hint.alpha = 0.00001;
		hint.label.alpha = (config.Config.hitboxType != "Hidden") ? config.Config.mobileCAlpha : 0.00001;
		hint.canChangeLabelAlpha = false;
		hint.label.antialiasing = hint.antialiasing = true;
		hint.color = Color;
		#if FLX_DEBUG
		hint.ignoreDrawDebug = true;
		#end
		return hint;
	}

	function createHintGraphic(Width:Int, Height:Int, ?isLane:Bool = false):FlxGraphic
	{
		var shape:Shape = new Shape();
		shape.graphics.beginFill(0xFFFFFF);

		if (config.Config.hitboxType == "No Gradient")
		{
			var matrix:Matrix = new Matrix();
			matrix.createGradientBox(Width, Height, 0, 0, 0);

			if (isLane)
				shape.graphics.beginFill(0xFFFFFF);
			else
				shape.graphics.beginGradientFill(RADIAL, [0xFFFFFF, 0xFFFFFF], [0, 1], [60, 255], matrix, PAD, RGB, 0);
			shape.graphics.drawRect(0, 0, Width, Height);
			shape.graphics.endFill();
		}
		else if (config.Config.hitboxType == "No Gradient (Old)")
		{
			shape.graphics.lineStyle(10, 0xFFFFFF, 1);
			shape.graphics.drawRect(0, 0, Width, Height);
			shape.graphics.endFill();
		}
		else // if (config.Config.hitboxType == 'Gradient')
		{
			shape.graphics.lineStyle(3, 0xFFFFFF, 1);
			shape.graphics.drawRect(0, 0, Width, Height);
			shape.graphics.lineStyle(0, 0, 0);
			shape.graphics.drawRect(3, 3, Width - 6, Height - 6);
			shape.graphics.endFill();
			if (isLane)
				shape.graphics.beginFill(0xFFFFFF);
			else
				shape.graphics.beginGradientFill(RADIAL, [0xFFFFFF, FlxColor.TRANSPARENT], [1, 0], [0, 255], null, null, null, 0.5);
			shape.graphics.drawRect(3, 3, Width - 6, Height - 6);
			shape.graphics.endFill();
		}

		var bitmap:BitmapData = new BitmapData(Width, Height, true, 0);
		bitmap.draw(shape);

		return FlxG.bitmap.add(bitmap);
	}
}

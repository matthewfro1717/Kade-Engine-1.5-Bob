package;

import Controls.KeyboardScheme;
import flixel.FlxG;
import flixel.FlxObject;
import flixel.FlxSprite;
import flixel.effects.FlxFlicker;
import flixel.graphics.frames.FlxAtlasFrames;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.text.FlxText;
import flixel.system.FlxSound;
import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;
import flixel.util.FlxColor;
import flixel.util.FlxTimer;
import io.newgrounds.NG;
import lime.app.Application;

#if windows
import Discord.DiscordClient;
#end

using StringTools;

class MainMenuState extends MusicBeatState
{
	var curSelected:Int = 0;
	var MainMenuSpin:Int = 0;
	var timer:Float = 0;
	var secretmusic:FlxSound;
	var secretguy:FlxSprite;
	var isguydancing:Bool = false;

	var menuItems:FlxTypedGroup<FlxSprite>;

	#if !switch
	var optionShit:Array<String> = ['story mode', 'freeplay', 'donate', 'options'];
	#else
	var optionShit:Array<String> = ['story mode', 'freeplay', 'donate', 'options'];
	#end

	var newGaming:FlxText;
	var newGaming2:FlxText;
	public static var firstStart:Bool = true;

	public static var nightly:String = "";

	public static var kadeEngineVer:String = "1.5" + nightly;
	public static var gameVer:String = "0.2.7.1";

	var magenta:FlxSprite;
	var camFollow:FlxObject;
	public static var finishedFunnyMove:Bool = false;

	override function create()
	{
		/**if (FlxG.random.bool(4))
		{
			GuyAppears(FlxG.random.int(1, 3));
		}**/

		#if windows
		// Updating Discord Rich Presence
		DiscordClient.changePresence("In the Menus", null);
		#end

		if (!FlxG.sound.music.playing)
		{
			FlxG.sound.playMusic(Paths.music('freakyMenu'));
		}

		persistentUpdate = persistentDraw = true;

		var bg:FlxSprite = new FlxSprite(-100).loadGraphic(Paths.image('menuBG'));
		bg.scrollFactor.x = 0;
		bg.scrollFactor.y = 0.10;
		bg.setGraphicSize(Std.int(bg.width * 1.1));
		bg.updateHitbox();
		bg.screenCenter();
		bg.antialiasing = true;
		add(bg);

		camFollow = new FlxObject(0, 0, 1, 1);
		add(camFollow);

		magenta = new FlxSprite(-80).loadGraphic(Paths.image('menuDesat'));
		magenta.scrollFactor.x = 0;
		magenta.scrollFactor.y = 0.10;
		magenta.setGraphicSize(Std.int(magenta.width * 1.1));
		magenta.updateHitbox();
		magenta.screenCenter();
		magenta.visible = false;
		magenta.antialiasing = true;
		magenta.color = 0xFFfd719b;
		add(magenta);
		// magenta.scrollFactor.set();

		menuItems = new FlxTypedGroup<FlxSprite>();
		add(menuItems);

		var tex = Paths.getSparrowAtlas('FNF_main_menu_assets');

		for (i in 0...optionShit.length)
		{
			var menuItem:FlxSprite = new FlxSprite(0, FlxG.height * 1.6);
			menuItem.frames = tex;
			menuItem.animation.addByPrefix('idle', optionShit[i] + " basic", 24);
			menuItem.animation.addByPrefix('selected', optionShit[i] + " white", 24);
			menuItem.animation.play('idle');
			menuItem.ID = i;
			menuItem.screenCenter(X);
			menuItems.add(menuItem);
			menuItem.scrollFactor.set();
			menuItem.antialiasing = true;
			if (firstStart)
				FlxTween.tween(menuItem,{y: 60 + (i * 160)},1 + (i * 0.25) ,{ease: FlxEase.expoInOut, onComplete: function(flxTween:FlxTween) 
					{ 
						finishedFunnyMove = true; 
						changeItem();
					}});
			else
				menuItem.y = 60 + (i * 160);
		}

		firstStart = false;

		FlxG.camera.follow(camFollow, null, 0.60 * (60 / FlxG.save.data.fpsCap));

		var versionShit:FlxText = new FlxText(5, FlxG.height - 18, 0, gameVer +  (Main.watermarks ? " FNF - " + kadeEngineVer + " Kade Engine" : ""), 12);
		versionShit.scrollFactor.set();
		versionShit.setFormat("VCR OSD Mono", 16, FlxColor.WHITE, LEFT, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
		add(versionShit);

		// NG.core.calls.event.logEvent('swag').send();


		if (FlxG.save.data.dfjk)
			controls.setKeyboardScheme(KeyboardScheme.Solo, true);
		else
			controls.setKeyboardScheme(KeyboardScheme.Duo(true), true);

		changeItem();

		super.create();
	}

	var selectedSomethin:Bool = false;

	override function update(elapsed:Float)
	{
		if (FlxG.sound.music.volume < 0.8)
		{
			FlxG.sound.music.volume += 0.5 * FlxG.elapsed;
		}

		if (!selectedSomethin)
		{
			if (controls.UP_P)
			{
				FlxG.sound.play(Paths.sound('scrollMenu'));
				changeItem(-1);
			}

			if (controls.DOWN_P)
			{
				FlxG.sound.play(Paths.sound('scrollMenu'));
				changeItem(1);
			}

			if (controls.BACK)
			{
				FlxG.switchState(new TitleState());
			}

			if (controls.ACCEPT)
			{
				if (optionShit[curSelected] == 'donate')
				{
					FlxG.sound.play(Paths.sound('fartsoundlol'));
					FlxFlicker.flicker(magenta, 1.1, 0.15, false);
				}
				else
				{
					selectedSomethin = true;
					FlxG.sound.play(Paths.sound('confirmMenu'));
					
					if (FlxG.save.data.flashing)
						FlxFlicker.flicker(magenta, 1.1, 0.15, false);

					menuItems.forEach(function(spr:FlxSprite)
					{
						if (curSelected != spr.ID)
						{
							FlxTween.tween(spr, {alpha: 0}, 1.3, {
								ease: FlxEase.quadOut,
								onComplete: function(twn:FlxTween)
								{
									spr.kill();
								}
							});
						}
						else
						{
							if (FlxG.save.data.flashing)
							{
								FlxFlicker.flicker(spr, 1, 0.06, false, false, function(flick:FlxFlicker)
								{
									goToState();
								});
							}
							else
							{
								new FlxTimer().start(1, function(tmr:FlxTimer)
								{
									goToState();
								});
							}
						}
					});
				}
			}
		}

		super.update(elapsed);

		menuItems.forEach(function(spr:FlxSprite)
		{
			spr.screenCenter(X);
		});
	}
	
	function goToState()
	{
		var daChoice:String = optionShit[curSelected];

		switch (daChoice)
		{
			case 'story mode':
				FlxG.switchState(new StoryMenuState());
				trace("Story Menu Selected");
			case 'freeplay':
				FlxG.switchState(new FreeplayState());

				trace("Freeplay Menu Selected");

			case 'options':
				FlxG.switchState(new OptionsMenu());
		}
	}
	function GuyAppears(rando)
	{
		if (rando == 1)
		{
			secretmusic = new FlxSound().loadEmbedded(Paths.sound('GuyDancing'));
			secretmusic.looped = true;
			secretmusic.volume = 0.3;
			secretguy = new FlxSprite(0, 0);
			secretguy.frames = Paths.getSparrowAtlas('CoolDance');
			secretguy.animation.addByPrefix('idle', 'CoolGuy', 24);
			secretguy.updateHitbox();
			secretguy.scrollFactor.set();
			add(secretguy);
			secretmusic.play();
			secretguy.animation.play('idle');
		}
		if (rando == 2)
			{
				secretmusic = new FlxSound().loadEmbedded(Paths.sound('SortingAlgorithm'));
				secretmusic.looped = true;
				secretmusic.volume = 0.3;
				secretguy = new FlxSprite(0, 0);
				secretguy.frames = Paths.getSparrowAtlas('Sorting');
				secretguy.animation.addByPrefix('idle', 'Sorting', 24);
				secretguy.updateHitbox();
				secretguy.scrollFactor.set();
				add(secretguy);
				secretmusic.play();
				secretguy.animation.play('idle');
			}
		if (rando == 3)
				{
					secretmusic = new FlxSound().loadEmbedded(Paths.sound('SpongSound'));
					secretmusic.looped = true;
					secretmusic.volume = 0.3;
					secretguy = new FlxSprite(0, 0);
					secretguy.frames = Paths.getSparrowAtlas('Spong');
					secretguy.animation.addByPrefix('idle', 'Dad idle dance', 24);
					secretguy.updateHitbox();
					secretguy.scrollFactor.set();
					add(secretguy);
					secretmusic.play();
					secretguy.animation.play('idle');
				}
		if (rando == 4)
			{
				secretmusic = new FlxSound().loadEmbedded(Paths.sound('crazy_little_guy'));
				secretmusic.looped = true;
				secretmusic.volume = 0.5;
				secretguy = new FlxSprite(0, 0);
				secretguy.frames = Paths.getSparrowAtlas('campaign_menu_UI_characters');
				secretguy.animation.addByPrefix('idle', 'BOBBY BOBINO BOBBLE menu asset', 60);
				secretguy.updateHitbox();
				secretguy.scrollFactor.set();
				add(secretguy);
				secretmusic.play();
				secretguy.animation.play('idle');
			}
	}
	function changeItem(huh:Int = 0)
	{
		if (finishedFunnyMove)
		{
			curSelected += huh;

			if (curSelected >= menuItems.length)
				curSelected = 0;
			if (curSelected < 0)
				curSelected = menuItems.length - 1;
		}
		menuItems.forEach(function(spr:FlxSprite)
		{
			spr.animation.play('idle');

			if (spr.ID == curSelected && finishedFunnyMove)
			{
				spr.animation.play('selected');
				camFollow.setPosition(spr.getGraphicMidpoint().x, spr.getGraphicMidpoint().y);
			}

			spr.updateHitbox();
		});
	}
}

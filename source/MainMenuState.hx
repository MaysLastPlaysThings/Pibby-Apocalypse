package;

import openfl.net.URLRequest;
import options.BaseOptionsMenu;
#if desktop
import Discord.DiscordClient;
#end
import flixel.FlxG;
import flixel.FlxObject;
import flixel.FlxSprite;
import flixel.FlxCamera;
import flixel.addons.transition.FlxTransitionableState;
import flixel.effects.FlxFlicker;
import flixel.graphics.frames.FlxAtlasFrames;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.text.FlxText;
import flixel.math.FlxMath;
import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;
import flixel.util.FlxColor;
import lime.app.Application;
import flixel.input.mouse.FlxMouseEvent;
import openfl.Lib;
#if !flash
import flixel.addons.display.FlxRuntimeShader;
import openfl.filters.ShaderFilter;
#end
import Achievements;
import editors.MasterEditorMenu;
import flixel.input.keyboard.FlxKey;

using StringTools;

class MainMenuState extends MusicBeatState
{
	public static var psychEngineVersion:String = '0.6.2'; // This is also used for Discord RPC
	public static var curSelected:Int = 0;

	public var cinematicdown:FlxSprite;
	public var cinematicup:FlxSprite;

	var menuItems:FlxTypedGroup<AlphabetTyped>;
	private var camGame:FlxCamera;
	private var camAchievement:FlxCamera;

	var pibbyFNF:Shaders.Pibbified;
	var VCR:Shaders.OldTVShader;

	var shaderIntensity:Float;

	var optionShit:Array<String> = ['FREEPLAY', 'CREDITS'];

	var magenta:FlxSprite;
	var camFollow:FlxObject;
	var camFollowPos:FlxObject;
	var debugKeys:Array<FlxKey>;
	var aweTxt:FlxText;
	var verTxt:FlxText;
	var barTab:FlxSprite;

	var URL:String = "https://pastebin.com/raw/HLtJfzAC";
	var MOTD:String;

	var options:FlxSprite;
	var discord:FlxSprite;

	var freeplayhitbox:FlxSprite;
	var creditshitbox:FlxSprite;

	override function create()
	{
		Paths.clearStoredMemory();
		Paths.clearUnusedMemory();

		#if MODS_ALLOWED
		Paths.pushGlobalMods();
		WeekData.loadTheFirstEnabledMod();
		#end

		openfl.Lib.application.window.title = "Pibby: Apocalypse - Main Menu";

		#if desktop
		// Updating Discord Rich Presence
		DiscordClient.changePresence("📱 | In the Menus", null);
		#end
		debugKeys = ClientPrefs.copyKey(ClientPrefs.keyBinds.get('debug_1'));

		camGame = new FlxCamera();
		camAchievement = new FlxCamera();
		camAchievement.bgColor.alpha = 0;

		FlxG.cameras.reset(camGame);
		FlxG.cameras.add(camAchievement, false);
		FlxG.cameras.setDefaultDrawTarget(camGame, true);

		transIn = FlxTransitionableState.defaultTransIn;
		transOut = FlxTransitionableState.defaultTransOut;

		FlxG.mouse.visible = false; //uh

		persistentUpdate = persistentDraw = true;

		VCR = new Shaders.OldTVShader();
		// ???????????????????????????
		pibbyFNF = new Shaders.Pibbified();

		//alpha 0 and visible false doesnt work (mouse dont detect the object for some reason)
		//so now the hitboxes are behind everything xdxdd
		freeplayhitbox = new FlxSprite(160, 30).makeGraphic(374, 59, FlxColor.GREEN);
		freeplayhitbox.alpha = 1;
		add(freeplayhitbox);

		creditshitbox = new FlxSprite(740, 30).makeGraphic(374, 59, FlxColor.GREEN);
		creditshitbox.alpha = 1;
		add(creditshitbox);

		var yScroll:Float = Math.max(0.25 - (0.05 * (optionShit.length - 4)), 0.1);
		var bg:FlxSprite = new FlxSprite(0, -10).loadGraphic(Paths.image('pibymenu/BACKGROUND'));
		bg.scrollFactor.set(0, 0);
		bg.setGraphicSize(Std.int(bg.width * 0.8));
		bg.updateHitbox();
		bg.screenCenter(X);
		bg.antialiasing = ClientPrefs.globalAntialiasing;
		if (ClientPrefs.shaders)
			bg.shader = VCR;
		add(bg);

		camFollow = new FlxObject(0, 0, 1, 1);
		camFollowPos = new FlxObject(0, 0, 1, 1);
		add(camFollow);
		add(camFollowPos);

		magenta = new FlxSprite(-80).loadGraphic(Paths.image('menuDesat'));
		magenta.scrollFactor.set(0, yScroll);
		magenta.setGraphicSize(Std.int(magenta.width * 1.175));
		magenta.updateHitbox();
		magenta.screenCenter();
		magenta.visible = false;
		magenta.antialiasing = ClientPrefs.globalAntialiasing;
		magenta.color = 0xFFfd719b;
		add(magenta);

		// magenta.scrollFactor.set();

		cinematicdown = new FlxSprite().makeGraphic(FlxG.width, 70, FlxColor.BLACK);
		cinematicdown.scrollFactor.set();
		cinematicdown.setPosition(0, FlxG.height - 70);
		cinematicdown.antialiasing = ClientPrefs.globalAntialiasing;
		add(cinematicdown);

		cinematicup = new FlxSprite().makeGraphic(FlxG.width, 100, FlxColor.BLACK);
		cinematicup.scrollFactor.set();
		cinematicup.antialiasing = ClientPrefs.globalAntialiasing;
		add(cinematicup);

		options = new FlxSprite().loadGraphic(Paths.image('pibymenu/Options'));
		options.alpha = 0.4;
		options.scale.set(0.3, 0.3);
		options.updateHitbox();
		options.setPosition(FlxG.width - 97, FlxG.height - 63);
		options.antialiasing = ClientPrefs.globalAntialiasing;
		add(options);

		discord = new FlxSprite().loadGraphic(Paths.image('pibymenu/discord'));

		discord.alpha = 0.4;
		discord.scale.set(0.3, 0.3);
		discord.updateHitbox();
		discord.setPosition(options.x - 85, FlxG.height - 60);
		discord.antialiasing = ClientPrefs.globalAntialiasing;
		add(discord);

		aweTxt = new FlxText(0, FlxG.height - 35, 0,
			'Now Playing: Menu Theme ${Main.funnyMenuMusic == 2 ? '(Alt)' : ''} - By ${Main.funnyMenuMusic == 2 ? 'Sodukoru' : 'GoddessAwe'} ♪', 8);
		aweTxt.setFormat(Paths.font("menuBUTTONS.ttf"), 24, FlxColor.WHITE, LEFT);
		aweTxt.alpha = 1;
		aweTxt.antialiasing = ClientPrefs.globalAntialiasing;
		add(aweTxt);
		verTxt = new FlxText(0, FlxG.height - 65, 0, 'PIBBY APOCALYPSE DEMO - V0.71 [WARMFIX]', 8);
		verTxt.setFormat(Paths.font("menuBUTTONS.ttf"), 24, FlxColor.WHITE, LEFT);
		verTxt.alpha = 1;
		verTxt.antialiasing = ClientPrefs.globalAntialiasing;
		add(verTxt);
		menuItems = new FlxTypedGroup<AlphabetTyped>();
		add(menuItems);
		for (i in 0...optionShit.length)
		{
			var menuItem:AlphabetTyped = new AlphabetTyped(0, 60 + (i * 160), optionShit[i]);

			menuItem.alpha = 0.4;
			menuItem.ID = i;
			switch (optionShit[i])
			{
				case 'CREDITS':
					menuItem.x = 795;
					menuItem.y = -75;
				case 'FREEPLAY':
					menuItem.y = -75;
					menuItem.x = 170;
			}
			menuItems.add(menuItem);
			var scr:Float = (optionShit.length - 4) * 0.135;
			if (optionShit.length < 6)
				scr = 0;
			menuItem.scrollFactor.set(0, scr);
			menuItem.antialiasing = ClientPrefs.globalAntialiasing;
			// menuItem.setGraphicSize(Std.int(menuItem.width * 0.58));
			menuItem.updateHitbox();
			menuItem.x -= 125;
		}

		FlxMouseEvent.add(freeplayhitbox, function onMouseDown(freeplay:FlxSprite)
		{
			if(curSelected != 0)
			changeItem(-1);
			else
            selectThing();

		}, null, null, null);

		FlxMouseEvent.add(creditshitbox, function onMouseDown(credits:FlxSprite)
		{
			if(curSelected != 1) 
			changeItem(1);
			else
		    selectThing();

		}, null, null, null);

		// NG.core.calls.event.logEvent('swag').send();

		changeItem();
		super.create();
		if (!FlxG.save.data.debugBuild)
		{
			FlxG.save.data.debugBuild = true;
			FlxG.save.flush();
		}
	}

	private var sickBeats:Int = 0; // Basically curBeat but won't be skipped if you hold the tab or resize the screen

	override function beatHit()
	{
		super.beatHit();

		sickBeats++;
	}

	var selectedSomethin:Bool = false;

	override function update(elapsed:Float)
	{

		if (FlxG.sound.music != null)
			Conductor.songPosition = FlxG.sound.music.time;

		if (FlxG.random.int(0, 1) < 0.01)
		{
			shaderIntensity = FlxG.random.float(0.2, 0.3);
		}

		if (ClientPrefs.shaders) {
			pibbyFNF.glitchMultiply.value[0] = shaderIntensity;
			pibbyFNF.uTime.value[0] += elapsed;
			VCR.iTime.value[0] += elapsed;
		}

		Conductor.changeBPM(100);

		if (FlxG.sound.music.volume < 0.8)
		{
			FlxG.sound.music.volume += 0.5 * FlxG.elapsed;
			if (FreeplayState.vocals != null)
				FreeplayState.vocals.volume += 0.5 * elapsed;
		}

		if (!selectedSomethin)
		{
			if (Main.debug)
			{
				if (FlxG.keys.anyJustPressed([SEVEN]))
				{
					MusicBeatState.switchState(new MasterEditorMenu());
				}
			}

/*			menuItems.forEach(function(spr:FlxSprite)
			{
				if (BSLTouchUtils.aperta(spr, spr.ID) == 'primeiro')
					changeItem(spr.ID);
				else if (BSLTouchUtils.aperta(spr, spr.ID) == 'segundo')
					selectThing();
			});*/

			if (BSLTouchUtils.apertasimples(options))
			{
				FlxTween.tween(options, {alpha: 1}, 0.25, {
					ease: FlxEase.quadOut,
					onComplete: function(twn:FlxTween)
					{
						twn.cancel(); // idk if this is necessary (idk how to write necessary sdfashdjfhdjhajdfhaskdhfalkdhfkj)
						MusicBeatState.switchState(new options.OptionsState());
					}
				});
			}

			if (BSLTouchUtils.apertasimples(discord))
			{
				FlxTween.tween(discord, {alpha: 1}, 0.25, {
					ease: FlxEase.quadOut,
					onComplete: function(twn:FlxTween)
					{
						twn.cancel(); // idk if this is necessary (idk how to write necessary sdfashdjfhdjhajdfhaskdhfalkdhfkj)
						FlxG.openURL('https://discord.gg/yPKffqXtJd');
					}
				});
			}

			if (FlxG.keys.anyJustPressed([LEFT, A]))
			{
				FlxG.sound.play(Paths.sound('scrollMenu'));
				changeItem(-1);
			}

			if (FlxG.keys.anyJustPressed([RIGHT, D]))
			{
				FlxG.sound.play(Paths.sound('scrollMenu'));
				changeItem(1);
			}

			if (controls.BACK #if mobile || FlxG.android.justReleased.BACK #end)
			{
				selectedSomethin = true;
				FlxG.sound.play(Paths.sound('cancelMenu'));
				MusicBeatState.switchState(new TitleState());
			}

			if (controls.ACCEPT)
			{
				selectedSomethin = true;
				FlxG.sound.play(Paths.sound('confirmMenu'));

				menuItems.forEach(function(spr:FlxSprite)
				{
					if (curSelected != spr.ID)
					{
						FlxTween.tween(spr, {alpha: 0}, 0.4, {
							ease: FlxEase.quadOut,
							onComplete: function(twn:FlxTween)
							{
								spr.kill();
							}
						});
					}
					else
					{
						FlxFlicker.flicker(spr, 1, 0.06, false, false, function(flick:FlxFlicker)
						{
							var daChoice:String = optionShit[curSelected];

							switch (daChoice)
							{
								case 'STORY MODE':
									MusicBeatState.switchState(new StoryMenuState());
								case 'FREEPLAY':
                                    MusicBeatState.switchState(new FreeplayState());
									FlxG.sound.playMusic(Paths.music('fpmenu'));
								case 'CREDITS':
									//credits aint done i just did this to make testing easier
									LoadingState.loadAndSwitchState(new PACreditsState());
									FlxG.sound.playMusic(Paths.music('creditsmenu'));

                                    //Lib.getURL(new URLRequest('https://gamebanana.com/wips/73842'));
                                    //MusicBeatState.switchState(this);
							}
						});
					}
				});
			}
		}

		super.update(elapsed);
}

	function selectThing()
		{
			selectedSomethin = true;
			FlxG.sound.play(Paths.sound('confirmMenu'));

			menuItems.forEach(function(spr:FlxSprite)
			{
				if (curSelected != spr.ID)
				{
					FlxTween.tween(spr, {alpha: 0}, 0.4, {
						ease: FlxEase.quadOut,
						onComplete: function(twn:FlxTween)
						{
							spr.kill();
						}
					});
				}
				else
				{
					FlxFlicker.flicker(spr, 1, 0.06, false, false, function(flick:FlxFlicker)
					{
						var daChoice:String = optionShit[curSelected];

						switch (daChoice)
						{
							case 'STORY MODE':
								MusicBeatState.switchState(new StoryMenuState());
							case 'FREEPLAY':
								MusicBeatState.switchState(new FreeplayState());
								FlxG.sound.playMusic(Paths.music('fpmenu'));
							case 'CREDITS':
								// credits aint done i just did this to make testing easier
								LoadingState.loadAndSwitchState(new PACreditsState());
								FlxG.sound.playMusic(Paths.music('creditsmenu'));

								// Lib.getURL(new URLRequest('https://gamebanana.com/wips/73842'));
								// MusicBeatState.switchState(this);
						}
					});
				}
			});
		}

	function changeItem(huh:Int = 0)
	{
		curSelected += huh;

		if (curSelected >= menuItems.length)
			curSelected = 0;
		if (curSelected < 0)
			curSelected = menuItems.length - 1;

		// If the bar exists we destroy it to save memory
		if (barTab != null)
			barTab.destroy();

		// A bunch of math shit to make bar under the text lolll --Aaron
		barTab = new FlxSprite().makeGraphic(Std.int(menuItems.members[curSelected].actualText.textField.textWidth) + 20, 5, FlxColor.WHITE);
		barTab.setPosition(menuItems.members[curSelected].x + (menuItems.members[curSelected].actualText.textField.textWidth / 2) - 5,
			menuItems.members[curSelected].y + 160);
		barTab.antialiasing = ClientPrefs.globalAntialiasing;
		add(barTab);

		menuItems.forEach(function(spr:FlxSprite)
		{
			spr.alpha = 0.4;
			spr.updateHitbox();

			if (spr.ID == curSelected)
			{
				FlxTween.tween(spr, {alpha: 1}, 0.1, {
					ease: FlxEase.quadInOut,
					onComplete: function(twn:FlxTween)
					{
						spr.alpha = 1;
					}
				});
			}
		});
	}
}

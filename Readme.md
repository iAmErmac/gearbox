# Gearbox

Gearbox is an add-on for GZDoom engine that provides more convenient ways to
select weapons and items.

This mod is a part of [m8f's toolbox](https://mmaulwurff.github.io/pages/toolbox).

![PyWeaponWheel mod for Doom](https://i.imgflip.com/7ahvfi.gif)

To download Gearbox VR Edition click the download button below:

[![Download Now](https://raster.shields.io/github/downloads/iAmErmac/gearbox/total)](https://github.com/iAmErmac/gearbox/releases/latest)

[<img src="https://cdn.ko-fi.com/cdn/kofi2.png?v=2" height="36" alt="Buy me a Cofee!">](https://ko-fi.com/ermac)

## What Changed in VR Version?
* Since level freezing also locks up head-tracking so it is replaced by new codes to freeze all monsters and projectiles instead.
* Mouse control for the weapon wheel is replaced by joystick control (off-hand joystick).
* When weapon wheel is open the player movement is disabled.
* Option to make player invulnerable while the weapon wheel is open.
* Option to use Slow-Mo instead of freeze using Bullet-Time-X mod. Bullet-Time-X mod must be loaded before this mod.
* Weapon wheel description panel is replaced with onscreen messages when message option is enabled.

## How to Use

GZDoom 4.5 required.

1. open the menu by assigned key, or by next/previous weapon keys, if enabled in options
2. select the weapon with next/previous weapon keys, or with offhand controller joystick (wheel only)

## Features

- Different representations: blocks, wheel, plain text
- Press Fire key to select and Alt Fire key to cancel
- Color and scale options
- Behavior options
- Multiplayer compatible
- Reaction to number keys
- extras.wad icon support for vanilla weapons
- Inventory item selection

## Compatibility Issues

- [PyWeaponWheel VR](https://github.com/iAmErmac/PyWeaponWheel-VR)
  overrides time freezing/slow-mo/invulnerability. If you are using both mods and want to freeze time with Gearbox, set PyWeaponWheel's option "Freeze when wheel is open" (`py_weaponwheel_freeze` CVar) to Off.

  Note that PyWeaponWheel may be built in some mods, for example in Project Brutality. The solution is the same: disable time PyWeaponWheel's time freezing.

## Known Issues

- Weapon icons in wheel aren't affected by "HUD preserves aspect ration" option.
- Anything other than monsters and proectiles will not freeze when the weapon wheel is open including decorative actors, ACS scripts and platforms/lifts.
- When loaded after Bullet-Time-X but slow-mo not enabled, opening the weapon wheel will reset adrenaline for Bullet Time. In that case use an alternate slow-mo mod like [SlomoBulletTime Ultimate](https://www.moddb.com/addons/slomobullettime-ultimate-r3)

## Planned

- Patches for weapon icon adjustments
- More representations
- Moving weapon between slots and changing order

## Note for Weapon Mod Authors

If you want Gearbox to support your mod out of the box, assign
Inventory.AltHudIcon for your weapons! Tag property is also nice to have.

## License

- code: [GPLv3](copying.txt)

## Acknowledgments

- Thanks to kadu522 for general help and support.
- Blocky view is designed to resemble the weapon menu from Half-Life by Valve.
- Thanks to Marrub for [ZScriptDoc](https://github.com/marrub--/zdoom-doc).
- Thanks to Talon1024 for help with time freezing option.
- Thanks to Player701 for help with key event processing code.
- Thanks to KeksDose for a concept of VM abort handler.
- Thanks to DrPyspy for allowing to use mouse input code from PyWeaponWheel.
- Thanks to Carrascado for bug fixes and new features.
- Thanks to Accensus, Proydoha, mamaluigisbagel, TheRailgunner, Captain J,
  Enjay, StroggVorbis, krutomisi, Cutmanmike, StraightWhiteMan, JohnDoe8, HDV,
  Zhs2 and Apollucas for feature suggestions.
- Thanks to Accensus, Proydoha, mamaluigisbagel, Ac!d, wildweasel,
  Dark-Assassin, rparhkdtp, Samarai1000, Mr. Blazkowicz, lucker42, spectrefps,
  Someone64, Lippeth, JMartinez9820, generic name guy and sebastianpanetta for
  bug reports.
- Thanks to generic name guy for providing brazilian portuguese localization.
- Thanks to Ermac for added alternate time freeze mode and codes to work with Bullet-Time-X mod
- See also [credits list](credits.md).

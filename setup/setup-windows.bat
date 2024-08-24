@echo off
color 0a
cd ..
@echo on
echo Installing dependencies.
haxelib install hxcpp > nul
haxelib install lime 8.0.0
haxelib install openfl
haxelib install flixel 4.11.0
haxelib run lime setup flixel
haxelib run lime setup         
haxelib remove flixel-addons
haxelib remove flixel-tools
haxelib remove flixel-ui
haxelib install flixel-tools
haxelib install flixel-ui
haxelib install flixel-addons 2.9.0
haxelib install tjson
haxelib install hxjsonast
haxelib install hxCodec 2.5.1
haxelib install linc_luajit
haxelib install hscript
haxelib git hscript-ex https://github.com/ianharrigan/hscript-ex
haxelib git discord_rpc https://github.com/Aidan63/linc_discord-rpc
haxelib git hxvm-luajit https://github.com/nebulazorua/hxvm-luajit
haxelib git faxe https://github.com/uhrobots/faxe
haxelib git polymod https://github.com/larsiusprime/polymod.git
haxelib install hxcpp-debug-server
haxelib install newgrounds
haxelib install away3d
echo Finished!
pause

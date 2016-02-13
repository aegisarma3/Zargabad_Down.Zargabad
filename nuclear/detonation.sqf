private ["_object", "_xpos", "_ypos"];

_object = _this select 0;
_xpos = getpos _object select 0;
_ypos = getpos _object select 1;
call compile preprocessfile "nuclear\config.sqf";

[_object] execvm "nuclear\script\destroy.sqf";

[_xpos, _ypos] execvm "nuclear\script\escape.sqf";

[] execVM "nuclear\script\athmo.sqf";

sleep 2;

[_xpos, _ypos] execvm "nuclear\script\glare.sqf";
[_xpos, _ypos] execvm "nuclear\script\light.sqf";
[_xpos, _ypos] exec "nuclear\script\blast_1.sqs";
[_xpos, _ypos] exec "nuclear\script\blast1.sqs";
[_xpos, _ypos] exec "nuclear\script\hat.sqs";
[_xpos, _ypos] execvm "nuclear\script\ears.sqf";
[_xpos, _ypos] execvm "nuclear\script\aperture.sqf";

sleep 0.5;
[_xpos, _ypos] exec "nuclear\script\hatnod.sqs";
[_xpos, _ypos] exec "nuclear\script\blast1.sqs";
[_xpos, _ypos] execvm "nuclear\script\damage.sqf";

[_xpos, _ypos] exec "nuclear\script\ring1.sqs";
sleep 0.5;
[_xpos, _ypos] exec "nuclear\script\ring2.sqs";

[_xpos, _ypos] exec "nuclear\script\blast2.sqs";
sleep 0.4;
[_xpos, _ypos] exec "nuclear\script\blast3.sqs";

sleep 5;
[_xpos, _ypos] execvm "nuclear\script\heartbeat.sqf";

sleep 60;

sleep 10;
[_xpos, _ypos] execvm "nuclear\script\dust.sqf";
[_xpos, _ypos] execvm "nuclear\script\snow.sqf";
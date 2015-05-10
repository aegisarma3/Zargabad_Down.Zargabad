// This file is part of Zenophon's ArmA 3 Co-op Mission Framework
// This file is released under Creative Commons Attribution-NonCommercial-NoDerivatives 4.0 International (CC BY-NC-ND 4.0)
// See Legal.txt

#include "Zen_StandardLibrary.sqf"
#include "Zen_FrameworkLibrary.sqf"

_Zen_stack_Trace = ["Zen_OrderAircraftPatrol", _this] call Zen_StackAdd;
private ["_vehicleArray", "_movecenter", "_blackList", "_maxx", "_speedMode", "_heliHeight", "_mpos", "_heliDirToLand", "_mposCorrected", "_vehDist", "_limitAngles", "_cleanupDead", "_crewGroupArray", "_crew"];

if !([_this, [["ARRAY", "OBJECT"], ["ARRAY", "OBJECT", "GROUP", "STRING"], ["ARRAY", "SCALAR"], ["ARRAY", "SCALAR"], ["STRING"], ["SCALAR"], ["BOOL"]], [["OBJECT", "ARRAY"], [], ["STRING"], ["SCALAR"]], 2] call Zen_CheckArguments) exitWith {
    call Zen_StackRemove;
};

_vehicleArray = [(_this select 0)] call Zen_ConvertToObjectArray;
_movecenter = _this select 1;

if (typeName _vehicleArray != "ARRAY") then {
    _vehicleArray = [_vehicleArray];
};

_blackList = [];
_maxx = 1000;
_speedMode = "normal";
_heliHeight = 75;
_limitAngles = [0, 360];

if !(typeName _movecenter == "String") then {
    if (count _this > 2) then {
        _maxx = _this select 2;
    };
} else {
    if (markerShape _movecenter == "ICON") then {
        _movecenter = [_movecenter] call Zen_ConvertToPosition;
        if (count _this > 2) then {
            _maxx = _this select 2;
        };
    } else {
        if (count _this > 2) then {
            _blackList = _this select 2;
        };
    };
};

if (count _this > 3) then {
    _limitAngles = _this select 3;
};

if (count _this > 4) then {
    _speedMode = _this select 4;
};

if (count _this > 5) then {
    _heliHeight = _this select 5;
};

ZEN_STD_Parse_GetArgumentDefault(_cleanupDead, 6, false)

_vehicleArray = [([_vehicleArray] call Zen_ConvertToObjectArray)] call Zen_ArrayRemoveDead;
_crewGroupArray = [];

{
    private "_veh";
    _veh = _x;
    _mpos = [0,0,0];
    _crewGroupArray pushBack (group driver _veh);

    if (typeName _movecenter == "String") then {
        _mpos = [_movecenter, 0,_blackList, 1, 0, _limitAngles] call Zen_FindGroundPosition;
    } else {
        _vehDist = [_veh, _movecenter] call Zen_Find2dDistance;
        _mpos = [_movecenter, [0, _maxx], [], 1, 0, _limitAngles, 0, [1, _veh, _vehDist]] call Zen_FindGroundPosition;
    };

    _heliDirToLand = [_veh,_mpos] call Zen_FindDirection;
    _mposCorrected = [_mpos, 100, _heliDirToLand, "trig"] call Zen_ExtendPosition;

    _veh move _mposCorrected;
    _veh flyInHeight _heliHeight;
    _veh setBehaviour "aware";
    _veh setCombatMode "Red";
    _veh setSpeedMode _speedMode;
} forEach _vehicleArray;

while {(count _vehicleArray != 0)} do {
    {
        if (isNull _x) then {
            _vehicleArray set [_forEachIndex, 0];
            _crewGroupArray set [_forEachIndex, 0];
        } else {
            private "_veh";
            _veh = _x;
            if (!(alive _veh) || (({alive _x} count crew _veh) == 0)) then {
                _vehicleArray set [_forEachIndex, 0];
                _crew = _crewGroupArray select _forEachIndex;
                _crewGroupArray set [_forEachIndex, 0];
                if (_cleanupDead) then {
                    0 = [_veh, _crew] spawn {
                        sleep 60;
                        deleteVehicle (_this select 0);
                        {
                            deleteVehicle _x;
                        } forEach units (_this select 1);
                    };
                };
            } else {
                if ([_veh] call Zen_IsReady) then {
                    _mpos = [0,0,0];
                    if (typeName _movecenter == "String") then {
                        _mpos = [_movecenter, 0,_blackList, 1, 0, _limitAngles] call Zen_FindGroundPosition;
                    } else {
                        _vehDist = [_veh, _movecenter] call Zen_Find2dDistance;
                        _mpos = [_movecenter, [0, _maxx], [], 1, 0, _limitAngles, 0, [1, _veh, _vehDist]] call Zen_FindGroundPosition;
                    };

                    _mposCorrected = [_veh, _mpos, 100] call Zen_ExtendRay;
                    _veh move _mposCorrected;
                    _veh flyInHeight _heliHeight;
                    _veh setBehaviour "aware";
                    _veh setCombatMode "Red";
                    _veh setSpeedMode _speedMode;
                };
            };
        };
    } forEach _vehicleArray;
    sleep 10;
    0 = [_vehicleArray, 0] call Zen_ArrayRemoveValue;
    0 = [_crewGroupArray, 0] call Zen_ArrayRemoveValue;
};

call Zen_StackRemove;
if (true) exitWith {};

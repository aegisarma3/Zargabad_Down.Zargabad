// This file is part of Zenophon's ArmA 3 Co-op Mission Framework
// This file is released under Creative Commons Attribution-NonCommercial-NoDerivatives 4.0 International (CC BY-NC-ND 4.0)
// See Legal.txt

#include "Zen_StandardLibrary.sqf"
#include "Zen_FrameworkLibrary.sqf"
#define RNG(ARR) ([(ARR select 0), (ARR select 1)] call Zen_FindInRange)

_Zen_stack_Trace = ["Zen_InvokeFireSupport", _this] call Zen_StackAdd;
private ["_firePosition", "_nameString", "_templateArray", "_roundType", "_round", "_guided", "_guidanceObject", "_guidanceType", "_artyVehicle", "_roundPosition", "_temp_roundsPerSalvo", "_temp_salvos", "_temp_timePerRound", "_temp_timePerSalvo", "_effectShapeData", "_temp_salvoDrift", "_artyVehicleClass", "_artyWeaponClass", "_effectMarker"];

if !([_this, [["VOID"], ["STRING"], ["OBJECT"], ["STRING"]], [], 2] call Zen_CheckArguments) exitWith {
    call Zen_StackRemove;
};

_firePosition = [(_this select 0)] call Zen_ConvertToPosition;
_nameString = _this select 1;

_templateArray = [_nameString] call Zen_GetFireSupportData;

if (count _templateArray == 0) exitWith {
    0 = ["Zen_InvokeFireSupport", "Given template does not exist", _this] call Zen_PrintError;
    call Zen_StackPrint;
    call Zen_StackRemove;
};

_roundType = _templateArray select 0;
_temp_roundsPerSalvo = _templateArray select 1;
_temp_salvos = _templateArray select 2;
_temp_timePerRound = _templateArray select 3;
_temp_timePerSalvo = _templateArray select 4;
_effectShapeData = _templateArray select 5;
_temp_salvoDrift = _templateArray select 6;
_guided = _templateArray select 7;

if (_guided) then {
    _guidanceObject = _this select 2;
    _guidanceType = "designator";
    if (count _this > 3) then {
        _guidanceType = toLower (_this select 3);
    };
};

_effectMarker = [_firePosition, "", "colorBlack", [_effectShapeData select 0, _effectShapeData select 1], _effectShapeData select 2, _effectShapeData select 3, 0] call Zen_SpawnMarker;
_quantAngles = [_effectMarker, 0, 360] call Zen_QuantizeAngles;

sleep RNG(_temp_timePerSalvo);

for "_i" from 1 to RNG(_temp_salvos) do {
    sleep RNG(_temp_timePerSalvo);
    _firePosition = ZEN_FMW_Math_RandomPoint(_firePosition, RNG(_temp_salvoDrift));

    for "_j" from 1 to RNG(_temp_roundsPerSalvo) do {
        sleep RNG(_temp_timePerRound);
        _roundPosition = [_effectMarker, _quantAngles] call Zen_FindPositionPoly;

        if !([_roundType, ["Sh_155mm_AMOS", "Sh_82mm_AMOS", "R_230mm_HE"]] call Zen_ValueIsInArray) then {
            _round = [_roundPosition, _roundType, 1000, 0, true] call Zen_SpawnVehicle;
            _round setVelocity [0, 0, -200];
            0 = _round spawn {
                while {alive _this} do {
                    _this setVectorDirAndUp [[0, 0, -1], [0, 1, 0]];
                };
            };
        } else {
            switch (toLower _roundType) do {
                case "sh_155mm_amos": {
                    _artyVehicleClass = "B_MBT_01_arty_F";
                    _artyWeaponClass = "mortar_155mm_amos";
                };
                case "sh_82mm_amos": {
                    _artyVehicleClass = "B_Mortar_01_F";
                    _artyWeaponClass = "mortar_82mm";
                };
                case "r_230mm_he": {
                    _artyVehicleClass = "B_MBT_01_mlrs_F";
                    _artyWeaponClass = "rockets_230mm_gat";
                };
            };

            _artyVehicle = [([[0,0,0], 50 + random 100, random 360] call Zen_ExtendPosition), _artyVehicleClass, 100, 0, true] call Zen_SpawnVehicle;
            0 = [_artyVehicle] call Zen_SpawnVehicleCrew;
            hideObject _artyVehicle;
            _artyVehicle allowDamage false;

            Zen_Fire_Support_Round_Local = objNull;
            _artyVehicle addEventhandler ["fired", {
                Zen_Fire_Support_Round_Local = _this select 6;
            }];
            _artyVehicle fire _artyWeaponClass;

            waitUntil {
                !(isNull Zen_Fire_Support_Round_Local)
            };
            _round = Zen_Fire_Support_Round_Local;

            ZEN_STD_OBJ_DeleteVehCrew(_artyVehicle)
            0 = [_round, _roundPosition, 1000, [0, 0, -200], 0, false] call Zen_TransformObject;
            0 = _round spawn {
                while {alive _this} do {
                    _this setVectorDirAndUp [[0, 0, -1], [0, 1, 0]];
                };
            };
        };

        if (_guided) then {
            if (_guidanceType == "designator") then {
                if (local _guidanceObject) then {
                    0 = [_round, _guidanceObject, _guidanceType] spawn Zen_GuideRound;
                } else {
                    Zen_MP_Closure_Packet = ["Zen_GuideRound", [_round, _guidanceObject, _guidanceType]];
                    (owner _guidanceObject) publicVariableClient "Zen_MP_Closure_Packet";
                };
            } else {
                0 = [_round, _guidanceObject, _guidanceType] spawn Zen_GuideRound;
            };
        };
    };
};

deleteMarker _effectMarker;
call Zen_StackRemove;
if (true) exitWith {};

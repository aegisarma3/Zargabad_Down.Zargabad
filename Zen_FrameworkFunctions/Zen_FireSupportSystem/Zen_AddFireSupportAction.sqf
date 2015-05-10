// This file is part of Zenophon's ArmA 3 Co-op Mission Framework
// This file is released under Creative Commons Attribution-NonCommercial-NoDerivatives 4.0 International (CC BY-NC-ND 4.0)
// See Legal.txt

#include "Zen_StandardLibrary.sqf"
#include "Zen_FrameworkLibrary.sqf"

_Zen_stack_Trace = ["Zen_AddFireSupportAction", _this] call Zen_StackAdd;
private ["_units", "_supportString", "_titleString", "_maxCalls", "_guideObj", "_guideType", "_templateArray", "_args"];

if !([_this, [["VOID"], ["STRING"], ["STRING"], ["SCALAR"], ["OBJECT"], ["STRING"], ["BOOL"]], [], 4] call Zen_CheckArguments) exitWith {
    call Zen_StackRemove;
};

_units = [(_this select 0)] call Zen_ConvertToObjectArray;
_supportString = _this select 1;
_titleString = _this select 2;
_maxCalls = _this select 3;

ZEN_STD_Parse_GetArgumentDefault(_guideObj, 4, (_units select 0))
ZEN_STD_Parse_GetArgumentDefault(_guideType, 5, "designator")

_templateArray = [_supportString] call Zen_GetFireSupportData;
if (count _templateArray == 0) exitWith {};

{
    if (isPlayer _x) then {
        _args = [_titleString, _supportString, _guideObj, _guideType, _maxCalls];
        ZEN_FMW_MP_REClient("Zen_AddFireSupportAction_AddCommMenu_MP", _args, _x)
    };
} forEach _units;

call Zen_StackRemove;
if (true) exitWith {};

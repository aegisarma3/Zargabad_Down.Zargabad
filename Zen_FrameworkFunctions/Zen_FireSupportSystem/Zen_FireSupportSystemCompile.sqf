// This file is part of Zenophon's ArmA 3 Co-op Mission Framework
// This file is released under Creative Commons Attribution-NonCommercial-NoDerivatives 4.0 International (CC BY-NC-ND 4.0)
// See Legal.txt

Zen_Fire_Support_Round_Local = objNull;
Zen_Fire_Support_Array_Global = [];
Zen_Fire_Support_Comm_ID_Array_Local = [];

Zen_AddFireSupportAction = compileFinal preprocessFileLineNumbers "Zen_FrameworkFunctions\Zen_FireSupportSystem\Zen_AddFireSupportAction.sqf";
Zen_CreateFireSupport = compileFinal preprocessFileLineNumbers "Zen_FrameworkFunctions\Zen_FireSupportSystem\Zen_CreateFireSupport.sqf";
Zen_GetFireSupportData = compileFinal preprocessFileLineNumbers "Zen_FrameworkFunctions\Zen_FireSupportSystem\Zen_GetFireSupportData.sqf";
Zen_GuideRound = compileFinal preprocessFileLineNumbers "Zen_FrameworkFunctions\Zen_FireSupportSystem\Zen_GuideRound.sqf";
Zen_InvokeFireSupport = compileFinal preprocessFileLineNumbers "Zen_FrameworkFunctions\Zen_FireSupportSystem\Zen_InvokeFireSupport.sqf";
Zen_InvokeFireSupportAction = compileFinal preprocessFileLineNumbers "Zen_FrameworkFunctions\Zen_FireSupportSystem\Zen_InvokeFireSupportAction.sqf";
Zen_RemoveFireSupport = compileFinal preprocessFileLineNumbers "Zen_FrameworkFunctions\Zen_FireSupportSystem\Zen_RemoveFireSupport.sqf";
Zen_RemoveFireSupportAction = compileFinal preprocessFileLineNumbers "Zen_FrameworkFunctions\Zen_FireSupportSystem\Zen_RemoveFireSupportAction.sqf";
Zen_UpdateFireSupport = compileFinal preprocessFileLineNumbers "Zen_FrameworkFunctions\Zen_FireSupportSystem\Zen_UpdateFireSupport.sqf";

Zen_AddFireSupportAction_AddCommMenu_MP = {
    if (!(isDedicated) && {hasInterface}) then {
        _commMenuID = [(_this select 5), "Zen_FireSupport", (_this select 0), (format ["0 = [_pos, '%1', %2, '%3'] call Zen_InvokeFireSupportAction;", (_this select 1), (_this select 2), (_this select 3)])] call BIS_fnc_AddCommMenuItem;
        Zen_Fire_Support_Comm_ID_Array_Local pushBack [(_this select 1), _commMenuID, 0, (_this select 4)];
    };
};

Zen_InvokeFireSupportAction_SideChat_MP = {
    if (isDedicated || !hasInterface) exitWith {};
    private ["_unit", "_side", "_group", "_pos", "_sentTime"];

    _unit = _this select 0;
    _pos = _this select 1;
    _sentTime = _this select 2;

    _side = side _unit;

    if (side player != _side) exitWith {};

    _group = toArray str group _unit;
    _group set [0, -1];
    _group set [1, -1];
    _group = toString (_group - [-1]);

    _unit sideChat format ["HQ, %1, Request fire support at grid %2, over.", _group, (mapGridPosition _pos)];
    sleep 7;
    [_side, "base"] sideChat format ["%1, HQ, Fire support inbound in %2 seconds, out.", _group, _sentTime];
    if (true) exitWith {};
};

if (true) exitWith {};

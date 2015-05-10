// This file is part of Zenophon's ArmA 3 Co-op Mission Framework
// This file is released under Creative Commons Attribution-NonCommercial-NoDerivatives 4.0 International (CC BY-NC-ND 4.0)
// See Legal.txt

_Zen_stack_Trace = ["Zen_InvokeFireSupportAction", _this] call Zen_StackAdd;
private ["_nameString", "_pos", "_fireSupportTime", "_marker", "_guideType", "_guideObj", "_templateData", "_salvoTime", "_menuIDArrayIndex", "_menuIDArrayValue"];

if !([_this, [["ARRAY"], ["STRING"], ["OBJECT"], ["STRING"]], [["SCALAR"]], 4] call Zen_CheckArguments) exitWith {
    call Zen_StackRemove;
};

_pos = _this select 0;
_nameString = _this select 1;
_guideObj = _this select 2;
_guideType = _this select 3;

_templateData = [_nameString] call Zen_GetFireSupportData;
_salvoTime = _templateData select 4;

_fireSupportTime = 2 * ([_salvoTime select 0, _salvoTime select 1] call Zen_FindInRange);

0 = [player, _pos, _fireSupportTime] spawn Zen_InvokeFireSupportAction_SideChat_MP;

if (isMultiplayer) then {
    Zen_MP_Closure_Packet = ["Zen_InvokeFireSupportAction_SideChat_MP", [player, _pos, _fireSupportTime]];
    publicVariable "Zen_MP_Closure_Packet";
};

if (isMultiplayer && {!isServer}) then {
    Zen_MP_Closure_Packet = ["Zen_InvokeFireSupport", [_pos, _nameString, _guideObj, _guideType]];
    publicVariableServer "Zen_MP_Closure_Packet";
} else {
    0 = [_pos, _nameString, _guideObj, _guideType] spawn Zen_InvokeFireSupport;
};

_marker = [_pos, "Fire Support Target", "colorRed", [0.6, 0.6], "mil_destroy", 45, 0] call Zen_SpawnMarker;
0 = [_marker, player] call Zen_ShowHideMarkers;

0 = _marker spawn {
    sleep 90;
    deleteMarker _this;
};

_index = 0;
_commArray = [];
{
    if ((_x select 0) isEqualTo _nameString) exitWith {
        _index = _forEachIndex;
        _commArray = _x;
    };
} forEach Zen_Fire_Support_Comm_ID_Array_Local;

_commArray set [2, ((_commArray select 2) + 1)];

if ((_commArray select 2) >= (_commArray select 3) && {((_commArray select 3) != -1)}) then {
    0 = [player, (_commArray select 1)] spawn BIS_fnc_RemoveCommMenuItem;
    0 = [Zen_Fire_Support_Comm_ID_Array_Local, _index] call Zen_ArrayRemoveIndex;
};

call Zen_StackRemove;
if (true) exitWith {};

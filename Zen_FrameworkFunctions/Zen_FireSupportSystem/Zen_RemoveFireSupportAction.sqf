// This file is part of Zenophon's ArmA 3 Co-op Mission Framework
// This file is released under Creative Commons Attribution-NonCommercial-NoDerivatives 4.0 International (CC BY-NC-ND 4.0)
// See Legal.txt

#include "Zen_StandardLibrary.sqf"

_Zen_stack_Trace = ["Zen_RemoveFireSupportAction", _this] call Zen_StackAdd;
private ["_nameString", "_index", "_sendPacket", "_commMenuID"];

if !([_this, [["STRING"], ["BOOL"]], [], 1] call Zen_CheckArguments) exitWith {
    call Zen_StackRemove;
};

_nameString = _this select 0;
ZEN_STD_Parse_GetSetArgumentDefault(_sendPacket, 1, true, false)

while {true} do {
    _index = [Zen_Fire_Support_Comm_ID_Array_Local, _nameString, 0] call Zen_ArrayGetNestedIndex;
    if (_index == -1) exitWith {};

    _commMenuID = (Zen_Fire_Support_Comm_ID_Array_Local select _index) select 1;
    0 = [player, _commMenuID] spawn BIS_fnc_RemoveCommMenuItem;

    0 = [Zen_Fire_Support_Comm_ID_Array_Local, _index] call Zen_ArrayRemoveIndex;
};

if (isMultiplayer && {_sendPacket}) then {
    Zen_MP_Closure_Packet = ["Zen_RemoveFireSupportAction", _this];
    publicVariable "Zen_MP_Closure_Packet";
};

call Zen_StackRemove;
if (true) exitWith {};

// This file is part of Zenophon's ArmA 3 Co-op Mission Framework
// This file is released under Creative Commons Attribution-NonCommercial-NoDerivatives 4.0 International (CC BY-NC-ND 4.0)
// See Legal.txt

#include "Zen_StandardLibrary.sqf"
#include "Zen_FrameworkLibrary.sqf"

#define SLING_HEIGHT 11

_Zen_stack_Trace = ["Zen_OrderSlingLoad", _this] call Zen_StackAdd;
private ["_heli", "_cargo", "_endPos", "_h_arrived"];

if !([_this, [["OBJECT"], ["OBJECT"], ["VOID"]], [], 3] call Zen_CheckArguments) exitWith {
    call Zen_StackRemove;
};

_heli = _this select 0;
_cargo = _this select 1;
_endPos = [(_this select 2)] call Zen_ConvertToPosition;

if !(_heli canSlingLoad _cargo) exitWith {
    ZEN_FMW_Misc_ErrorExitVoid("Zen_OrderSlingLoad", "Given helicopter cannot sling-load given cargo")
};

_h_arrived = [_heli, _cargo, "normal", 30, true] spawn Zen_OrderHelicopterLand;

ZEN_STD_Code_WaitScript(_h_arrived)

sleep 2;
waitUntil {
    sleep 0.2;
    _heli setVelocity [0,0,-6];
    ((_heli distance _cargo) < SLING_HEIGHT)
};

_heli setVelocity [0,0,-1];
_heli setSlingLoad _cargo;

_heli flyInHeight 30;
sleep 4;
_h_arrived = [_heli, _endPos, "normal", 30, true] spawn Zen_OrderHelicopterLand;

ZEN_STD_Code_WaitScript(_h_arrived)

sleep 3;
waitUntil {
    sleep 0.2;
    _heli setVelocity [0,0,-6];
    (ZEN_STD_OBJ_ATLPositionZ(_heli) < SLING_HEIGHT)
};

_heli setVelocity [0,0,-1];
_heli setSlingLoad objNull;
_heli flyInHeight 30;
sleep 2;

call Zen_StackRemove;
if (true) exitWith {};

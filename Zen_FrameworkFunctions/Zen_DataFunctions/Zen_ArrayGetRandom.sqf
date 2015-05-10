// This file is part of Zenophon's ArmA 3 Co-op Mission Framework
// This file is released under Creative Commons Attribution-NonCommercial-NoDerivatives 4.0 International (CC BY-NC-ND 4.0)
// See Legal.txt

#include "Zen_StandardLibrary.sqf"

_Zen_stack_Trace = ["Zen_ArrayGetRandom", _this] call Zen_StackAdd;
private ["_array", "_returnElement"];

if !([_this, [["VOID"]], [], 1] call Zen_CheckArguments) exitWith {
    call Zen_StackRemove;
    ([])
};

_array = _this select 0;

if (typeName _array == "ARRAY") then {
    if (count _array == 0) then {
        _returnElement = [];
    } else {
        _returnElement = ZEN_STD_Array_RandElement(_array);
    };
} else {
    _returnElement = _array;
};

call Zen_StackRemove;
(_returnElement)

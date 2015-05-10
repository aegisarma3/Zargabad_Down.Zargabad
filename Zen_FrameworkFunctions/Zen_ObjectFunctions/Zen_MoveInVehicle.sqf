// This file is part of Zenophon's ArmA 3 Co-op Mission Framework
// This file is released under Creative Commons Attribution-NonCommercial-NoDerivatives 4.0 International (CC BY-NC-ND 4.0)
// See Legal.txt

#include "Zen_StandardLibrary.sqf"
#include "Zen_FrameworkLibrary.sqf"

#define RESET_MP_SYNCH_OBJ_VAR(U) \
    { \
        _args = ["setVariable", [_x, ["Zen_MoveInVehicle_IsSynchd_MP", 0, true]]]; \
        ZEN_FMW_MP_REClient("Zen_ExecuteCommand", _args, _x) \
    } forEach U;

#define WAITUNTIL_MP_RESET_SYNCH_OBJ_VAR(U) \
    waitUntil { \
        ({(_x getVariable ["Zen_MoveInVehicle_IsSynchd_MP", 1]) == 1} count U == 0) \
    };

#define WAITUNTIL_MP_MOVE_SYNCH_OBJ_VAR(U) \
    waitUntil { \
        ({(_x getVariable "Zen_MoveInVehicle_IsSynchd_MP") == 0} count U == 0) \
    };

_Zen_stack_Trace = ["Zen_MoveInVehicle", _this] call Zen_StackAdd;
private ["_unitsArray", "_vehicle", "_turrets", "_vehicleSlot", "_turretTypes", "_args"];

if !([_this, [["VOID"], ["OBJECT"], ["STRING"], ["ARRAY", "STRING"]], [[], [], [], ["STRING"]], 2] call Zen_CheckArguments) exitWith {
    call Zen_StackRemove;
};

_unitsArray = [(_this select 0)] call Zen_ConvertToObjectArray;
_vehicle = _this select 1;

_vehicleSlot = "cargo";

if (count _this > 2) then {
    _vehicleSlot = _this select 2;
};

_turretTypes = ["All"];
ZEN_STD_Parse_GetArgument(_turretTypes, 3)

if !(alive _vehicle) exitWith {
    0 = ["Zen_MoveInVehicle", "Given vehicle is destroyed or does not exist", _this] call Zen_PrintError;
    call Zen_StackPrint;
    call Zen_StackRemove;
};

switch (toLower _vehicleSlot) do {
    case "cargo": {
        if ((count _unitsArray) > ((ZEN_STD_OBJ_CountCargoSeats(_vehicle)) + (count ([_vehicle, "CargoFFV"] call Zen_GetTurretPaths)))) then {
            0 = ["Zen_MoveInVehicle", "Given vehicle does not have enough passenger positions to hold all of the given units", _this] call Zen_PrintError;
            call Zen_StackPrint;
        };

        _turrets = [_vehicle, "cargoFFV"] call Zen_GetTurretPaths;
        RESET_MP_SYNCH_OBJ_VAR(_unitsArray)
        WAITUNTIL_MP_RESET_SYNCH_OBJ_VAR(_unitsArray)

        {
            _args = [[_x], _vehicle, _turrets];
            ZEN_FMW_MP_REClient("Zen_MoveInVehicle_Turret_MP", _args, _x)
            WAITUNTIL_MP_MOVE_SYNCH_OBJ_VAR([_x])
        } forEach _unitsArray;

        _unitsArray = [_unitsArray, {(vehicle _this != _this)}] call Zen_ArrayFilterCondition;
        if (count _unitsArray > 0) then {
            {
                _args = [[_x], _vehicle];
                ZEN_FMW_MP_REClient("Zen_MoveInVehicle_Cargo_MP", _args, _x)
                WAITUNTIL_MP_MOVE_SYNCH_OBJ_VAR([_x])
            } forEach _unitsArray;
        };
    };
    case "driver": {
        if (count _unitsArray > 1) then {
            0 = ["Zen_MoveInVehicle", "Two or more units cannot be in the driver seat", _this] call Zen_PrintError;
            call Zen_StackPrint;
        };

        _args = [(_unitsArray select 0), _vehicle];
        ZEN_FMW_MP_REClient("Zen_MoveInVehicle_Driver_MP", _args, (_unitsArray select 0))
    };
    case "turret": {
        _turrets = [_vehicle, _turretTypes] call Zen_GetTurretPaths;
        {
            _args = [[_x], _vehicle, _turrets];
            ZEN_FMW_MP_REClient("Zen_MoveInVehicle_Turret_MP", _args, _x)
            WAITUNTIL_MP_MOVE_SYNCH_OBJ_VAR([_x])
        } forEach _unitsArray;
    };
    case "all": {
        if (count _unitsArray > 0) then {
            RESET_MP_SYNCH_OBJ_VAR([(_unitsArray select 0)])
            WAITUNTIL_MP_RESET_SYNCH_OBJ_VAR([(_unitsArray select 0)])

            _args = [(_unitsArray select 0), _vehicle];
            ZEN_FMW_MP_REClient("Zen_MoveInVehicle_Driver_MP", _args, (_unitsArray select 0))
            WAITUNTIL_MP_MOVE_SYNCH_OBJ_VAR([(_unitsArray select 0)])

            _unitsArray = [_unitsArray, {(vehicle _this != _this)}] call Zen_ArrayFilterCondition;
            if (count _unitsArray > 0) then {
                _turrets = [_vehicle, _turretTypes] call Zen_GetTurretPaths;

                RESET_MP_SYNCH_OBJ_VAR(_unitsArray)
                WAITUNTIL_MP_RESET_SYNCH_OBJ_VAR(_unitsArray)

                {
                    _args = [[_x], _vehicle, _turrets];
                    ZEN_FMW_MP_REClient("Zen_MoveInVehicle_Turret_MP", _args, _x)
                    WAITUNTIL_MP_MOVE_SYNCH_OBJ_VAR([_x])
                } forEach _unitsArray;

                _unitsArray = [_unitsArray, {(vehicle _this != _this)}] call Zen_ArrayFilterCondition;
                if (count _unitsArray > 0) then {
                    {
                        _args = [[_x], _vehicle];
                        ZEN_FMW_MP_REClient("Zen_MoveInVehicle_Cargo_MP", _args, _x)
                        WAITUNTIL_MP_MOVE_SYNCH_OBJ_VAR([_x])
                    } forEach _unitsArray;
                };
            };
        };
    };
};

call Zen_StackRemove;
if (true) exitWith {};

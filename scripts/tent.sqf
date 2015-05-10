[-1,{
    waitUntil {!isNull findDisplay 46};
    findDisplay 46 displayAddEventHandler ["KeyDown", {
        if (_this select 1 in actionKeys "Gear") then [{
            _tents = nearestObjects [
                player modelToWorld [0,2,0], ["Land_TentA_F"], 2
            ];
            if (count _tents > 0) then [{
                _tent = _tents select 0;
                _gwh = _tent getVariable ["_gwh", objNull];
                if (isNull _gwh) then {
                    _gwh = createVehicle [
                        "GroundWeaponHolder", [0,0,0], [], 0, "NONE"
                    ];
                    _gwh attachTo [_tent, [0,0,0]];
                    _gwh setVectorUp vectorUp _tent;
                    _tent setVariable ["_gwh", _gwh, true];
                    detach _gwh;
                };
                player action ["Gear", _gwh];
                true
            },{false}];
        },{false}];
    }];
}] call CBA_fnc_globalExecute;
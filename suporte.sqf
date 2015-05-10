if (!(isNil "CUL_DROP_USED")) exitWith {cutText ["Supply drop not available","PLAIN"]; [player,CUL_DROP_NR] call BIS_fnc_removeCommMenuItem;};
CUL_DROP_USED = true; publicVariable "CUL_DROP_USED";
[player,CUL_DROP_NR] call BIS_fnc_removeCommMenuItem;
_callsign = "Shadow panther";
_spawnPoint = markerPos "dropStart";
_dropPos = position player;
_tmp = "B_TargetSoldier" createVehicle _spawnPoint;
_tmp2 = [_tmp, player] call BIS_fnc_relativeDirTo;
_ch = [_spawnPoint, _tmp2, "B_Heli_Transport_01_F", civilian] call BIS_fnc_spawnVehicle;
deleteVehicle _tmp;
_helo = _ch select 0;
_helo flyInHeight 80;
_grp = _ch select 2;
_grp setBehaviour "CARELESS";
_wp0 = _grp addwaypoint [_dropPos, 0];
_wp0 setwaypointtype "MOVE";
_wp0 setWaypointBehaviour "SAFE";
_wp0 setWaypointStatements ["!(isNil 'CUL_HELO_DROP')","(vehicle this) flyInHeight 250; "];
sleep 2;
[player sideChat format ["Requesting supply drop at the transmitted coordinates: %1, over.",mapGridPosition (getPosATL player)],"BIS_fnc_spawn",true,false] spawn BIS_fnc_MP;
//[[[s1,s2], "drop_req"],"CUL_playSound",true,false] spawn BIS_fnc_MP;
sleep 3+(random 2);
[systemChat  format ["%1: Affirmative, supplies en route, out.",_callsign],"BIS_fnc_spawn",true,false] spawn BIS_fnc_MP;
//[[[s1,s2], "drop_ack"],"CUL_playSound",true,false] spawn BIS_fnc_MP;
waitUntil {sleep 1;([getposatl _helo select 0,getposatl _helo select 1,0] distance [(getPosATL player) select 0, (getPosATL player) select 1,0]) < 100 };
sleep 3;
if (alive _helo && alive (driver _helo)) then {
    _tmpwnd = wind;
    setWind [0,0,true];
    _crate = createVehicle [(["B_supplyCrate_F", "O_supplyCrate_F", "IG_supplyCrate_F","B_supplyCrate_F"] select ([WEST, EAST, RESISTANCE,CIVILIAN] find side player)),[0,0,3],[],0,"NONE"];
    _crate setPosATL [getPosATL _helo select 0, getPosATL _helo select 1,((getPosATL _helo select 2)-1)];
    _crate setVelocity [0,0,-1];
    _crate allowdamage false;
    _wp1 = _grp addwaypoint [_spawnPoint, 200];
    _wp1 setwaypointtype "MOVE";
    _wp1 setWaypointBehaviour "SAFE";
    _wp1 setWaypointStatements ["true","deleteVehicle (vehicle this); {deleteVehicle _x} forEach units this;"];
    sleep 2;
    CUL_HELO_drop = true;
    _chute = createVehicle[(["B_Parachute_02_F", "O_Parachute_02_F", "I_Parachute_02_F","B_Parachute_02_F"] select ([WEST, EAST, RESISTANCE,CIVILIAN] find side player)),[0,0,3],[],0,"FLY"];
    sleep 0.01;
    clearWeaponCargoGlobal _crate;
    clearMagazineCargoGlobal _crate;
    clearItemCargoGlobal _crate;
    _crate addWeaponCargoGlobal ["arifle_MX_pointer_F",4];
    _crate addItemCargoGlobal ["Medikit",10];
    _crate addItemCargoGlobal ["FirstAidKit",20];
    _ammo = [
        ["20Rnd_762x51_Mag",40],
        ["200Rnd_65x39_cased_Box",8],
        ["SmokeShellGreen",18],
        ["HandGrenade",10],
        ["30Rnd_65x39_caseless_mag_Tracer",60],
        ["1Rnd_HE_Grenade_shell",8],
        ["30Rnd_9x21_Mag",10],
        ["NLAW_F",4],
        ["SatchelCharge_Remote_Mag",2],
        ["16Rnd_9x21_Mag",20],
        ["LaserBatteries",2]
    ];
    {
        _crate addMagazineCargoGlobal [_x select 0,_x select 1];
    }forEach _ammo;
    if (!isNull _chute) then {
        _chute setPosATL [getPosATL _crate select 0, getPosATL _crate select 1,(getPosATL _crate select 2)];
        _crate attachTo [_chute, [0, 0, -1.3]];
    };
    waitUntil {sleep 0.3; getPosATL _crate select 2 < 500 };
    [systemChat format ["%1: The supplies have been dropped, out.",_callsign],"BIS_fnc_spawn",true,false] spawn BIS_fnc_MP;
    //[[[s1,s2], "drop_complete"],"CUL_playSound",true,false] spawn BIS_fnc_MP;
    waitUntil {sleep 0.3; getPosATL _crate select 2 < 300 };
    if ((alive driver _helo) && (alive _helo)) then {
        _flr = createVehicle["F_40mm_Cir",[0,0,100],[],0,"NONE"];
        sleep 0.01;
        _flr attachTo [_crate,[0,0,0.5]];
        waitUntil {position _crate select 2 < 0.5 || isNull _chute};
        detach _crate;
        _crate setPos [position _crate select 0, position _crate select 1, 0.1];
        _crate setVelocity [0,0,0];
        setWind [_tmpwnd select 0,_tmpwnd select 1,false];
        _crate allowdamage true;
        sleep 1;
        detach _flr;
        sleep 1;
        _flr setVelocity [random 1,random 1,-0.01];
        sleep 5;
        deleteVehicle _chute;
    };
}else{
    sleep 120;
    {deleteVehicle _x} forEach units _grp;
    deletevehicle _helo;
};
#include "Zen_FrameworkFunctions\Zen_InitHeader.sqf";

waitUntil { isServer || !isNull player };

enableSaving [false, false];


//execVM "Intro.sqf";

//[3, 500, 1200] execVM "MAD_traffic.sqf";


// MISSÃO AEGIS

_ObjectivePos = "VIP";

// Deixa o marker transparente
_ObjectivePos setMarkerAlpha 0;

_yourObjective = [_ObjectivePos, (group s1), BLUFOR, "POW", "rescue"] call Zen_CreateObjective;

// Seleciona o retorno do método como array e pega o valor do civil
_pow = (_yourObjective select 0) select 0;

// Posiciona o VIP na altura correta
_pow setPosATL (_pow modelToWorld[0,0,4.2]);


//NUKE codigo
CODEINPUT = [];
CODE = [(round(random 9)), (round(random 9)), (round(random 9)), (round(random 9)), (round(random 9)), (round(random 9))]; //6 digit code can be more or less
WIRE = ["BLUE", "WHITE", "YELLOW", "GREEN"] call bis_fnc_selectRandom;
DEFUSED = false;
ARMED = false;

codeHolder = [laptop1, laptop2, laptop3, laptop4, laptop5, laptop6, laptop7, laptop8] call BIS_fnc_selectRandom;
codeHolder addAction [("<t color='#E61616'>" + ("The Code") + "</t>"),"DEFUSE\searchAction.sqf","",1,true,true,"","(_target distance _this) < 3"];



// NUKE RELATED STUFF
/////////////////////////////////////////////////////////////////////////////////////////
mdh_nuke_destruction_zone   = 1000; // DESTRUCTION ZONE OF NUKE IN METERS, USE 0 TO DEACTIVATE
mdh_nuke_camshake           = 1;    // CAEMRASHAKE AT NUKEDETONATION 1=ON, 0=OFF
mdh_nuke_ash                = 1;    // ASH AFTER NUKEDETONATION 1=ON, 0=OFF
mdh_nuke_colorcorrection    = 1;    // COLLORCORRECTION AFTER NUKEDETONATION 1=ON, 0=OFF
////////////////////////////////////////////////////////////////////////////////////////



//MISSÃO NATO
if (isServer) then {
    [ west, "Task_Defuse", ["Encontrar e desarmar a o protótipo NUKE. ", "Neutralizar o protótipo NUKE.", "DEFUSE"],  objNull, true ] call BIS_fnc_taskCreate;
};


[] spawn {
    waitUntil {DEFUSED};
    ["Task_Defuse", "Succeeded"] call BIS_fnc_taskSetState;
    sleep 2;
//  ["end1", true] call BIS_fnc_endMission;
};

[] spawn {
    waitUntil {ARMED};
    ["Task_Defuse", "Failed"] call BIS_fnc_taskSetState;
    sleep 10;
    ["LOSER", false] call BIS_fnc_endMission;
};

diag_log format["Initialisation Completed"];

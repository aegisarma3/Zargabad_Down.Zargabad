waitUntil { isServer || !isNull player };

#include "core\modules\gridMarkers\functions\functions.sqf"
#include "core\modules\cacheScript\functions\cacheFunctions.sqf"
#include "core\modules\cacheScript\functions\cacheGetPositions.sqf"

#ifndef execNow
#define execNow call compile preprocessfilelinenumbers
#endif

//execVM "Intro.sqf";

// Desabilita o lixo do thermal image
0 = [] spawn {

    _layer = 85125; 
    while {true} do 
    { 
        if (currentVisionMode player == 2) then
            { 
                //hint "Porcaria de thermal";
                _layer  cutText ["ERR 0921F - No battery or insufficient memory","BLACK",-3];
                waituntil {currentVisionMode player != 2};
                _layer cutText ["", "PLAIN"];
            };
            sleep 0.5; 
    };
};


execNow "init-custom.sqf";
execNow "core\init.sqf";
execNow "support\init.sqf";
execNow "enemy\init.sqf";


enableSaving [false, false];

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



//Mission Task
if (isServer) then {
    [ units defuseGrp, "Task_Defuse", ["Encontrar e desarmar a o protótipo NUKE. ", "Neutralizar o protótipo NUKE.", "DEFUSE"],  TRUE ] call BIS_fnc_taskCreate;
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



execVM "Intro.sqf";

waitUntil { isServer || !isNull player };

enableSaving [false, false];

// addon scripts
[10, 500, 10]execVM "scripts\MAD_civilians.sqf";  //Ambientalização de civis
[3, 500, 500]execVM "scripts\MAD_traffic.sqf";    //Ambientalização de veiculos
[] spawn {call compile preprocessFileLineNumbers "scripts\EPD\Ied_Init.sqf";}; // IED

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
    [ west, "Task_Defuse", ["Encontrar e desarmar o protótipo NUKE. ", "Neutralizar o protótipo NUKE.", "DEFUSE"],  objNull, true ] call BIS_fnc_taskCreate;
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
//  ["LOSER", false] call BIS_fnc_endMission;
};

diag_log format["Initialisation Completed"];

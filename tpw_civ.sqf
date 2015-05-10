/* 
AMBIENT CIVILIAN SCRIPT
tpw 20130828

    - This script will gradually spawn civilians into houses within a specified radius of the player.
    - Civilian density (how many houses per civilian) can be specified.
    - Civilian density will halve at night.
    - Civilians will wander from house to house, with a specified number of waypoints
    - If a civilian is killed another will spawn 
    - Civs are removed if more than the specified radius from the player

Disclaimer: Feel free to use and modify this code, on the proviso that you post back changes and improvements so that everyone can benefit from them, and acknowledge the original author (tpw) in any derivative works.     

To use: 
1 - Save this script into your mission directory as eg tpw_civ.sqf
2 - Call it with 0 = [200,15,10] execvm "tpw_civ.sqf", where 200 = radius, 5 = number of waypoints, 10 = how many houses per civilian
*/

if (!isServer) exitWith {};

private ["_civlist","_sqname","_centree","_centrew","_centrec","_centrer"];

// READ IN VARIABLES
tpw_civ_radius = _this select 0;
tpw_civ_waypoints = _this select 1;
tpw_civ_density = _this select 2;

// VARIABLES
_civlist = ["CAF_AG_ME_CIV","CAF_AG_ME_CIV_02","CAF_AG_ME_CIV_03","CAF_AG_ME_CIV_04"];

tpw_civ_civarray = []; // array holding spawned civs
tpw_civ_civnum = 0; // number of civs to spawn

// CREATE AI CENTRES SO SPAWNED UNITS KNOW WHO'S AN ENEMY
private ["_centerW", "_centerE", "_centerR", "_centerC"];
_centerW = createCenter west;
_centerE = createCenter east;
_centerR = createCenter resistance;
_centerC = createCenter civilian;
west setFriend [east, 0];
east setFriend [west, 0];
east setFriend [resistance, 0];
east setFriend [civilian, 1];
civilian setFriend [east, 1];
resistance setFriend [east, 1];

// CREATE ARRAY OF EMPTY SQUADS TO SPAWN CIVS INTO
tpw_civ_civsquadarray = [];
for "_z" from 1 to 100 do
    {
    _sqname = creategroup civilian;
    tpw_civ_civsquadarray set [count tpw_civ_civsquadarray,_sqname];    
    };

// WAYPOINTS WITHIN DIFFERENT HOUSES
tpw_civ_fnc_waypoint = 
    {
    private ["_grp","_house","_m","_pos","_wp"];
    //Pick random position within random house
    _grp = _this select 0;
    _house = tpw_civ_houses select (floor (random (count tpw_civ_houses)));
    _m = 0; while { format ["%1", (_house) buildingPos _m] != "[0,0,0]" } do 
        {
    _m = _m + 1
        };
    _m = _m - 1;
    if (_m > 0) then 
        {
        _pos = floor random _m; 
        _wp = (_house buildingpos _pos);
        _grp addWaypoint [_wp, 0];
        };
    [_grp, (tpw_civ_waypoints - 1)] setWaypointType "CYCLE";    
    };

// SPAWN CIV INTO EMPTY GROUP
tpw_civ_fnc_civspawn =
    {
    private ["_civ","_spawnpos","_i","_ct","_sqname"];
    // Pick a random house for civ to spawn into
    _spawnpos = getposasl (tpw_civ_houses select (floor (random (count tpw_civ_houses))));
    _civ = _civlist select (floor (random (count _civlist)));

    //Find the first empty civ squad to spawn into
    for "_i" from 1 to (count tpw_civ_civsquadarray) do
        {
        _ct = _i - 1;        
        _sqname = tpw_civ_civsquadarray select _ct;
        if (count units _sqname == 0) exitwith 
            {
            //Spawn civ into empty group
            _civ createUnit [_spawnpos, _sqname];
            
            //Mark it as one of my ambient civs
            (leader _sqname) setvariable ["tpw_civ", 1];
            
            //Add it to the array of spawened civs
            tpw_civ_civarray set [count tpw_civ_civarray,leader _sqname];

            //Speed and behaviour
            _sqname setspeedmode "LIMITED";
            _sqname setBehaviour "SAFE";

            //Assign waypoints
            for "_i" from 1 to tpw_civ_waypoints do
                {
                0 = [_sqname] call tpw_civ_fnc_waypoint; 
                };
            [_sqname, (tpw_civ_waypoints - 1)] setWaypointType "CYCLE";
            };
        };
    };

// PERIODICALLY UPDATE POOL OF ENTERABLE HOUSES NEAR PLAYER, DETERMINE MAX CIVILIAN NUMBER
0 = [] spawn 
    {
    
    while {true} do
        { 
        private ["_allhouses"];
        _allhouses = nearestObjects [position vehicle player,["House"],tpw_civ_radius]; 
        tpw_civ_houses = []; 
            {
            if (((_x buildingpos 0) select 0) != 0) then 
                {
                tpw_civ_houses  set [count tpw_civ_houses,_x];
                }
            } foreach _allhouses;
        tpw_civ_civnum = floor ((count tpw_civ_houses) / tpw_civ_density);
        
        // Fewer civs at night
        if (daytime < 5 || daytime > 20) then 
            {
            tpw_civ_civnum = floor (tpw_civ_civnum / 2);
            };
        sleep 10;
        };
    };

    
// MAIN LOOP
while {true} do 
    {
    // Add civs 
    if (count tpw_civ_civarray < tpw_civ_civnum) then
        {
        0 = [] call tpw_civ_fnc_civspawn;
        };
        
        //Delete dead or distant civs (only if they are not visible to player)
        { 
        if !(alive _x) then 
            {
            tpw_civ_civarray = tpw_civ_civarray - [_x];    
            };
        if (_x distance vehicle player > tpw_civ_radius && (lineintersects [eyepos player,getposasl _x])) then
            {
            while {(count (waypoints( group _x))) > 0} do
                {
                 deleteWaypoint ((waypoints (group _x)) select 0);
                };
            tpw_civ_civarray = tpw_civ_civarray - [_x];    
            deletevehicle _x;
            };
        } foreach tpw_civ_civarray;    
    sleep random 10;    
    };
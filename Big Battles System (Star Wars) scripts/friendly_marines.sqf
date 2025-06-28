//Spawn a squad of friendly marines to engage occaisionally
_plyr_cnt_scaling = 4; 

_max_friendly_units = 66;

_tank_chance = 10;


while { true } do { 
    _plyr_cnt = count allPlayers;  
    _cur_enemy_count = count ((units west inAreaArray area_marker) select {!(dynamicSimulationEnabled (group _x)) && !(isPlayer _x)});   
    _floor_enemies = _max_friendly_units; 

    if (_cur_enemy_count >= (_floor_enemies min ((count allPlayers) * _plyr_cnt_scaling))) then {
        sleep floor(random [ 30, 45, 60 ]);
        continue;
    };
    private _position =  [nil, ["water"], {     
                    ({_x distance _this > 250} count allPlayers > 0) && ({_x distance _this <= 500} count allPlayers > 0);
    }] call BIS_fnc_randomPos;     

    if (_position isEqualTo [0, 0]) then {
        sleep 1;
        continue;
    };

    //USMC units to pick
    _commander_list = ["SWLB_clone_501stCaptain", "SWLB_clone_501stCommander", "SWLB_clone_501stLieutenant", "SWLB_clone_501stMarshalCommander", "SWLB_clone_501stDogma", "SWLB_clone_501stEcho", "SWLB_clone_501stFives", "SWLB_clone_501stHardcase", "SWLB_clone_501stJesse", "SWLB_clone_501stKix", "SWLB_clone_501stTup", "SWLB_CEE_Rex"];
    
    
    _unit_list = ["SWLB_clone_501stTrooper_assault", "SWLB_clone_501stTrooper_assault", "SWLB_clone_501stTrooper_assault", "SWLB_clone_501stTrooper_assault", "SWLB_clone_501stTrooper_assault", "SWLB_clone_501stTrooper_assault", "SWLB_clone_501stTrooper_assault", "SWLB_clone_501stAT", "SWLB_clone_501stTrooper", "SWLB_clone_501stSniper", "SWLB_clone_501stSG", "SWLB_clone_501stMedic", "SWLB_clone_501stRTO"];
    
    _unit_list_backpacks_ok = ["SWLB_clone_501stMedic", "SWLB_clone_501stRTO", "SWLB_clone_501stCaptain", "SWLB_clone_501stCommander", "SWLB_clone_501stLieutenant", "SWLB_clone_501stMarshalCommander", "SWLB_clone_501stDogma", "SWLB_clone_501stEcho", "SWLB_clone_501stFives", "SWLB_clone_501stHardcase", "SWLB_clone_501stJesse", "SWLB_clone_501stKix", "SWLB_clone_501stTup", "SWLB_CEE_Rex"];
    _grp = createGroup west;      
    
    _tank_list = ["3AS_Saber_M1_501", "3AS_Saber_M1Recon_501", "3AS_Saber_Super_501", "3AS_Saber_M1G_501", "3AS_ATTE_Base"];
    while {_cur_enemy_count < (_floor_enemies min (_plyr_cnt * _plyr_cnt_scaling))} do {
        if ((random 100) < _tank_chance) then {
            _tank = (selectRandom _tank_list) createVehicle _position;
            createVehicleCrew _tank;
            _grp = group (driver _tank);
            sleep 1;
        } else {
            for "_k" from 1 to 6 do {
                if (count (units _grp) == 0) then {
                    _unit_l = _grp createUnit [selectRandom _commander_list, _position, [], 0, "NONE"];
                    [_unit_l, selectRandom ["Male01ENGB", "Male02ENGB", "Male03ENGB"]] remoteExec ["setSpeaker", 0];
                    sleep 1;
                } else {
                    _chosen_unit = selectRandom _unit_list;
                    _unit_h = _grp createUnit [_chosen_unit, _position, [], 0, "NONE"];
                    [_unit_h, selectRandom ["Male01ENGB", "Male02ENGB", "Male03ENGB"]] remoteExec ["setSpeaker", 0];
                    sleep 1;
                    if !(_unit_h in _unit_list_backpacks_ok) then {
                        removeBackpack _unit_h;
                    };
                };

            };       
        };


        _wp = _grp addWaypoint [getPos (leader _grp), 0]; 
        _wp setWaypointType "SCRIPTED"; 
        _wp setWaypointScript "\z\lambs\addons\wp\scripts\fnc_wpRush.sqf";

        (leader _grp) spawn {
            waitUntil { sleep 10; ({(_x distance _this) < 1000} count allPlayers == 0)};
            _units = units group _this;
            {deleteVehicle _x} forEach _units;
        };
        
        _grp = createGroup west; 
        _position =  [nil, ["water"], {     
                        ({_x distance _this > 250} count allPlayers > 0) && ({_x distance _this <= 500} count allPlayers > 0);
        }] call BIS_fnc_randomPos;     

        while {(_position isEqualTo [0, 0])} do {
            sleep 1;
            _position =  [nil, ["water"], {     
                        ({_x distance _this > 250} count allPlayers > 0) && ({_x distance _this <= 500} count allPlayers > 0);
            }] call BIS_fnc_randomPos;
        };
        _cur_enemy_count = count ((units west inAreaArray area_marker) select {!(dynamicSimulationEnabled (group _x)) && !(isPlayer _x)});   
    
    };

    sleep floor(random [ 30, 45, 60 ]);  

};

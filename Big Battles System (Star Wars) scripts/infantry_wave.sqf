_plyr_cnt_scaling = 4; 
_max_units = 100;

_officer_units = ["WBK_B1_Officer", "WBK_B1_SquadLead"];

_infantry_units = ["WBK_B1_standart", "WBK_B1_Heavy"];
_sleep_time = 0.1;        

_b2_units = ["WBK_B2_Mod_GL", "WBK_B2_Mod_Standart"];

_b2_chance = 20;

_tank_chance = 10;
_tank_classes = ["3AS_Combat_Speeder_F", "3AS_AAT", "3AS_AAT_CIS", "3AS_Heavy_AAT_Defoliator_Red", "3AS_Advanced_DSD", "3AS_Heavy_AAT_Flamer_Red", "3AS_Hailfire_AT", "3AS_Hailfire_SAM"];

//CHANCE THAT B2 IS COMMANDO
_commando_chance = 20;
_commando_units = ["WBK_BX_Assasin_1", "WBK_BX_Assasin_Commander"];

while { true } do {
    _plyr_cnt = count allPlayers;  
    _cur_enemy_count = count ((units opfor inAreaArray area_marker) select {!(dynamicSimulationEnabled (group _x))});   
    _floor_enemies = _max_units; 
    if (_cur_enemy_count < _floor_enemies && (_cur_enemy_count < ((_plyr_cnt * _plyr_cnt_scaling) + 11))) then { 
        _rem_enemies = _floor_enemies - _cur_enemy_count; 
         _grp = createGroup east;     
        _min_spawn_dist = (dynamicSimulationDistance "Group") * (dynamicSimulationDistanceCoef "IsMoving") * 0.5; 
        
        
        //spawn dynamically
        _position =  [nil, ["water"], {     
                    ({_x distance _this > _min_spawn_dist} count allPlayers > 0) && ({_x distance _this <= _min_spawn_dist + 250} count allPlayers > 0);
        }] call BIS_fnc_randomPos;     
        
        while {_position isEqualTo [0, 0]} do {
            sleep 0.1;
            _position =  [nil, ["water"], {     
                        ({_x distance _this > _min_spawn_dist} count allPlayers > 0) && ({_x distance _this <= _min_spawn_dist + 250} count allPlayers > 0);
            }] call BIS_fnc_randomPos;     
        };

        _is_b2 = false;
        _is_commando = false;
        for "_i" from 1 to (_rem_enemies min (_plyr_cnt * _plyr_cnt_scaling)) do {
            //Chance to add a tank into the mix
            if ((random 100) < _tank_chance) then {
                //Find a new position to spawn tank
                _tank = (selectRandom _tank_classes) createVehicle _position;
                createVehicleCrew _tank;
                sleep 1;
                
                _wp = (group (driver _tank)) addWaypoint [getPos (driver _tank), 0];
                _wp setWaypointType "SCRIPTED"; 
                _wp setWaypointScript "\z\lambs\addons\wp\scripts\fnc_wpRush.sqf";

                _i = _i + 4;
                
                //Reset positions
                 _position =  [nil, ["water"], {     
                             ({_x distance _this > _min_spawn_dist} count allPlayers > 0) && ({_x distance _this <= _min_spawn_dist + 500} count allPlayers > 0);
                 }] call BIS_fnc_randomPos;     

                while {_position isEqualTo [0, 0]} do {
                    sleep 0.1;
                    _position =  [nil, ["water"], {     
                                ({_x distance _this > _min_spawn_dist} count allPlayers > 0) && ({_x distance _this <= _min_spawn_dist + 500} count allPlayers > 0);
                    }] call BIS_fnc_randomPos;     
                };
                /* CLEANUP SHOULD WORK WITHOUT THIS (NEW SCRIPT) but we'd have to fix this to not rely on a leader (who may die)
                (leader group (driver _tank)) spawn {
                    waitUntil { sleep 10; ({(_x distance _this) < 1000} count allPlayers == 0)};
                    _units = units group _this;
                    
                    {if ((vehicle _x) != _x) then deleteVehicle (vehicle _x); deleteVehicle _x;} forEach _units;
                };
                */
                 _is_b2 = false;
                continue;

            };
            if (!_is_b2 && (random 100) <= _b2_chance) then {
                _is_b2 = true;
                if ((random 100) <= _commando_chance) then {
                    _is_commando = true;
                };
            };
            if !(_is_b2) then {
                if (count (units _grp) == 0) then {
                    //Create officer
                    _unit = _grp createUnit [selectRandom _officer_units, [_position select 0, _position select 1, 0], [], 0, "NONE"];
                    sleep 1;
                } else {
                    //Create normal unit
                    _unit = _grp createUnit [selectRandom _infantry_units, [_position select 0, _position select 1, 0], [], 0, "NONE"];
                    sleep 1;
                };            
            } else {
                if !(_is_commando) then {
                    _unit = _grp createUnit [selectRandom _b2_units, [_position select 0, _position select 1, 0], [], 0, "NONE"];
                    sleep 1;
                    //Cleanup and give its own thing
                    _wp = _grp addWaypoint [getPos (leader _grp), 0];
                    _wp setWaypointType "SCRIPTED"; 
                    _wp setWaypointScript "\z\lambs\addons\wp\scripts\fnc_wpRush.sqf";
                    
                    /* CLEANUP SHOULD WORK WITHOUT THIS (NEW SCRIPT) but we'd have to fix this to not rely on a leader (who may die)
                    (leader _grp) spawn {
                        waitUntil { sleep 10; ({(_x distance _this) < 1000} count allPlayers == 0)};
                        _units = units group _this;
                        {deleteVehicle _x} forEach _units;
                    };
                    */
                    _grp = createGroup east;
                    _is_b2 = false;
                    continue
                } else {
                    _unit = _grp createUnit [selectRandom _commando_units, [_position select 0, _position select 1, 0], [], 0, "NONE"];
                    sleep 1;
                };
            };
            //Snip the group if full
            if (count (units _grp) >= _plyr_cnt_scaling) then {
                 { 
                    _wp = _x addWaypoint [getPos (leader _x), 0];
                    _wp setWaypointType "SCRIPTED"; 
                    _wp setWaypointScript "\z\lambs\addons\wp\scripts\fnc_wpRush.sqf";
                    
                    (leader _x) spawn {
                        waitUntil { sleep 10; ({(_x distance _this) < 1000} count allPlayers == 0)};
                        _units = units group _this;
                        {deleteVehicle _x} forEach _units;
                    };
                 } forEach [_grp]; 
                 _grp = createGroup east;
                 _position =  [nil, ["water"], {     
                             ({_x distance _this > _min_spawn_dist} count allPlayers > 0) && ({_x distance _this <= _min_spawn_dist + 500} count allPlayers > 0);
                 }] call BIS_fnc_randomPos;     

                while {_position isEqualTo [0, 0]} do {
                    sleep 0.1;
                    _position =  [nil, ["water"], {     
                                ({_x distance _this > _min_spawn_dist} count allPlayers > 0) && ({_x distance _this <= _min_spawn_dist + 500} count allPlayers > 0);
                    }] call BIS_fnc_randomPos;     
                };

                 _is_b2 = false;
                 _is_commando = false;
            };
        }; 
         { 
            _wp = _x addWaypoint [getPos (leader _x), 0];
            _wp setWaypointType "SCRIPTED"; 
            _wp setWaypointScript "\z\lambs\addons\wp\scripts\fnc_wpRush.sqf";
            
            /* CLEANUP SHOULD WORK WITHOUT THIS (NEW SCRIPT) but we'd have to fix this to not rely on a leader (who may die)
            (leader _x) spawn {
                waitUntil { sleep 10; ({(_x distance _this) < 1000} count allPlayers == 0)};
                _units = units group _this;
                {deleteVehicle _x} forEach _units;
            };
            */
         } forEach [_grp]; 
    }; 
    sleep floor(random [ 30, 45, 60 ]);    

}; 
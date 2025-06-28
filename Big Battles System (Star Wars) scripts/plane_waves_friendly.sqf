_max_planes = 3; 

_plane_classes = ["3AS_ARC_170_Blue", "3AS_BTLB_Bomber", "3as_V19_base", "3AS_ARC_170_Green", "3AS_ARC_170_Orange", "3AS_ARC_170_Yellow", "3AS_Z95_Republic", "3AS_Z95_Blue", "3AS_Z95_Green", "3AS_Z95_Orange", "3AS_Z95_Yellow", "lsd_heli_laatc", "lsd_heli_laati_ab", "lsd_heli_laati_transport", "3AS_Vwing_base"]; 

while {true } do { 
    _cur_plane_count = count ((units blufor inAreaArray area_marker) select {typeOf (vehicle _x) in _plane_classes}); 
    if (_cur_plane_count < _max_planes) then { 
        _plyr = selectRandom allPlayers; 

        _min_spawn_dist = (dynamicSimulationDistance "Group") * (dynamicSimulationDistanceCoef "IsMoving"); 
        _spawnpos = [_plyr, _min_spawn_dist + 250, _min_spawn_dist + 500, 1, 0, 20, 0, [], [getPos area_marker, getPos area_marker]] call BIS_fnc_findSafePos; 

        _veh = createVehicle [selectRandom _plane_classes, [_spawnpos select 0, _spawnpos select 1, 50], [], 0, "FLY"]; 
        createVehicleCrew _veh; 
        _grp = group driver _veh; 

        _wp = _grp addWaypoint [getPos area_marker, 0];  
        _wp setWaypointType "SCRIPTED";  
        _wp setWaypointScript "\z\lambs\addons\wp\scripts\fnc_wpRush.sqf";  
    }; 
     sleep floor(random [ 30, 60, 90 ]);    
};    
// --- Configuration ---
private _playerOpforProximity = 300; // Distance in meters to trigger OPFOR drop
private _playerBluforProximity = 150; // Distance in meters for player to be near BLUFOR AI
private _cooldownDuration = 300;     // in seconds

// --- Cooldown Timers ---
private _lastOpforDropTime = -_cooldownDuration;
private _lastBluforDropTime = -_cooldownDuration;

// --- Main Loop ---
while {true} do {
    // --- OPFOR Drop Check ---
    if ((time - _lastOpforDropTime) > _cooldownDuration) then {
        private _opforDropCalled = false;
        {
            private _player = _x;
            if (!_opforDropCalled) then {
                // Find the closest OPFOR unit to the player
                private _nearestOpfor = _player findNearestEnemy (getPos _player);

                if (!isNull _nearestOpfor && {_player distance _nearestOpfor < _playerOpforProximity}) then {
                    private _position = getPos _nearestOpfor;

                    // Call the OPFOR vehicle drop
                    [_position, "3AS_HMP_Transport", selectRandom ["3AS_Combat_Speeder_F", "3AS_AAT", "3AS_AAT_CIS", "3AS_Heavy_AAT_Defoliator_Red", "3AS_Advanced_DSD", "3AS_Heavy_AAT_Flamer_Red", "3AS_Hailfire_AT", "3AS_Hailfire_SAM"], true, 1000, [1, 364] call BIS_fnc_randomInt, false] call PHEN_ScifiSupportPlus_fnc_VehicleDrop;

                    // Set the cooldown and break the loop
                    _lastOpforDropTime = time;
                    _opforDropCalled = true;
                };
            };
        } forEach allPlayers;
    };

    // --- BLUFOR Drop Check ---
    if ((time - _lastBluforDropTime) > _cooldownDuration) then {
        private _bluforDropCalled = false;
        {
            private _player = _x;
            if (!_bluforDropCalled) then {
                // Find the closest OPFOR and BLUFOR units to the player
                private _nearestOpfor = _player findNearestEnemy (getPos _player);
                private _allBluforUnits = allUnits select {side _x == west && !isPlayer _x};
                private _nearestBlufor = objNull;
                private _shortestBluforDist = _playerBluforProximity;

                {
                    private _dist = _player distance _x;
                    if (_dist < _shortestBluforDist) then {
                        _shortestBluforDist = _dist;
                        _nearestBlufor = _x;
                    };
                } forEach _allBluforUnits;


                if (!isNull _nearestOpfor && {_player distance _nearestOpfor < _playerOpforProximity} && {!isNull _nearestBlufor}) then {
                    private _position = getPos _player; // Drop near the player in this case

                    // Call the BLUFOR vehicle drop
                    [_position, "lsd_heli_laatc", selectRandom ["3AS_Saber_M1_501", "3AS_Saber_M1Recon_501", "3AS_Saber_Super_501", "3AS_Saber_M1G_501", "3AS_ATTE_Base"], true, 1000, [1, 364] call BIS_fnc_randomInt, false] call PHEN_ScifiSupportPlus_fnc_VehicleDrop;

                    // Set the cooldown and break the loop
                    _lastBluforDropTime = time;
                    _bluforDropCalled = true;
                };
            };
        } forEach allPlayers;
    };
    
    //Special support call: dropping blaster volleys (mortars) on spotted enemies
    // --- Configuration ---
    private _hitChance = 0.5;
    private _minKnowledgeLevel = 1.0;

    // --- Script Logic ---
    private _players = allPlayers call BIS_fnc_arrayShuffle;
    private _barrageCalled = false; // Flag to stop after one barrage

    // Iterate through players
    {
        private _player = _x;

        // Skip if player is dead or not playable
        if (!alive _player || !isPlayer _player) then {continue;};

        private _opforSeesPlayer = false;
        // Check if any alive OPFOR unit knows about this player
        {
            private _opforUnit = _x;
            if ((side _opforUnit == opfor) && (alive _opforUnit) && (_opforUnit knowsAbout _player >= _minKnowledgeLevel)) then {
                _opforSeesPlayer = true;
                break;
            };
        } forEach allUnits; // Iterate through all units to find OPFOR

        // If seen by OPFOR, roll for a hit
        if (_opforSeesPlayer && (random 1 < _hitChance)) then {
            private _targetedPlayerPos = getPos _player;

            // Call the blaster volley function
            [_targetedPlayerPos, 100, 50] call PHAN_ScifiSupportPlus_fnc_SW_BlasterVolley_Red_HE;

            _barrageCalled = true; // Mark as called
            break; // Exit player loop
        };

    } forEach _players;
    

    //Final support: random enemy drop pods
    /* deprecated
    _drop_pods_chance = 3;
    if ((random 100) < _drop_pods_chance) then {
        _position = getPos (selectRandom allPlayers);
        [_position, [1, 364] call BIS_fnc_randomInt, [east], 3, 2, false, 2, true] call PHAN_ScifiSupportPlus_fnc_SW_Munificent_QRF;
    };
    */
    // Run the check every 30-60 seconds to not overload the server
    sleep ([30, 60] call BIS_fnc_randomInt);

};
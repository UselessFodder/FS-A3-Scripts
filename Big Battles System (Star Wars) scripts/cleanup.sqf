/*
Deletes OPFOR units, BLUFOR units, and empty vehicles
                 that are more than 1000 meters away from any player.
*/


while {true} do {
    // --- CONFIGURATION ---
    private _cleanupRadius = 1000;
    // Add the names of any triggers that should protect OPFOR units from deletion. 
    private _opforSafeTriggers = ["aurek_trigger", "besh_trigger", "cresh_trigger", "dorn_trigger"]; 
    // Name of the trigger that protects flying vehicles and their occupants.
    private _flyingVehicleSafeTrigger = "area_marker";
    // -------------------

    private _players = allPlayers;
    if (_players isEqualTo []) then { 
        sleep 30;
        continue;
    };

    // --- Get the trigger object for the flying vehicle safe zone ---
    private _safeAreaTrigger = missionNamespace getVariable [_flyingVehicleSafeTrigger, objNull];

    // --- Cleanup OPFOR Units --- 
    {
        private _unit = _x;
        private _vehicle = vehicle _unit; 
        private _isProtected = false;

        // Primary Protection: Unit is in a flying vehicle inside the safe trigger.
        private _isFlyingInSafeZone = (_vehicle != _unit) && (!isTouchingGround _vehicle) && (!isNull _safeAreaTrigger) && (_vehicle inArea _safeAreaTrigger);

        if (_isFlyingInSafeZone) then {
            _isProtected = true;
        } else {
            // Fallback Protection 1: Unit has dynamic simulation enabled. 
            if (dynamicSimulationEnabled _unit) then { 
                _isProtected = true;
            } else {
                // Fallback Protection 2: Unit is inside a standard OPFOR safe trigger. 
                {
                    private _trigger = missionNamespace getVariable [_x, objNull]; 
                    if (!isNull _trigger && (_unit inArea _trigger)) exitWith { 
                        _isProtected = true;
                    };
                } forEach _opforSafeTriggers;
            };
        };

        // If not protected by any condition, check distance and delete if far away. 
        if (!_isProtected) then {
            private _isFarFromAllPlayers = true;
            {
                if ((_unit distance2D _x) <= _cleanupRadius) then { 
                    _isFarFromAllPlayers = false;
                    break; 
                };
            } forEach _players;

            if (_isFarFromAllPlayers) then {
                deleteVehicle _unit; 
            };
        };
    } forEach (allUnits select {side _x == opfor});

    // --- Cleanup BLUFOR Units --- 
    {
        private _unit = _x;
        private _vehicle = vehicle _unit; 
        private _isProtected = false;

        // Primary Protection: Unit is in a flying vehicle inside the safe trigger.
        private _isFlyingInSafeZone = (_vehicle != _unit) && (!isTouchingGround _vehicle) && (!isNull _safeAreaTrigger) && (_vehicle inArea _safeAreaTrigger);

        if (_isFlyingInSafeZone) then {
            _isProtected = true;
        } else {
            // Fallback Protection: Unit has dynamic simulation enabled. 
            if (dynamicSimulationEnabled _unit) then { 
                _isProtected = true;
            };
        };

        if (!_isProtected) then {
            private _isFarFromAllPlayers = true;
            {
                if ((_unit distance2D _x) <= _cleanupRadius) then { 
                    _isFarFromAllPlayers = false;
                    break; 
                };
            } forEach _players;

            if (_isFarFromAllPlayers) then {
                deleteVehicle _unit; 
            };
        };
    } forEach (allUnits select {side _x == blufor});

    // --- Cleanup Empty Vehicles --- 
    {
        private _vehicle = _x;
        private _isProtected = false;

        // Primary Protection: Vehicle is flying inside the safe trigger.
        private _isFlyingInSafeZone = (!isTouchingGround _vehicle) && (!isNull _safeAreaTrigger) && (_vehicle inArea _safeAreaTrigger);

        if (_isFlyingInSafeZone) then {
            _isProtected = true;
        };

        // Any vehicle that is NOT protected (i.e., on the ground, or flying outside the safe zone)
        // is a candidate for deletion.
        if (!_isProtected) then {
            if (!dynamicSimulationEnabled _vehicle) then {
                if (count crew _vehicle == 0) then {
                    private _isFarFromAllPlayers = true;
                    {
                        if ((_vehicle distance2D _x) <= _cleanupRadius) then { 
                            _isFarFromAllPlayers = false;
                            break; 
                        };
                    } forEach _players;

                    if (_isFarFromAllPlayers) then {
                        deleteVehicle _vehicle; 
                    };
                };
            };
        };
    } forEach vehicles;

    sleep 30; 
};
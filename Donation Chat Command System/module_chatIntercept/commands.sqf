pvpfw_chatIntercept_allCommands = [
	[
		"help",
		{
			_commands = "";
			{
				_commands = _commands + (pvpfw_chatIntercept_commandMarker + (_x select 0)) + ", ";
			}forEach pvpfw_chatIntercept_allCommands;
			systemChat format["Available Commands: %1",_commands];
		}
	],
	[
		"donate",
		{
			_amnt = round (parseNumber (_this select 0));
            
            //Donation reward tiers
            if (_amnt <= 0) then {
                //Invalid
                systemChat "Invalid donation amount.";
            };
            if (_amnt >= 1 && _amnt <= 5) then {
                //Add tickets
                [btc_player_side, _amnt, btc_player_side] remoteExecCall ["btc_respawn_fnc_addTicket", 2];
            };
            if (_amnt >= 6 && _amnt <= 10) then {
                //Goat storm
                _goat_num = _amnt * 4;
                
                _max_goats = 100;
                _current_goats = count (agents select {typeOf (agent _x) isEqualTo "Goat_random_F" });
                
                if ((_max_goats - _current_goats) > 0) then {
                    _goats_to_spawn = _goat_num min (_max_goats - _current_goats);
                    
                    for "_i" from 1 to _goats_to_spawn do {
                        _goats = createAgent ["Goat_random_F", getPos player, [], 5, "CAN_COLLIDE"];
                    };
                } else {
                        systemChat "At max goat capacity!";
                };
            };
            if (_amnt >= 11 && _amnt <= 19) then {
                //Sandstorm
                _sandstorm_time = _amnt * 15;
                [[_sandstorm_time],"ROS_Sandstorm\scripts\ROS_Sandstorm.sqf"] remoteexec ["BIS_fnc_execVM",0];
            };
            if (_amnt >= 20 && _amnt <= 29) then {
                //Ammo Supply Drop
                _mag_types = [];
                {
                    _mag_types pushBack (currentMagazine _x);
                } forEach allPlayers;
                
                _pos = getPos player;
                _holder = createvehicle ["CargoNet_01_box_F", [_pos select 0, _pos select 1, 75], [], 0, "CAN_COLLIDE"];
                [objNull, _holder] call BIS_fnc_curatorobjectedited;
                
                {
                    _holder addItemCargoGlobal [_x, _amnt];
                } forEach _mag_types;
                systemChat "Ammo crate dropped.";

            };
            
            if (_amnt >= 30 && _amnt <= 39) then {
                //Medical Supply Drop
                _pos = getPos player;
                _holder = createvehicle ["CargoNet_01_box_F", [_pos select 0, _pos select 1, 75], [], 0, "CAN_COLLIDE"];
                [objNull, _holder] call BIS_fnc_curatorobjectedited;
                
                _holder addItemCargoGlobal ["ACE_fieldDressing", (count allPlayers) * 20];
                _holder addItemCargoGlobal ["ACE_bloodIV", (count allPlayers) * 1];
                _holder addItemCargoGlobal ["ACE_morphine", (count allPlayers) * 4];
                _holder addItemCargoGlobal ["ACE_tourniquet", (count allPlayers) * 2];
                _holder addItemCargoGlobal ["ACE_personalAidKit", 4];
                systemChat "Medical crate dropped.";
            };
            
            if (_amnt >= 40 && _amnt <= 49) then {
                //HUMRAT Supply Drop
                _pos = getPos player;
                _holder = createvehicle ["CargoNet_01_box_F", [_pos select 0, _pos select 1, 75], [], 0, "CAN_COLLIDE"];
                [objNull, _holder] call BIS_fnc_curatorobjectedited;
                
                _holder addItemCargoGlobal ["ACE_Humanitarian_Ration", _amnt];
                systemChat "Humanitarian ration crate dropped.";
            };
            
            if (_amnt >= 50 && _amnt <= 75) then {
                //MRAP Supply Drop
                _pos = getPos player;
                _holder = createvehicle ["CUP_B_RG31_M2_USA", [_pos select 0, _pos select 1, 75], [], 0, "CAN_COLLIDE"];
                [objNull, _holder] call BIS_fnc_curatorobjectedited;
                
                systemChat "MRAP dropped.";
            };
            if (_amnt >= 76 && _amnt <= 100) then {
                //Nemmara Supply Drop
                _pos = getPos player;
                _holder = createvehicle ["B_APC_Tracked_01_CRV_F", [_pos select 0, _pos select 1, 75], [], 0, "CAN_COLLIDE"];
                [objNull, _holder] call BIS_fnc_curatorobjectedited;
                
                systemChat "Nemmara dropped.";
            };
            if (_amnt >= 101 && _amnt <= 149) then {
                //Heal players
                {
                    [paramedic, _x] remoteExecCall ["ace_medical_treatment_fnc_fullHeal", 0];
                } forEach allPlayers;
                systemChat "Healing all players.";
            };
            if (_amnt >= 150) then {
                //Wolverine mode
                _wolv_time = 60 + (60 * (floor((_amnt - 150) / 50)));
                _wolv_time spawn {
                    _end_time = time + _this;
                    while { time < _end_time } do {
                        {
                            [paramedic, _x] remoteExecCall ["ace_medical_treatment_fnc_fullHeal", 0];
                        } forEach allPlayers;
                        sleep 0.5;
                    };
                };
                systemChat format["Wolverine mode activated for %1 seconds.", _wolv_time];
            };


		}
	]
];
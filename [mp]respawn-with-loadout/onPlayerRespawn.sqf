/*
	Author: UselessFodder
	Purpose: Retrieves loadout set by initPlayerLocal.sqf when arsenal
		was closed in order to spawn with full loadout
	Source: https://github.com/UselessFodder/FS-A3-Scripts
	Last Updated: 24 April 2023
	
	Instructions: Place in main mission folder w/initPlayerLocal.sqf
*/

private _loadout = player getVariable ["savedLoadout", []];

// Check if there is a saved loadout
if (!(_loadout isEqualTo [])) then {
	// Restore the unit's loadout when they respawn
	player setUnitLoadout _loadout;
};


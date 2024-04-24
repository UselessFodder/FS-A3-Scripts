/*
	Author: UselessFodder
	Purpose: Adds event handlers when arsenals close in order
		to generate loadouts to be called in onPlayerRespawn.sqf
	Source: https://github.com/UselessFodder/FS-A3-Scripts
	Last Updated: 24 April 2023
	
	Instructions: Place in main mission folder w/onPlayerRespawn.sqf	
*/

// Add the event handler for the arsenal closing
[missionNamespace,"arsenalClosed", {
    // Save the unit's loadout when the arsenal is closed
    player setVariable ["savedLoadout", getUnitLoadout player];
}] call BIS_fnc_addScriptedEventHandler;

["ace_arsenal_displayClosed", {
    // Save the unit's loadout when the arsenal is closed
    player setVariable ["savedLoadout", getUnitLoadout player];
}] call CBA_fnc_addEventHandler;

/*
	This script creates a "cinematic shooting" scenario between all units that are synchronized to the 
		parameter object, meaning they will be able to fire more or less non-stop at each other without
		killing anyone or running out of ammunition. The script ends when the synchObject is deleted
*/

params ["_synchObject"];

//get all units synched to object
private _units = synchronizedObjects _synchObject;

//set all _units to be invincible and unable to move
_units apply {
	_x allowDamage false;
	_x disableAI "PATH";
};

//function to rearm unit with primary weapon magazines after a random delay
fnc_rearm = {
	params ["_unit", "_mag"];
	
	//get magazine types
	//private _mag = currentMagazine _unit;
	
	//wait a random amount of time before rearming
	private _delay = 15 + ceil(random 45);
	
	diag_log format["Unit %1 has run out of ammo. Rearming with magazie %2 in %3 seconds", _unit, _mag, _delay];
	
	sleep _delay;
	
	//give between 2-4 magazines
	_unit addMagazines [_mag, 1 + ceil(random 3)];
};

//counter to ensure while loop doesn't overload system if run in a non-sleep environment
private _loopCount = 0;

//keep units in this state until synchObject is destroyed
while {!isNull _synchObject && _loopCount < 1000} do {
	_loopCount = _loopCount + 1;
	
	//if unit is almost out of ammo, execute function to rearm them
	{	
	
		private _mag = currentMagazine _x;
		//private _magCount = count magazines _x;
		private _magCount = {_x isEqualTo _mag} count (magazines _x);
		
		diag_log format["Unit %1 has %2 primary magazines left. ",_x, _magCount];
		if (_magCount == 0) then {
			diag_log format ["Executing fnc_rearm on unit %1 ", _x];
			[_x, _mag] spawn fnc_rearm;
		};
	} forEach _units;
	
	sleep 30;
};

//if while loop ended due to count, log error
if (_loopCount >= 1000) then {
	diag_log "***ERROR: cinematicShooting script was not run with sleep enabled. Please CALL next time.";
};

//reset all units to normal
_units apply {
	_x allowDamage true;
	_x enableAI "PATH";
};

diag_log "*** cinematicShooting script ended successfully!";
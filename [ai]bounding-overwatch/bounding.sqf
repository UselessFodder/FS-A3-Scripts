/*
	Forces AI squad to do a bounding overwatch to passed in target locationNull
	**WARNING:** All current waypoints are lost during this movement. Ensure you save before
	Example Calls:
		[_group, getPos player] execVM "bounding.sqf";
		[[_group, getPos player],"bounding.sqf"] remoteExec ["BIS_fnc_execVM",0];
*/

params["_group","_target"];
//params["_group"];

//get group SL and other info
_squadLeader = leader _group;
_behavior = behaviour _squadLeader;

//split the group relatively evenly into 2 new groups
private _numSoldiers = count units _group;
private _halfGroup = round (_numSoldiers / 2);
_tempGroup = createGroup [side _squadLeader, true];
private _allUnits = units _group;

for [{ private _i = 0 }, { _i < _halfGroup }, { _i = _i + 1 }] do { 
	private _tempUnit = _allUnits select _i;
	[_tempUnit] joinSilent _tempGroup;
};

//set original squad to overwatch
units _group apply {
	_x disableAI "PATH";
};

//set new squad to bound
_tempGroup setBehaviour "AWARE";
_tempGroup setCombatMode "BLUE";
units _tempGroup apply {
	_x disableAI "AUTOCOMBAT";
};

//set the current overwatch group
_overwatchGroup = _group;

//set the current bounding group
_boundGroup = _tempGroup;

//give groups move order to target pos
_group addWaypoint [_target, 0];
_tempGroup addWaypoint [_target, 0];

//until group gets to target, do bounding
while {(leader _boundGroup distance _target) > 10} do {
	//set squad to overwatch
	_overwatchGroup setCombatMode "RED";
	units _overwatchGroup apply {
		_x disableAI "PATH";
		_x enableAI "AUTOCOMBAT";
		_x enableAI "TARGET";
	};
	
	//set new squad to bound
	_boundGroup setCombatBehaviour "CARELESS";
	_boundGroup setCombatBehaviour "AWARE";
	_boundGroup setCombatMode "BLUE";
	units _boundGroup apply {
		_x enableAI "PATH";
		_x disableAI "AUTOCOMBAT";
		_x disableAI "TARGET";
	};
	
	if (_overwatchGroup == _group) then {
		_overwatchGroup = _tempGroup;
		_boundGroup = _group;
	} else {
		_overwatchGroup = _group;
		_boundGroup = _tempGroup;
	};
	
	sleep floor((random 14))+12;
};

//rejoin groups and reset
units _overwatchGroup joinSilent _boundGroup;
_boundGroup selectLeader _squadLeader;
_boundGroup setCombatBehaviour _behavior;

units _boundGroup apply {
	_x enableAI "PATH";
	_x enableAI "AUTOCOMBAT";
	_x enableAI "TARGET";
};
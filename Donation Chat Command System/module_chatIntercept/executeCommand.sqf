private ["_chatArr","_seperator","_commandDone","_command","_argument"];

_chatArr = [_this,0,[]] call BIS_fnc_param;

// Remove leading intercept character
_chatArr set [0,-1];
_chatArr = _chatArr - [-1];

_seperator = (toArray " ") select 0;
_commandDone = false;
_command = [];
_argument = [];

{
	if (_x == _seperator && !_commandDone)then{
		_commandDone = true;
	}else{
		if (!_commandDone) then{
			_command set[count _command,_x];
		}else{
			_argument set[count _argument,_x];
		};
	};
}forEach _chatArr;

_command = toString _command;
_argument = toString _argument;

{
	if (_command == (_x select 0))exitWith{
		[_argument] call (_x select 1);
	};
}forEach pvpfw_chatIntercept_allCommands;
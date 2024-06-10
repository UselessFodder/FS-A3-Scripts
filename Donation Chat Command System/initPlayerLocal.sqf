//Chat command init
_access_allowed = ["UselessFodder"]; //Which players are allowed to use donation commands?
if ((name player) in _access_allowed || (call BIS_fnc_admin) > 0) then {
    [] call compile preProcessFilelineNumbers "module_chatIntercept\config.sqf";
    [] call compile preProcessFilelineNumbers "module_chatIntercept\commands.sqf";

    pvpfw_chatIntercept_executeCommand = compile preProcessFilelineNumbers "module_chatIntercept\executeCommand.sqf";

    // Reset and old EH IDs and scripthandles
    if (!isNil "pvpfw_chatIntercept_handle")then{
        terminate pvpfw_chatIntercept_handle
    };
    if (!isNil "pvpfw_chatIntercept_EHID")then{
        (findDisplay 24) displayRemoveEventHandler ["KeyDown",pvpfw_chatIntercept_EHID];
        pvpfw_chatIntercept_EHID = nil;
    };

    pvpfw_chatIntercept_handle = [] spawn {
        private["_equal","_chatArr"];

        while{true}do{
            pvpfw_chatString = "";

            waitUntil{sleep 0.22;!isNull (finddisplay 24 displayctrl 101)};

            pvpfw_chatIntercept_EHID = (findDisplay 24) displayAddEventHandler["KeyDown",{
                if ((_this select 1) != 28) exitWith{false};

                _equal = false;

                _chatArr = toArray pvpfw_chatString;
                //_chatArr resize 1;
                if ((_chatArr select 0) isEqualTo ((toArray pvpfw_chatIntercept_commandMarker) select 0))then{
                    if (pvpfw_chatIntercept_debug)then{
                        systemChat format["Intercepted: %1",pvpfw_chatString];
                    };
                    _equal = true;
                    closeDialog 0;
                    (findDisplay 24) closeDisplay 1;

                    [_chatArr] call pvpfw_chatIntercept_executeCommand;
                };

                _equal
            }];

            waitUntil{
                if (isNull (finddisplay 24 displayctrl 101))exitWith{
                    if (!isNil "pvpfw_chatIntercept_EHID")then{
                        (findDisplay 24) displayRemoveEventHandler ["KeyDown",pvpfw_chatIntercept_EHID];
                    };
                    pvpfw_chatIntercept_EHID = nil;
                    true
                };
                pvpfw_chatString = (ctrlText (finddisplay 24 displayctrl 101));
                false
            };
        };
    };
};

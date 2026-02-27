params ["_caller","_leader"];

if ((_leader getVariable ["RP_object", objNull]) isEqualTo objNull) exitWith {
    hintSilent "Точка развертывания не активна";
    "Установи точку развертывания\nНу пожалуйста\nуебок" remoteExec ["hint", _leader];
};

private _respawnHold = missionNamespace getVariable ["RP_respawnHold", false];

if (!_respawnHold) then {
    private _rpobj = _leader getVariable ["RP_object", objNull];
    if (!(_rpobj isEqualTo objNull)) then {
        ["TAG_aVeryUniqueID2", true, 0.5] call BIS_fnc_blackOut;
        uisleep 0.5;
        
        private _2dpos = [_rpobj, 1, 5, 2, 0] call BIS_fnc_findSafePos;
        _caller setPosASL [_2dpos # 0, _2dpos # 1, getTerrainHeightASL _2dpos];
        
        ["TAG_aVeryUniqueID2", true, 0.5] call BIS_fnc_blackIn;
    };
} else {
    private _holdDuration = missionNamespace getVariable ["RP_respawnHold_duration", 0];
    private _counter = missionNamespace getVariable ["RP_respawnHold_counter", 0];
    private _windowDuration = missionNamespace getVariable ["RP_respawn_windowDuration",0];
    hintSilent parseText format ["Телепортация невозможна,<br/>Ожидайте %1 сек.", _holdDuration - _counter + _windowDuration];
};
if (!isServer) exitWith {};

if (isNil "VS_KILL_REWARDS") then {
    execVM "scripts\vehicleshop\cfg.sqf";
    waitUntil { !isNil "VS_KILL_REWARDS" };
};

VS_TeamPoints = VS_START_POINTS;
publicVariable "VS_TeamPoints";

VS_KSM_Vehicles = [];
publicVariable "VS_KSM_Vehicles";
VS_PlayerVehicles = [];
publicVariable "VS_PlayerVehicles";

VS_DeployedDefenses = [];
publicVariable "VS_DeployedDefenses";

VS_fnc_addTeamPoints = {
    params ["_amount"];
    VS_TeamPoints = VS_TeamPoints + _amount;
    if (VS_TeamPoints < 0) then { VS_TeamPoints = 0 };
    publicVariable "VS_TeamPoints";
};

VS_fnc_notifyAll = {
    params ["_killer", "_msg", "_msgOthers"];
    {
        if (!isPlayer _x) exitWith {};
        if (side _x != RESISTANCE) exitWith {};
        private _m = if (_x == _killer) then { _msg } else { _msgOthers };
        if (hasInterface && _x == player) then {
            [_m] call VS_fnc_showHint;
        } else {
            [_m] remoteExec ["VS_fnc_showHint", _x];
        };
    } forEach allPlayers;
};


VS_fnc_spawnVehicle = {
    params ["_requester", "_classname", "_cost"];
    if (!isServer) exitWith {};

    if (side _requester != RESISTANCE) exitWith {
        private _m = "Только Independent могут покупать технику!";
        if (hasInterface && _requester == player) then {
            [_m] call VS_fnc_showHint;
        } else {
            [_m] remoteExec ["VS_fnc_showHint", _requester];
        };
    };

    if (VS_TeamPoints < _cost) exitWith {
        private _m = format ["Недостаточно командных очков!\nНужно: %1 | Есть: %2", _cost, VS_TeamPoints];
        if (hasInterface && _requester == player) then {
            [_m] call VS_fnc_showHint;
        } else {
            [_m] remoteExec ["VS_fnc_showHint", _requester];
        };
    };

    private _pos = getPosATL _requester;
    private _spawnPos = [];
    private _found = false;

    for "_i" from 0 to 29 do {
        if (_found) exitWith {};
        private _angle = random 360;
        private _dist = 4 + random VS_SPAWN_RADIUS;
        private _test = [
            (_pos select 0) + (_dist * sin _angle),
            (_pos select 1) + (_dist * cos _angle),
            0
        ];
        private _ep = _test findEmptyPosition [0, VS_SPAWN_RADIUS + 5, _classname];
        if (count _ep > 0) then { _spawnPos = _ep; _found = true };
    };

    if (!_found) then {
        _spawnPos = _pos getPos [8, getDir _requester + 90];
        _spawnPos set [2, 0];
    };

    private _grp = createGroup [RESISTANCE, true];
    private _veh = createVehicle [_classname, [_spawnPos select 0, _spawnPos select 1, (_spawnPos select 2) + 1.5], [], 0, "NONE"];
    _veh setDir (random 360);
    _veh setPosASL [_spawnPos select 0, _spawnPos select 1, (_spawnPos select 2) + 1.5];
    (crew _veh) joinSilent _grp;
    _veh setVariable ["VS_PlayerVehicle", true, true];

    [-_cost] call VS_fnc_addTeamPoints;

    private _dispName = getText (configFile >> "CfgVehicles" >> _classname >> "displayName");

    [_requester,
        format ["Куплено: %1\nСписано: %2 | Очков команды: %3", _dispName, _cost, VS_TeamPoints],
        format ["%1 купил: %2 (-%3)\nОчков команды: %4", name _requester, _dispName, _cost, VS_TeamPoints]
    ] call VS_fnc_notifyAll;

};

VS_fnc_spawnVehicleAt = {
    params ["_requester", "_classname", "_cost", "_pos", "_dir"];
    if (!isServer) exitWith {};

    if (side _requester != RESISTANCE) exitWith {
        private _m = "Только Independent могут покупать технику!";
        if (hasInterface && _requester == player) then {
            [_m] call VS_fnc_showHint;
        } else {
            [_m] remoteExec ["VS_fnc_showHint", _requester];
        };
    };

    if (VS_TeamPoints < _cost) exitWith {
        private _m = format ["Недостаточно командных очков!\nНужно: %1 | Есть: %2", _cost, VS_TeamPoints];
        if (hasInterface && _requester == player) then {
            [_m] call VS_fnc_showHint;
        } else {
            [_m] remoteExec ["VS_fnc_showHint", _requester];
        };
    };

    private _grp = createGroup [RESISTANCE, true];
    private _spawnPos = [_pos select 0, _pos select 1, (_pos select 2) + 1.5];
    private _veh = createVehicle [_classname, _spawnPos, [], 0, "NONE"];
    _veh setDir _dir;
    _veh setPosASL _spawnPos;
    (crew _veh) joinSilent _grp;
    _veh setVariable ["VS_PlayerVehicle", true, true];
    _veh setVariable ["VS_vehicle_owner", _requester, true];
    _veh setVariable ["VS_purchase_time", time, true];
    _veh setVariable ["VS_purchase_cost", _cost, true];
    VS_PlayerVehicles pushBack _veh;
    publicVariable "VS_PlayerVehicles";

    if (_classname == VS_KSM_CLASS) then {
        private _ksmList = missionNamespace getVariable ["VS_KSM_Vehicles", []];
        _ksmList pushBack _veh;
        VS_KSM_Vehicles = _ksmList;
        publicVariable "VS_KSM_Vehicles";
        _veh setVariable ["VS_ksm_deployed", false, true];
        _veh setVariable ["VS_ksm_defenses", [], true];
    };

    [-_cost] call VS_fnc_addTeamPoints;

    private _dispName = getText (configFile >> "CfgVehicles" >> _classname >> "displayName");

    [_requester,
        format ["Куплено: %1\nСписано: %2 | Очков команды: %3", _dispName, _cost, VS_TeamPoints],
        format ["%1 купил: %2 (-%3)\nОчков команды: %4", name _requester, _dispName, _cost, VS_TeamPoints]
    ] call VS_fnc_notifyAll;

};

VS_fnc_ksmAntennaUp = {
    params ["_ksm"];
    if (isNull _ksm) exitWith {};
    private _anims = [
        "antennamast_01_elev_trigger",
        "antennamast_01_elev_01","antennamast_01_elev_02","antennamast_01_elev_03",
        "antennamast_01_elev_04","antennamast_01_elev_05","antennamast_01_elev_06",
        "antennamast_01_elev_07","antennamast_01_elev_08","antennamast_01_elev_09"
    ];
    { _ksm animate [_x, 1, true]; } forEach _anims;
};

VS_fnc_ksmAntennaDown = {
    params ["_ksm"];
    if (isNull _ksm) exitWith {};
    private _anims = [
        "antennamast_01_elev_trigger",
        "antennamast_01_elev_01","antennamast_01_elev_02","antennamast_01_elev_03",
        "antennamast_01_elev_04","antennamast_01_elev_05","antennamast_01_elev_06",
        "antennamast_01_elev_07","antennamast_01_elev_08","antennamast_01_elev_09"
    ];
    { _ksm animate [_x, 0, true]; } forEach _anims;
};

VS_fnc_ksmAddEngineEH = {
    params ["_ksm"];
    if (isNull _ksm) exitWith {};
    private _ehId = _ksm addEventHandler ["Engine", {
        params ["_veh", "_engineState"];
        if (_engineState && (_veh getVariable ["VS_ksm_deployed", false])) then {
            [_veh] remoteExec ["VS_fnc_ksmKillEngine", 0];
        };
    }];
    _ksm setVariable ["VS_ksm_engine_eh", _ehId];
};

VS_fnc_ksmRemoveEngineEH = {
    params ["_ksm"];
    if (isNull _ksm) exitWith {};
    private _ehId = _ksm getVariable ["VS_ksm_engine_eh", -1];
    if (_ehId >= 0) then {
        _ksm removeEventHandler ["Engine", _ehId];
        _ksm setVariable ["VS_ksm_engine_eh", -1];
    };
};

VS_fnc_ksmKillEngine = {
    params ["_ksm"];
    if (!isServer) exitWith {};
    if (isNull _ksm) exitWith {};
    _ksm engineOn false;
};

VS_fnc_ksmDeploy = {
    params ["_ksm"];
    if (!isServer) exitWith {};
    if (isNull _ksm) exitWith {};
    if (typeOf _ksm != VS_KSM_CLASS) exitWith {};
    if (_ksm getVariable ["VS_ksm_deployed", false]) exitWith {};

    _ksm setVariable ["VS_ksm_deployed", true, true];
    _ksm engineOn false;

    [_ksm] remoteExec ["VS_fnc_ksmAddEngineEH", owner _ksm];

    private _anims = [
        "antennamast_01_elev_trigger",
        "antennamast_01_elev_01","antennamast_01_elev_02","antennamast_01_elev_03",
        "antennamast_01_elev_04","antennamast_01_elev_05","antennamast_01_elev_06",
        "antennamast_01_elev_07","antennamast_01_elev_08","antennamast_01_elev_09"
    ];
    { _ksm animate [_x, 1, true]; } forEach _anims;
    [_ksm] remoteExec ["VS_fnc_ksmAntennaUp", 0];
};

VS_fnc_ksmUndeploy = {
    params ["_ksm"];
    if (!isServer) exitWith {};
    if (isNull _ksm) exitWith {};
    if (!(_ksm getVariable ["VS_ksm_deployed", false])) exitWith {};

    _ksm setVariable ["VS_ksm_deployed", false, true];

    [_ksm] remoteExec ["VS_fnc_ksmRemoveEngineEH", owner _ksm];

    private _anims = [
        "antennamast_01_elev_trigger",
        "antennamast_01_elev_01","antennamast_01_elev_02","antennamast_01_elev_03",
        "antennamast_01_elev_04","antennamast_01_elev_05","antennamast_01_elev_06",
        "antennamast_01_elev_07","antennamast_01_elev_08","antennamast_01_elev_09"
    ];
    { _ksm animate [_x, 0, true]; } forEach _anims;
    [_ksm] remoteExec ["VS_fnc_ksmAntennaDown", 0];
};

VS_fnc_ksmSpawnDefense = {
    params ["_requester", "_classname", "_cost", "_pos", "_dir", "_ksm"];
    if (!isServer) exitWith {};
    
    if (isNull _ksm) exitWith {
    };
    
    if (!(_ksm getVariable ["VS_ksm_deployed", false])) exitWith {
        private _m = "КШМ должна быть развернута!";
        [_m] remoteExec ["VS_fnc_showHint", _requester];
    };
    
    private _currentDefenses = 0;
    {
        if ((_x getVariable ["VS_parentKSM", objNull]) == _ksm && alive _x) then {
            _currentDefenses = _currentDefenses + 1;
        };
    } forEach VS_DeployedDefenses;
    
    if (_currentDefenses >= VS_MAX_DEFENSES_PER_KSM) exitWith {
        private _m = format ["Достигнут лимит оборонительных средств (%1) для этой КШМ!", VS_MAX_DEFENSES_PER_KSM];
        [_m] remoteExec ["VS_fnc_showHint", _requester];
    };
    
    private _grp = createGroup [RESISTANCE, true];
    private _spawnPos = [_pos select 0, _pos select 1, (_pos select 2) + 1.5];
    private _defense = createVehicle [_classname, _spawnPos, [], 0, "NONE"];
    _defense setDir _dir;
    _defense setPosASL _spawnPos;
    (crew _defense) joinSilent _grp;
    
    _defense setVariable ["VS_isKSMDefense", true, true];
    _defense setVariable ["VS_parentKSM", _ksm, true];
    _defense setVariable ["VS_owner", _requester, true];
    _defense setVariable ["VS_purchase_cost", _cost, true];
    
    VS_DeployedDefenses pushBack _defense;
    publicVariable "VS_DeployedDefenses";
    
    [-_cost] call VS_fnc_addTeamPoints;
    
    private _dispName = getText (configFile >> "CfgVehicles" >> _classname >> "displayName");
    
    [_requester,
        format ["Размещено: %1\nСписано: %2 | Очков команды: %3", _dispName, _cost, VS_TeamPoints],
        format ["%1 разместил: %2 (-%3) у КШМ\nОчков команды: %4", name _requester, _dispName, _cost, VS_TeamPoints]
    ] call VS_fnc_notifyAll;
    
};

VS_fnc_sellVehicle = {
    params ["_veh", "_requester"];
    if (!isServer) exitWith {};
    if (isNull _veh) exitWith {};
    if (!alive _veh) exitWith {
        [format ["Техника уничтожена — продажа невозможна."]] remoteExec ["VS_fnc_showHint", _requester];
    };

    private _cost = _veh getVariable ["VS_purchase_cost", 0];
    if (_cost <= 0) exitWith {
        ["Стоимость техники неизвестна."] remoteExec ["VS_fnc_showHint", _requester];
    };

    private _health  = 1 - damage _veh;
    private _maxFuel = getNumber (configFile >> "CfgVehicles" >> (typeOf _veh) >> "fuelCapacity");
    private _fuel    = if (_maxFuel > 0) then { fuel _veh } else { 1 };

    private _refund = round (_cost * ((_health * 0.7) + (_fuel * 0.3)));

    private _isDefense = _veh getVariable ["VS_isKSMDefense", false];
    private _dispName = getText (configFile >> "CfgVehicles" >> (typeOf _veh) >> "displayName");

    if (_isDefense) then {
        VS_DeployedDefenses = VS_DeployedDefenses - [_veh];
        publicVariable "VS_DeployedDefenses";
    };

    { deleteVehicle _x } forEach (crew _veh);
    VS_PlayerVehicles = VS_PlayerVehicles - [_veh];
    publicVariable "VS_PlayerVehicles";
    deleteVehicle _veh;

    [_refund] call VS_fnc_addTeamPoints;
    [_requester,
        format ["Продано: %1\nВозвращено: %2 оч. (здоровье %3%%, топливо %4%%)\nОчков команды: %5",
            _dispName, _refund,
            round (_health * 100), round (_fuel * 100),
            VS_TeamPoints],
        format ["%1 продал: %2 (+%3)\nОчков команды: %4",
            name _requester, _dispName, _refund, VS_TeamPoints]
    ] call VS_fnc_notifyAll;
};

VS_fnc_sellTrophy = {
    params ["_veh", "_requester"];
    if (!isServer) exitWith {};
    if (isNull _veh) exitWith {};
    if (!alive _veh) exitWith {
        ["Техника уничтожена — продажа невозможна."] remoteExec ["VS_fnc_showHint", _requester];
    };
    if (side _veh == RESISTANCE) exitWith {
        ["Это своя техника — используй обычную продажу."] remoteExec ["VS_fnc_showHint", _requester];
    };

    private _reward = 0;
    { if (_veh isKindOf (_x select 0)) exitWith { _reward = (_x select 1) * 2 } } forEach VS_KILL_REWARDS;

    if (_reward <= 0) exitWith {
        ["Нет данных о стоимости этой техники."] remoteExec ["VS_fnc_showHint", _requester];
    };

    private _dispName = getText (configFile >> "CfgVehicles" >> (typeOf _veh) >> "displayName");

    { deleteVehicle _x } forEach (crew _veh);
    deleteVehicle _veh;

    [_reward] call VS_fnc_addTeamPoints;
    [_requester,
        format ["Трофей сдан: %1\nНаграда: +%2 оч.\nОчков команды: %3", _dispName, _reward, VS_TeamPoints],
        format ["%1 сдал трофей: %2 (+%3)\nОчков команды: %4", name _requester, _dispName, _reward, VS_TeamPoints]
    ] call VS_fnc_notifyAll;
};

addMissionEventHandler ["EntityKilled", {
    params ["_killed", "_killer", "_instigator"];

    private _player = objNull;
    if (!isNull _instigator && { isPlayer _instigator }) then { _player = _instigator };
    if (isNull _player && { !isNull _killer }) then {
        if (isPlayer _killer) then {
            _player = _killer;
        } else {
            { if (isPlayer _x) exitWith { _player = _x } } forEach (crew (vehicle _killer));
        };
    };

    if (isNull _player || { !isPlayer _player }) exitWith {};
    if (side _player != RESISTANCE) exitWith {};
    if (side _killed == RESISTANCE) exitWith {};

    private _rewards = missionNamespace getVariable ["VS_KILL_REWARDS", []];
    private _reward = 0;
    { if (_killed isKindOf (_x select 0)) exitWith { _reward = _x select 1 } } forEach _rewards;
    if (_reward <= 0) exitWith {};

    [_reward] call VS_fnc_addTeamPoints;

    if !(_killed isKindOf "CAManBase") then {
        private _dispName = getText (configFile >> "CfgVehicles" >> (typeOf _killed) >> "displayName");
        [_player,
            format ["%1 очков команде!\nУничтожено: %2\nОчков команды: %3", _reward, _dispName, VS_TeamPoints],
            format ["Команда +%1 (%2)\nВсего: %3", _reward, _dispName, VS_TeamPoints]
        ] call VS_fnc_notifyAll;
    };
}];

publicVariable "VS_fnc_spawnVehicle";
publicVariable "VS_fnc_spawnVehicleAt";
publicVariable "VS_fnc_addTeamPoints";

VS_fnc_triggerReward = {
    params ["_amount", ["_msg", ""]];
    if (!isServer) exitWith {};
    if (_amount <= 0) exitWith {};
    [_amount] call VS_fnc_addTeamPoints;
    private _text = if (_msg != "") then { _msg } else {
        format ["Командное вознаграждение: +%1 оч.\nОчков команды: %2", _amount, VS_TeamPoints]
    };
    {
        if (!isPlayer _x) exitWith {};
        if (side _x != RESISTANCE) exitWith {};
        [_text] remoteExec ["VS_fnc_showHint", _x];
    } forEach allPlayers;
};
publicVariable "VS_fnc_triggerReward";
publicVariable "VS_fnc_ksmDeploy";
publicVariable "VS_fnc_ksmUndeploy";
publicVariable "VS_fnc_ksmSpawnDefense";
publicVariable "VS_fnc_ksmAntennaUp";
publicVariable "VS_fnc_ksmAntennaDown";
publicVariable "VS_fnc_ksmAddEngineEH";
publicVariable "VS_fnc_ksmRemoveEngineEH";
publicVariable "VS_fnc_ksmKillEngine";
publicVariable "VS_fnc_sellVehicle";
publicVariable "VS_fnc_sellTrophy";
publicVariable "VS_PlayerVehicles";


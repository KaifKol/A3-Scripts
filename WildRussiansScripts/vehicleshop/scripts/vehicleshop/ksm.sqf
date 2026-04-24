if (!hasInterface) exitWith {};

waitUntil { !isNil "VS_KSM_DEFENSES" };
waitUntil { !isNil "VS_fnc_spawnVehicleAt" };
waitUntil { !isNil "VS_KSM_Vehicles" };

VS_fnc_ksmDeploy = {
    params ["_ksm"];
    if (isNull _ksm) exitWith {};
    if (_ksm getVariable ["VS_ksm_deployed", false]) exitWith {};

    _ksm setVariable ["VS_ksm_deployed", true, true];
    _ksm engineOn false;

    _ksm animate ["antennamast_01_elev_trigger", 1, true];
    for "_i" from 1 to 9 do {
        _ksm animate [format ["antennamast_01_elev_0%1", _i], 1, true];
    };
};

VS_fnc_ksmUndeploy = {
    params ["_ksm"];
    if (isNull _ksm) exitWith {};
    if (!(_ksm getVariable ["VS_ksm_deployed", false])) exitWith {};

    _ksm setVariable ["VS_ksm_deployed", false, true];

    for "_i" from 9 to 1 step -1 do {
        _ksm animate [format ["antennamast_01_elev_0%1", _i], 0, true];
    };
    _ksm animate ["antennamast_01_elev_trigger", 0, true];
};

VS_fnc_ksmEngineHandler = {
    params ["_ksm"];
    if (isNull _ksm) exitWith {};
    
    [_ksm] spawn {
        params ["_ksm"];
        while { alive _ksm } do {
            if (_ksm getVariable ["VS_ksm_deployed", false]) then {
                _ksm engineOn false;
            };
            sleep 1;
        };
    };
};

VS_fnc_ksmRefreshMenu = {
    private _disp = findDisplay 9200;
    if (isNull _disp) exitWith {};
    (_disp displayCtrl 9201) ctrlSetText format ["Очки команды: %1", VS_TeamPoints];
    private _lb = _disp displayCtrl 9202;
    private _pts = VS_TeamPoints;
    for "_i" from 0 to ((lbSize _lb) - 1) do {
        private _cost = _lb lbValue _i;
        if (_pts >= _cost) then {
            _lb lbSetColor [_i, [0.95, 0.95, 0.95, 1]];
        } else {
            _lb lbSetColor [_i, [0.75, 0.3, 0.3, 1]];
        };
    };
};

[] spawn {
    private _last = -1;
    while { true } do {
        sleep 0.5;
        if ((!isNil "VS_TeamPoints") && { VS_TeamPoints != _last }) then {
            _last = VS_TeamPoints;
            [] call VS_fnc_ksmRefreshMenu;
        };
    };
};

VS_fnc_ksmOpenMenu = {
    params ["_ksm"];
    if (dialog) then { closeDialog 0 };
    
    private _success = createDialog "KSMDialog";
    if (!_success) exitWith {
        hintSilent "Ошибка создания диалога КШМ!";
    };

    private _disp = findDisplay 9200;
    if (isNull _disp) exitWith {
        hintSilent "Ошибка: диалог КШМ не найден!";
    };

    (_disp displayCtrl 9201) ctrlSetText format ["Очки команды: %1", VS_TeamPoints];

    private _lb = _disp displayCtrl 9202;
    lbClear _lb;
    private _pts = VS_TeamPoints;

    {
        private _idx = _lb lbAdd (_x select 0);
        _lb lbSetValue [_idx, _x select 2];
        _lb lbSetData [_idx, _x select 1];
        if (_pts < (_x select 2)) then {
            _lb lbSetColor [_idx, [0.75, 0.3, 0.3, 1]];
        };
    } forEach VS_KSM_DEFENSES;

    _lb ctrlAddEventHandler ["LBSelChanged", {
        params ["_ctrl", "_idx"];
        if (_idx < 0) exitWith {};
        private _info = findDisplay 9200 displayCtrl 9203;
        private _cost = VS_KSM_DEFENSES select _idx select 2;
        private _have = VS_TeamPoints;
        _info ctrlSetText format ["Стоимость: %1 | Очков команды: %2", _cost, _have];
        if (_have >= _cost) then {
            _info ctrlSetTextColor [0.3, 1, 0.3, 1];
        } else {
            _info ctrlSetTextColor [1, 0.35, 0.35, 1];
        };
    }];

    missionNamespace setVariable ["VS_activeKSM", _ksm];
};

VS_fnc_ksmPlaceDefense = {
    private _lb = findDisplay 9200 displayCtrl 9202;
    private _idx = lbCurSel _lb;
    if (_idx < 0) exitWith { hintSilent "Выберите оборонительное средство!" };

    private _entry = VS_KSM_DEFENSES select _idx;
    private _class = _entry select 1;
    private _cost = _entry select 2;

    if (VS_TeamPoints < _cost) exitWith {
        hintSilent format ["Недостаточно очков!\nНужно: %1 | Есть: %2", _cost, VS_TeamPoints];
    };

    private _ksm = missionNamespace getVariable ["VS_activeKSM", objNull];
    if (isNull _ksm) exitWith { hintSilent "КШМ не найдена!" };
    if (!alive _ksm) exitWith { hintSilent "КШМ уничтожена!" };

    closeDialog 0;
    [_class, _cost, _ksm] spawn VS_fnc_ksmStartPlacement;
};

VS_fnc_ksmStartPlacement = {
    params ["_class", "_cost", "_ksm"];

    private _ghost = createVehicle [_class, getPosASL _ksm, [], 0, "NONE"];
    _ghost allowDamage false;
    _ghost enableSimulationGlobal false;
    _ghost setVariable ["VS_noTrophy", true, true];
    _ghost disableCollisionWith player;
    { _x disableCollisionWith player } forEach (crew _ghost);

    private _dir = getDir player;
    private _placing = true;
    private _confirm = false;
    private _finalPos = getPosASL _ksm;

    VS_placement_confirm = false;
    VS_placement_cancel  = false;
    VS_placement_active  = true;
    private _prevWeapon = currentWeapon player;
    player action ["SwitchWeapon", player, player, -1];
    VS_placement_rotL    = false;
    VS_placement_rotR    = false;

    private _ehKeyDown = (findDisplay 46) displayAddEventHandler ["KeyDown", {
        params ["_disp", "_key"];
        if (!VS_placement_active) exitWith { false };
        switch _key do {
            case 1:  { VS_placement_cancel  = true };
            case 16: { VS_placement_rotL    = true };
            case 18: { VS_placement_rotR    = true };
        };
        false
    }];
    
    private _ehKeyUp = (findDisplay 46) displayAddEventHandler ["KeyUp", {
        params ["_disp", "_key"];
        switch _key do {
            case 16: { VS_placement_rotL = false };
            case 18: { VS_placement_rotR = false };
        };
        false
    }];
    
    private _ehMouse = (findDisplay 46) displayAddEventHandler ["MouseButtonDown", {
        params ["_disp", "_btn"];
        if (!VS_placement_active) exitWith {};
        if (_btn == 0) then { VS_placement_confirm = true };
        if (_btn == 1) then { VS_placement_cancel  = true };
    }];

    hintSilent format ["РАЗМЕЩЕНИЕ (радиус %1м от КШМ)\nЛКМ - установить | ПКМ - отмена\nQ/E - вращение", VS_KSM_RADIUS];

    while { _placing && alive player } do {
        sleep 0.03;

        private _screenPos = screenToWorld [0.5, 0.5];
        private _tx = _screenPos select 0;
        private _ty = _screenPos select 1;
        private _kx = getPosASL _ksm select 0;
        private _ky = getPosASL _ksm select 1;
        private _dx = _tx - _kx;
        private _dy = _ty - _ky;
        private _dist = sqrt (_dx * _dx + _dy * _dy);

        if (_dist > VS_KSM_RADIUS) then {
            private _ang = _dx atan2 _dy;
            _tx = _kx + VS_KSM_RADIUS * sin _ang;
            _ty = _ky + VS_KSM_RADIUS * cos _ang;
        };

        private _pos = [_tx, _ty, getTerrainHeightASL [_tx, _ty]];

        if (VS_placement_rotL) then { _dir = (_dir - 3 + 360) % 360 };
        if (VS_placement_rotR) then { _dir = (_dir + 3) % 360 };

        _ghost setPosASL _pos;
        _ghost setDir _dir;

        if (VS_placement_confirm) then {
            VS_placement_confirm = false;
            _placing = false;
            _confirm = true;
            _finalPos = _pos;
        };
        
        if (VS_placement_cancel) then {
            VS_placement_cancel = false;
            _placing = false;
        };
    };

    VS_placement_active = false;
    if (_prevWeapon != "") then { player selectWeapon _prevWeapon };
    (findDisplay 46) displayRemoveEventHandler ["KeyDown",        _ehKeyDown];
    (findDisplay 46) displayRemoveEventHandler ["KeyUp",          _ehKeyUp];
    (findDisplay 46) displayRemoveEventHandler ["MouseButtonDown", _ehMouse];

    deleteVehicle _ghost;
    { deleteVehicle _x } forEach (crew _ghost);

    if (_confirm) then {
        hintSilent "";
        if (isServer) then {
            [player, _class, _cost, _finalPos, _dir, _ksm] call VS_fnc_ksmSpawnDefense;
        } else {
            VS_request_spawnDefense = [getPlayerUID player, _class, _cost, _finalPos, _dir, netId _ksm];
        publicVariableServer "VS_request_spawnDefense";
        };
    } else {
        hintSilent "Размещение отменено.";
        [] spawn { sleep 3; hintSilent "" };
    };
};

VS_fnc_ksmCreateRadiusMarker = {
    params ["_ksm"];
    if (!hasInterface) exitWith {};
    
    private _markerName = format ["KSM_Radius_%1", netId _ksm];
    private _marker = createMarkerLocal [_markerName, getPos _ksm];
    _markerName setMarkerShapeLocal  "ELLIPSE";
    _markerName setMarkerSizeLocal   [VS_KSM_RADIUS, VS_KSM_RADIUS];
    _markerName setMarkerColorLocal  "ColorYellow";
    _markerName setMarkerBrushLocal  "BORDER";
    _markerName setMarkerAlphaLocal  0.5;
    
    _ksm setVariable ["VS_radius_marker", _markerName];
};

VS_fnc_ksmUpdateMarker = {
    params ["_ksm"];
    if (!hasInterface) exitWith {};
    
    private _markerName = _ksm getVariable ["VS_radius_marker", ""];
    if (_markerName != "") then {
        _markerName setMarkerPosLocal getPos _ksm;
    };
};

VS_fnc_ksmAttachActions = {
    params ["_ksm"];
    if (isNull _ksm) exitWith {};

    if (_ksm getVariable ["VS_ksm_actions_added", false]) exitWith {};
    
    _ksm setVariable ["VS_ksm_actions_added", true];

    [_ksm] call VS_fnc_ksmEngineHandler;

    private _idDeploy = _ksm addAction [
        "<t color='#ffcc44'>Развернуть КШМ</t>",
        {
            params ["_target", "_caller", "_id", "_params"];
            if (_target getVariable ["VS_ksm_deployed", false]) exitWith {
                hintSilent "КШМ уже развёрнута!";
            };

            if (isServer) then {
                [_target] call VS_fnc_ksmDeploy;
            } else {
                VS_request_deploy = netId _target;
                publicVariableServer "VS_request_deploy";
            };
            hint "Разворачивание КШМ... Антенна поднимается.";
        },
        nil,
        6,
        true,
        true,
        "",
        "alive _target && player distance _target < 10",
        10
    ];

    private _idUndeploy = _ksm addAction [
        "<t color='#aaaaaa'>Свернуть КШМ</t>",
        {
            params ["_target", "_caller", "_id", "_params"];
            if (!(_target getVariable ["VS_ksm_deployed", false])) exitWith {
                hintSilent "КШМ не развёрнута!";
            };

            if (isServer) then {
                [_target] call VS_fnc_ksmUndeploy;
            } else {
                VS_request_undeploy = netId _target;
                publicVariableServer "VS_request_undeploy";
            };
            hint "Сворачивание КШМ... Антенна опускается.";
        },
        nil,
        5,
        true,
        true,
        "",
        "alive _target && player distance _target < 10",
        10
    ];

    private _idDefense = _ksm addAction [
        "<t color='#ff8844'>Оборонительные позиции</t>",
        {
            params ["_target", "_caller", "_id", "_params"];
            if (!(_target getVariable ["VS_ksm_deployed", false])) exitWith {
                hintSilent "Сначала разверните КШМ!";
            };
            [_target] call VS_fnc_ksmOpenMenu;
        },
        nil,
        4,
        true,
        true,
        "",
        "alive _target && player distance _target < 10",
        10
    ];

    _ksm setVariable ["VS_ksm_actionIDs", [_idDeploy, _idUndeploy, _idDefense]];

    if (hasInterface) then {
        [_ksm] call VS_fnc_ksmCreateRadiusMarker;
        
        [_ksm] spawn {
            params ["_ksm"];
            while { alive _ksm } do {
                [_ksm] call VS_fnc_ksmUpdateMarker;
                sleep 0.1;
            };
            private _marker = _ksm getVariable ["VS_radius_marker", ""];
            if (_marker != "") then { deleteMarkerLocal _marker; };
        };
    };

};

[] spawn {
    private _known = [];
    
    while { true } do {
        if (!isNil "VS_KSM_Vehicles") then {
            {
                if (!isNull _x && alive _x && !(_x in _known)) then {
                    _known pushBack _x;
                    [_x] spawn VS_fnc_ksmAttachActions;
                };
            } forEach VS_KSM_Vehicles;
        };
        sleep 3;
    };
};


if (!hasInterface) exitWith {};

waitUntil { !isNull player };
waitUntil { alive player };
waitUntil { !isNil "VS_VEHICLE_LIST" };
waitUntil { !isNil "VS_TeamPoints" };
waitUntil { !isNil "VS_fnc_spawnVehicle" };
waitUntil { !isNil "VS_fnc_spawnVehicleAt" };

player createDiaryRecord ["Diary", [
    "Командные очки и техника",
    "<font size='16' color='#00BFFF'>Как зарабатывать очки</font><br/>Очки начисляются автоматически за уничтожение техники и пехоты противника:<br/><font color='#FFFF00'>Танк</font> — 2000    <font color='#FFFF00'>БТР / БМП</font> — 1000    <font color='#FFFF00'>Самолёт</font> — 4000<br/><font color='#FFFF00'>Вертолёт</font> — 3000   <font color='#FFFF00'>Грузовик</font> — 400     <font color='#FFFF00'>Автомобиль</font> — 200<br/><font color='#FFFF00'>Орудие / ПТО</font> — 100   <font color='#FFFF00'>Пехота</font> — 5<br/><br/><font size='16' color='#00BFFF'>Продажа трофейной техники</font><br/>Любую вражескую технику можно доставить к <font color='#FFFF00'>доске с картой</font> и продать через контекстное меню. Награда — <font color='#FFFF00'>вдвое больше</font>, чем за простое уничтожение. Выгоднее захватывать, чем уничтожать.<br/><br/><font size='16' color='#00BFFF'>Покупка техники</font><br/>Подойди к <font color='#FFFF00'>доске с картой</font> на базе и выбери «Купить технику» в контекстном меню. Выбери машину из списка и размести её:<br/><font color='#FFFF00'>ЛКМ</font> — установить    <font color='#FFFF00'>ПКМ</font> — отмена    <font color='#FFFF00'>Q / E</font> — повернуть<br/><br/><font size='16' color='#00BFFF'>КШМ — командно-штабная машина</font><br/>После покупки КШМ подойди к ней и используй контекстное меню:<br/><font color='#FFFF00'>Развернуть КШМ</font> — поднимает антенну, блокирует двигатель.<br/><font color='#FFFF00'>Свернуть КШМ</font> — убирает антенну, снимает блокировку.<br/><font color='#FFFF00'>Оборонительные позиции</font> — открывает меню установки орудий.<br/><br/><font size='16' color='#00BFFF'>Оборонительные позиции</font><br/>Доступны только у <font color='#FFFF00'>развёрнутой КШМ</font>, в радиусе 50м. Лимит: 10 орудий на КШМ.<br/><br/><font color='#FF4444'>Пока КШМ развёрнута — двигатель не заводится. Сначала сверните КШМ.</font>"
]];

VS_fnc_showHint = {
    params ["_msg"];
    hintSilent _msg;
    [] spawn { sleep 6; hintSilent "" };
};
publicVariable "VS_fnc_showHint";

VS_fnc_refreshPointsDisplay = {
    if (!dialog) exitWith {};
    private _disp = findDisplay 9100;
    if (isNull _disp) exitWith {};
    (_disp displayCtrl 9101) ctrlSetText format ["Очки команды: %1", VS_TeamPoints];
    private _lb = _disp displayCtrl 9102;
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
    while {true} do {
        sleep 0.5;
        if (!isNil "VS_TeamPoints" && { VS_TeamPoints != _last }) then {
            _last = VS_TeamPoints;
            [] call VS_fnc_refreshPointsDisplay;
        };
    };
};

VS_fnc_openShop = {
    if (dialog) then { closeDialog 0 };
    createDialog "VehicleShopDialog";
    [] call VS_fnc_refreshPointsDisplay;

    private _lb = findDisplay 9100 displayCtrl 9102;
    private _pts = VS_TeamPoints;
    lbClear _lb;

    {
        private _name = _x select 0;
        private _cost = _x select 2;
        private _idx = _lb lbAdd _name;
        _lb lbSetValue [_idx, _cost];
        if (_pts < _cost) then {
            _lb lbSetColor [_idx, [0.75, 0.3, 0.3, 1]];
        };
    } forEach VS_VEHICLE_LIST;

    _lb ctrlAddEventHandler ["LBSelChanged", {
        params ["_ctrl", "_idx"];
        private _info = findDisplay 9100 displayCtrl 9105;
        if (_idx < 0) exitWith {};
        private _cost = VS_VEHICLE_LIST select _idx select 2;
        private _have = VS_TeamPoints;
        _info ctrlSetText format ["Стоимость: %1 | Очков команды: %2", _cost, _have];
        if (_have >= _cost) then {
            _info ctrlSetTextColor [0.3, 1, 0.3, 1];
        } else {
            _info ctrlSetTextColor [1, 0.35, 0.35, 1];
        };
    }];
};

VS_fnc_buyVehicle = {
    private _lb = findDisplay 9100 displayCtrl 9102;
    private _idx = lbCurSel _lb;

    if (_idx < 0) exitWith { hintSilent "Выберите технику из списка!" };

    private _entry = VS_VEHICLE_LIST select _idx;
    private _class = _entry select 1;
    private _cost = _entry select 2;

    if (VS_TeamPoints < _cost) exitWith {
        hintSilent format ["Недостаточно командных очков!\nНужно: %1 | Есть: %2", _cost, VS_TeamPoints];
    };

    closeDialog 0;

    [_class, _cost] spawn VS_fnc_startPlacement;
};

VS_fnc_startPlacement = {
    params ["_class", "_cost"];

    private _startPos = getPosASL player;

    private _ghost = createVehicle [_class, _startPos, [], 0, "NONE"];
    _ghost allowDamage false;
    _ghost enableSimulationGlobal false;
    _ghost setVariable ["VS_noTrophy", true, true];
    _ghost disableCollisionWith player;
    { _x disableCollisionWith player } forEach (crew _ghost);

    private _dir = getDir player;
    private _placing = true;
    private _confirm = false;
    private _finalPos = _startPos;

    VS_placement_confirm = false;
    VS_placement_cancel = false;
    VS_placement_active = true;
    private _prevWeapon = currentWeapon player;
    player action ["SwitchWeapon", player, player, -1];
    VS_placement_rotL = false;
    VS_placement_rotR = false;

    private _ehKeyDown = (findDisplay 46) displayAddEventHandler ["KeyDown", {
        params ["_disp", "_key"];
        if (!VS_placement_active) exitWith { false };
        switch _key do {
            case 1: { VS_placement_cancel = true };
            case 16: { VS_placement_rotL = true };
            case 18: { VS_placement_rotR = true };
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

    hintSilent "РАЗМЕЩЕНИЕ ТЕХНИКИ\nЛКМ - установить | ПКМ - отмена\nQ — повернуть влево | E — вправо";

    while { _placing && alive player } do {
        sleep 0.03;

        private _screenPos = screenToWorld [0.5, 0.5];
        private _tx = _screenPos select 0;
        private _ty = _screenPos select 1;
        private _tz = getTerrainHeightASL [_tx, _ty];
        private _pos = [_tx, _ty, _tz];

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
    (findDisplay 46) displayRemoveEventHandler ["KeyDown", _ehKeyDown];
    (findDisplay 46) displayRemoveEventHandler ["KeyUp", _ehKeyUp];
    (findDisplay 46) displayRemoveEventHandler ["MouseButtonDown", _ehMouse];

    deleteVehicle _ghost;
    { deleteVehicle _x } forEach (crew _ghost);

    if (_confirm) then {
        hintSilent "";
        if (isServer) then {
            [player, _class, _cost, _finalPos, _dir] call VS_fnc_spawnVehicleAt;
        } else {
            VS_request_spawnVehicle = [getPlayerUID player, _class, _cost, _finalPos, _dir];
            publicVariableServer "VS_request_spawnVehicle";
        };
    } else {
        hintSilent "Размещение отменено.";
        [] spawn { sleep 3; hintSilent "" };
    };
};

[] spawn {
    private _board = missionNamespace getVariable ["MapBoard_Pink", objNull];
    
    if (isNull _board) then {
        private _nearby = nearestObjects [player, ["Land_MapBoard_F", "Land_MapBoard_01_F"], 50];
        if (count _nearby > 0) then {
            _board = _nearby select 0;
        };
    };
    
    waitUntil {
        sleep 1;
        if (isNull _board) then {
            _board = missionNamespace getVariable ["MapBoard_Pink", objNull];
            if (isNull _board) then {
                _nearby = nearestObjects [player, ["Land_MapBoard_F", "Land_MapBoard_01_F"], 50];
                if (count _nearby > 0) then {
                    _board = _nearby select 0;
                };
            };
        };
        !isNull _board
    };
    
    _board addAction [
        "<img size='1.5' image='\A3\ui_f\data\map\VehicleIcons\iconcar_ca.paa'/> <t color='#44ff88'>Купить технику</t>",
        { [] call VS_fnc_openShop; },
        nil,
        1.5,
        true,
        true,
        "",
        "player distance _target < 5",
        5,
        false
    ];
    
};

VS_fnc_startSellLoop = {
    [] spawn {
        waitUntil { alive player };

        private _addedSellActions = [];
        private _addedTrophyActions = [];

        while { alive player } do {
            sleep 2;

            private _allBought = (allMissionObjects "AllVehicles") select {
                alive _x &&
                !(_x isKindOf "CAManBase") &&
                !(_x in _addedSellActions) &&
                (
                    (_x getVariable ["VS_PlayerVehicle", false]) ||
                    (_x getVariable ["VS_isKSMDefense", false])
                )
            };

            {
                private _veh = _x;
                private _isDefense = _veh getVariable ["VS_isKSMDefense", false];
                private _cost = _veh getVariable ["VS_purchase_cost", 0];

                private _condStr = if (_isDefense) then {
                    "alive _target && { private _km = _target getVariable ['VS_parentKSM', objNull]; !isNull _km && alive _km && (_km getVariable ['VS_ksm_deployed', false]) && player distance _km <= VS_KSM_RADIUS }"
                } else {
                    format ["alive _target && { count (nearestObjects [player, ['Land_MapBoard_F', 'Land_MapBoard_01_F'], %1]) > 0 }", VS_SPAWN_RADIUS + 5]
                };

                _veh addAction [
                    format ["<t color='#FF4444'>Продать (%1 оч.)</t>", _cost],
                    {
                        private _target = _this select 0;
                        private _caller = _this select 1;
                        VS_request_sellVehicle = [netId _target, getPlayerUID _caller];
                        publicVariableServer "VS_request_sellVehicle";
                    },
                    nil, 1.5, true, true, "", _condStr
                ];

                _addedSellActions pushBack _veh;

            } forEach _allBought;

            _addedSellActions = _addedSellActions select { alive _x };

            private _nearBoard = count (nearestObjects [player, ["Land_MapBoard_F", "Land_MapBoard_01_F"], VS_SPAWN_RADIUS + 5]) > 0;
            if (_nearBoard) then {
                private _trophies = (allMissionObjects "AllVehicles") select {
                    alive _x &&
                    !(_x isKindOf "CAManBase") &&
                    !(_x in _addedTrophyActions) &&
                    side _x != RESISTANCE &&
                    !(_x getVariable ["VS_PlayerVehicle", false]) &&
                    !(_x getVariable ["VS_isKSMDefense", false]) &&
                    !(_x getVariable ["VS_noTrophy", false])
                };
                {
                    private _veh = _x;
                    private _condStr = format ["alive _target && side _target != RESISTANCE && { count (nearestObjects [player, ['Land_MapBoard_F', 'Land_MapBoard_01_F'], %1]) > 0 }", VS_SPAWN_RADIUS + 5];
                    _veh addAction [
                        "<t color='#FFD700'>Сдать трофей</t>",
                        {
                            private _target = _this select 0;
                            private _caller = _this select 1;
                            VS_request_sellTrophy = [netId _target, getPlayerUID _caller];
                            publicVariableServer "VS_request_sellTrophy";
                        },
                        nil, 1.5, true, true, "", _condStr
                    ];
                    _addedTrophyActions pushBack _veh;
                } forEach _trophies;
            };

            _addedTrophyActions = _addedTrophyActions select { alive _x };
        };
    };
};

[] spawn {
    waitUntil { !isNil "VS_fnc_sellVehicle" };
    waitUntil { !isNil "VS_fnc_sellTrophy" };
    waitUntil { !isNil "VS_DeployedDefenses" };
    waitUntil { !isNil "VS_SPAWN_RADIUS" };
    waitUntil { !isNil "VS_KSM_RADIUS" };

    [] call VS_fnc_startSellLoop;

    player addEventHandler ["Respawn", {
        [] call VS_fnc_startSellLoop;
    }];
};

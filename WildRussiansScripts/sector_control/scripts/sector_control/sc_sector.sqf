params [
    ["_trigger",  objNull,   [objNull]],
    ["_zoneName", "Zone",    [""]],
    ["_zoneSide", sideEmpty, [sideEmpty]],
    ["_onCaptureWEST",        objNull, [objNull]],
    ["_onCaptureEAST",        objNull, [objNull]],
    ["_onCaptureINDEPENDENT", objNull, [objNull]],
    ["_reward",   5000,      [0]]
];

if (isNull _trigger) exitWith {
    diag_log "[SC] ERROR: sc_sector.sqf — передан null триггер.";
};

// Шаг сетки в метрах. Меньше = точнее линия фронта, но больше маркеров на карте.
// Рекомендуется: 30–50 для малых зон, 60–100 для больших.
private _gridStep = 80;

// Время захвата в секундах. Сторона должна удерживать зону непрерывно это время.
private _captureTime = 20;

// Время "остывания" боя в секундах после последнего выстрела в зоне.
private _combatCooldown = 15;

// Прозрачность ячеек сетки фронта.
private _bgAlpha = 0.25;

// Читаем глобальные стороны (заданы в sc_init.sqf)
private _sideBlufor  = missionNamespace getVariable ["SC_SIDE_BLUFOR",      WEST];
private _sideOpfor   = missionNamespace getVariable ["SC_SIDE_OPFOR",       EAST];
private _sideIndep   = missionNamespace getVariable ["SC_SIDE_INDEPENDENT", INDEPENDENT];
private _tasksOn     = missionNamespace getVariable ["SC_TASKS_ENABLED",    true];

SC_fnc_sideColor = {
    params ["_side"];
    private _b = missionNamespace getVariable ["SC_SIDE_BLUFOR",      WEST];
    private _e = missionNamespace getVariable ["SC_SIDE_OPFOR",       EAST];
    private _i = missionNamespace getVariable ["SC_SIDE_INDEPENDENT", INDEPENDENT];
    switch (true) do {
        case (_side == _b): { "ColorBLUFOR"      };
        case (_side == _e): { "ColorOPFOR"       };
        case (_side == _i): { "ColorIndependent" };
        default             { "ColorUnknown"     };
    };
};

private _pos    = getPos _trigger;
private _area   = triggerArea _trigger;
private _sizeA  = _area select 0;
private _sizeB  = _area select 1;
private _angle  = _area select 2;
private _isRect = _area select 3;

private _uid        = format ["%1_%2", round (_pos select 0), round (_pos select 1)];
private _markerIcon = "sc_icon_" + _uid;
private _varName    = "sc_var_"  + _uid;
private _shotKey    = "sc_shot_" + _uid;
private _taskID     = "sc_task_" + _uid;

if (isServer) then {
    deleteMarker _markerIcon;

    private _ownerColor = ([_zoneSide] call SC_fnc_sideColor);

    private _mi = createMarker [_markerIcon, _pos];
    _mi setMarkerType  "mil_dot";
    _mi setMarkerTextLocal  _zoneName;
    _mi setMarkerColorLocal _ownerColor;
    _mi setMarkerAlpha 1.0;

    missionNamespace setVariable [_shotKey, -999];

    if (_tasksOn) then {
        [
            allPlayers,
            [_taskID, "sc_tasks"],
            [format ["Захватить сектор %1", _zoneName],
             format ["Захватите сектор %1 для независимых.", _zoneName],
             ""],
            _pos,
            "CREATED",
            1,
            true,
            "flag"
        ] call BIS_fnc_taskCreate;
    };
};

if (isServer) then {
    _trigger setVariable [_varName, _zoneSide, true];
};
waitUntil { sleep 0.5; !isNil { _trigger getVariable _varName } };

if (isServer) then {
    [_trigger, _markerIcon, _zoneName, _varName, _shotKey, _taskID, _zoneSide,
     _gridStep, _captureTime, _combatCooldown, _bgAlpha, _uid, _pos, _sizeA, _sizeB,
     _onCaptureWEST, _onCaptureEAST, _onCaptureINDEPENDENT, _reward,
     _sideBlufor, _sideOpfor, _sideIndep, _tasksOn] spawn {
        params ["_t", "_mIcon", "_zName", "_vName", "_shotKey", "_taskID", "_prevSide",
                "_step", "_capTime", "_cooldown", "_bgAlpha", "_uid", "_cPos", "_sizeA", "_sizeB",
                "_trigW", "_trigE", "_trigI", "_reward",
                "_sB", "_sE", "_sI", "_tasksOn"];

        private _cells    = [];
        private _cellIdx  = 0;
        private _halfCols = ceil (_sizeA / _step);
        private _halfRows = ceil (_sizeB / _step);

        for "_row" from (-_halfRows) to _halfRows do {
            for "_col" from (-_halfCols) to _halfCols do {
                private _cx      = (_cPos select 0) + (_col * _step);
                private _cy      = (_cPos select 1) + (_row * _step);
                private _cellPos = [_cx, _cy, 0];
                if (_cellPos inArea _t) then {
                    private _mName = format ["sc_cell_%1_%2", _uid, _cellIdx];
                    deleteMarker _mName;
                    private _mc = createMarker [_mName, _cellPos];
                    _mc setMarkerShape "RECTANGLE";
                    _mc setMarkerSize  [(_step * 0.5), (_step * 0.5)];
                    _mc setMarkerBrush "Solid";
                    _mc setMarkerColorLocal ([_prevSide] call SC_fnc_sideColor);
                    _mc setMarkerAlpha _bgAlpha;
                    _cells pushBack [_cellPos, _mName];
                    _cellIdx = _cellIdx + 1;
                };
            };
        };

        private _capSide      = sideEmpty;
        private _capProgress  = 0;
        private _tickInterval = 1;
        private _trackedUnits = [];
        private _taskDone     = false;

        private _fnc_fireCaptureTrigger = {
            params ["_trig"];
            if (isNull _trig) exitWith {};
            if (_trig getVariable ["sc_fired", false]) exitWith {};
            _trig setVariable ["sc_fired", true];
            [_trig] spawn {
                params ["_t"];
                sleep 0.5;
                private _onAct = triggerStatements _t select 1;
                if (_onAct != "") then { [] call compile _onAct };
            };
        };

        while { true } do {
            sleep _tickInterval;

            private _inZoneAll = allUnits select { _x inArea _t };
            {
                private _u = _x;
                if !(_u in _trackedUnits) then {
                    _u setVariable ["sc_shotKey", _shotKey];
                    _u setVariable ["sc_trig",    _t];
                    _u addEventHandler ["FiredNear", {
                        params ["_unit", "_firer", "_distance", "_projectile"];
                        private _sk   = _firer getVariable ["sc_shotKey", ""];
                        private _trig = _firer getVariable ["sc_trig", objNull];
                        if (_sk == "" || isNull _trig) exitWith {};
                        if (_firer distance2D _trig < (triggerArea _trig select 0) * 1.5) then {
                            missionNamespace setVariable [_sk, time];
                        };
                    }];
                    _trackedUnits pushBack _u;
                };
            } forEach _inZoneAll;
            _trackedUnits = _trackedUnits select { alive _x };

            private _lastShot = missionNamespace getVariable [_shotKey, -999];
            private _inCombat = (time - _lastShot) < _cooldown;

            private _inZone = (allUnits + vehicles) select {
                alive _x && !(captive _x) &&
                (side _x in [_sB, _sE, _sI]) &&
                (_x inArea _t)
            };

            private _nW = ({ side _x == _sB } count _inZone);
            private _nE = ({ side _x == _sE } count _inZone);
            private _nI = ({ side _x == _sI } count _inZone);

            private _dominant = sideEmpty;
            if (_nW > _nE && _nW > _nI) then { _dominant = _sB };
            if (_nE > _nW && _nE > _nI) then { _dominant = _sE };
            if (_nI > _nW && _nI > _nE) then { _dominant = _sI };

            if (_inCombat) then {
                _mIcon setMarkerColorLocal "ColorYellow";
                _mIcon setMarkerText format ["%1 | БОЙ", _zName];
            } else {
                if (_dominant == sideEmpty) then {
                    // Зона пуста — иконка серая если нейтральная, иначе цвет владельца
                    private _emptyColor = if (_prevSide == sideEmpty) then { "ColorUnknown" } else { [_prevSide] call SC_fnc_sideColor };
                    _mIcon setMarkerColorLocal _emptyColor;
                    _mIcon setMarkerText _zName;
                    if (_capProgress > 0) then {
                        _capProgress = (_capProgress - _tickInterval) max 0;
                        if (_capProgress == 0) then { _capSide = sideEmpty };
                    };
                } else {
                    if (_dominant != _prevSide) then {
                        if (_dominant != _capSide) then {
                            _capSide     = _dominant;
                            _capProgress = 0;
                        };
                        _capProgress = (_capProgress + _tickInterval) min _capTime;

                        private _pct    = round ((_capProgress / _capTime) * 100);
                        private _filled = round (_pct / 10);
                        private _bar    = "";
                        for "_b" from 1 to 10 do {
                            if (_b <= _filled) then { _bar = _bar + "|" } else { _bar = _bar + "." };
                        };
                        _mIcon setMarkerColorLocal ([_capSide] call SC_fnc_sideColor);
                        _mIcon setMarkerText format ["%1 | %2 %3%", _zName, _bar, _pct];

                        if (_capProgress >= _capTime) then {
                            _prevSide    = _capSide;
                            _capProgress = 0;
                            _capSide     = sideEmpty;
                            _t setVariable [_vName, _prevSide, true];

                            private _newCol = ([_prevSide] call SC_fnc_sideColor);
                            _mIcon setMarkerColorLocal _newCol;
                            { (_x select 1) setMarkerColorLocal _newCol; (_x select 1) setMarkerAlpha _bgAlpha } forEach _cells;
                            _mIcon setMarkerText _zName;
                            hint format ["%1 захвачена!", _zName];

                            if (_prevSide == _sI && !_taskDone) then {
                                _taskDone = true;
                                if (_tasksOn) then {
                                    [_taskID, "SUCCEEDED", true] call BIS_fnc_taskSetState;
                                };
                                [_reward, format ["Захвачена %1!\n+%2 очков команде.", _zName, _reward]] remoteExec ["VS_fnc_triggerReward", 2];
                            };

                            switch (_prevSide) do {
                                case _sB: { [_trigW] call _fnc_fireCaptureTrigger };
                                case _sE: { [_trigE] call _fnc_fireCaptureTrigger };
                                case _sI: { [_trigI] call _fnc_fireCaptureTrigger };
                            };
                        };
                    } else {
                        _capProgress = 0;
                        _capSide     = sideEmpty;
                        _mIcon setMarkerColorLocal ([_prevSide] call SC_fnc_sideColor);
                        _mIcon setMarkerText _zName;
                    };
                };
            };

            // Обновление ячеек фронта
            if (count _inZone == 0) then {
                private _ownerCol = if (_prevSide == sideEmpty) then { "ColorUnknown" } else { [_prevSide] call SC_fnc_sideColor };
                { (_x select 1) setMarkerColorLocal _ownerCol; (_x select 1) setMarkerAlpha _bgAlpha } forEach _cells;
            } else {
                {
                    private _cellPos  = _x select 0;
                    private _cellMark = _x select 1;
                    private _wW = 0; private _wE = 0; private _wI = 0;

                    {
                        private _dist   = (_x distance2D _cellPos) max 1;
                        private _weight = 1 / (_dist ^ 0.8);
                        if   (side _x == _sB) then { _wW = _wW + _weight }
                        else { if (side _x == _sE) then { _wE = _wE + _weight }
                        else { if (side _x == _sI) then { _wI = _wI + _weight } } };
                    } forEach _inZone;

                    private _domSide = sideEmpty;
                    private _domW    = 0;
                    if (_wW >= _wE && _wW >= _wI && _wW > 0) then { _domSide = _sB; _domW = _wW };
                    if (_wE >  _wW && _wE >= _wI && _wE > 0) then { _domSide = _sE; _domW = _wE };
                    if (_wI >  _wW && _wI >  _wE && _wI > 0) then { _domSide = _sI; _domW = _wI };

                    private _total      = _wW + _wE + _wI;
                    private _confidence = if (_total > 0) then { _domW / _total } else { 0 };
                    private _alpha      = 0.15 + (_confidence * 0.4);
                    private _cellColor  = if (_domSide == sideEmpty) then { "ColorUnknown" } else { [_domSide] call SC_fnc_sideColor };

                    _cellMark setMarkerColorLocal _cellColor;
                    _cellMark setMarkerAlpha _alpha;
                } forEach _cells;
            };
        };
    };
};

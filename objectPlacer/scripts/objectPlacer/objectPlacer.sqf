if (!hasInterface) exitWith {};

waitUntil { !isNull player };

execVM "scripts\objectPlacer\objectList.sqf";
waitUntil { !isNil "objectCategories" };

placedObjects    = [];
selectedObject   = "";
placedCount      = 0;
maxPlacedObjects = 20;
previewObject    = objNull;
previewActive    = false;
previewDir       = 0;
previewHeight    = 0;
previewKeyEH      = -1;
previewScrollEH   = -1;
previewMouseEH    = -1;
previewSavedWeapon = "";

fnc_stopPreview = {
    previewActive = false;
    if (!isNull previewObject) then {
        deleteVehicle previewObject;
        previewObject = objNull;
    };
    if (previewKeyEH >= 0) then {
        (findDisplay 46) displayRemoveEventHandler ["KeyDown", previewKeyEH];
        previewKeyEH = -1;
    };
    if (previewScrollEH >= 0) then {
        (findDisplay 46) displayRemoveEventHandler ["MouseZChanged", previewScrollEH];
        previewScrollEH = -1;
    };
    if (previewMouseEH >= 0) then {
        (findDisplay 46) displayRemoveEventHandler ["MouseButtonDown", previewMouseEH];
        previewMouseEH = -1;
    };
    if (!isNil "previewSavedWeapon" && previewSavedWeapon != "") then {
        player selectWeapon previewSavedWeapon;
        previewSavedWeapon = "";
    };
};

fnc_startPreview = {
    [] call fnc_stopPreview;
    if (selectedObject == "") exitWith {};

    previewDir    = getDir player;
    previewHeight = 0;

    private _startPos = player getRelPos [3, 0];
    private _posATL   = getPosATL player;
    _posATL set [0, _startPos select 0];
    _posATL set [1, _startPos select 1];

    previewSavedWeapon = currentWeapon player;
    if (previewSavedWeapon != "") then {
        player selectWeapon "";
    };

    previewObject = (createVehicle [selectedObject, _posATL, [], 0, "NONE"]);
    previewObject allowDamage false;
    player disableCollisionWith previewObject;
    previewObject enableSimulation false;
    previewObject hideObjectGlobal true;
    previewObject hideObject false;
    previewActive = true;

    previewKeyEH = (findDisplay 46) displayAddEventHandler ["KeyDown", {
        params ["_display", "_key", "_shift", "_ctrl", "_alt"];
        if (!previewActive) exitWith { false };
        if (_key == 16) then { previewDir = (previewDir - 5) mod 360; };
        if (_key == 18) then { previewDir = (previewDir + 5) mod 360; };
        false
    }];

    previewMouseEH = (findDisplay 46) displayAddEventHandler ["MouseButtonDown", {
        params ["_display", "_button"];
        if (!previewActive) exitWith { false };
        if (_button == 0) then {
            if (selectedObject != "" && placedCount < maxPlacedObjects) then {
                private _posATL = getPosATL previewObject;
                private _dir    = getDir previewObject;
                [] call fnc_stopPreview;
                OBJECT_PLACER_REQUEST = [selectedObject, _posATL, _dir];
                publicVariableServer "OBJECT_PLACER_REQUEST";
                placedCount = placedCount + 1;
                hint format ["Объектов установлено: %1/%2", placedCount, maxPlacedObjects];
            };
        };
        if (_button == 1) then {
            [] call fnc_stopPreview;
            selectedObject = "";
            hint "Размещение отменено.";
        };
        false
    }];

    previewScrollEH = (findDisplay 46) displayAddEventHandler ["MouseZChanged", {
        params ["_display", "_delta"];
        if (!previewActive) exitWith {};
        previewHeight = previewHeight + (_delta * 0.1);
        previewHeight = (previewHeight max -0.5) min 2;
    }];

    [] spawn {
        while {previewActive && !isNull previewObject} do {
            private _pos    = player getRelPos [3, 0];
            private _posATL = getPosATL player;
            _posATL set [0, _pos select 0];
            _posATL set [1, _pos select 1];
            _posATL set [2, (_posATL select 2) + previewHeight];
            previewObject setPosATL _posATL;
            previewObject setDir previewDir;
            sleep 0.05;
        };
    };
};

fnc_openObjectDialog = {
    [] call fnc_stopPreview;
    createDialog "ObjectPlacerDialog";
    private _catList = findDisplay 9002 displayCtrl 2001;
    lbClear _catList;
    { _catList lbAdd (_x select 0); } forEach objectCategories;
    _catList lbSetCurSel 0;
    [] call fnc_updateObjectList;
};

fnc_updateObjectList = {
    private _catList = findDisplay 9002 displayCtrl 2001;
    private _objList = findDisplay 9002 displayCtrl 2002;
    private _catIdx  = lbCurSel _catList;
    lbClear _objList;
    if (_catIdx < 0) exitWith {};
    private _objects = (objectCategories select _catIdx) select 1;
    {
        _objList lbAdd (_x select 0);
        _objList lbSetData [lbSize _objList - 1, _x select 1];
    } forEach _objects;
    _objList lbSetCurSel 0;
};

fnc_confirmObjectSelect = {
    private _objList = findDisplay 9002 displayCtrl 2002;
    private _idx = lbCurSel _objList;
    if (_idx >= 0) then {
        selectedObject = _objList lbData _idx;
        hint format [
            "Выбрано: %1\nЛКМ — установить | ПКМ — отмена\nQ/E — вращение\nКолесико — высота",
            (_objList lbText _idx)
        ];
    };
    closeDialog 0;
    [] call fnc_startPreview;
};

if (!isNil "playerActionSelect") then { player removeAction playerActionSelect; };

playerActionSelect = player addAction [
    "<t color='#00BFFF'>Выбрать объект</t>",
    { [] call fnc_openObjectDialog; },
    nil, 1.6, false, true, "", "vehicle player == player"
];


player addEventHandler ["Respawn", {
    [] call fnc_stopPreview;
    selectedObject  = "";
    previewObject   = objNull;
    previewActive   = false;
    previewDir      = 0;
    previewHeight   = 0;
    previewKeyEH       = -1;
    previewScrollEH    = -1;
    previewMouseEH     = -1;
    previewSavedWeapon = "";
    execVM "scripts\objectPlacer\objectPlacer.sqf";
}];

player addEventHandler ["GetInMan", {
    if (previewActive) then {
        [] call fnc_stopPreview;
        selectedObject = "";
        hint "Размещение отменено: вы сели в технику.";
    };
}];

fnc_addDeleteAction = {
    params ["_obj"];
    _obj addAction [
        "<t color='#FF0000'>Удалить объект</t>",
        {
            private _obj = _this select 0;
            OBJECT_DELETE_REQUEST = _obj;
            publicVariableServer "OBJECT_DELETE_REQUEST";
            placedCount = (placedCount - 1) max 0;
        },
        nil, 1.5, false, true, "", ""
    ];
};

player createDiaryRecord ["Diary", [
    "Размещение объектов",
    "Для размещения объектов используй контекстное меню (удерживай пробел).<br/><br/><font size='16' color='#00BFFF'>Выбор объекта</font><br/>Нажми «Выбрать объект» — откроется окно со списком категорий слева и объектов справа. Выбери категорию, затем объект и нажми «Выбрать».<br/><br/><font size='16' color='#00BFFF'>Размещение</font><br/><font color='#FFFF00'>Q / E</font> — поворот влево / вправо<br/><font color='#FFFF00'>Колесико мыши</font> — поднять или опустить<br/><font color='#FFFF00'>ЛКМ</font> — установить объект<br/><font color='#FFFF00'>ПКМ</font> — отменить размещение<br/><br/><font size='16' color='#00BFFF'>Удаление</font><br/>Подойди к объекту и выбери «Удалить объект» в контекстном меню.<br/><br/><font color='#FF4444'>Лимит: 20 объектов на игрока. Недоступно в технике.</font>"
]];

// =============================================================================
// VEM — fnc_VEM_common_camo.sqf  v1.3
// Применяет камуфляж. MP-safe. Без sleep — можно вызывать через call.
// =============================================================================

params ["_vehicle", "_camoClass"];

private _vehicleclass = typeof _vehicle;
private _sources = "true" configClasses (configfile >> "CfgVehicles" >> _vehicleclass >> "TextureSources");

{
    if (configName _x isEqualTo _camoClass) exitWith {
        private _fileNames = getArray (_x >> "fileNames");
        {
            [_vehicle, _forEachIndex, _x] call VEM_applyTexture_global;
        } forEach _fileNames;
    };
} forEach _sources;

// Обновляем переменную и список
VEM_current_camo = _camoClass;

// Перестраиваем список с новым маркером [✔]
disableSerialization;
private _display  = findDisplay 5100;
private _camoList = _display displayCtrl 5180;
private _curSel   = lbCurSel _camoList;

lbClear _camoList;
{
    private _idx   = _forEachIndex;
    private _label = camo_display_names select _idx;
    private _cn    = camo_class_names select _idx;
    if (_cn isEqualTo VEM_current_camo) then { _label = format ["[✔] %1", _label]; };
    _camoList lbAdd _label;
} forEach camo_class_names;

_camoList lbSetCurSel _curSel;

// Статус-строка
(_display displayCtrl 5162) ctrlSetText format ["Камуфляж: %1", _camoClass];

// Звуковой сигнал применения (необязательно)
playSound "FD_CP_disconect_SND";

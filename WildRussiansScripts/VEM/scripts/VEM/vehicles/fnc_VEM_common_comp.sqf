// =============================================================================
// VEM — fnc_VEM_common_comp.sqf  v1.9
// Передаём _newVal напрямую в rebuild — не читаем animationPhase после remoteExec.
// =============================================================================

params ["_vehicle", "_compClass", "_listIndex"];

private _vehicleclass = typeof _vehicle;
private _compCfg = configfile >> "CfgVehicles" >> _vehicleclass >> "AnimationSources" >> _compClass;
private _maxVal  = getNumber (_compCfg >> "maxValue");
if (_maxVal isEqualTo 0) then { _maxVal = 1; };

private _current = _vehicle animationPhase _compClass;
private _newVal  = if (_current > 0.5) then { 0 } else { _maxVal };

// Применяем глобально
[_vehicle, _compClass, _newVal] call VEM_applyAnim_global;

// Применяем локально сразу — чтобы animationPhase обновилось до rebuild
_vehicle animate [_compClass, _newVal, true];

// Перестраиваем список — теперь animationPhase уже актуальный
[] call fnc_VEM_rebuild_comp_list;

// Статус-строка
disableSerialization;
private _display = findDisplay 5100;
private _dn = comp_display_names select _listIndex;
(_display displayCtrl 5162) ctrlSetText format [
    "%1: %2", _dn, if (_newVal > 0.5) then {"ВКЛЮЧЁН"} else {"ВЫКЛЮЧЕН"}
];

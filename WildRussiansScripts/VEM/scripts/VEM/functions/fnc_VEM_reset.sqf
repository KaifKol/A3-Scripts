// =============================================================================
// VEM — fnc_VEM_reset.sqf  v1.6
// Сбрасывает внешний вид, обновляет оба списка и подсветку.
// =============================================================================

[VEM_targetvehicle, true, [true]] call bis_fnc_initVehicle;
VEM_check_fnc_delay = false;
VEM_current_camo    = "";

disableSerialization;
private _display = findDisplay 5100;

// Перестраиваем список камуфляжей без маркера [✔]
private _camoList = _display displayCtrl 5180;
lbClear _camoList;
if (!isNil "camo_display_names") then {
    { _camoList lbAdd _x; } forEach camo_display_names;
    if (lbSize _camoList > 0) then { _camoList lbSetCurSel 0; };
};

// Перестраиваем список компонентов (все серые после сброса)
if (!isNil "comp_class_names") then {
    [] call fnc_VEM_rebuild_comp_list;
};

(_display displayCtrl 5162) ctrlSetText "Сброс выполнен";

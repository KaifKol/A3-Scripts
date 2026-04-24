// =============================================================================
// VEM — fnc_VEM_common_camo_check.sqf
// Считывает доступные варианты камуфляжа из CfgVehicles >> TextureSources
// и заполняет список в GUI.
// =============================================================================

disableSerialization;
private _display      = findDisplay 5100;
private _vehicleclass = typeof VEM_targetvehicle;

// Получаем все TextureSources
private _camoPaths = "true" configClasses (configfile >> "CfgVehicles" >> _vehicleclass >> "TextureSources");

camo_class_names   = [];
camo_display_names = [];

{
    private _className   = configName _x;
    private _displayName = getText (_x >> "displayName");
    if (_displayName isEqualTo "") then { _displayName = _className; };
    camo_class_names   pushBack _className;
    camo_display_names pushBack _displayName;
} forEach _camoPaths;

VEM_camo_check_complete = true;

// Заполнить listbox камуфляжа (IDC 5180)
private _camoList = _display displayCtrl 5180;
lbClear _camoList;

{
    _camoList lbAdd _x;
} forEach camo_display_names;

// Выделить первый элемент
if (lbSize _camoList > 0) then {
    _camoList lbSetCurSel 0;
};

// Применение выбранного камуфляжа по клику
_camoList ctrlAddEventHandler ["LBSelChanged", {
    params ["_control", "_selectedIndex"];
    if (_selectedIndex < 0 || _selectedIndex >= count camo_class_names) exitWith {};
    private _camoClass = camo_class_names select _selectedIndex;
    [VEM_targetvehicle, _camoClass] call fnc_VEM_common_camo;
}];

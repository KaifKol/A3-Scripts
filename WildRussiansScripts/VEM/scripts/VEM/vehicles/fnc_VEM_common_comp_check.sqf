// =============================================================================
// VEM — fnc_VEM_common_comp_check.sqf  v1.7
// Заполняет список. Никаких событий — переключение только через кнопку.
// =============================================================================

disableSerialization;
private _vehicleclass = typeof VEM_targetvehicle;

private _compPaths = configProperties [
    configfile >> "CfgVehicles" >> _vehicleclass >> "AnimationSources",
    "!('' isEqualTo getText (_x >> 'DisplayName'))"
];

comp_class_names   = [];
comp_display_names = [];

{
    comp_class_names   pushBack (configName _x);
    comp_display_names pushBack (getText (_x >> "displayName"));
} forEach _compPaths;

VEM_comp_check_complete = true;

[] call fnc_VEM_rebuild_comp_list;

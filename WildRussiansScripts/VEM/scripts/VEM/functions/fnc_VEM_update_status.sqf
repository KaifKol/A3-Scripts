// =============================================================================
// VEM — fnc_VEM_update_status.sqf  v1.6
// Обновляет статус-строку. Исправлена проверка пустой строки.
// =============================================================================

disableSerialization;
private _display = findDisplay 5100;
if (isNull _display) exitWith {};

private _statusCtrl = _display displayCtrl 5162;

if (VEM_active_tab isEqualTo "camo") then {
    private _cur = if (isNil "VEM_current_camo") then {""} else {VEM_current_camo};
    if (_cur isEqualTo "") then {
        _statusCtrl ctrlSetText "Камуфляж: стандартный";
    } else {
        _statusCtrl ctrlSetText format ["Активный камуфляж: %1", _cur];
    };
} else {
    _statusCtrl ctrlSetText "Выберите компонент, затем нажмите «Применить / Отключить»";
};

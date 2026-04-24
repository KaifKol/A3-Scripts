// =============================================================================
// VEM — fnc_VEM_rebuild_comp_list.sqf  v1.9
// Явно устанавливаем цвет каждой строки:
//   включён  → зелёный  [0.3, 0.9, 0.3, 1]
//   выключен → серый    [0.75, 0.75, 0.75, 1]
// lbSetColor вызывается сразу после lbAdd для каждой строки.
// =============================================================================

disableSerialization;
private _display = findDisplay 5100;
if (isNull _display) exitWith {};

private _list    = _display displayCtrl 5181;
private _prevSel = lbCurSel _list;

lbClear _list;

{
    private _idx = _forEachIndex;
    private _cn  = comp_class_names   select _idx;
    private _dn  = comp_display_names select _idx;
    private _on  = (VEM_targetvehicle animationPhase _cn) > 0.5;

    _list lbAdd _dn;

    // Цвет устанавливаем сразу после добавления строки
    _list lbSetColor [_idx, if (_on) then {[0.3, 0.9, 0.3, 1]} else {[0.75, 0.75, 0.75, 1]}];

} forEach comp_class_names;

if (lbSize _list > 0) then {
    private _sel = if (_prevSel >= 0 && _prevSel < lbSize _list) then {_prevSel} else {0};
    _list lbSetCurSel _sel;
};

// =============================================================================
// VEM — fnc_VEM_common_setup.sqf  v1.7
// Камуфляж отключён. Только компоненты. Без LBSelChanged.
// =============================================================================

disableSerialization;
private _display = findDisplay 5100;

// Статус
(_display displayCtrl 5162) ctrlSetText "Выберите компонент и нажмите «Применить / Отключить»";

// Кнопка «Применить / Отключить» — только здесь происходит переключение
(_display displayCtrl 5175) ctrlAddEventHandler ["ButtonClick", {
    disableSerialization;
    private _d    = findDisplay 5100;
    private _list = _d displayCtrl 5181;
    private _sel  = lbCurSel _list;
    if (_sel < 0 || _sel >= count comp_class_names) exitWith {};
    [VEM_targetvehicle, comp_class_names select _sel, _sel] call fnc_VEM_common_comp;
}];

// Кнопка «Сброс»
(_display displayCtrl 5170) ctrlAddEventHandler ["ButtonClick", {
    [] call fnc_VEM_reset;
}];

// Кнопка «Закрыть»
(_display displayCtrl 5199) ctrlAddEventHandler ["ButtonClick", {
    closeDialog 0;
    [] spawn fnc_VEM_variable_cleaner;
}];

// Заполняем список компонентов
[] call fnc_VEM_common_comp_check;

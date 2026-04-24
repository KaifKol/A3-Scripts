// =============================================================================
// VEM — fnc_VEM_variable_cleaner.sqf
// Очищает все временные переменные после закрытия GUI.
// Вызывается автоматически при закрытии диалога (onUnload в RscTitles).
// =============================================================================

uiSleep 0.1;

// Данные камуфляжа
camo_class_names        = nil;
camo_display_names      = nil;
VEM_camo_check_complete = nil;

// Данные компонентов
comp_class_names        = nil;
comp_display_names      = nil;
current_comp            = nil;
VEM_comp_check_complete = nil;

// Общие
VEM_check_fnc_delay     = nil;
VEM_targetvehicle       = nil;
VEM_active_tab          = nil;

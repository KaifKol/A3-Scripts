// =============================================================================
// VEM — fnc_VEM_GUI_check.sqf
// Открывает диалог и маршрутизирует инициализацию по классу техники.
// Исключения загружаются ЛЕНИВО через fnc_VEM_load_exception при первом вызове.
// =============================================================================

disableSerialization;

private _display      = findDisplay 5100;
private _vehicleclass = typeof VEM_targetvehicle;
private _vehiclename  = getText (configFile >> "CfgVehicles" >> _vehicleclass >> "displayName");

// Заголовок окна — имя техники
private _titleCtrl = _display displayCtrl 5150;
_titleCtrl ctrlSetText format ["[VEM] %1", _vehiclename];

// Показываем/скрываем вкладки по настройкам
(_display displayCtrl 5160) ctrlShow VEM_enable_camo;
(_display displayCtrl 5161) ctrlShow VEM_enable_components;

// Кнопка «Сброс»
(_display displayCtrl 5170) ctrlAddEventHandler ["ButtonClick", {
    [] spawn fnc_VEM_reset;
}];

// Кнопка «Закрыть»
(_display displayCtrl 5199) ctrlAddEventHandler ["ButtonClick", {
    closeDialog 0;
    [] spawn fnc_VEM_variable_cleaner;
}];

// По умолчанию показываем вкладку камуфляжа, скрываем компоненты
(_display displayCtrl 5180) ctrlShow true;
(_display displayCtrl 5181) ctrlShow false;
VEM_active_tab = "camo";

// =============================================================================
// Маршрутизация: стандартная техника или исключение
// =============================================================================

if !(_vehicleclass in VEM_exceptions) exitWith {
    [] spawn fnc_VEM_common_setup;
};

switch (true) do {
    case (_vehicleclass in ["I_APC_Wheeled_03_cannon_F","B_APC_Wheeled_03_cannon_F"]): {
        ["Gorgon"] call fnc_VEM_load_exception;
        [] spawn fnc_VEM_Gorgon_setup;
    };
    case (_vehicleclass in ["I_LT_01_AT_F","I_LT_01_scout_F","I_LT_01_AA_F","I_LT_01_cannon_F"]): {
        ["Nyx"] call fnc_VEM_load_exception;
        [] spawn fnc_VEM_Nyx_setup;
    };
    case (_vehicleclass in ["O_APC_Wheeled_02_rcws_F","O_T_APC_Wheeled_02_rcws_ghex_F"]): {
        ["Marid_v1"] call fnc_VEM_load_exception;
        [] spawn fnc_VEM_Marid_v1_setup;
    };
    case (_vehicleclass in ["O_APC_Wheeled_02_rcws_v2_F","O_T_APC_Wheeled_02_rcws_v2_ghex_F"]): {
        ["Marid_v2"] call fnc_VEM_load_exception;
        [] spawn fnc_VEM_Marid_v2_setup;
    };
    case (_vehicleclass in ["B_Heli_Light_01_dynamicLoadout_F","B_Heli_Light_01_armed_F","B_Heli_Light_01_F"]): {
        ["HBPN"] call fnc_VEM_load_exception;
        [] spawn fnc_VEM_HBPN_setup;
    };
    case (_vehicleclass in ["B_Heli_Attack_01_dynamicLoadout_F","B_Heli_Attack_01_F"]): {
        ["Blackfoot"] call fnc_VEM_load_exception;
        [] spawn fnc_VEM_Blackfoot_setup;
    };
    case (_vehicleclass in ["O_Heli_Light_02_dynamicLoadout_F","O_Heli_Light_02_F","O_Heli_Light_02_unarmed_F","O_Heli_Light_02_v2_F"]): {
        ["Orca"] call fnc_VEM_load_exception;
        [] spawn fnc_VEM_Orca_setup;
    };
    case (_vehicleclass in ["B_UGV_01_rcws_F","B_T_UGV_01_rcws_olive_F","O_UGV_01_rcws_F","O_T_UGV_01_rcws_ghex_F","I_UGV_01_rcws_F"]): {
        ["UGV_rcws"] call fnc_VEM_load_exception;
        [] spawn fnc_VEM_UGV_rcws_setup;
    };
    default {
        // Неизвестное исключение — откат на общий setup
        [] spawn fnc_VEM_common_setup;
    };
};

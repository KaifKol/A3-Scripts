// =============================================================================
// VEM — Vehicle Exterior Manager  v1.1
// MP-ready: работает на выделенном и локальном сервере
//
// УСТАНОВКА:
//   init.sqf:         if (hasInterface) then { [] execVM "scripts\VEM\VEM_init.sqf"; };
//   description.ext:  #include "scripts\VEM\VEM_GUI_defines.hpp"
// =============================================================================

if (!hasInterface) exitWith {};

// =============================================================================
// НАСТРОЙКИ
// =============================================================================

VEM_enable_camo             = true;   // Вкладка «Камуфляж»
VEM_enable_components       = true;   // Вкладка «Компоненты»
VEM_interaction_distance    = 10;     // Дистанция взаимодействия (метры)

// Условия активации. [] = всегда.
// 1 = рядом сервисная техника | 2 = в маркерной зоне VEM_service_area_N | 3 = у FOB (KP Lib)
VEM_condition_check_options = [2];  // 2 = зона маркера VEM_service_area_0

VEM_service_vehicle_list = [
    "B_APC_Tracked_01_CRV_F","B_T_APC_Tracked_01_CRV_F",
    "B_Slingload_01_Repair_F","B_Truck_01_Repair_F","B_T_Truck_01_Repair_F",
    "I_Truck_02_box_F","B_G_Offroad_01_repair_F","O_G_Offroad_01_repair_F",
    "I_G_Offroad_01_repair_F","Land_Pod_Heli_Transport_04_repair_F",
    "O_Heli_Transport_04_repair_F","O_Truck_03_repair_F",
    "O_T_Truck_03_repair_ghex_F","O_Truck_02_box_F","C_Truck_02_box_F"
];

VEM_exceptions = [
    "I_APC_Wheeled_03_cannon_F","B_APC_Wheeled_03_cannon_F",
    "I_LT_01_AT_F","I_LT_01_scout_F","I_LT_01_AA_F","I_LT_01_cannon_F",
    "O_APC_Wheeled_02_rcws_F","O_T_APC_Wheeled_02_rcws_ghex_F",
    "O_APC_Wheeled_02_rcws_v2_F","O_T_APC_Wheeled_02_rcws_v2_ghex_F",
    "B_Heli_Light_01_dynamicLoadout_F","B_Heli_Light_01_armed_F","B_Heli_Light_01_F",
    "B_Heli_Attack_01_dynamicLoadout_F","B_Heli_Attack_01_F",
    "O_Heli_Light_02_dynamicLoadout_F","O_Heli_Light_02_F",
    "O_Heli_Light_02_unarmed_F","O_Heli_Light_02_v2_F",
    "B_UGV_01_rcws_F","B_T_UGV_01_rcws_olive_F","O_UGV_01_rcws_F",
    "O_T_UGV_01_rcws_ghex_F","I_UGV_01_rcws_F"
];

// =============================================================================
// ПРЕДЗАГРУЗКА — только ядро и стандартная техника.
// Исключения НЕ грузятся при старте (ленивая загрузка через fnc_VEM_load_exception).
// Это устраняет ошибку "Script not found" для неиспользуемых исключений.
// =============================================================================

fnc_VEM_action           = compileFinal preprocessFileLineNumbers "scripts\VEM\functions\fnc_VEM_action.sqf";
fnc_VEM_GUI_check        = compileFinal preprocessFileLineNumbers "scripts\VEM\functions\fnc_VEM_GUI_check.sqf";
fnc_VEM_reset            = compileFinal preprocessFileLineNumbers "scripts\VEM\functions\fnc_VEM_reset.sqf";
fnc_VEM_condition_check  = compileFinal preprocessFileLineNumbers "scripts\VEM\functions\fnc_VEM_condition_check.sqf";
fnc_VEM_variable_cleaner = compileFinal preprocessFileLineNumbers "scripts\VEM\functions\fnc_VEM_variable_cleaner.sqf";

fnc_VEM_common_setup      = compileFinal preprocessFileLineNumbers "scripts\VEM\vehicles\fnc_VEM_common_setup.sqf";
fnc_VEM_common_camo       = compileFinal preprocessFileLineNumbers "scripts\VEM\vehicles\fnc_VEM_common_camo.sqf";
fnc_VEM_common_camo_check = compileFinal preprocessFileLineNumbers "scripts\VEM\vehicles\fnc_VEM_common_camo_check.sqf";
fnc_VEM_common_comp       = compileFinal preprocessFileLineNumbers "scripts\VEM\vehicles\fnc_VEM_common_comp.sqf";
fnc_VEM_common_comp_check = compileFinal preprocessFileLineNumbers "scripts\VEM\vehicles\fnc_VEM_common_comp_check.sqf";
fnc_VEM_update_status     = compileFinal preprocessFileLineNumbers "scripts\VEM\functions\fnc_VEM_update_status.sqf";
fnc_VEM_rebuild_comp_list = compileFinal preprocessFileLineNumbers "scripts\VEM\vehicles\fnc_VEM_rebuild_comp_list.sqf";

// =============================================================================
// ЛЕНИВАЯ ЗАГРУЗКА ИСКЛЮЧЕНИЙ
// Каждая группа загружается один раз при первом обращении к данному типу техники.
// =============================================================================

fnc_VEM_load_exception = {
    params ["_group"];
    private _base = "scripts\VEM\vehicles\exceptions\";
    switch (_group) do {
        case "Gorgon": {
            if (isNil "fnc_VEM_Gorgon_setup") then {
                fnc_VEM_Gorgon_setup      = compile preprocessFileLineNumbers (_base + "Gorgon\fnc_VEM_Gorgon_setup.sqf");
                fnc_VEM_Gorgon_camo       = compile preprocessFileLineNumbers (_base + "Gorgon\fnc_VEM_Gorgon_camo.sqf");
                fnc_VEM_Gorgon_camo_check = compile preprocessFileLineNumbers (_base + "Gorgon\fnc_VEM_Gorgon_camo_check.sqf");
            };
        };
        case "Nyx": {
            if (isNil "fnc_VEM_Nyx_setup") then {
                fnc_VEM_Nyx_setup      = compile preprocessFileLineNumbers (_base + "Nyx\fnc_VEM_Nyx_setup.sqf");
                fnc_VEM_Nyx_camo       = compile preprocessFileLineNumbers (_base + "Nyx\fnc_VEM_Nyx_camo.sqf");
                fnc_VEM_Nyx_camo_check = compile preprocessFileLineNumbers (_base + "Nyx\fnc_VEM_Nyx_camo_check.sqf");
            };
        };
        case "Marid_v1": {
            if (isNil "fnc_VEM_Marid_v1_setup") then {
                fnc_VEM_Marid_v1_setup      = compile preprocessFileLineNumbers (_base + "Marid\fnc_VEM_Marid_v1_setup.sqf");
                fnc_VEM_Marid_camo          = compile preprocessFileLineNumbers (_base + "Marid\fnc_VEM_Marid_camo.sqf");
                fnc_VEM_Marid_camo_check    = compile preprocessFileLineNumbers (_base + "Marid\fnc_VEM_Marid_camo_check.sqf");
                fnc_VEM_Marid_v1_comp       = compile preprocessFileLineNumbers (_base + "Marid\fnc_VEM_Marid_v1_comp.sqf");
                fnc_VEM_Marid_v1_comp_check = compile preprocessFileLineNumbers (_base + "Marid\fnc_VEM_Marid_v1_comp_check.sqf");
            };
        };
        case "Marid_v2": {
            if (isNil "fnc_VEM_Marid_v2_setup") then {
                fnc_VEM_Marid_v2_setup = compile preprocessFileLineNumbers (_base + "Marid\fnc_VEM_Marid_v2_setup.sqf");
                if (isNil "fnc_VEM_Marid_camo") then {
                    fnc_VEM_Marid_camo       = compile preprocessFileLineNumbers (_base + "Marid\fnc_VEM_Marid_camo.sqf");
                    fnc_VEM_Marid_camo_check = compile preprocessFileLineNumbers (_base + "Marid\fnc_VEM_Marid_camo_check.sqf");
                };
            };
        };
        case "HBPN": {
            if (isNil "fnc_VEM_HBPN_setup") then {
                fnc_VEM_HBPN_setup      = compile preprocessFileLineNumbers (_base + "HBPN\fnc_VEM_HBPN_setup.sqf");
                fnc_VEM_HBPN_camo       = compile preprocessFileLineNumbers (_base + "HBPN\fnc_VEM_HBPN_camo.sqf");
                fnc_VEM_HBPN_camo_check = compile preprocessFileLineNumbers (_base + "HBPN\fnc_VEM_HBPN_camo_check.sqf");
            };
        };
        case "Blackfoot": {
            if (isNil "fnc_VEM_Blackfoot_setup") then {
                fnc_VEM_Blackfoot_setup      = compile preprocessFileLineNumbers (_base + "Blackfoot\fnc_VEM_Blackfoot_setup.sqf");
                fnc_VEM_Blackfoot_camo       = compile preprocessFileLineNumbers (_base + "Blackfoot\fnc_VEM_Blackfoot_camo.sqf");
                fnc_VEM_Blackfoot_camo_check = compile preprocessFileLineNumbers (_base + "Blackfoot\fnc_VEM_Blackfoot_camo_check.sqf");
            };
        };
        case "Orca": {
            if (isNil "fnc_VEM_Orca_setup") then {
                fnc_VEM_Orca_setup      = compile preprocessFileLineNumbers (_base + "Orca\fnc_VEM_Orca_setup.sqf");
                fnc_VEM_Orca_camo       = compile preprocessFileLineNumbers (_base + "Orca\fnc_VEM_Orca_camo.sqf");
                fnc_VEM_Orca_camo_check = compile preprocessFileLineNumbers (_base + "Orca\fnc_VEM_Orca_camo_check.sqf");
            };
        };
        case "UGV_rcws": {
            if (isNil "fnc_VEM_UGV_rcws_setup") then {
                fnc_VEM_UGV_rcws_setup = compile preprocessFileLineNumbers (_base + "UGV_rcws\fnc_VEM_UGV_rcws_setup.sqf");
            };
        };
    };
};

// =============================================================================
// MP — применение изменений ГЛОБАЛЬНО (видно всем игрокам)
// remoteExec ["VEM_applyTexture", 0]  →  выполнить на ВСЕХ машинах (0 = все + сервер)
// =============================================================================

VEM_applyTexture = {
    params ["_veh", "_idx", "_tex"];
    _veh setObjectTexture [_idx, _tex];
};

VEM_applyTexture_global = {
    params ["_veh", "_idx", "_tex"];
    [_veh, _idx, _tex] remoteExec ["VEM_applyTexture", 0];
};

VEM_applyAnim = {
    params ["_veh", "_anim", "_phase"];
    _veh animate [_anim, _phase, true];
};

VEM_applyAnim_global = {
    params ["_veh", "_anim", "_phase"];
    [_veh, _anim, _phase] remoteExec ["VEM_applyAnim", 0];
};

// =============================================================================
// ЗАПУСК
// =============================================================================
if !(VEM_condition_check_options isEqualTo []) then {
    [] spawn fnc_VEM_condition_check;
};

[] spawn fnc_VEM_action;

systemChat "VEM: Vehicle Exterior Manager загружен.";

// Инструктаж
execVM "scripts\VEM\fnc_VEM_briefing.sqf";

// =============================================================================
// VEM — fnc_VEM_action.sqf  v1.2
// Добавляет экшн игроку. MP-safe.
// fnc_VEM_GUI_check вызывается автоматически через onLoad диалога в .hpp
// =============================================================================

disableSerialization;

VEM_condition_result = true;
VEM_cursor_condition = false;

// Передача locality техники клиенту (нужно для setObjectTexture на выд.сервере)
VEM_check_locality = {
    params ["_target", "_caller"];
    if (!(owner _target isEqualTo _caller) && !(unitIsUAV _target)) then {
        _target setOwner _caller;
    };
    if (!(owner _target isEqualTo _caller) && unitIsUAV _target) then {
        (group _target) setGroupOwner _caller;
    };
};

// Экшн «Внешний вид техники»
VEM_action = {
    player addAction [
        "Внешний вид техники",
        {
            if (VEM_cursor_condition) then {
                VEM_targetvehicle = cursorObject;
                [VEM_targetvehicle, clientOwner] remoteExec ["VEM_check_locality", 2];
                uiSleep 0.4;
            } else {
                VEM_targetvehicle = vehicle player;
            };
            // GUI открывается; fnc_VEM_GUI_check вызывается через onLoad в .hpp
            createDialog "VEM_GUI";
        },
        [],
        0,
        false,
        true,
        "",
        "VEM_condition_result && (VEM_cursor_condition || (!(player isEqualTo vehicle player) && (player isEqualTo driver vehicle player)))",
        -1
    ];
};

[] spawn VEM_action;

player addEventHandler ["Respawn", { [] spawn VEM_action; }];

// =============================================================================
// Цикл проверки курсора
// =============================================================================
while {true} do {
    if (
        player isEqualTo vehicle player &&
        !isNull cursorObject &&
        cursorObject isKindOf "AllVehicles" &&
        player distance cursorObject < VEM_interaction_distance &&
        ((crew cursorObject isEqualTo []) || (unitIsUAV cursorObject && !(isUAVConnected cursorObject)))
    ) then {
        private _vc = typeof cursorObject;

        private _camoPaths = "true" configClasses (configfile >> "CfgVehicles" >> _vc >> "TextureSources");
        private _camoOK = (count _camoPaths > 0 || _vc in VEM_exceptions) && VEM_enable_camo;

        private _compPaths = configProperties [
            configfile >> "CfgVehicles" >> _vc >> "AnimationSources",
            "!('' isEqualTo getText (_x >> 'DisplayName'))"
        ];
        private _compOK = count _compPaths > 0 && VEM_enable_components;

        VEM_cursor_condition = (_camoOK || _compOK);
    } else {
        VEM_cursor_condition = false;
    };
    sleep 1;
};

// =============================================================================
// VEM — fnc_VEM_condition_check.sqf  v1.9
// Условие 2: игрок в радиусе 50м от центра маркера VEM_service_area_N
// =============================================================================

VEM_condition_1 = false;
VEM_condition_2 = false;
VEM_condition_3 = false;

while {true} do {

    // ------------------------------------------------------------------
    // Условие 1: рядом сервисная техника
    // ------------------------------------------------------------------
    if (1 in VEM_condition_check_options) then {
        private _near = vehicles inAreaArray [getPos player, 20, 20, 0, false, 20]
            select {(typeof _x) in VEM_service_vehicle_list};
        VEM_condition_1 = (count _near > 0 && alive player);
    };

    // ------------------------------------------------------------------
    // Условие 2: игрок в радиусе 50м от центра маркера VEM_service_area_N
    // ------------------------------------------------------------------
    if (2 in VEM_condition_check_options) then {
        VEM_condition_2 = false;
        {
            if (_x find "VEM_service_area_" > -1) then {
                if (!VEM_condition_2) then {
                    private _markerPos = getMarkerPos _x;
                    private _dist      = player distance2D _markerPos;
                    if (_dist <= 50 && alive player) then {
                        VEM_condition_2 = true;
                    };
                };
            };
        } forEach allMapMarkers;
    };

    // ------------------------------------------------------------------
    // Условие 3: вблизи FOB (KP Liberation)
    // ------------------------------------------------------------------
    if (3 in VEM_condition_check_options) then {
        private _nearFob  = [] call F_getNearestFob;
        private _fobDist  = 9999;
        if (count _nearFob isEqualTo 3) then {
            _fobDist = player distance _nearFob;
        };
        VEM_condition_3 = (_fobDist < GRLIB_fob_range && alive player);
    };

    // ------------------------------------------------------------------
    // Итог
    // ------------------------------------------------------------------
    VEM_condition_result = (VEM_condition_1 || VEM_condition_2 || VEM_condition_3);

    sleep 1;
};

if (isServer) then {
    missionNamespace setVariable ["fnc_initVehicle", {
        params ["_veh"];
        if (!(_veh isKindOf "AllVehicles") || {_veh isKindOf "Man"}) exitWith {};

        [_veh] spawn {
            params ["_veh"];

            waitUntil {
                sleep 0.5;
                private _hull = _veh getHitPointDamage "HitHull";
                isNull _veh || {!alive _veh} || {_hull >= 0.89}
            };

            if (isNull _veh || {!alive _veh}) exitWith {};
            if (_veh getVariable ["burning", false]) exitWith {};

            _veh setVariable ["burning", true, true];
            _veh engineOn false;
            _veh setVehicleLock "LOCKED";

            sleep 10;
            if (isNull _veh || {!alive _veh}) exitWith {};

            private _p1 = "Particle_SmallSmoke_F" createVehicle (getPos _veh);
            _p1 attachTo [_veh, [0, 0, -2]];

            sleep 10;
            if (isNull _veh || {!alive _veh}) exitWith { deleteVehicle _p1; };

            private _p2 = "Particle_MediumSmoke_F" createVehicle (getPos _veh);
            _p2 attachTo [_veh, [0, 0, -2]];
            deleteVehicle _p1;

            sleep 10;
            if (isNull _veh || {!alive _veh}) exitWith { deleteVehicle _p2; };

            private _p3 = "Particle_MediumFire_F" createVehicle (getPos _veh);
            _p3 attachTo [_veh, [0, 0, -1]];
            deleteVehicle _p2;

            sleep 10;
            if (isNull _veh || {!alive _veh}) exitWith { deleteVehicle _p3; };

            private _p4 = "Particle_BigFire_F" createVehicle (getPos _veh);
            _p4 attachTo [_veh, [0, 0, -2]];
            deleteVehicle _p3;

            sleep 10;
            if (isNull _veh || {!alive _veh}) exitWith { deleteVehicle _p4; };

            deleteVehicle _p4;
            _veh setDamage [1, true];
        };
    }];

    [] spawn {
        sleep 3;
        {
            [_x] call (missionNamespace getVariable "fnc_initVehicle");
        } forEach vehicles;
    };

    addMissionEventHandler ["EntityCreated", {
        params ["_entity"];
        [_entity] call (missionNamespace getVariable "fnc_initVehicle");
    }];
};
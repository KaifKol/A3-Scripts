/* 
	
	DESCRIPTION: function assigned to leaders of groups
				 manages rallypoint deployment 
				
	PARAMETERS:  _target  -  object, the object which the action is assigned to
				 _caller  -  object, the unit that activated the action
                 _cooldown - number, duration of redeployment cooldown 
				 
	RETURN:		 None
	
*/ 

#include "\a3\ui_f\hpp\definedikcodes.inc"
params ["_target", "_caller","_cooldown"];

fn_rp_redeploymentCooldown  = {
    params ["_c"];
            
    missionNamespace setVariable ["RP_redeployment_cooldown", true, true];
    private _endTime = time + _c;
            
    while {time < _endTime && (missionNamespace getVariable "RP_redeployment_cooldown")} do {
        missionNamespace setVariable [
            "RP_redeployment_cooldown_remTime", 
            ceil (_endTime - time),
            true
        ];
        sleep 1;
    };
    missionNamespace setVariable ["RP_redeployment_cooldown", false, true];
    missionNamespace setVariable ["RP_redeployment_cooldown_remTime", 0, true];   
};

if (missionNamespace getVariable "RP_redeployment_cooldown") exitWith {
    hintSilent parseText format ["Равертывание новой точки будет доступно через %1 сек.",missionNamespace getVariable "RP_redeployment_cooldown_remTime"];
};
if (_target getVariable ["RP_player_isRPinstalled",false]) exitWith {hint "Точка развертывания уже активна"};

waitUntil { !isNull (findDisplay 46) };

RallyPoint_object_class = missionNamespace getVariable ["RP_RallyPoint_object_class",objNull];

if (local _caller && alive _caller && !(_caller in vehicles) && isNull attachedTo _caller) then {
    private _previewObj = RP_RallyPoint_object_class createVehicleLocal [0,0,0];
    _previewObj setPosASL [0,0,0];
    _previewObj enableSimulationGlobal false;
    _previewObj setVariable ["BIS_enableRandomization", false, true];
    _previewObj allowDamage false;
    _previewObj setVelocity [0,0,0];

    private _placementActive = true;
    private _finalPos = [];
	_caller forceWalk true;
    private _finalDir = 0;
	
	missionNamespace setVariable ["RP_placeConfirmed", false];
	missionNamespace setVariable ["RP_placeCancelled", false];

    // Manage mouse control
    private _display = findDisplay 46;
    private _mouseHandler = _display displayAddEventHandler ["MouseButtonDown", {
        params ["_display", "_button"];
        if (_button == 0) then {
            missionNamespace setVariable ["RP_placeConfirmed", true];
        };
        if (_button == 1) then {
            missionNamespace setVariable ["RP_placeCancelled", true];
        };
		
    }];
	
	private _mouseHandler = _display displayAddEventHandler ["MouseButtonUp", {
        params ["_display", "_button"];
        if (_button == 0) then {
            missionNamespace setVariable ["RP_placeConfirmed", false];
        };
		
    }];
	// Manage rotation via QE
	private _keyHandler = _display displayAddEventHandler ["KeyDown", {
		params ["_displayOrControl", "_key", "_shift", "_ctrl", "_alt"];
		private _rotation = missionNamespace getVariable ["RP_rotation",0]; 
		if (_key isEqualTo 16) then { _rotation = _rotation - 1; }; // Q
        if (_key isEqualTo 18) then { _rotation = _rotation + 1; }; // E
		missionNamespace setVariable ["RP_rotation",_rotation%360];
	}];

    hintSilent "Размещение точки развертывания:\nЛКМ - установить | ПКМ - отмена\nQ/E - вращение";

    // Preview cycle
    while {_placementActive} do {
		_caller action ["SWITCHWEAPON", _caller, _caller, -1];
		
        private _cameraPos = positionCameraToWorld [0,0,0];
        private _cursorWorld = screenToWorld [0.5, 0.5];
        private _direction = _cursorWorld vectorDiff _cameraPos;
        _rayEnd = _cameraPos vectorAdd (_direction vectorMultiply 1);
		
		[_previewObj] call RallyPointC_fnc_RP_checkCollision;
		
		if ((vectorMagnitude _direction) >= 5) then {_direction = (vectorNormalized _direction) vectorMultiply 5};

		_fallback = _cameraPos vectorAdd (_direction vectorMultiply 1);
        _fallback set [2, getTerrainHeightASL _fallback];
        private _pos = _fallback;

        _previewObj setPosASL _pos;
        _previewObj setDir (missionNamespace getVariable ["RP_rotation",0]);
        _previewObj setVectorUp surfaceNormal _pos;

        // Manage conf. & cancel.
        if (missionNamespace getVariable ["RP_placeConfirmed", false]) then {
			if (!([_previewObj] call RallyPointC_fnc_RP_checkCollision)) then {
				_finalPos = _pos;
				_finalDir = missionNamespace getVariable ["RP_rotation",0];
				_placementActive = false;
				_target setVariable ["RP_player_isRPinstalled",true];
			} else {
				hint "Невозможно разместить";
			};
        };
        if (missionNamespace getVariable ["RP_placeCancelled", false] || !alive _caller) then {
            _placementActive = false;
			missionNamespace setVariable ["RP_placeCancelled",true];
        };
        sleep 0.1;
    };

    // post-deployment
    _display displayRemoveEventHandler ["MouseButtonDown", _mouseHandler];
	_display displayRemoveEventHandler ["KeyDown", _KeyHandler];
	missionNamespace setVariable ["RP_rotation",0];
	
    deleteVehicle _previewObj;
    hintSilent "";
	
	if (((missionNamespace getVariable ["RP_placeCancelled",false])) and !(missionNamespace getVariable ["RP_placeConfirmed", false])) exitWith{_caller forceWalk false;};
	
    // Deployment on confirmation
    if (!isNil "_finalPos" && {!isNil "_finalDir"}) then {
        private _realObj = createVehicle [RP_RallyPoint_object_class, _finalPos, [], 0, "CAN_COLLIDE"];
        _realObj setDir _finalDir;
        _realObj setVectorUp surfaceNormal _finalPos;
        _realObj setPosASL _finalPos;
        _realObj enableSimulationGlobal true;
        _realObj allowDamage true;
		_caller forceWalk false;
		_caller setVariable ["RP_object",_realObj,true];

        // Redeployment cooldown
        [_cooldown] call fn_rp_redeploymentCooldown;
		
        // Create rallypoint 
        _caller addAction [
            "<t color='#FF5555'>Удалить точку развертывания</t>",
            {
				params ["_targetn", "_callern", "_actionIdn", "_argumentsn"];
				_targetn setVariable ["RP_player_isRPinstalled",false];
				_targetn setVariable ["RP_object",objNull,true];
                deleteVehicle (_this select 3);
				_targetn removeAction _actionIdn;
            },
            [_realObj],
            1.5,
            false,
            true,
            "",
            "!(missionNamespace getVariable 'RP_redeployment_cooldown')"
        ];
    };
};
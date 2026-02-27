params [
	["_logic", objNull, [objNull]],
	["_units", [], [[]]],
	["_activated", true, [true]]
];

diag_log "[RPC_RPS] MODULE INIT";
diag_log format ["[RPC_RPS] Logic: %1 | Activated: %2", _logic, _activated];
diag_log format ["[RPC_RPS] Synced Units Count: %1", count _units];

if ((count _units > 1) or (count _units == 0)) exitWith {};

diag_log "[RPC_RPS] Synced object is present and singular";
diag_log "[RPC_RPS] Proceeding init";

sleep 10;

RallyPoint_object_class = _logic getVariable ["RPS_rpClass","Land_TentSolar_01_folded_sand_F"];
RallyPoint_redeployment_cooldown = _logic getVariable ["RPS_rpRedeploymentCooldown",300];
Base_object_variable = _units select 0;
Teleport_hold_duration = _logic getVariable ["RPS_teleportHoldDuration",120];
Teleport_window_duration = _logic getVariable ["RPS_teleportWindowDuration",20];
Teleport_alarm = _logic getVariable ["RPS_teleportAlarm",True];
Teleport_alarm_sound_class = _logic getVariable ["RPS_teleportAlarmSoundClass","Sound_Alarm"];
Teleport_initialActivationDelay = _logic getVariable ["RPS_teleportInitialActivationDelay",300];

missionNamespace setVariable ["RP_respawnHold", false, true];
missionNamespace setVariable ["RP_redeployment_cooldown", false, true];
missionNamespace setVariable ["RP_base_object_variable", Base_object_variable, true];
missionNamespace setVariable ["RP_respawnHold_duration", Teleport_hold_duration, true];
missionNamespace setVariable ["RP_RallyPoint_object_class", RallyPoint_object_class, true];
missionNamespace setVariable ["RP_respawn_windowDuration", Teleport_window_duration, true];
missionNamespace setVariable ["RP_vrotebalrepickcd", RallyPoint_redeployment_cooldown,true];

diag_log "[RPC_RPS] Functions:";

fn_rp_clientSetup = {
	fn_rp_getPlayerGroupLeader = {
		params ["_unit"];
		private _leader = leader group _unit;
		if (_leader in allPlayers && alive _leader && side _leader != sideLogic) exitWith { _leader };
		private _players = units (group _unit) select { _x in allPlayers && alive _x && side _x != sideLogic };
		if (count _players > 0) then { _players select 0 } else { objNull }
	};

	fn_rp_addAction_leader = {
		_this addAction [
			"<t color='#4c9141'>Установить точку развертывания</t>",
			{
				params ["_target", "_caller", "_actionId", "_arguments"];
				[_target, _caller, _this select 3] call RallyPointC_fnc_RP_spawnRallyPoint
			},
			[RallyPoint_redeployment_cooldown],
			1.5,
			false,
			true,
			"",
			"(_target == _this) && (alive _target)"
		];
	};

	fn_rp_deleteAction = {
		if (_this getVariable ["RP_player_isRPinstalled", nil]) then {
			_this addAction [
				"<t color='#FF5555'>Удалить точку развертывания</t>",
				{
					params ["_targetn", "_callern", "_actionIdn", "_argumentsn"];
					_targetn setVariable ["RP_player_isRPinstalled", false];
					_targetn setVariable ["RP_object", objNull, true];
					deleteVehicle (_this select 3);
					_targetn removeAction _actionIdn;
				},
				[_this getVariable "RP_object"],
				1.5,
				false,
				true,
				"",
				"(_target == _this) && (alive _target)"
			];
		};
	};

	// Добавляем action лидера только если игрок является лидером группы
	if (player == leader group player) then {
		player call fn_rp_addAction_leader;
	};

	player call fn_rp_deleteAction;

	player addMPEventHandler ["MPRespawn", {
		params ["_unit", "_corpse"];
		removeAllActions _corpse;
		if ("INCAPACITATED" != (lifeState _unit)) then {
			if (_unit == leader group _unit) then {
				_unit call fn_rp_addAction_leader;
			};
			_unit call fn_rp_deleteAction;
		};
	}];

	private _baseObj = missionNamespace getVariable ["RP_base_object_variable", objNull];
	if (!isNull _baseObj) then {
		_baseObj addAction [
			"Переместиться на точку развертывания",
			{
				params ["_target", "_caller", "_actionId", "_arguments"];
				private _myLeader = leader group _caller;
				[_caller, _myLeader] call RallyPointC_fnc_RP_handleTeleportRequest;
			},
			nil,
			1.5,
			false,
			true,
			""
		];
	};
};

diag_log "[RPC_RPS] Sending client setup via remoteExec (JIP enabled)...";

[fn_rp_clientSetup] remoteExec ["call", 0, true];

diag_log "[RPC_RPS] Client setup dispatched";
diag_log "[RPC_RPS] calling RallyPoint_fnc_RP_processRallyClock";

[Teleport_alarm, Teleport_alarm_sound_class, Teleport_initialActivationDelay] call RallyPointC_fnc_RP_processRallyClock;

diag_log "[RPC_RPS] Successfully initialized";
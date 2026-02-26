params [
	["_logic", objNull, [objNull]],		// Argument 0 is module logic
	["_units", [], [[]]],				// Argument 1 is a list of affected units (affected by value selected in the 'class Units' argument))
	["_activated", true, [true]]		// True when the module was activated, false when it is deactivated (i.e., synced triggers are no longer active)
];

diag_log "[RPC_RPS] MODULE INIT";
diag_log format ["[RPC_RPS] Logic: %1 | Activated: %2", _logic, _activated];
diag_log format ["[RPC_RPS] Synced Units Count: %1", count _units];

if ((count _units > 1) or (count _units == 0)) exitWith {}; // exit if no teleporter object is provided or several objects are synced

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

/*
RP_checkCollision = compile preprocessFileLineNumbers "RallyPoint\fn_RP_checkCollision.sqf";
RP_getLeaders = compile preprocessFileLineNumbers "RallyPoint\fn_RP_getLeaders.sqf";
RP_spawnRallyPoint = compile preprocessFileLineNumbers "RallyPoint\fn_RP_spawnRallyPoint.sqf";
RP_getSubs = compile preprocessFileLineNumbers "RallyPoint\fn_RP_getSubs.sqf";
RP_processRallyClock = compile preprocessFileLineNumbers "RallyPoint\fn_RP_processRallyClock.sqf";
RP_handleTeleportRequest = compile preprocessFileLineNumbers "RallyPoint\fn_RP_handleTeleportRequest.sqf";
*/

missionNamespace setVariable ["RP_respawnHold",false,true];
missionNamespace setVariable ["RP_redeployment_cooldown",false,true];

playerLeaders = call RallyPointC_fnc_RP_getLeaders;
currentPlayers = call BIS_fnc_listPlayers;

diag_log format ["Leaders: %1",playerLeaders];

missionNamespace setVariable ["RP_base_object_variable",Base_object_variable];
missionNamespace setVariable ["RP_respawnHold_duration",Teleport_hold_duration];
missionNamespace setVariable ["RP_RallyPoint_object_class",RallyPoint_object_class];
missionNamespace setVariable ["RP_respawn_windowDuration",Teleport_window_duration];

diag_log "[RPC_RPS] Functions:";

fn_rp_getPlayerGroupLeader = {
    params ["_unit"];
    private _leader = leader group _unit;
    if (_leader in allPlayers && alive _leader && side _leader != sideLogic) exitWith { _leader };
    private _players = units (group _unit) select { _x in allPlayers && alive _x && side _x != sideLogic };
    if (count _players > 0) then { _players select 0 } else { objNull }
};
diag_log "[RPC_RPS] fn_rp_getPlayerGroupLeader";

fn_rp_addAction_leader = {
	_this addAction [ 
		"<t color='#4c9141'>Установить точку развертывания</t>", 
		{
			params ["_target", "_caller", "_actionId", "_arguments"];

			[_target, _caller,RallyPoint_redeployment_cooldown] call RallyPointC_fnc_RP_spawnRallyPoint
		},
		nil,
		1.5,
		false,
		true,
		"",
		"(_target == _this) && (alive _target)"
	];
};
diag_log "[RPC_RPS] fn_rp_addAction_leader";

fn_rp_deleteAction = {
	if (_this getVariable ["RP_player_isRPinstalled",nil]) then {
		_this addAction [
				"<t color='#FF5555'>Удалить точку развертывания</t>",
				{
					params ["_targetn", "_callern", "_actionIdn", "_argumentsn"];
					_targetn setVariable ["RP_player_isRPinstalled",false];
					_targetn setVariable ["RP_object",objNull,true];
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
diag_log "[RPC_RPS] fn_rp_deleteAction";
diag_log "[RPC_RPS] adding actions to all leaders...";

[{
	_x call fn_rp_addAction_leader;
	_x addMPEventHandler ["MPRespawn",{
		params ["_unit", "_corpse"];
		removeAllActions _corpse;
		if ("INCAPACITATED" != (lifeState _unit)) then {
			_unit call fn_rp_addAction_leader;
			_unit call fn_rp_deleteAction;
		};
	}];
}] remoteExec ["call",playerLeaders];

diag_log "[RPC_RPS] leader actions added";
diag_log "[RPC_RPS] creating acton for teleporter";

[{
	Base_object_variable addAction [
		"Переместиться на точку развертывания",
		{
			params ["_target", "_caller", "_actionId", "_arguments"];
			[_caller,_caller call fn_rp_getPlayerGroupLeader] call RallyPointC_fnc_RP_handleTeleportRequest;
		},
		nil,
		1.5,
		false,
		true,
		""
	];
}] remoteExec ["call",currentPlayers];

diag_log "[RPC_RPS] teleporter action added";
diag_log "[RPC_RPS] calling RallyPoint_fnc_RP_processRallyClock";

[Teleport_alarm, Teleport_alarm_sound_class, Teleport_initialActivationDelay] call RallyPointC_fnc_RP_processRallyClock;

diag_log "[RPC_RPS] Successefully initialized";

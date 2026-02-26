/* 
	
	DESCRIPTION: handles teleport request
				
	PARAMETERS:  _caller  -  object, the unit that activated the action 
				 _leader  -  object, the leader of _caller 
				 
	RETURN:		 None 
	
*/ 

params ["_caller","_leader"];
if ((_leader getVariable ["RP_object",objNull]) isEqualTo objNull) exitWith {
	hintSilent "Точка развертывания не активна";
	"Установи точку развертывания\nНу пожалуйста\nуебок" remoteExec ["hint",_leader];
};

teleportAvailable = missionNamespace getVariable ["RP_respawnHold",nil];

if (teleportAvailable) then {
	private _rpobj = (_this call fn_rp_getPlayerGroupLeader) getVariable ['RP_object',objNull];
	if (!(_rpobj isEqualTo objNull)) then {
		["TAG_aVeryUniqueID2", true, 0.5] call BIS_fnc_blackOut;
		uisleep 0.5;
		
		private _2dpos = [_rpobj,1,5,2,0] call BIS_fnc_findSafePos;
		_caller setPosASL [_2dpos # 0,_2dpos # 1,getTerrainHeightASL _2dpos];
		
		["TAG_aVeryUniqueID2", true, 0.5] call BIS_fnc_blackIn;
	};
} else {
	if ((missionNamespace isNil "RP_respawnHold_duration") || (missionNamespace isNil "RP_respawnHold_counter")) exitWith { hint "Телепортация невозможна" };
	hintSilent parseText format ["Телепортация невозможна,<br/>Ожидайте %1 сек.", (missionNamespace getVariable "RP_respawnHold_duration") - (missionNamespace getVariable "RP_respawnHold_counter")];
};

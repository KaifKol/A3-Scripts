/* 
	
	DESCRIPTION: creates and manages variables
				 responsible for creating wave-a-like
				 player teleportation to assigned rally points
				
	PARAMETERS:  _alarm - Boolean
				 _sound - String, sound class
				 _delay - Number, activation delay 
				 
	RETURN:		 None 
	
*/ 
params["_alarm","_sound","_delay"];

uiSleep _delay;

missionNamespace setVariable ["RP_respawnHold",false];
teleportHoldDuration = missionNamespace getVariable "RP_respawnHold_duration";
teleportClosingTime = teleportHoldDuration + (missionNamespace getVariable "RP_respawn_windowDuration");
baseObj = missionNamespace getVariable ["RP_base_object_variable",objNull];

release = true;
counter = 0;

while {true} do {
	missionNamespace setVariable ["RP_respawnHold_counter",counter];
	if ((counter>=teleportHoldDuration) and release) then {
		missionNamespace setVariable ["RP_respawnHold",true];
		release = false;
		[_alarm,_sound] spawn {
			if (_this select 0) then {alarm = createSoundSourceLocal [_this select 1, position baseObj, [], 0];};
			sleep (missionNamespace getVariable ["RP_respawn_windowDuration",5]);
			if (_this select 0) then {deleteVehicle alarm};
		};
	}; 

	if ((counter>=teleportClosingTime) and !release) then {
		missionNamespace setVariable ["RP_respawnHold",false];
		release = true;
		counter = 0;
	};
	
	uiSleep 1;
	counter = counter + 1;
	
};
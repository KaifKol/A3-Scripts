class CfgPatches
{
	class RallyPointC_RallyPointSystem
	{
		units[] = { "RallyPointC_RallyPointSystem" };
		requiredVersion = 1.0;
		requiredAddons[] = { "A3_Modules_F" };
	};
};
class CfgFactionClasses
{
	class NO_CATEGORY;
	class RallyPointC_Modules: NO_CATEGORY
	{
		displayName = "RallyPoint Modules";
	};
};
class CfgFunctions
{
	class RallyPointC
	{
		class RallyPointSystem
		{
			file = "RallyPointSystem\functions";
			class RP_init {};
			class RP_getLeaders {};
			class RP_getSubs {};
			class RP_processRallyClock {};
			class RP_spawnRallypoint {};
			class RP_handleTeleportRequest {};
			class RP_checkCollision {};
		};
	};
};
class CfgVehicles
{
	class Logic;
	class Module_F: Logic
	{
		class AttributesBase
		{
			class Default;
			class Edit;
			class Checkbox;
			class ModuleDescription;
			class Units;
		};
		class ModuleDescription
		{
			class Anything;
		};
	};
	class RallyPointC_RallyPointSystem: Module_F
	{
		scope = 2;
		displayName="Rally Point System";
		category="RallyPointC_Modules";
		function="RallyPointC_fnc_RP_init";
		functionPriority=1;
		isGlobal=0;
		isTriggerActivated=0;
		isDisposable=1;
		is3DEN=0;
		canSetArea=0;
		canSetAreaShape=0;
		canSetAreaHeight=0;
		class Attributes: AttributesBase
		{
			class Units: Units
			{
				property = "RPS_Units";
			};
			class RPS_rpClass: Edit
			{
				displayName = "Rally point object class";
				tooltip = "Enter the class name of the object to be used as the rally point";
				property = "RPS_rpClass";
				typeName = "STRING";
				defaultValue = """Land_TentSolar_01_folded_sand_F""";
			};
			class RPS_teleportHoldDuration: Edit
			{
				displayName = "Deactivation duration";
				tooltip = "Enter the duration (in seconds) for which the teleporter remains disabled";
				property = "RPS_teleportHoldDuration";
				typeName = "NUMBER";
				defaultValue = "120";
			};
			class RPS_teleportWindowDuration: Edit
			{
				displayName = "Activation duration";
				tooltip = "Enter the duration (in seconds) for which the teleporter remains active";
				property = "RPS_teleportWindowDuration";
				typeName = "NUMBER";
				defaultValue = "20";
			};
			class RPS_teleportInitialActivationDelay: Edit 
			{
				displayName = "Initial Activation Delay";
				tooltip = "Enter the duration (in seconds) for which the teleporter remains disabled at start of the mission";
				property = "RPS_teleportInitialActivationDelay";
				typeName = "NUMBER";
				defaultValue = "300"
			};
			class RPS_rpRedeploymentCooldown: Edit 
			{
				displayName = "Redeployment cooldown";
				tooltip = "Enter the duration (in seconds) for rally point redeployment cooldown";
				property = "RPS_rpRedeploymentCooldown";
				typeName = "NUMBER";
				defaultValue = "300"
			};
            class RPS_teleportAlarm: Checkbox
            {
                displayName = "Siren";
                tooltip = "Enable siren sound when teleport is activated?";
                property = "RPS_teleportAlarm";
                typeName = "BOOLEAN";
                defaultValue = "TRUE"
            };
            class RPS_teleportAlarmSoundClass: Edit
            {
                displayName = "Siren sound class";
				tooltip = "Enter the desired sound class for the siren";
				property = "RPS_teleportAlarmSoundClass";
				typeName = "STRING";
				defaultValue = """Sound_Alarm"""
            };
			class ModuleDescription: ModuleDescription {};
		};
		class ModuleDescription: ModuleDescription
		{
			description[] =
			{
				"Synchronize this module with the desired teleport object.",
				"The teleport object will enable the use of the rally point system.",
				"Will not work if none or more than one object are synced.",
               	"TvT compatibility has not been tested."
			};
		};
	};
};

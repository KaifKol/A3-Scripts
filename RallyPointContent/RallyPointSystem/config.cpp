class CfgPatches
{
	class RallyPointC_RallyPointSystem
	{
		units[]=
		{
			"RallyPointC_RallyPointSystem"
		};
		requiredVersion=1;
		requiredAddons[]=
		{
			"A3_Modules_F"
		};
	};
};
class CfgFactionClasses
{
	class NO_CATEGORY;
	class RallyPointC_Modules: NO_CATEGORY
	{
		displayName="RallyPoint Modules";
	};
};
class CfgFunctions
{
	class RallyPointC
	{
		class RallyPointSystem
		{
			file="RallyPointSystem\functions";
			class RP_init
			{
			};
			class RP_getLeaders
			{
			};
			class RP_getSubs
			{
			};
			class RP_processRallyClock
			{
			};
			class RP_spawnRallypoint
			{
			};
			class RP_handleTeleportRequest
			{
			};
			class RP_checkCollision
			{
			};
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
		scope=2;
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
				property="RPS_Units";
			};
			class RPS_rpClass: Edit
			{
				displayName="$STR_RPS_RPCLASS_DISPLAYNAME";
				tooltip="$STR_RPS_RPCLASS_TOOLTIP";
				property="RPS_rpClass";
				typeName="STRING";
				defaultValue="""Land_TentSolar_01_folded_sand_F""";
			};
			class RPS_teleportHoldDuration: Edit
			{
				displayName="$STR_RPS_TELEPORTHOLDDURATION_DISPLAYNAME";
				tooltip="$STR_RPS_TELEPORTHOLDDURATION_TOOLTIP";
				property="RPS_teleportHoldDuration";
				typeName="NUMBER";
				defaultValue="120";
			};
			class RPS_teleportWindowDuration: Edit
			{
				displayName="$STR_RPS_TELEPORTWINDOWDURATION_DISPLAYNAME";
				tooltip="$STR_RPS_TELEPORTWINDOWDURATION_TOOLTIP";
				property="RPS_teleportWindowDuration";
				typeName="NUMBER";
				defaultValue="20";
			};
			class RPS_teleportInitialActivationDelay: Edit
			{
				displayName="$STR_RPS_TELEPORTINITIALACTIVATIONDELAY_DISPLAYNAME";
				tooltip="$STR_RPS_TELEPORTINITIALACTIVATIONDELAY_TOOLTIP";
				property="RPS_teleportInitialActivationDelay";
				typeName="NUMBER";
				defaultValue="300";
			};
			class RPS_rpRedeploymentCooldown: Edit
			{
				displayName="$STR_RPS_RPREDEPLOYMENTCOOLDOWN_DISPLAYNAME";
				tooltip="$STR_RPS_RPREDEPLOYMENTCOOLDOWN_TOOLTIP";
				property="RPS_rpRedeploymentCooldown";
				typeName="NUMBER";
				defaultValue="300";
			};
			class RPS_teleportAlarm: Checkbox
			{
				displayName="$STR_RPS_TELEPORTALARM_DISPLAYNAME";
				tooltip="$STR_RPS_TELEPORTALARM_TOOLTIP";
				property="RPS_teleportAlarm";
				typeName="BOOLEAN";
				defaultValue="true";
			};
			class RPS_teleportAlarmSoundClass: Edit
			{
				displayName="$STR_RPS_TELEPORTALARMSOUNDCLASS_DISPLAYNAME";
				tooltip="$STR_RPS_TELEPORTALARMSOUNDCLASS_TOOLTIP";
				property="RPS_teleportAlarmSoundClass";
				typeName="STRING";
				defaultValue="""Sound_Alarm""";
			};
			class ModuleDescription: ModuleDescription
			{
			};
		};
		class ModuleDescription: ModuleDescription
		{
			description[]=
			{
				"$STR_RPS_MODULE_DESCRIPTION_0",
				"$STR_RPS_MODULE_DESCRIPTION_1",
				"$STR_RPS_MODULE_DESCRIPTION_2",
				"$STR_RPS_MODULE_DESCRIPTION_3"
			};
		};
	};
};
class cfgMods
{
	author="Mogoff";
	timepacked="1770848355";
};

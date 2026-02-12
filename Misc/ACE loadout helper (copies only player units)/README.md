**Script for easier ACE arsenal setup (copies loadout of player units only)**

Insert it into the **Extended Debug Console** (which can be activated by pausing while testing the scenario) and execute it locally. After that, go into the editor and import it into the arsenal (it works a little imperfectly but completes most of the work).

```sqf
AllPlayableUnitsItems = []; 
{AllPlayableUnitsItems = AllPlayableUnitsItems + [(headgear _x)] + [(goggles _x)] + (assignedItems _x) + (backpackitems _x)+ [(backpack _x)] + (uniformItems _x) + [(uniform _x)] + (vestItems _x) + [(vest _x)] + (magazines _x) + (weapons _x) + (primaryWeaponItems _x)+ (primaryWeaponMagazine _x) + (handgunMagazine _x) + (handgunItems _x) + (secondaryWeaponItems _x) + (secondaryWeaponMagazine _x)} forEach (playableUnits + switchableUnits); 
AllPlayableUnitsItems = AllPlayableUnitsItems select {count _x > 0}; 
AllPlayableUnitsItems = AllPlayableUnitsItems arrayIntersect AllPlayableUnitsItems; 
copyToClipboard str AllPlayableUnitsItems;
```
```sqf
if (isServer) then {
    ["1", "SUCCEEDED", true] call BIS_fnc_taskSetState; // taskNumber, taskState, showHint
};
```
* Run on debug console from server-side
* Remove comments
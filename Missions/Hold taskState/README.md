```sqf
if (isServer) then { 
    ["1", "SUCCEEDED", true] call BIS_fnc_taskSetState; // taskNumber, taskState, showHint
}; 
```
* Add to `Code executed` in `Object: Action on button hold`
* Remove comments
* Server-side
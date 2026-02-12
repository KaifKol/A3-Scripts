```sqf
this addAction [ 
    "Complete task", 
    { 
        params ["_target", "_caller", "_actionId"]; 
  
        ["1", "SUCCEEDED", true] remoteExec ["BIS_fnc_taskSetState", 0, true]; // taskNumber, taskState, showHint
 
        [_target] remoteExec ["deleteVehicle", 2]; 
 
        _target remoteExec ["removeAllActions", 0]; 
    }, 
    nil, 
    1.5, 
    true, 
    true, 
    "", 
    "", 
    3 // distance to use in meters
]; 
```
* Add to object init
* Remove comments
* *Server-side
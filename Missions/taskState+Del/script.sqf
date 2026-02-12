this addAction [ 
    "Complete task", 
    { 
        params ["_target", "_caller", "_actionId"]; 
  
        ["1", "SUCCEEDED", true] remoteExec ["BIS_fnc_taskSetState", 0, true]; 
 
        [_target] remoteExec ["deleteVehicle", 2]; 
 
        _target remoteExec ["removeAllActions", 0]; 
    }, 
    nil, 
    1.5, 
    true, 
    true, 
    "", 
    "", 
    3 
]; 
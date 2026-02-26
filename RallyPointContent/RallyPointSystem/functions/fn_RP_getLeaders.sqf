/* 
	
	DESCRIPTION: finds all playable group leaders
				
	PARAMETERS:  None 
				 
	RETURN:		 Array (array of all leaders)
	
*/ 
private _allPlayers = call BIS_fnc_listPlayers;
private _playerSide = side (_allPlayers select 0);
private _leaders = _allPlayers select {
    private _player = _x;
	
    if (side _player == sideLogic) exitWith { false };
    if (!alive _player || {side group _player != _playerSide}) exitWith { false };
    
    _player == leader group _player
};
_leaders
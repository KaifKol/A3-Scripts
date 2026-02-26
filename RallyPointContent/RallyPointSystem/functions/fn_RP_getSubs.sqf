/* 
	
	DESCRIPTION: finds all playable subordinates of given leader
				
	PARAMETERS:  None 
				 
	RETURN:		 Array (array of subordinates for given group leader)
	
*/ 

leaders = [] call RP_getLeaders;

{
	private _grp = group _x;
	subordinates = units _grp select {
		_x in allPlayers &&
		alive _x &&
		side _x != sideLogic &&
		_x != _x
	};
}forEach leaders;

subordinates
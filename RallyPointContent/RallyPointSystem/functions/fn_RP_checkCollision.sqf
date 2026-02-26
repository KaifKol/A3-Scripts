/* 
	
	DESCRIPTION: checks for collision for six vectors 
				 with origins in object's barycenter 
				 and ends in centers of each face of parallelepiped
				
	PARAMETERS:  _obj - object
				 
	RETURN:		 Boolean (true if at least one coolision is detected)
	
*/ 

params ["_obj"];

obj_centre = getPosWorld _obj;
dimensions = _obj call BIS_fnc_boundingBoxDimensions;
a = ( dimensions # 0 ) / 2;
b = ( dimensions # 1 ) / 2;
c = ( dimensions # 2 ) / 2;
result = false;

top_collider = obj_centre VectorAdd [0,0,2];
side_a_collider = obj_centre VectorAdd [a,0,0];
side_b_collider = obj_centre VectorAdd [0,b,0];
oppside_a_collider = obj_centre VectorAdd [-a,0,0];
oppside_b_collider = obj_centre VectorAdd [0,-b,0];
bottom_collider = obj_centre VectorAdd [0,0,-c];

colliders = [top_collider,side_a_collider,side_b_collider,oppside_a_collider,oppside_b_collider,bottom_collider];

{
	if ( ( lineIntersects [ obj_centre, _x, _obj] ) == true ) exitWith {result = true};
}forEach colliders;

if (((getPosASL _obj) # 3) < 0) then {result = true}; // underwater = collision. (idk if lineIntersects considers underwater as intersect case)

result 
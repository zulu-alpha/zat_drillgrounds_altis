/*

    Author: Phoenix of Zulu-Alpha

    Description: Runs local group update, circle drawing and draw job tasks in a loop for
	             all groups regardless of locality.

    Params: None

    Returns: None

*/

[] spawn {
	missionNamespace setVariable ["knowledge_isActive", true, true];

	private ["_eh_index", "_drawJobs", "_drawJobs_isNear"];
	if (hasInterface) then {
		knowledge_drawJobs = [];
		knowledge_drawJobs_isNear = [];
		_drawJobs = [];
		_drawJobs_isNear = [];
		_eh_index = addMissionEventHandler ["Draw3D", {call knowledge_fnc_draw}];
	};

	while {sleep 0.5; knowledge_isActive} do {
		{
			private _group = _x;
			private _group_ID = _group call BIS_fnc_netId;
			{
				private _player_ID = _x call BIS_fnc_netId;
				[_group, _player_ID, _x] call knowledge_fnc_groupUpdateKnowledge;
				if (hasInterface) then {
					private _knowledge = _group getVariable [
						format ["knowledge_of_%1", _player_ID],
						nil
					];
					if (isNil "_knowledge") then {
						[_group_ID, _x] call knowledge_fnc_deleteCircle
					} else {
						_knowledge params [
							"_leader",
							"_knows_about_level",
							"_known_by_group",
							"_known_by_leader",
							"_last_seen",
							"_last_endangered",
							"_target_side",
							"_position_error",
							"_target_position"
						];
						if (((leader _group) distance _x) < 150) then {
							_drawJobs_isNear pushBackUnique _group;
						};
						if ((_knows_about_level > 0) and {count (units _group) > 0}) then {
							[
								_group_ID, 
								_x, 
								_target_position, 
								_position_error
							] call knowledge_fnc_updateCircle;
							_drawJobs pushBack [
								_leader,
								_knows_about_level,
								_known_by_leader,
								_last_seen,
								_last_endangered,
								_target_side,
								_target_position
							];
						} else {
							[_group_ID, _x] call knowledge_fnc_deleteCircle;
						};
					};
				};
			} forEach (allPlayers - entities "HeadlessClient_F");

		} forEach (call knowledge_fnc_allAIGroups);

		if (hasInterface) then {
			knowledge_drawJobs = +_drawJobs;
			_drawJobs = [];
			knowledge_drawJobs_isNear = +_drawJobs_isNear;
			_drawJobs_isNear = [];
		};
	};

	// Cleanup after turning off
	{
		private _group_ID = _x call BIS_fnc_netId;
		{
			[_group_ID, _x] call knowledge_fnc_deleteCircle
		} forEach (allPlayers - entities "HeadlessClient_F");
	} forEach (call knowledge_fnc_allAIGroups);
	if (hasInterface) then {removeMissionEventHandler ["Draw3D", _eh_index]};

};

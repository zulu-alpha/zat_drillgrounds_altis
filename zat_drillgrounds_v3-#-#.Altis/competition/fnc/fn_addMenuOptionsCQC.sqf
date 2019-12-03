/*

    Author: Phoenix of Zulu-Alpha

    Description: Add the standard set of addaction menu options (MVP for CQC).

    Params:
        0: OBJECT - Control object 

    Returns: None

*/

if !(hasInterface) exitWith {};

params ["_control_object"];

_control_object addAction [
    "Start course",
    {
        params ["_target", "_caller", "_actionId", "_arguments"];
        [_caller] remoteExec ["competition_fnc_cqc", 2];
        [cqc_course, _caller, false] call paintball_fnc_addParticipant;
    },
    nil,
    1.5,
    true,
    true,
    "",
    "!(cqc_course getVariable ['course_isActive', false])"
];

_control_object addAction [
    "Cancel course run",
    {
        params ["_target", "_caller", "_actionId", "_arguments"];
        [_caller, true] remoteExec ["competition_fnc_cqcCleanup", 2];
        [cqc_course, _caller, false] call paintball_fnc_removeParticipant;
    },
    nil,
    1.5,
    true,
    true,
    "",
    "cqc_course getVariable ['course_isActive', false]"
];

% Parameters
int: n_students;
int: n_days;
int: n_classes;
int: n_groups;
int: n_time_units_in_hour;
int: exclusion = -1;

int: n_building;

set of int: Student = 1..n_students;
set of int: Class = 1..n_classes;
set of int: Group = 1..n_groups;
set of int: Day = 1..n_days;
set of int: Time = 0..n_time_units_in_hour * 24;
set of int: WorkTime = 0..max(Time)*n_days;
set of int: preference = exclusion..max([student_prefers[s,g] | s in Student, g in Group]);

array[Student] of 0..5: student_break_importance;
array[Student, Group] of int: student_prefers;

array[Class] of Time: class_duration;
array[Class] of int: class_size;

array[Group] of Class: group_class;
array[Group] of Time: group_start;
array[Group] of Day: group_day;
array[Group, Group] of bool: groups_conflicts;

array[Group] of int: group_building;
array[1..n_building, 1..n_building] of int: travel_time;
% array[Building, Building] of int: travel_time;

% helper function
function var int: ceil_div(var int: x, var int: y) =
  x div y + ((x mod y) > 0);

% Decision variable: Assign students to groups
array[Student, Class] of var Group: assignment;

% Constraints
constraint forall(s in Student, c in Class)(
  let { var Group: g = assignment[s, c]; } in (g in Group \/ g = exclusion)
);

% Ensure no bilocation (no student attends conflicting groups at the same time)
constraint forall(s in Student, g1 in Group, g2 in Group where g1 != g2)(
  (assignment[s, group_class[g1]] = g1 /\ assignment[s, group_class[g2]] = g2) -> 
    not groups_conflicts[g1, g2]
);

% Ensure students have enough travel time between Building
constraint forall(s in Student, g1 in Group, g2 in Group where g1 != g2)(
  let {
    var Time: start1 = group_start[g1],
    var Time: start2 = group_start[g2],
    var int: b1 = group_building[g1],
    var int: b2 = group_building[g2],
  } in
  (assignment[s, group_class[g1]] = g1 /\ assignment[s, group_class[g2]] = g2) ->
  (start2 >= start1 + class_duration[group_class[g1]] + travel_time[b1, b2])
);

% Calculate break disappointment
array[Student] of var int: break_disappointment;
constraint forall(s in Student)(
  break_disappointment[s] = 
  let {
    var Time: first_class = 
      min([group_start[g] | c in Class, g in Group where assignment[s, c] = g]);
    var Time: last_class = max([group_start[g] + class_duration[group_class[g]] | c in Class, g in Group where assignment[s, c] = g]);
    var Time: total_learning_time = sum([class_duration[group_class[g]] | c in Class, g in Group where assignment[s, c] = g]);
  } in
    max(0, (last_class - first_class) - total_learning_time) div n_time_units_in_hour
);

% Calculate Preference disappointment
array[Student] of var int: preference_disappointment;
constraint forall(s in Student)(
  preference_disappointment[s] =
   sum(c in Class)(
    let { var Group: g = assignment[s, c]; } in
    if g != exclusion then abs(student_prefers[s, g]) else 0
    )
);

% Calculate total disappointment
array[Student] of var int: total_disappointment;
constraint forall(s in Student)(
  total_disappointment[s] = ceil_div(
    student_break_importance[s] * break_disappointment[s] + 
    (10 - student_break_importance[s]) * preference_disappointment[s], 
    10
  )
);

% Objective: Minimize the sum of squared total disappointment
var int: objective = sum(s in Student)(total_disappointment[s] * total_disappointment[s]);
solve minimize objective;

% Output
output [
  % "assignment = [" ++ concat(["{" ++ concat(["show(assignment[s, c]) | c in Class]) ++ "}" | s in Student]) ++ "]\n",
  "assignment = [" ++ concat([ "{" ++ concat([show(assignment[s, c]) ++ ", " | c in Class]) ++ "}" | s in Student]) ++ "]\n",
  "total_break_disappointment = " ++ show(sum (s in Student)(break_disappointment[s])) ++ "\n",
  "total_preference_diasappintment = " ++ show(sum(s in Student)(preference_disappointment[s])) ++ "\n",
  "objective = " ++ show(objective) ++ "\n"
];